function(get_action output_variable)
  if(CMAKE_ARGC LESS 4)
    message(FATAL_ERROR "Missing action. Use: cmake -P tools/project.cmake create lib my_library")
  endif()

  set(${output_variable} "${CMAKE_ARGV3}" PARENT_SCOPE)
endfunction()

function(get_component_type output_variable)
  if(CMAKE_ARGC LESS 5)
    message(FATAL_ERROR "Missing component type. Use: cmake -P tools/project.cmake create lib my_library")
  endif()

  set(${output_variable} "${CMAKE_ARGV4}" PARENT_SCOPE)
endfunction()

function(get_component_name output_variable)
  if(CMAKE_ARGC LESS 6)
    message(FATAL_ERROR "Missing component name. Use: cmake -P tools/project.cmake create lib my_library")
  endif()

  set(${output_variable} "${CMAKE_ARGV5}" PARENT_SCOPE)
endfunction()

function(get_dependencies output_variable)
  set(dependencies "")

  if(CMAKE_ARGC GREATER 6)
    math(EXPR last_argument_index "${CMAKE_ARGC} - 1")

    foreach(argument_index RANGE 6 ${last_argument_index})
      list(APPEND dependencies "${CMAKE_ARGV${argument_index}}")
    endforeach()
  endif()

  set(${output_variable} "${dependencies}" PARENT_SCOPE)
endfunction()

function(require_no_dependencies dependencies)
  if(NOT "${dependencies}" STREQUAL "")
    message(FATAL_ERROR "The 'remove' action does not accept dependencies.")
  endif()
endfunction()

function(validate_name name)
  if(NOT name MATCHES "^[A-Za-z_][A-Za-z0-9_]*$")
    message(FATAL_ERROR "Invalid name: ${name}. Use a valid C++ namespace-like name, for example my_library.")
  endif()
endfunction()

function(validate_names names)
  foreach(name ${names})
    validate_name("${name}")
  endforeach()
endfunction()

function(require_directory_exists directory_path)
  if(NOT EXISTS "${directory_path}")
    message(FATAL_ERROR "Directory does not exist: ${directory_path}")
  endif()
endfunction()

function(require_directory_does_not_exist directory_path)
  if(EXISTS "${directory_path}")
    message(FATAL_ERROR "Directory already exists: ${directory_path}")
  endif()
endfunction()

function(require_lib_exists lib_name)
  if(NOT EXISTS "libs/${lib_name}")
    message(FATAL_ERROR "Library does not exist: ${lib_name}")
  endif()
endfunction()

function(require_libs_exist lib_names)
  foreach(lib_name ${lib_names})
    require_lib_exists("${lib_name}")
  endforeach()
endfunction()

function(append_subdirectory file_path directory_name)
  file(READ "${file_path}" file_content)

  if(file_content MATCHES "add_subdirectory\\(${directory_name}\\)")
    return()
  endif()

  if(NOT file_content STREQUAL "" AND NOT file_content MATCHES "\n$")
    file(APPEND "${file_path}" "\n")
  endif()

  file(APPEND "${file_path}" "add_subdirectory(${directory_name})\n")
endfunction()

function(remove_subdirectory file_path directory_name)
  file(READ "${file_path}" file_content)

  string(REPLACE "add_subdirectory(${directory_name})\n" "" file_content "${file_content}")
  string(REPLACE "add_subdirectory(${directory_name})" "" file_content "${file_content}")

  file(WRITE "${file_path}" "${file_content}")
endfunction()

function(format_dependency_lines output_variable dependencies)
  set(lines "")

  foreach(dependency ${dependencies})
    string(APPEND lines "    ${dependency}\n")
  endforeach()

  set(${output_variable} "${lines}" PARENT_SCOPE)
endfunction()

