function(get_action output_variable)
  if(CMAKE_ARGC LESS 4)
    message(FATAL_ERROR "Missing action.")
  endif()

  set(${output_variable} "${CMAKE_ARGV3}" PARENT_SCOPE)
endfunction()

function(get_component_type output_variable)
  if(CMAKE_ARGC LESS 5)
    message(FATAL_ERROR "Missing component type.")
  endif()

  set(${output_variable} "${CMAKE_ARGV4}" PARENT_SCOPE)
endfunction()

function(get_component_name output_variable)
  if(CMAKE_ARGC LESS 6)
    message(FATAL_ERROR "Missing component name.")
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

function(require_dependencies dependencies)
  if("${dependencies}" STREQUAL "")
    message(FATAL_ERROR "Missing dependency name.")
  endif()
endfunction()

function(require_no_dependencies dependencies)
  if(NOT "${dependencies}" STREQUAL "")
    message(FATAL_ERROR "This action does not accept dependencies.")
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

function(require_app_exists app_name)
  if(NOT EXISTS "apps/${app_name}")
    message(FATAL_ERROR "Application does not exist: ${app_name}")
  endif()
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

function(format_test_dependencies output_variable lib_name)
  set(block
"target_link_libraries(\${TEST_NAME}_tests
  PRIVATE
    unit_test
    ${lib_name}
)
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(format_target_dependencies output_variable target_name visibility dependencies)
  format_dependency_lines(dependency_lines "${dependencies}")

  if(dependency_lines STREQUAL "")
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  set(block
"target_link_libraries(${target_name}
  ${visibility}
${dependency_lines})
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(extract_existing_dependencies output_variable dependency_text)
  string(REGEX MATCHALL "[A-Za-z_][A-Za-z0-9_]*" dependencies "${dependency_text}")
  set(${output_variable} "${dependencies}" PARENT_SCOPE)
endfunction()

function(read_target_dependencies output_variable file_path target_name visibility)
  file(READ "${file_path}" file_content)

  set(block_header
"target_link_libraries(${target_name}
  ${visibility}
"
  )

  string(FIND "${file_content}" "${block_header}" block_start)

  if(block_start EQUAL -1)
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  string(LENGTH "${block_header}" block_header_length)
  math(EXPR dependencies_start "${block_start} + ${block_header_length}")

  string(SUBSTRING "${file_content}" "${dependencies_start}" -1 content_after_dependencies_start)
  string(FIND "${content_after_dependencies_start}" ")" relative_block_end)

  if(relative_block_end EQUAL -1)
    message(FATAL_ERROR "Could not parse target_link_libraries block in ${file_path}")
  endif()

  string(SUBSTRING "${content_after_dependencies_start}" 0 "${relative_block_end}" dependency_text)
  extract_existing_dependencies(existing_dependencies "${dependency_text}")

  set(${output_variable} "${existing_dependencies}" PARENT_SCOPE)
endfunction()

function(write_target_dependencies file_path target_name visibility dependencies)
  file(READ "${file_path}" file_content)

  set(block_header
"target_link_libraries(${target_name}
  ${visibility}
"
  )

  string(FIND "${file_content}" "${block_header}" block_start)
  format_target_dependencies(new_block "${target_name}" "${visibility}" "${dependencies}")

  if(block_start EQUAL -1)
    if(new_block STREQUAL "")
      return()
    endif()

    string(FIND "${file_content}" "project_set_warnings(" warnings_position)

    if(warnings_position EQUAL -1)
      if(NOT file_content STREQUAL "" AND NOT file_content MATCHES "\n$")
        string(APPEND file_content "\n")
      endif()

      string(APPEND file_content "${new_block}")
    else()
      string(SUBSTRING "${file_content}" 0 "${warnings_position}" content_before_warnings)
      string(SUBSTRING "${file_content}" "${warnings_position}" -1 content_after_warnings)

      set(file_content "${content_before_warnings}${new_block}${content_after_warnings}")
    endif()

    file(WRITE "${file_path}" "${file_content}")
    return()
  endif()

  string(LENGTH "${block_header}" block_header_length)
  math(EXPR dependencies_start "${block_start} + ${block_header_length}")

  string(SUBSTRING "${file_content}" "${dependencies_start}" -1 content_after_dependencies_start)
  string(FIND "${content_after_dependencies_start}" ")" relative_block_end)

  if(relative_block_end EQUAL -1)
    message(FATAL_ERROR "Could not parse target_link_libraries block in ${file_path}")
  endif()

  math(EXPR block_end "${dependencies_start} + ${relative_block_end} + 2")

  string(SUBSTRING "${file_content}" 0 "${block_start}" content_before_block)
  string(SUBSTRING "${file_content}" "${block_end}" -1 content_after_block)

  file(WRITE "${file_path}" "${content_before_block}${new_block}${content_after_block}")
endfunction()

function(create_dependencies_in_target file_path target_name visibility dependencies)
  read_target_dependencies(existing_dependencies "${file_path}" "${target_name}" "${visibility}")

  foreach(dependency ${dependencies})
    list(FIND existing_dependencies "${dependency}" dependency_index)

    if(NOT dependency_index EQUAL -1)
      message(FATAL_ERROR "Dependency already exists: ${dependency}")
    endif()
  endforeach()

  set(all_dependencies "${existing_dependencies}")

  foreach(dependency ${dependencies})
    list(APPEND all_dependencies "${dependency}")
  endforeach()

  write_target_dependencies("${file_path}" "${target_name}" "${visibility}" "${all_dependencies}")
