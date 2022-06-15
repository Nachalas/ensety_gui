//
// Created by uladzislau on 2/8/22.
//

#include "SpdlogWrapper.h"

SpdlogWrapper::~SpdlogWrapper() {
    spdlog::shutdown();
}

