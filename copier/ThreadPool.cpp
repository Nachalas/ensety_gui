//
// Created by uladzislau on 2/2/22.
//

#include "ThreadPool.h"

ThreadPool::ThreadPool(size_t thread_count) :
        done_(false),
        busy_threads_{0u}
{
    CreateThreads(thread_count);
}

ThreadPool::~ThreadPool() {
    SetDone();
    JoinThreads();
}

void ThreadPool::WorkerThread() {
    while(!done_) {
        std::function<void()> task;
        if(tasks_.TryPop(task)) {
            std::unique_lock lock(stats_mutex_);
            ++busy_threads_;
            stats_mutex_.unlock();

            task();

            stats_mutex_.lock();
            --busy_threads_;
            cv_finished_.notify_one();
        } else {
            std::this_thread::yield();
        }
    }
}

void ThreadPool::WaitUntilAllTasksFinish() {
    std::unique_lock<std::mutex> lock(stats_mutex_);
    cv_finished_.wait(lock, [this](){return (busy_threads_ == 0u) && tasks_.Empty();});
}

size_t ThreadPool::GetBusyThreadsCount() const {
    std::lock_guard lock(stats_mutex_);
    return busy_threads_;
}

void ThreadPool::Reset(size_t thread_count) {
    spdlog::info("Changing the amount of thread in a thread pool");
    SetDone();
    JoinThreads();
    done_ = false;
    CreateThreads(thread_count ? thread_count : std::thread::hardware_concurrency());
}

void ThreadPool::JoinThreads() {
    for(auto& worker : workers_) {
        worker.join();
    }
}

void ThreadPool::CreateThreads(size_t thread_count) {
    workers_.resize(thread_count);
    spdlog::info("Thread count now is: {}", workers_.size());
    try {
        for(auto& worker : workers_) {
            worker = std::thread(&ThreadPool::WorkerThread, this);
        }
    } catch (...) {
        done_ = true;
        throw;
    }
}

void ThreadPool::SetDone() {
    done_ = true;
}

size_t ThreadPool::GetPendingTasks() const {
    return tasks_.Size();
}

void ThreadPool::Stop() {
    SetDone();
}


