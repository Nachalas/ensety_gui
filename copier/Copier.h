//
// Created by uladzislau on 2/2/22.
//

#include <filesystem>
#include <iostream>
#include <string_view>
#include <regex>

#include "Program.h"
#include "ConfigParser.h"
#include "InputParser.h"
#include "ThreadPool.h"

#ifndef COPIER_COPIER_H
#define COPIER_COPIER_H


class Copier : public Program {
public:
    Copier();
    ~Copier() override;
    void HandleCommand(std::string_view) override;

    void Run() override;

private:
    // copying strategies
    void CopyFilesWithMask();
    void CopyFilesWithMaskAndNewExt();
    void CopyFilesWithoutMask();
    void CopyFilesWithoutMaskAndWithNewExt();

    size_t file_count_;
};


#endif //COPIER_COPIER_H
