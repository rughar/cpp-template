cmake_minimum_required(VERSION 3.20)

set(PROJECT_ROOT "${CMAKE_CURRENT_LIST_DIR}/..")
set(TEST_ROOT "${PROJECT_ROOT}/build/project_script_test")
set(TEST_PROJECT "${TEST_ROOT}/project")
set(TEST_CONFIGURATION Debug)

get_filename_component(CMAKE_BIN_DIR "${CMAKE_COMMAND}" DIRECTORY)

find_program(CTEST_COMMAND
  NAMES ctest
  HINTS "${CMAKE_BIN_DIR}"
  REQUIRED
)

set(TEST_PREFIX "project_script_test_9f3a7c")
set(TEST_LIB_A "${TEST_PREFIX}_alpha")
set(TEST_LIB_B "${TEST_PREFIX}_beta")
set(TEST_APP "${TEST_PREFIX}_demo")

function(step text)
  message(STATUS "")
  message(STATUS "===================================================")
  message(STATUS "${text}")
  message(STATUS "===================================================")
endfunction()

function(print_output label text)
  if(NOT "${text}" STREQUAL "")
    string(STRIP "${text}" stripped_text)

    if(NOT "${stripped_text}" STREQUAL "")
      message(STATUS "${label}:")
      message(STATUS "${stripped_text}")
    endif()
  endif()
endfunction()

function(run)
  message(STATUS "Running: ${ARGV}")

  execute_process(
    COMMAND ${ARGV}
    WORKING_DIRECTORY "${TEST_PROJECT}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )

  print_output("Output" "${output}")
  print_output("Error" "${error}")

  if(NOT result EQUAL 0)
    message(FATAL_ERROR "Command failed: ${ARGV}")
  endif()
endfunction()

function(run_expect_failure)
  message(STATUS "Expecting failure: ${ARGV}")

  execute_process(
    COMMAND ${ARGV}
    WORKING_DIRECTORY "${TEST_PROJECT}"
    RESULT_VARIABLE result
    OUTPUT_VARIABLE output
    ERROR_VARIABLE error
  )

  if(result EQUAL 0)
    print_output("Output" "${output}")
    print_output("Error" "${error}")
    message(FATAL_ERROR "Command unexpectedly succeeded: ${ARGV}")
  endif()

  message(STATUS "Failed as expected.")
endfunction()

function(require_exists path)
  message(STATUS "Checking exists: ${path}")

  if(NOT EXISTS "${path}")
    message(FATAL_ERROR "Expected path does not exist: ${path}")
  endif()
endfunction()

function(require_file_contains file_path text)
  message(STATUS "Checking file contains: ${file_path}")
  message(STATUS "Expected text: ${text}")

  file(READ "${file_path}" content)
  string(FIND "${content}" "${text}" index)

  if(index EQUAL -1)
    message(FATAL_ERROR
      "File does not contain expected text:\n"
      "${file_path}\n\n"
      "Expected:\n${text}"
    )
  endif()
endfunction()

function(require_file_does_not_contain file_path text)
  message(STATUS "Checking file does not contain: ${file_path}")
  message(STATUS "Unexpected text: ${text}")

  file(READ "${file_path}" content)
  string(FIND "${content}" "${text}" index)

  if(NOT index EQUAL -1)
    message(FATAL_ERROR
      "File contains unexpected text:\n"
      "${file_path}\n\n"
      "Unexpected:\n${text}"
    )
  endif()
endfunction()

step("Prepare isolated project copy")

file(REMOVE_RECURSE "${TEST_ROOT}")
file(MAKE_DIRECTORY "${TEST_ROOT}")

file(COPY "${PROJECT_ROOT}/"
  DESTINATION "${TEST_PROJECT}"
  PATTERN ".git" EXCLUDE
  PATTERN "build" EXCLUDE
  PATTERN ".vs" EXCLUDE
  PATTERN ".vscode" EXCLUDE
)

step("Create first library")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib
  ${TEST_LIB_A}
)

require_exists("${TEST_PROJECT}/libs/${TEST_LIB_A}")
require_exists("${TEST_PROJECT}/tests/${TEST_LIB_A}_test")
require_file_contains("${TEST_PROJECT}/libs/CMakeLists.txt" "add_subdirectory(${TEST_LIB_A})")
require_file_contains("${TEST_PROJECT}/tests/CMakeLists.txt" "add_subdirectory(${TEST_LIB_A}_test)")

step("Create second library depending on first library")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib
  ${TEST_LIB_B}
  ${TEST_LIB_A}
)

require_exists("${TEST_PROJECT}/libs/${TEST_LIB_B}")
require_exists("${TEST_PROJECT}/tests/${TEST_LIB_B}_test")
require_file_contains("${TEST_PROJECT}/libs/${TEST_LIB_B}/CMakeLists.txt" "    ${TEST_LIB_A}")

step("Reject duplicate library dependency")

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib_dependency
  ${TEST_LIB_B}
  ${TEST_LIB_A}
)

step("Remove library dependency")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  remove
  lib_dependency
  ${TEST_LIB_B}
  ${TEST_LIB_A}
)

require_file_does_not_contain("${TEST_PROJECT}/libs/${TEST_LIB_B}/CMakeLists.txt" "    ${TEST_LIB_A}")

step("Reject removing missing library dependency")

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  remove
  lib_dependency
  ${TEST_LIB_B}
  ${TEST_LIB_A}
)

step("Create application depending on first library")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  app
  ${TEST_APP}
  ${TEST_LIB_A}
)

require_exists("${TEST_PROJECT}/apps/${TEST_APP}")
require_file_contains("${TEST_PROJECT}/apps/${TEST_APP}/CMakeLists.txt" "    ${TEST_LIB_A}")

step("Create application dependency")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  app_dependency
  ${TEST_APP}
  ${TEST_LIB_B}
)

require_file_contains("${TEST_PROJECT}/apps/${TEST_APP}/CMakeLists.txt" "    ${TEST_LIB_B}")

step("Reject duplicate application dependency")

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  app_dependency
  ${TEST_APP}
  ${TEST_LIB_B}
)

step("Remove application dependency")

run(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  remove
  app_dependency
  ${TEST_APP}
  ${TEST_LIB_B}
)

require_file_does_not_contain("${TEST_PROJECT}/apps/${TEST_APP}/CMakeLists.txt" "    ${TEST_LIB_B}")

step("Reject invalid create operations")

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib
  ${TEST_LIB_A}
)

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  app
  ${TEST_APP}
)

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib_dependency
  missing_library
  ${TEST_LIB_A}
)

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  app_dependency
  missing_app
  ${TEST_LIB_A}
)

run_expect_failure(
  "${CMAKE_COMMAND}"
  -P
  tools/project.cmake
  create
  lib_dependency
  ${TEST_LIB_A}
  missing_dependency
)

step("Configure generated project")

run(
  "${CMAKE_COMMAND}"
  -S
  .
  -B
  build
)

step("Build generated project")

run(
  "${CMAKE_COMMAND}"
  --build
  build
  --config
  ${TEST_CONFIGURATION}
)

step("Run generated project tests")

run(
  "${CTEST_COMMAND}"
  --test-dir
  build
  -C
  ${TEST_CONFIGURATION}
  --output-on-failure
)

step("Project script test passed")