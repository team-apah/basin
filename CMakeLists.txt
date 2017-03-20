cmake_minimum_required(VERSION 3.4)

project(BASIN_D8)
#include(ExternalProject)
#set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules" ${CMAKE_MODULE_PATH})

# Use C++11
set(CMAKE_CXX_STANDARD 11)

# Main Program
set(EXECUTABLE_NAME "cahokia")
include_directories("include")
#include_directories(${PROJECT_BINARY_DIR}/include)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
add_executable(${EXECUTABLE_NAME}
    src/main.cpp
    src/dem_fill.cpp
    src/d8.cpp
    src/flow.cpp
    src/dem_misc.cpp
)
install(TARGETS ${EXECUTABLE_NAME} RUNTIME DESTINATION bin)

# Dependencies
find_package(GDAL REQUIRED)
include_directories(${GDAL_INCLUDE_DIR})
target_link_libraries(${EXECUTABLE_NAME} ${GDAL_LIBRARY})
