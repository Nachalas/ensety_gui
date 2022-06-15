//
// Created by uladzislau on 2/2/22.
//

#include <iostream>
#include "Program.h"

Program::Program() :
        from_path_(""),
        to_path_(""),
        thread_count_{0u},
        tp_(thread_count_),
        mask_("")
{
}

void Program::Init() {
    InitFromConfig();
    InitFromConsole();
    tp_.Reset(thread_count_ ? thread_count_ : std::thread::hardware_concurrency());
}

void Program::Start() {
    thread_ = std::thread(&Program::Run, this);
}

void Program::InitFromConsole() {
    const InputParser& input_parser_instance = InputParser::getInstance();
    GetOptionFromConsole<std::string>(input_parser_instance, from_path_, "source_folder");
    GetOptionFromConsole<std::string>(input_parser_instance, to_path_, "destination_folder");
    GetOptionFromConsole<int>(input_parser_instance, thread_count_, "thread_count");
    GetOptionFromConsole<std::string>(input_parser_instance, mask_, "file_mask");
    GetOptionFromConsole<std::string>(input_parser_instance, additional_ext_, "additional_ext");
}

void Program::InitFromConfig() {
    const ConfigParser& config_parser_instance = ConfigParser::getInstance();
    if(config_parser_instance.IsInitialized()) {
        GetOptionFromConfig<const char*>(config_parser_instance, from_path_, "source_folder");
        GetOptionFromConfig<const char*>(config_parser_instance, to_path_, "destination_folder");
        GetOptionFromConfig<size_t>(config_parser_instance, thread_count_, "thread_count");
        GetOptionFromConfig<const char*>(config_parser_instance, mask_, "file_mask");
        GetOptionFromConfig<const char*>(config_parser_instance, additional_ext_, "additional_ext");
    }
}

void Program::CopyFileTask(std::filesystem::path path, std::filesystem::copy_options options) {
    namespace fs = std::filesystem;
    const auto relative_path = fs::relative(path, from_path_);
    const auto target_folder_path = to_path_ / relative_path.parent_path();
    spdlog::debug("Copying {}", relative_path.string());
    try {
        fs::create_directories(target_folder_path);
        fs::copy(path, to_path_ / relative_path, options);
    } catch(const std::exception& exc) {
        spdlog::critical(exc.what());
    }
}

void Program::CopyFileWithNewExtTask(std::filesystem::path path, std::filesystem::copy_options options) {
    namespace fs = std::filesystem;
    const auto relative_path = fs::relative(path, from_path_);
    const auto target_folder_path = to_path_ / relative_path.parent_path();
    spdlog::debug("Copying {} with additional ext: {}", relative_path.string(), additional_ext_);
    try {
        fs::create_directories(target_folder_path);
        fs::copy(path, AppendExtension(to_path_ / relative_path, additional_ext_), options);
    } catch(const std::exception& exc) {
        spdlog::critical(exc.what());
    }
}

void Program::Join() {
    thread_.join();
}
