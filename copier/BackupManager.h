//
// Created by uladzislau on 2/2/22.
//

#include <unordered_map>
#include <iostream>
#include <atomic>
#include <regex>
#include <functional>

#include "spdlog/spdlog.h"

#include "Program.h"
#include "Timer.h"
#include "util/Utils.h"

#ifndef COPIER_BACKUPMANAGER_H
#define COPIER_BACKUPMANAGER_H


class BackupManager : public Program {
public:
    BackupManager() : timeout_{0u} {};
    ~BackupManager() override;

    void InitFromConfig() override;
    void InitFromConsole() override;

    void Run() override;
    void HandleCommand(std::string_view command) override;
    void Stop();
private:
    void CopyFileAndLogTask(std::filesystem::path path, std::filesystem::copy_options options);
    void CopyFileWithNewExtAndLogTask(std::filesystem::path path, std::filesystem::copy_options options);
    void HandleRegularFile(const std::filesystem::path& entry_path, const std::filesystem::file_time_type& last_write_time);
    void HandleRegularFileWithExt(const std::filesystem::path& entry_path, const std::filesystem::file_time_type& last_write_time);

    // indexing strategies
    void IndexFilesInDestinationFolderWithMask();
    void IndexFilesInDestinationFolderWithMaskAndExt();
    void IndexFilesInDestinationFolderWithoutMask();
    void IndexFilesInDestinationFolderWithoutMaskAndWithExt();

    // checking strategies
    void CheckFilesInSourceFolderWithoutMask();
    void CheckFilesInSourceFolderWithoutMaskAndWithExt();
    void CheckFilesInSourceFolderWithMask();
    void CheckFilesInSourceFolderWithMaskAndExt();

    size_t timeout_;
    Timer timer_;
    std::mutex map_mutex_;
    std::unordered_map<std::string, std::filesystem::file_time_type> last_write_time_map_;
};


#endif //COPIER_BACKUPMANAGER_H
