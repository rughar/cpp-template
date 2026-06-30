function(project_format_library_dependencies output_variable dependencies)
  project_format_link_block(
    block
    "\${LIBRARY_NAME}"
    "\${LIBRARY_USAGE}"
    "${dependencies}"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(project_format_application_dependencies output_variable dependencies)
  project_format_link_block(
    block
    "\${APP_NAME}"
    "PRIVATE"
    "${dependencies}"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(project_format_test_dependencies output_variable library_name)
  set(block
"target_link_libraries(\${TEST_NAME}
  PRIVATE
    ${PROJECT_TEST_FRAMEWORK_TARGET}
    ${library_name}
)
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(project_write_library_cmake library_directory dependencies)
  project_format_library_dependencies(library_dependencies "${dependencies}")

  file(WRITE "${library_directory}/CMakeLists.txt"
"file(GLOB LIBRARY_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(LIBRARY_NAME
  \${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

if(LIBRARY_SOURCES)
  add_library(\${LIBRARY_NAME})

  target_sources(\${LIBRARY_NAME}
    PRIVATE
      \${LIBRARY_SOURCES}
  )

  set(LIBRARY_USAGE PUBLIC)
else()
  add_library(\${LIBRARY_NAME} INTERFACE)

  set(LIBRARY_USAGE INTERFACE)
endif()

target_include_directories(\${LIBRARY_NAME}
  \${LIBRARY_USAGE}
    \${CMAKE_CURRENT_SOURCE_DIR}
)

${library_dependencies}if(LIBRARY_SOURCES)
  project_set_warnings(\${LIBRARY_NAME})
endif()
"
  )
endfunction()

function(project_write_library_header library_directory library_name)
  file(WRITE "${library_directory}/${library_name}.hpp"
"#pragma once

namespace ${library_name}
{

}
"
  )
endfunction()

function(project_write_test_cmake test_directory library_name)
  project_format_test_dependencies(test_dependencies "${library_name}")

  file(WRITE "${test_directory}/CMakeLists.txt"
"file(GLOB TEST_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(TEST_NAME
  \${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_executable(\${TEST_NAME}
  \${TEST_SOURCES}
)

${test_dependencies}project_set_warnings(\${TEST_NAME})

add_test(
  NAME \${TEST_NAME}
  COMMAND \${TEST_NAME}
)

set_tests_properties(\${TEST_NAME}
  PROPERTIES
    DEPENDS ${PROJECT_TEST_FRAMEWORK_SMOKE_TEST}
)
"
  )
endfunction()

function(project_write_test_source test_directory library_name)
  file(WRITE "${test_directory}/${library_name}Tests.cpp"
"#include \"${library_name}.hpp\"
#include \"${PROJECT_TEST_FRAMEWORK_HEADER}\"

int main()
{
  utest::Runner runner;

  runner.printSummary();

  return runner.getExitCode();
}
"
  )
endfunction()

function(project_write_application_cmake application_directory dependencies)
  project_format_application_dependencies(application_dependencies "${dependencies}")

  file(WRITE "${application_directory}/CMakeLists.txt"
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

${application_dependencies}project_set_warnings(\${APP_NAME})
"
  )
endfunction()

function(project_write_application_source application_directory application_name)
  file(WRITE "${application_directory}/main.cpp"
"#include <iostream>

int main()
{
  std::cout << \"Hello from ${application_name}!\\n\";

  return 0;
}
"
  )
endfunction()