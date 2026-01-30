cmake_minimum_required(VERSION 3.10)

# Define project name
project(RegPressureApp)

# Specify the C++ standard
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add the executable
add_executable(regpressure regpressure.cpp)
