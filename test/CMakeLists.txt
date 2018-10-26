cmake_minimum_required(VERSION 3.9)
project(common-cmake-test)

include(${CMAKE_CURRENT_LIST_DIR}/../cmake/macros.cmake)

add_library(Test1 INTERFACE)

PrintTargetType(Test1)