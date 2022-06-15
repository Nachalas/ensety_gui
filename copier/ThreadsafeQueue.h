//
// Created by uladzislau on 2/7/22.
//

#include <mutex>
#include <queue>
#include <condition_variable>

#ifndef COPIER_THREADSAFEQUEUE_H
#define COPIER_THREADSAFEQUEUE_H

template <typename T>
class ThreadsafeQueue {
public:
    ThreadsafeQueue() = default;

    void Push(T new_value) {
        {
            std::lock_guard lock(mut_);
            data_.push(new_value);
        }
        cv_.notify_one();
    }

    void WaitThenPop(T& value) {
        std::unique_lock lock(mut_);
        cv_.wait(lock, [this](){ return !data_.empty(); });
        value = std::move(data_.front());
        data_.pop();
    }

    bool TryPop(T& value) {
        std::lock_guard lock(mut_);
        if(data_.empty()) {
            return false;
        }
        value = std::move(data_.front());
        data_.pop();
        return true;
    }

    bool Empty() const {
        std::lock_guard lock(mut_);
        return data_.empty();
    }

    size_t Size() const {
        std::lock_guard lock(mut_);
        return data_.size();
    }

private:
    mutable std::mutex mut_;
    std::queue<T> data_;
    std::condition_variable cv_;
};


#endif //COPIER_THREADSAFEQUEUE_H