endfunction()

function(remove_dependencies_from_target file_path target_name visibility dependencies)
  read_target_dependencies(existing_dependencies "${file_path}" "${target_name}" "${visibility}")

  foreach(dependency ${dependencies})
    list(FIND existing_dependencies "${dependency}" dependency_index)

    if(dependency_index EQUAL -1)
      message(FATAL_ERROR "Dependency does not exist: ${dependency}")
    endif()
  endforeach()

  set(remaining_dependencies "${existing_dependencies}")

  foreach(dependency ${dependencies})
    list(REMOVE_ITEM remaining_dependencies "${dependency}")
  endforeach()

  write_target_dependencies("${file_path}" "${target_name}" "${visibility}" "${remaining_dependencies}")
endfunction()

function(create_app_dependency app_name dependencies)
  require_app_exists("${app_name}")
  require_libs_exist("${dependencies}")

  create_dependencies_in_target(
    "apps/${app_name}/CMakeLists.txt"
    "\${APP_NAME}"
    "PRIVATE"
    "${dependencies}"
  )
endfunction()

function(create_lib_dependency lib_name dependencies)
  require_lib_exists("${lib_name}")
  require_libs_exist("${dependencies}")

  create_dependencies_in_target(
    "libs/${lib_name}/CMakeLists.txt"
    "\${LIBRARY_NAME}"
    "PUBLIC"
    "${dependencies}"
  )
endfunction()

function(remove_app_dependency app_name dependencies)
  require_app_exists("${app_name}")
  require_libs_exist("${dependencies}")

  remove_dependencies_from_target(
    "apps/${app_name}/CMakeLists.txt"
    "\${APP_NAME}"
    "PRIVATE"
    "${dependencies}"
  )
endfunction()

function(remove_lib_dependency lib_name dependencies)
  require_lib_exists("${lib_name}")
  require_libs_exist("${dependencies}")

  remove_dependencies_from_target(
    "libs/${lib_name}/CMakeLists.txt"
    "\${LIBRARY_NAME}"
    "PUBLIC"
    "${dependencies}"
  )
endfunction()

function(create_lib lib_name dependencies)
  set(lib_dir "libs/${lib_name}")
  set(test_dir "tests/${lib_name}")

  require_directory_does_not_exist("${lib_dir}")
  require_directory_does_not_exist("${test_dir}")

  file(MAKE_DIRECTORY "${lib_dir}")
  file(MAKE_DIRECTORY "${test_dir}")

  format_library_dependencies(library_dependencies "${dependencies}")
  format_test_dependencies(test_dependencies "${lib_name}")

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
  if(COMPONENT_TYPE STREQUAL "lib")
    require_libs_exist("${DEPENDENCIES}")

    create_lib("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created lib with tests: ${COMPONENT_NAME}")

  elseif(COMPONENT_TYPE STREQUAL "app")
    require_libs_exist("${DEPENDENCIES}")

    create_app("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created app: ${COMPONENT_NAME}")

  elseif(COMPONENT_TYPE STREQUAL "lib_dependency")
    require_dependencies("${DEPENDENCIES}")

    create_lib_dependency("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created lib dependencies for ${COMPONENT_NAME}: ${DEPENDENCIES}")

  elseif(COMPONENT_TYPE STREQUAL "app_dependency")
    require_dependencies("${DEPENDENCIES}")

    create_app_dependency("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Created app dependencies for ${COMPONENT_NAME}: ${DEPENDENCIES}")

  else()
    message(FATAL_ERROR "Unknown component type: ${COMPONENT_TYPE}. Supported types: lib, app, lib_dependency, app_dependency")
  endif()

elseif(ACTION STREQUAL "remove")
  if(COMPONENT_TYPE STREQUAL "lib")
    require_no_dependencies("${DEPENDENCIES}")

    remove_lib("${COMPONENT_NAME}")
    message(STATUS "Removed lib with tests: ${COMPONENT_NAME}")

  elseif(COMPONENT_TYPE STREQUAL "app")
    require_no_dependencies("${DEPENDENCIES}")

    remove_app("${COMPONENT_NAME}")
    message(STATUS "Removed app: ${COMPONENT_NAME}")

  elseif(COMPONENT_TYPE STREQUAL "lib_dependency")
    require_dependencies("${DEPENDENCIES}")

    remove_lib_dependency("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Removed lib dependencies from ${COMPONENT_NAME}: ${DEPENDENCIES}")

  elseif(COMPONENT_TYPE STREQUAL "app_dependency")
    require_dependencies("${DEPENDENCIES}")

    remove_app_dependency("${COMPONENT_NAME}" "${DEPENDENCIES}")
    message(STATUS "Removed app dependencies from ${COMPONENT_NAME}: ${DEPENDENCIES}")

  else()
    message(FATAL_ERROR "Unknown component type: ${COMPONENT_TYPE}. Supported types: lib, app, lib_dependency, app_dependency")
  endif()

else()
  message(FATAL_ERROR "Unknown action: ${ACTION}. Supported actions: create, remove")
endif()