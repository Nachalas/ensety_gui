//
// Created by uladzislau on 2/2/22.
//

#ifndef COPIER_PROGRAM_H
#define COPIER_PROGRAM_H


#include <filesystem>

#include "spdlog/spdlog.h"

#include "ThreadPool.h"
#include "ConfigParser.h"
#include "InputParser.h"
#include "util/Utils.h"

class Program {
public:
    Program();
    virtual ~Program() = default;
    void Init();
    void Start();
    virtual void Run() = 0;
    virtual void HandleCommand(std::string_view) = 0;

    virtual void InitFromConsole();
    virtual void InitFromConfig();
protected:
    // это вообще можно в utils какой, наверное
    template <typename T, typename U>
    void GetOptionFromConfig(const ConfigParser& config, U& value, std::string_view option) {
        if(config.OptionExists(option)) {
            value = config.GetOptionValue<T>(option);
        }
    }

    template <typename T, typename U>
    void GetOptionFromConsole(const InputParser& input, U& value, std::string_view option) {
        if(input.OptionExists(option)) {
            value = input.GetOptionValue<T>(option);
        }
    }

    void Join();
    void CopyFileTask(std::filesystem::path path, std::filesystem::copy_options options);
    void CopyFileWithNewExtTask(std::filesystem::path path, std::filesystem::copy_options options);

    std::filesystem::path from_path_;
    std::filesystem::path to_path_;
    size_t thread_count_;
    ThreadPool tp_;
    std::string mask_;
    std::thread thread_;
    std::string additional_ext_;
};


#endif //COPIER_PROGRAM_H
