//
// Created by uladzislau on 2/1/22.
//

#include "ConfigParser.h"

bool ConfigParser::IsInitialized() const {
    return initialized_;
}

bool ConfigParser::OptionExists(const std::string_view option) const {
    return document_.HasMember(option.data());
}

const ConfigParser &ConfigParser::getInstance() {
    static ConfigParser instance;
    return instance;
}

ConfigParser::ConfigParser() {
    spdlog::info("ConfigParser is being initialized");
    if(std::filesystem::exists("../config.json")) {
        namespace rjs = rapidjson;

        std::ifstream ifs("../config.json");
        rjs::IStreamWrapper isw(ifs);

        document_.ParseStream(isw);
        assert(document_.IsObject());
        initialized_ = true;
    } else {
        spdlog::warn("No configuration file found");
        initialized_ = false;
    }
}
