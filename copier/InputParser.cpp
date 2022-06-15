//
// Created by uladzislau on 2/1/22.
//

#include "InputParser.h"

int InputParser::argc_ = 0;
char** InputParser::argv_ = nullptr;

const InputParser &InputParser::getInstance() {
    static InputParser instance;
    return instance;
}

void InputParser::SetArgc(int argc) {
    argc_ = argc;
}

void InputParser::SetArgv(char **argv) {
    argv_ = argv;
}

const boost::program_options::options_description &InputParser::GetDescription() const {
    return options_description_;
}

bool InputParser::OptionExists(const std::string_view option) const {
    return variables_map_.count(option.data());
}

InputParser::InputParser() {
    spdlog::info("InputParser is being initialized");
    namespace po = boost::program_options;
    InitializeOptionsDescriptions();
    po::store(po::parse_command_line(argc_, argv_, options_description_), variables_map_);
    po::notify(variables_map_);
}

void InputParser::InitializeOptionsDescriptions() {
    namespace po = boost::program_options;
    options_description_.add_options()
            ("help", "Show the help message")
            ("thread_count", po::value<int>(), "Copy-threads count")
            ("destination_folder", po::value<std::string>(), "Destination folder location")
            ("source_folder", po::value<std::string>(), "Source folder location")
            ("file_mask", po::value<std::string>(),"Mask showing what files not to copy")
            ("additional_ext", po::value<std::string>(), "Additional file extension")
            ("log_level", po::value<std::string>(), "Log level for app")
            ("scan_timeout", po::value<int>(), "Scan timeout (seconds)")
            ("mode", po::value<std::string>(), "Program running mode: 'copy' for copying, 'backup' for continuous backup of files")
            ;
}
