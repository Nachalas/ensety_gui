//
// Created by uladzislau on 2/3/22.
//

#include "SmallProfiler.h"

LogDuration::LogDuration(const string &msg)
        : message(msg + ": ")
        , start(steady_clock::now())
{
}

LogDuration::~LogDuration() {
    auto finish = steady_clock::now();
    auto dur = finish - start;
    cerr << message
         << duration_cast<milliseconds>(dur).count()
         << " ms" << endl;
}
