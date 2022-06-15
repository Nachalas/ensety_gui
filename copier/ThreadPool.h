//
// Created by uladzislau on 2/2/22.
//

#include <atomic>
#include <vector>
#include <thread>
#include <functional>
#include <queue>
#include <mutex>
#include <condition_variable>
#include <filesystem>
#include <iostream>

#include "spdlog/spdlog.h"

#include "ThreadsafeQueue.h"

#ifndef COPIER_THREADPOOL_H
#define COPIER_THREADPOOL_H


class ThreadPool {
public:
    explicit ThreadPool(size_t thread_count);
    void Reset(size_t thread_count);
    void Stop();
    ~ThreadPool();
    void WaitUntilAllTasksFinish();
    size_t GetBusyThreadsCount() const;
    size_t GetPendingTasks() const;

    template<typename FunctionType>
    void SubmitTask(FunctionType f) {
        std::unique_lock<std::mutex> lock(stats_mutex_);
        tasks_.Push(std::function<void()>(f));
        cv_new_tasks_.notify_one();
    }

private:
    void WorkerThread();
    void CreateThreads(size_t thread_count);
    void SetDone();
    void JoinThreads();

    std::vector<std::thread> workers_;
    ThreadsafeQueue<std::function<void()>> tasks_;
    mutable std::mutex stats_mutex_;
    std::condition_variable cv_new_tasks_;
    std::condition_variable cv_finished_;
    std::atomic<bool> done_;
    size_t busy_threads_;
};


#endif //COPIER_THREADPOOL_H
