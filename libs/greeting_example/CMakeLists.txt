file(GLOB LIBRARY_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

get_filename_component(LIBRARY_NAME
  ${CMAKE_CURRENT_SOURCE_DIR}
  NAME
)

add_library(${LIBRARY_NAME}
  ${LIBRARY_SOURCES}
)

target_include_directories(${LIBRARY_NAME}
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
)

project_set_warnings(${LIBRARY_NAME})
