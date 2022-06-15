//
// Created by uladzislau on 2/3/22.
//

#include <mutex>
#include <condition_variable>
#include <atomic>

#ifndef COPIER_TIMER_H
#define COPIER_TIMER_H


class Timer {
public:
    Timer();
    ~Timer();

    void Stop();

    template <typename R, typename P>
    bool WaitFor(const std::chrono::duration<R, P>& time) {
        std::unique_lock lock(mut_);
        return !cv_.wait_for(lock, time, [this](){return stop_;});
    }

    Timer(const Timer&) = delete;
    Timer(Timer&&) = delete;
    Timer& operator=(const Timer&) = delete;
    Timer& operator=(Timer&&) = delete;
private:
    std::mutex mut_;
    std::condition_variable cv_;
    bool stop_;
};


#endif //COPIER_TIMER_H
