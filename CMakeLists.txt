cmake_minimum_required(VERSION 3.0.0)
project(lunar-dreamland VERSION 0.1.0)

include(ExternalProject)

set(luajit_CC "gcc -m32")
ExternalProject_Add(luajit
    URL http://luajit.org/download/LuaJIT-2.1.0-beta3.tar.gz
    PREFIX ${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1.0-beta3
    CONFIGURE_COMMAND ""
    BUILD_COMMAND make CC=${luajit_CC}
    INSTALL_COMMAND make install PREFIX=${CMAKE_CURRENT_BINARY_DIR}/luajit-2.1.0-beta3
    BUILD_IN_SOURCE 1
)
ExternalProject_Get_Property(luajit install_dir)


add_library(hookerino SHARED hookerino/main.cpp hookerino/sigscan.cpp)
set_target_properties(hookerino PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")
add_dependencies(hookerino luajit)
target_include_directories(hookerino PUBLIC ${install_dir}/include/luajit-2.1)
target_link_directories(hookerino PUBLIC ${install_dir}/lib)
target_link_libraries(hookerino luajit-5.1)

add_library(byondffi SHARED byondffi/dllmain.cpp byondffi/sigscan.cpp)
set_target_properties(byondffi PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")

add_library(maptick SHARED maptick/dllmain.cpp maptick/sigscan.cpp)
set_target_properties(maptick PROPERTIES COMPILE_FLAGS "-m32" LINK_FLAGS "-m32")