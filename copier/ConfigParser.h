//
// Created by uladzislau on 2/1/22.
//

#include <filesystem>
#include <fstream>
#include <iostream>

#include "3rdparty/rapidjson/document.h"
#include "3rdparty/rapidjson/istreamwrapper.h"

#include "spdlog/spdlog.h"

#ifndef COPIER_CONFIGPARSER_H
#define COPIER_CONFIGPARSER_H


class ConfigParser {
public:
    [[nodiscard]] bool IsInitialized() const;
    [[nodiscard]] bool OptionExists(std::string_view option) const;
    static const ConfigParser& getInstance();

    template<typename T>
    T GetOptionValue(const std::string_view option) const {
        return document_[option.data()].Get<T>();
    }

    ConfigParser(const ConfigParser&) = delete;
    ConfigParser(ConfigParser&&) = delete;
    ConfigParser& operator=(const ConfigParser&) = delete;
    ConfigParser& operator=(ConfigParser&&) = delete;
private:
    ConfigParser();

    bool initialized_;
    rapidjson::Document document_;
};


#endif //COPIER_CONFIGPARSER_H
