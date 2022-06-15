//
// Created by uladzislau on 2/2/22.
//

#include "Copier.h"

void Copier::Run() {
    namespace fs = std::filesystem;

    if(from_path_.empty() || !fs::exists(from_path_) || !fs::is_directory(from_path_)
        || to_path_.empty() || !fs::exists(to_path_) || !fs::is_directory(to_path_)
    ) {
        spdlog::warn("The chosen directory does not exist.");
        return;
    }

    file_count_ = std::count_if(
            fs::recursive_directory_iterator(from_path_),
            fs::recursive_directory_iterator{},
            [](const std::filesystem::path& path){return is_regular_file(path);}
            );

    std::function<void()> CopyStrategy;
    if(mask_.empty() && additional_ext_.empty()) {
        spdlog::info("Copying files with no mask or additional extension");
        CopyStrategy = [this](){ CopyFilesWithoutMask(); };
    } else if (!mask_.empty() && !additional_ext_.empty()) {
        spdlog::info("Copying files with a mask and an additional extension");
        CopyStrategy = [this](){ CopyFilesWithMaskAndNewExt(); };
    } else if(!mask_.empty()) {
        spdlog::info("Copying files with a mask");
        CopyStrategy = [this](){ CopyFilesWithMask(); };
    } else {
        spdlog::info("Copying files with an additional extension");
        CopyStrategy = [this](){ CopyFilesWithoutMaskAndWithNewExt(); };
    }

    CopyStrategy();
    tp_.WaitUntilAllTasksFinish();

    std::cerr << "Finished copying all files." << std::endl;
    spdlog::info("Finished copying all files.");
}
void Copier::HandleCommand(std::string_view command) {
    if(command == "stats") {
        std::cout << "There are " <<
        file_count_ << " files in total, " <<
        tp_.GetPendingTasks() << " tasks pending, " <<
        tp_.GetBusyThreadsCount() << " threads running." << std::endl;
    } else if (command == "stop") {
        tp_.Stop();
    }
}

Copier::Copier() : file_count_{0u} {}

void Copier::CopyFilesWithMask() {
    namespace fs = std::filesystem;

    fs::recursive_directory_iterator iter(from_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            tp_.SubmitTask([this, the_path = iter->path()]() { CopyFileTask(the_path, fs::copy_options::overwrite_existing); });
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void Copier::CopyFilesWithMaskAndNewExt() {
    namespace fs = std::filesystem;

    fs::recursive_directory_iterator iter(from_path_);
    std::error_code ec;
    std::regex regex(mask_);
    while(iter != fs::recursive_directory_iterator{}) {
        bool regex_matched = std::regex_match(iter->path().filename().string(), regex);
        if(iter->is_directory() && regex_matched) {
            iter.disable_recursion_pending();
        } else if(iter->is_regular_file() && !regex_matched) {
            tp_.SubmitTask([this, the_path = iter->path()]() { CopyFileWithNewExtTask(the_path, fs::copy_options::overwrite_existing); });
        }
        iter.increment(ec);
        if(ec) {
            spdlog::critical("Error while iterating over {}: {}", iter->path().string(), ec.message());
        }
    }
}

void Copier::CopyFilesWithoutMask() {
    namespace fs = std::filesystem;

    for (const auto &dirEntry: fs::recursive_directory_iterator(from_path_)) {
        if (dirEntry.is_regular_file()) {
            tp_.SubmitTask([this, dirEntry]() { CopyFileTask(dirEntry, fs::copy_options::overwrite_existing); });
        }
    }
}

void Copier::CopyFilesWithoutMaskAndWithNewExt() {
    namespace fs = std::filesystem;

    for (const auto &dirEntry: fs::recursive_directory_iterator(from_path_)) {
        if (dirEntry.is_regular_file()) {
            tp_.SubmitTask([this, dirEntry]() { CopyFileWithNewExtTask(dirEntry, fs::copy_options::overwrite_existing); });
        }
    }
}

Copier::~Copier() {
    Join();
}


