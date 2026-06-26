cmake_minimum_required(VERSION 3.20)

project(
  cpp_template
  VERSION 0.1.0
  DESCRIPTION "Modern C++ project template"
  LANGUAGES CXX
)

add_subdirectory(libs)
add_subdirectory(apps)

enable_testing()
add_subdirectory(tests)