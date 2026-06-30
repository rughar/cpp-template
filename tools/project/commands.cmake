function(project_create_library library_name dependencies)
  project_library_directory(library_directory "${library_name}")
  project_test_directory(test_directory "${library_name}")

  project_require_library_does_not_exist("${library_name}")
  project_require_test_does_not_exist("${library_name}")

  file(MAKE_DIRECTORY "${library_directory}")
  file(MAKE_DIRECTORY "${test_directory}")

  project_write_library_cmake("${library_directory}" "${dependencies}")
  project_write_library_header("${library_directory}" "${library_name}")

  project_write_test_cmake("${test_directory}" "${library_name}")
  project_write_test_source("${test_directory}" "${library_name}")

  project_add_subdirectory_once("${PROJECT_LIBRARY_ROOT}/CMakeLists.txt" "${library_name}")
  project_add_subdirectory_once("${PROJECT_TEST_ROOT}/CMakeLists.txt" "${library_name}_test")
endfunction()

function(project_remove_library library_name)
  project_library_directory(library_directory "${library_name}")
  project_test_directory(test_directory "${library_name}")

  project_require_path_exists("${library_directory}" "Library does not exist")
  project_require_path_exists("${test_directory}" "Test application does not exist")

  file(REMOVE_RECURSE "${library_directory}")
  file(REMOVE_RECURSE "${test_directory}")

  project_remove_subdirectory("${PROJECT_LIBRARY_ROOT}/CMakeLists.txt" "${library_name}")
  project_remove_subdirectory("${PROJECT_TEST_ROOT}/CMakeLists.txt" "${library_name}_test")
endfunction()

function(project_create_application application_name dependencies)
  project_application_directory(application_directory "${application_name}")

  project_require_application_does_not_exist("${application_name}")

  file(MAKE_DIRECTORY "${application_directory}")

  project_write_application_cmake("${application_directory}" "${dependencies}")
  project_write_application_source("${application_directory}" "${application_name}")

  project_add_subdirectory_once("${PROJECT_APPLICATION_ROOT}/CMakeLists.txt" "${application_name}")
endfunction()

function(project_remove_application application_name)
  project_application_directory(application_directory "${application_name}")

  project_require_path_exists("${application_directory}" "Application does not exist")

  file(REMOVE_RECURSE "${application_directory}")
  project_remove_subdirectory("${PROJECT_APPLICATION_ROOT}/CMakeLists.txt" "${application_name}")
endfunction()

function(project_create_library_dependency library_name dependencies)
  project_require_library_exists("${library_name}")
  project_require_libraries_exist("${dependencies}")

  project_library_cmake(cmake_file "${library_name}")

  project_add_dependencies_to_target(
    "${cmake_file}"
    "\${LIBRARY_NAME}"
    "\${LIBRARY_USAGE}"
    "${dependencies}"
  )
endfunction()

function(project_remove_library_dependency library_name dependencies)
  project_require_library_exists("${library_name}")
  project_require_libraries_exist("${dependencies}")

  project_library_cmake(cmake_file "${library_name}")

  project_remove_dependencies_from_target(
    "${cmake_file}"
    "\${LIBRARY_NAME}"
    "\${LIBRARY_USAGE}"
    "${dependencies}"
  )
endfunction()

function(project_create_application_dependency application_name dependencies)
  project_require_application_exists("${application_name}")
  project_require_libraries_exist("${dependencies}")

  project_application_cmake(cmake_file "${application_name}")

  project_add_dependencies_to_target(
    "${cmake_file}"
    "\${APP_NAME}"
    "PRIVATE"
    "${dependencies}"
  )
endfunction()

function(project_remove_application_dependency application_name dependencies)
  project_require_application_exists("${application_name}")
  project_require_libraries_exist("${dependencies}")

  project_application_cmake(cmake_file "${application_name}")

  project_remove_dependencies_from_target(
    "${cmake_file}"
    "\${APP_NAME}"
    "PRIVATE"
    "${dependencies}"
  )
endfunction()

function(project_create component_type component_name dependencies)
  if(component_type STREQUAL PROJECT_TYPE_LIBRARY)
    project_require_libraries_exist("${dependencies}")
    project_create_library("${component_name}" "${dependencies}")
    message(STATUS "Created lib with test app: ${component_name}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_APPLICATION)
    project_require_libraries_exist("${dependencies}")
    project_create_application("${component_name}" "${dependencies}")
    message(STATUS "Created app: ${component_name}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_LIBRARY_DEPENDENCY)
    project_require_dependencies("${dependencies}")
    project_create_library_dependency("${component_name}" "${dependencies}")
    message(STATUS "Created lib dependencies for ${component_name}: ${dependencies}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_APPLICATION_DEPENDENCY)
    project_require_dependencies("${dependencies}")
    project_create_application_dependency("${component_name}" "${dependencies}")
    message(STATUS "Created app dependencies for ${component_name}: ${dependencies}")
    return()
  endif()

  project_fail("Unknown component type: ${component_type}. Supported types: lib, app, lib_dependency, app_dependency")
endfunction()

function(project_remove component_type component_name dependencies)
  if(component_type STREQUAL PROJECT_TYPE_LIBRARY)
    project_require_no_dependencies("${dependencies}")
    project_remove_library("${component_name}")
    message(STATUS "Removed lib with test app: ${component_name}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_APPLICATION)
    project_require_no_dependencies("${dependencies}")
    project_remove_application("${component_name}")
    message(STATUS "Removed app: ${component_name}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_LIBRARY_DEPENDENCY)
    project_require_dependencies("${dependencies}")
    project_remove_library_dependency("${component_name}" "${dependencies}")
    message(STATUS "Removed lib dependencies from ${component_name}: ${dependencies}")
    return()
  endif()

  if(component_type STREQUAL PROJECT_TYPE_APPLICATION_DEPENDENCY)
    project_require_dependencies("${dependencies}")
    project_remove_application_dependency("${component_name}" "${dependencies}")
    message(STATUS "Removed app dependencies from ${component_name}: ${dependencies}")
    return()
  endif()

  project_fail("Unknown component type: ${component_type}. Supported types: lib, app, lib_dependency, app_dependency")
endfunction()

function(project_execute action component_type component_name dependencies)
  if(action STREQUAL PROJECT_ACTION_CREATE)
    project_create("${component_type}" "${component_name}" "${dependencies}")
    return()
  endif()

  if(action STREQUAL PROJECT_ACTION_REMOVE)
    project_remove("${component_type}" "${component_name}" "${dependencies}")
    return()
  endif()

  project_fail("Unknown action: ${action}. Supported actions: create, remove")
endfunction()