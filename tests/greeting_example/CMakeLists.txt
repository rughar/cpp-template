file(GLOB TEST_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(TEST_NAME
  ${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_executable(${TEST_NAME}_tests
  ${TEST_SOURCES}
)

target_link_libraries(${TEST_NAME}_tests
  PRIVATE
    unit_test
    greeting_example
)
project_set_warnings(${TEST_NAME}_tests)

add_test(
  NAME ${TEST_NAME}_tests
  COMMAND ${TEST_NAME}_tests
)

set_tests_properties(${TEST_NAME}_tests
  PROPERTIES
    DEPENDS unit_test_tests
)
