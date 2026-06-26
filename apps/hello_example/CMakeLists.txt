file(GLOB APP_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(APP_NAME
  ${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_executable(${APP_NAME}
  ${APP_SOURCES}
)

target_link_libraries(${APP_NAME}
  PRIVATE
    greeting_example
)

project_set_warnings(${APP_NAME})