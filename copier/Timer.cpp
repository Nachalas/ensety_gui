//
// Created by uladzislau on 2/3/22.
//

#include "Timer.h"

Timer::Timer()
        : stop_(false)
{}

Timer::~Timer() {
    Stop();
}

void Timer::Stop() {
    std::lock_guard lock(mut_);
    stop_ = true;
    cv_.notify_all();
}
