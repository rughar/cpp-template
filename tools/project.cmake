cmake_minimum_required(VERSION 3.20)

include("${CMAKE_CURRENT_LIST_DIR}/project/constants.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/validation.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/arguments.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/paths.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/subdirectories.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/dependencies.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/generators.cmake")
include("${CMAKE_CURRENT_LIST_DIR}/project/commands.cmake")

project_read_arguments(
  PROJECT_ACTION
  PROJECT_COMPONENT_TYPE
  PROJECT_COMPONENT_NAME
  PROJECT_DEPENDENCIES
)

project_validate_name("${PROJECT_COMPONENT_NAME}")
project_validate_names("${PROJECT_DEPENDENCIES}")

project_execute(
  "${PROJECT_ACTION}"
  "${PROJECT_COMPONENT_TYPE}"
  "${PROJECT_COMPONENT_NAME}"
  "${PROJECT_DEPENDENCIES}"
)