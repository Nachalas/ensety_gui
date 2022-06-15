//
// Created by uladzislau on 2/2/22.
//

#include "BackupManager.h"

void BackupManager::Stop() {
    timer_.Stop();
    tp_.Stop();
}

void BackupManager::InitFromConfig() {
    Program::InitFromConfig();
    const ConfigParser& config_parser_instance = ConfigParser::getInstance();
    if(config_parser_instance.IsInitialized()) {
        GetOptionFromConfig<size_t>(config_parser_instance, timeout_, "scan_timeout");
    }
}

void BackupManager::InitFromConsole() {
    Program::InitFromConsole();
    const InputParser& input_parser_instance = InputParser::getInstance();
    GetOptionFromConsole<int>(input_parser_instance, timeout_, "scan_timeout");
}

void BackupManager::CopyFileAndLogTask(std::filesystem::path path, std::filesystem::copy_options options) {
    namespace fs = std::filesystem;
    auto relative_path = fs::relative(path, from_path_);
    auto new_file_path = to_path_ / relative_path;
    spdlog::debug("Copying {} and changing the last time write entry", relative_path.string());
    try {
        fs::copy(path, new_file_path, options);
        std::lock_guard lock(map_mutex_);
        last_write_time_map_[relative_path.string()] = fs::last_write_time(new_file_path);
    } catch(const std::exception& exc) {
        spdlog::critical(exc.what());
    }
}

void BackupManager::CopyFileWithNewExtAndLogTask(std::filesystem::path path, std::filesystem::copy_options options) {
    namespace fs = std::filesystem;
    auto relative_path = fs::relative(path, from_path_);
    auto new_file_path = AppendExtension(to_path_ / relative_path, additional_ext_);
    spdlog::debug("Copying {} with additional ext: {} and changing the last time write entry", relative_path.string(), additional_ext_);
    try {
        fs::copy(path, new_file_path, options);
        std::lock_guard lock(map_mutex_);
        last_write_time_map_[relative_path.string()] = fs::last_write_time(new_file_path);
    } catch(const std::exception& exc) {
        spdlog::critical(exc.what());
    }
}

void BackupManager::Run() {
    namespace fs = std::filesystem;
    using namespace std::literals::chrono_literals;

    if(from_path_.empty() || !fs::exists(from_path_) || !fs::is_directory(from_path_)
       || to_path_.empty() || !fs::exists(to_path_) || !fs::is_directory(to_path_)
            ) {
        spdlog::warn("The chosen directory does not exist.");
        return;
    }

    std::function<void()> IndexingFilesStrategy;
    std::function<void()> CheckingFilesStrategy;

    if(mask_.empty() && additional_ext_.empty()) {
        IndexingFilesStrategy = [this]() { IndexFilesInDestinationFolderWithoutMask();};
        CheckingFilesStrategy = [this](){ CheckFilesInSourceFolderWithoutMask(); };
    } else if (!mask_.empty() && !additional_ext_.empty()) {
        IndexingFilesStrategy = [this]() { IndexFilesInDestinationFolderWithMaskAndExt();};
        CheckingFilesStrategy = [this](){  CheckFilesInSourceFolderWithMaskAndExt(); };
    } else if(!mask_.empty()) {
        IndexingFilesStrategy = [this]() { IndexFilesInDestinationFolderWithMask(); };
        CheckingFilesStrategy = [this](){ CheckFilesInSourceFolderWithMask(); };
    } else {
        IndexingFilesStrategy = [this]() { IndexFilesInDestinationFolderWithoutMaskAndWithExt(); };
        CheckingFilesStrategy = [this](){ CheckFilesInSourceFolderWithoutMaskAndWithExt(); };
    }

    IndexingFilesStrategy();

    do {
        CheckingFilesStrategy();
        tp_.WaitUntilAllTasksFinish();
    } while (timer_.WaitFor(std::chrono::duration<size_t>(timeout_)));
}

void BackupManager::HandleCommand(std::string_view command) {
    if(command == "stop") {
        Stop();
    }
}

void BackupManager::CheckFilesInSourceFolderWithoutMask() {
    namespace fs = std::filesystem;

    spdlog::info("Checking the files");
    for (const auto &dirEntry: fs::recursive_directory_iterator(from_path_)) {
        if (dirEntry.is_regular_file()) {
            HandleRegularFile(dirEntry.path(), dirEntry.last_write_time());
        }
    }
}

