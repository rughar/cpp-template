function(project_library_directory output_variable library_name)
  set(${output_variable} "${PROJECT_LIBRARY_ROOT}/${library_name}" PARENT_SCOPE)
endfunction()

function(project_application_directory output_variable application_name)
  set(${output_variable} "${PROJECT_APPLICATION_ROOT}/${application_name}" PARENT_SCOPE)
endfunction()

function(project_test_directory output_variable library_name)
  set(${output_variable} "${PROJECT_TEST_ROOT}/${library_name}_test" PARENT_SCOPE)
endfunction()

function(project_library_cmake output_variable library_name)
  project_library_directory(directory "${library_name}")
  set(${output_variable} "${directory}/CMakeLists.txt" PARENT_SCOPE)
endfunction()

function(project_application_cmake output_variable application_name)
  project_application_directory(directory "${application_name}")
  set(${output_variable} "${directory}/CMakeLists.txt" PARENT_SCOPE)
endfunction()

function(project_require_library_exists library_name)
  project_library_directory(directory "${library_name}")
  project_require_path_exists("${directory}" "Library does not exist")
endfunction()

function(project_require_libraries_exist library_names)
  foreach(library_name ${library_names})
    project_require_library_exists("${library_name}")
  endforeach()
endfunction()

function(project_require_application_exists application_name)
  project_application_directory(directory "${application_name}")
  project_require_path_exists("${directory}" "Application does not exist")
endfunction()

function(project_require_library_does_not_exist library_name)
  project_library_directory(directory "${library_name}")
  project_require_path_does_not_exist("${directory}" "Library already exists")
endfunction()

function(project_require_application_does_not_exist application_name)
  project_application_directory(directory "${application_name}")
  project_require_path_does_not_exist("${directory}" "Application already exists")
endfunction()

function(project_require_test_does_not_exist library_name)
  project_test_directory(directory "${library_name}")
  project_require_path_does_not_exist("${directory}" "Test application already exists")
endfunction()