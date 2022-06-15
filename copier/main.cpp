#include <iostream>
#include <memory>
#include <unordered_map>

#include "spdlog/spdlog.h"
#include "spdlog/sinks/basic_file_sink.h"
#include "InputParser.h"
#include "ConfigParser.h"
#include "Copier.h"
#include "BackupManager.h"
#include "SmallProfiler.h"
#include "util/SpdlogWrapper.h"

//trace, debug, info, warn, err, critical, off
const std::unordered_map<std::string_view, spdlog::level::level_enum> STRING_TO_LEVEL_MAP = {
        {"trace", spdlog::level::trace},
        {"debug", spdlog::level::debug},
        {"info", spdlog::level::info},
        {"warn", spdlog::level::warn},
        {"err", spdlog::level::err},
        {"critical", spdlog::level::critical},
        {"off", spdlog::level::off},
};

spdlog::level::level_enum StringToLevel(std::string string) {
    if(auto it = STRING_TO_LEVEL_MAP.find(string); it != STRING_TO_LEVEL_MAP.end()) {
        return it->second;
    } else {
        return spdlog::level::trace;
    }
}

int main(int argc, char** argv) {
    SpdlogWrapper sw;
    try {
        auto logger = spdlog::basic_logger_mt("file_log", "log/log.txt", true);
        spdlog::set_default_logger(logger);
    } catch(const spdlog::spdlog_ex& exc) {
        std::cerr << "Log init failed: " << exc.what() << std::endl;
    }

    InputParser::SetArgc(argc);
    InputParser::SetArgv(argv);

    const auto& cli_options_instance = InputParser::getInstance();
    if(cli_options_instance.OptionExists("help")) {
        std::cout << cli_options_instance.GetDescription() << std::endl;
        return 0;
    }

    const auto& cfg_options_instance = ConfigParser::getInstance();
    if(cfg_options_instance.OptionExists("log_level")) {
        std::string option = cfg_options_instance.GetOptionValue<const char*>("log_level");
        std::cerr << "Trying to set the level to \'" << option << "\'" << std::endl;
        spdlog::set_level(StringToLevel(option));
    }
    if(cli_options_instance.OptionExists("log_level")) {
        std::string option = cli_options_instance.GetOptionValue<std::string>("log_level");
        std::cerr << "Trying to set the level to \'" << option << "\'" << std::endl;
        spdlog::set_level(StringToLevel(option));
    }

    LOG_DURATION("MT copy")
    std::unique_ptr<Program> ptr;
    if(cli_options_instance.OptionExists("mode")) {
        if(cli_options_instance.GetOptionValue<std::string>("mode") == "copy") {
            ptr = std::make_unique<Copier>();
        } else {
            ptr = std::make_unique<BackupManager>();
        }
    } else {
        ptr = std::make_unique<BackupManager>();
    }
    ptr->Init();
    ptr->Start();

//    std::string command;
//    while(true) {
//        std::getline(std::cin, command);
//        ptr->HandleCommand(command);
//        if(command == "exit") {
//            break;
//        }
//    }

    return 0;
}
