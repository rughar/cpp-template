file(GLOB UTEST_FRAMEWORK_SOURCES CONFIGURE_DEPENDS
  *.cpp
)

list(REMOVE_ITEM UTEST_FRAMEWORK_SOURCES
  "${CMAKE_CURRENT_SOURCE_DIR}/utestSmoke.cpp"
)

if(UTEST_FRAMEWORK_SOURCES)
  add_library(utest_framework)

  target_sources(utest_framework
    PRIVATE
      ${UTEST_FRAMEWORK_SOURCES}
  )

  set(UTEST_FRAMEWORK_USAGE PUBLIC)
else()
  add_library(utest_framework INTERFACE)

  set(UTEST_FRAMEWORK_USAGE INTERFACE)
endif()

target_include_directories(utest_framework
  ${UTEST_FRAMEWORK_USAGE}
    ${CMAKE_CURRENT_SOURCE_DIR}
)

add_executable(utest_framework_smoke
  utestSmoke.cpp
)

target_link_libraries(utest_framework_smoke
  PRIVATE
    utest_framework
)

project_set_warnings(utest_framework_smoke)

add_test(
  NAME utest_framework_smoke
  COMMAND utest_framework_smoke
)