//
// Created by uladzislau on 2/4/22.
//

#include "Utils.h"

// TODO: possibly change path to string_view
std::filesystem::path
AppendExtension(const std::filesystem::path &path, const std::filesystem::path &extension) {
    auto cstr_ext = extension.c_str();
    if(*cstr_ext == '.') ++cstr_ext;
    return path.string() + "." + cstr_ext;
}

std::string RemoveExtension(const std::filesystem::path& path) {
    size_t last_dot_position = path.string().find_last_of('.');
    return last_dot_position == std::string::npos ? path.string() : path.string().substr(0, last_dot_position);
}

