//
// Created by uladzislau on 2/4/22.
//

#include <filesystem>
#include <string>

#ifndef COPIER_UTILS_H
#define COPIER_UTILS_H

std::filesystem::path AppendExtension(const std::filesystem::path& path, const std::filesystem::path& extension);
std::string RemoveExtension(const std::filesystem::path& path);

#endif //COPIER_UTILS_H