function(format_library_dependencies output_variable dependencies)
  format_dependency_lines(dependency_lines "${dependencies}")

  if(dependency_lines STREQUAL "")
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  set(block
"target_link_libraries(\${LIBRARY_NAME}
  PUBLIC
${dependency_lines})
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(format_app_dependencies output_variable dependencies)
  format_dependency_lines(dependency_lines "${dependencies}")

  if(dependency_lines STREQUAL "")
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  set(block
"target_link_libraries(\${APP_NAME}
  PRIVATE
${dependency_lines})
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(format_test_dependencies output_variable lib_name dependencies)
  set(all_dependencies "${lib_name};${dependencies}")
  format_dependency_lines(dependency_lines "${all_dependencies}")

  set(block
"target_link_libraries(\${TEST_NAME}_tests
  PRIVATE
    unit_test
${dependency_lines})
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(create_lib lib_name dependencies)
  set(lib_dir "libs/${lib_name}")
  set(test_dir "tests/${lib_name}")

  require_directory_does_not_exist("${lib_dir}")
  require_directory_does_not_exist("${test_dir}")

  file(MAKE_DIRECTORY "${lib_dir}")
  file(MAKE_DIRECTORY "${test_dir}")

  format_library_dependencies(library_dependencies "${dependencies}")
  format_test_dependencies(test_dependencies "${lib_name}" "${dependencies}")

  file(WRITE "${lib_dir}/CMakeLists.txt"
"file(GLOB LIBRARY_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(LIBRARY_NAME
  \${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_library(\${LIBRARY_NAME}
  \${LIBRARY_SOURCES}
)

target_include_directories(\${LIBRARY_NAME}
  PUBLIC
    \${CMAKE_CURRENT_SOURCE_DIR}
)

${library_dependencies}project_set_warnings(\${LIBRARY_NAME})
"
  )

  file(WRITE "${lib_dir}/${lib_name}.hpp"
"#pragma once

namespace ${lib_name}
{

}
"
  )

  file(WRITE "${lib_dir}/${lib_name}.cpp"
"#include \"${lib_name}.hpp\"

namespace ${lib_name}
{

}
"
  )

  file(WRITE "${test_dir}/CMakeLists.txt"
"file(GLOB TEST_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(TEST_NAME
  \${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_executable(\${TEST_NAME}_tests
  \${TEST_SOURCES}
)

${test_dependencies}project_set_warnings(\${TEST_NAME}_tests)

add_test(
  NAME \${TEST_NAME}_tests
  COMMAND \${TEST_NAME}_tests
)

set_tests_properties(\${TEST_NAME}_tests
  PROPERTIES
    DEPENDS unit_test_tests
)
"
  )

  file(WRITE "${test_dir}/${lib_name}Tests.cpp"
"#include \"${lib_name}.hpp\"
#include \"UnitTest.hpp\"

int main()
{
  unit_test::Runner runner;

  runner.printSummary();

  return runner.getExitCode();
}
"
  )

  append_subdirectory("libs/CMakeLists.txt" "${lib_name}")
  append_subdirectory("tests/CMakeLists.txt" "${lib_name}")
endfunction()

function(create_app app_name dependencies)
  set(app_dir "apps/${app_name}")

  require_directory_does_not_exist("${app_dir}")

  file(MAKE_DIRECTORY "${app_dir}")

  format_app_dependencies(app_dependencies "${dependencies}")

  file(WRITE "${app_dir}/CMakeLists.txt"
"file(GLOB APP_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(APP_NAME
  \${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_executable(\${APP_NAME}
  \${APP_SOURCES}
)

${app_dependencies}project_set_warnings(\${APP_NAME})
"
  )

  file(WRITE "${app_dir}/main.cpp"
"#include <iostream>

int main()
{
  std::cout << \"Hello from ${app_name}!\\n\";

  return 0;
}
"
  )

  append_subdirectory("apps/CMakeLists.txt" "${app_name}")
endfunction()

function(remove_lib lib_name)
  set(lib_dir "libs/${lib_name}")
  set(test_dir "tests/${lib_name}")

  require_directory_exists("${lib_dir}")
  require_directory_exists("${test_dir}")

  file(REMOVE_RECURSE "${lib_dir}")
  file(REMOVE_RECURSE "${test_dir}")

  remove_subdirectory("libs/CMakeLists.txt" "${lib_name}")
  remove_subdirectory("tests/CMakeLists.txt" "${lib_name}")
endfunction()

function(remove_app app_name)
  set(app_dir "apps/${app_name}")

  require_directory_exists("${app_dir}")

  file(REMOVE_RECURSE "${app_dir}")

  remove_subdirectory("apps/CMakeLists.txt" "${app_name}")
endfunction()

get_action(ACTION)
get_component_type(COMPONENT_TYPE)
get_component_name(COMPONENT_NAME)
get_dependencies(DEPENDENCIES)

validate_name("${COMPONENT_NAME}")
validate_names("${DEPENDENCIES}")

if(ACTION STREQUAL "create")
  require_libs_exist("${DEPENDENCIES}")
  if(COMPONENT_TYPE STREQUAL "lib")
    create_lib("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created lib with tests: ${COMPONENT_NAME}")
  elseif(COMPONENT_TYPE STREQUAL "app")
    create_app("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created app: ${COMPONENT_NAME}")
  else()
    message(FATAL_ERROR "Unknown component type: ${COMPONENT_TYPE}. Supported types: lib, app")
  endif()
elseif(ACTION STREQUAL "remove")
  require_no_dependencies("${DEPENDENCIES}")
  if(COMPONENT_TYPE STREQUAL "lib")
    remove_lib("${COMPONENT_NAME}")
    message(STATUS "Removed lib with tests: ${COMPONENT_NAME}")
  elseif(COMPONENT_TYPE STREQUAL "app")
    remove_app("${COMPONENT_NAME}")
    message(STATUS "Removed app: ${COMPONENT_NAME}")
  else()
    message(FATAL_ERROR "Unknown component type: ${COMPONENT_TYPE}. Supported types: lib, app")
  endif()
else()
  message(FATAL_ERROR "Unknown action: ${ACTION}. Supported actions: create, remove")
endif()