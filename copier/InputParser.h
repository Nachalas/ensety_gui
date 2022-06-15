//
// Created by uladzislau on 2/1/22.
//

#include <string>
#include <string_view>

#include <boost/program_options.hpp>

#include "spdlog/spdlog.h"

#ifndef COPIER_INPUTPARSER_H
#define COPIER_INPUTPARSER_H

class InputParser {
public:
    static const InputParser& getInstance();
    static void SetArgc(int argc);
    static void SetArgv(char** argv);
    [[nodiscard]] const boost::program_options::options_description& GetDescription() const;
    [[nodiscard]] bool OptionExists(std::string_view option) const;

    template<typename T>
    const T& GetOptionValue(const std::string_view option) const {
        return variables_map_[option.data()].as<T>();
    }

    InputParser(const InputParser&) = delete;
    InputParser(InputParser&&) = delete;
    InputParser& operator=(const InputParser&) = delete;
    InputParser& operator=(InputParser&&) = delete;
private:
    InputParser();
    void InitializeOptionsDescriptions();

    boost::program_options::options_description options_description_;
    boost::program_options::variables_map variables_map_;
    static int argc_;
    static char** argv_;
};


#endif //COPIER_INPUTPARSER_H