void BackupManager::CheckFilesInSourceFolderWithoutMaskAndWithExt() {
    namespace fs = std::filesystem;

    spdlog::info("Checking the files");
    for (const auto &dirEntry: fs::recursive_directory_iterator(from_path_)) {
        if (dirEntry.is_regular_file()) {
            HandleRegularFileWithExt(dirEntry.path(), dirEntry.last_write_time());
        }
    }
}

void BackupManager::CheckFilesInSourceFolderWithMask() {
    namespace fs = std::filesystem;

    spdlog::info("Checking the files");
    fs::recursive_directory_iterator iter(from_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            HandleRegularFile(iter->path(), iter->last_write_time());
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void BackupManager::CheckFilesInSourceFolderWithMaskAndExt() {
    namespace fs = std::filesystem;

    spdlog::info("Checking the files");
    fs::recursive_directory_iterator iter(from_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            HandleRegularFileWithExt(iter->path(), iter->last_write_time());
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void BackupManager::HandleRegularFile(const std::filesystem::path& entry_path, const std::filesystem::file_time_type& last_write_time) {
    namespace fs = std::filesystem;

    fs::path from_relative_path = fs::relative(entry_path, from_path_);
    if(fs::exists(to_path_ / from_relative_path)) {
//        if(!last_write_time_map_.count(from_relative_path)) {
//            std::cerr << "No entry found in the map!" << std::endl;
//        }
        if(last_write_time > last_write_time_map_[from_relative_path]) {
            tp_.SubmitTask([this, entry_path]() { CopyFileAndLogTask(entry_path, fs::copy_options::overwrite_existing); });
        }
    } else {
        try {
            fs::create_directories((to_path_ / from_relative_path).parent_path());
        } catch (const std::exception& exc) {
            spdlog::critical(exc.what());
        }
        tp_.SubmitTask([this, entry_path]() { CopyFileAndLogTask(entry_path, fs::copy_options{}); });
    }
}

void BackupManager::HandleRegularFileWithExt(const std::filesystem::path &entry_path,
                                             const std::filesystem::file_time_type &last_write_time) {
    namespace fs = std::filesystem;

    fs::path from_relative_path = fs::relative(entry_path, from_path_);
    if(fs::exists(AppendExtension(to_path_ / from_relative_path, additional_ext_))) {
//        if(!last_write_time_map_.count(from_relative_path)) {
//            std::cerr << "No entry found in the map!" << std::endl;
//        }
        if(last_write_time > last_write_time_map_[from_relative_path]) {
            tp_.SubmitTask([this, entry_path]() { CopyFileWithNewExtAndLogTask(entry_path, fs::copy_options::overwrite_existing); });
        }
    } else {
        try {
            fs::create_directories((to_path_ / from_relative_path).parent_path());
        } catch (const std::exception& exc) {
            spdlog::critical(exc.what());
        }
        tp_.SubmitTask([this, entry_path]() { CopyFileWithNewExtAndLogTask(entry_path, fs::copy_options{}); });
    }
}

void BackupManager::IndexFilesInDestinationFolderWithMask() {
    namespace fs = std::filesystem;

    fs::recursive_directory_iterator iter(to_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            last_write_time_map_[fs::relative(iter->path(), to_path_).string()] = iter->last_write_time();
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void BackupManager::IndexFilesInDestinationFolderWithoutMask() {
    namespace fs = std::filesystem;
    for (const auto &dirEntry: fs::recursive_directory_iterator(to_path_)) {
        if (dirEntry.is_regular_file()) {
            last_write_time_map_[fs::relative(dirEntry, to_path_).string()] = dirEntry.last_write_time();
        }
    }
}

void BackupManager::IndexFilesInDestinationFolderWithMaskAndExt() {
    namespace fs = std::filesystem;

    fs::recursive_directory_iterator iter(to_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            auto relative_path = fs::relative(iter->path(), to_path_);
            auto path_without_ext = relative_path.parent_path() / RemoveExtension(relative_path.filename());
            last_write_time_map_[path_without_ext] = iter->last_write_time();
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void BackupManager::IndexFilesInDestinationFolderWithoutMaskAndWithExt() {
    namespace fs = std::filesystem;
    for (const auto &dirEntry: fs::recursive_directory_iterator(to_path_)) {
        if (dirEntry.is_regular_file()) {
            // TODO: search for methods to remove extension from path, not filename
            auto relative_path = fs::relative(dirEntry, to_path_);
            auto path_without_ext = relative_path.parent_path() / RemoveExtension(relative_path.filename());
            last_write_time_map_[path_without_ext] = dirEntry.last_write_time();
        }
    }
}

BackupManager::~BackupManager() {
    Join();
}
