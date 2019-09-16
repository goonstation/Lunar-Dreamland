list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")

cmake_minimum_required(VERSION 3.0.0)
project(lunar-dreamland VERSION 0.1.0)

include(ExternalProject)

set(SUBHOOK_INSTALL_LOCATION "${CMAKE_CURRENT_LIST_DIR}/subhook")

ExternalProject_Add(subhook
    GIT_REPOSITORY https://github.com/Zeex/subhook
    CMAKE_ARGS -DSUBHOOK_TESTS=false -DCMAKE_INSTALL_PREFIX=${SUBHOOK_INSTALL_LOCATION}
)


include_directories(${SUBHOOK_INSTALL_LOCATION}/include)
link_directories(${SUBHOOK_INSTALL_LOCATION}/lib)

find_package(LuaJIT REQUIRED)
include_directories(${LUA_INCLUDE_DIR})

add_library(lunar-dreamland SHARED cpp/main.cpp)
add_dependencies(lunar-dreamland subhook)
target_link_libraries(lunar-dreamland ${LUA_LIBRARIES})