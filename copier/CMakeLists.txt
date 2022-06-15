cmake_minimum_required(VERSION 3.21)
set(CMAKE_CXX_STANDARD 20)

project(copier)

set(vcpkg_repo "/home/uladzislau/vcpkg")
set(BOOST_ROOT "${vcpkg_repo}/installed/x64-linux")

set(CMAKE_CXX_FLAGS_RELEASE "-O3")

find_package(Boost REQUIRED program_options)
find_package(spdlog REQUIRED)
IF(UNIX)
    IF(CMAKE_BUILD_TYPE MATCHES DEBUG)
        SET(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -fsanitize=address")
        SET(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -fsanitize=memory -fsanitize-memory-track-origins=2 -fomit-frame-pointer")
    ENDIF()
    find_package(Threads REQUIRED)
ENDIF()

# message(STATUS ${Boost_INCLUDE_DIR})
include_directories(${Boost_INCLUDE_DIR})
include_directories("./") # for rapidjson

add_executable(copier main.cpp InputParser.cpp InputParser.h ConfigParser.cpp ConfigParser.h Copier.cpp Copier.h ThreadPool.cpp ThreadPool.h Program.cpp Program.h BackupManager.cpp BackupManager.h Timer.cpp Timer.h SmallProfiler.cpp SmallProfiler.h util/Utils.cpp util/Utils.h ThreadsafeQueue.h util/SpdlogWrapper.cpp util/SpdlogWrapper.h)
TARGET_LINK_LIBRARIES(copier PRIVATE ${Boost_LIBRARIES})
TARGET_LINK_LIBRARIES (copier PRIVATE ${CMAKE_THREAD_LIBS_INIT})
TARGET_LINK_LIBRARIES (copier PRIVATE spdlog::spdlog)