cmake_minimum_required(VERSION 3.20)

project(
  cpp_template
  VERSION 0.1.0
  DESCRIPTION "Modern C++ project template"
  LANGUAGES CXX
)

include(cmake/ProjectOptions.cmake)
include(cmake/CompilerWarnings.cmake)

add_subdirectory(libs)

if(PROJECT_BUILD_APPS)
  add_subdirectory(apps)
endif()

if(PROJECT_BUILD_TESTS)
  enable_testing()
  add_subdirectory(tests)
endif()