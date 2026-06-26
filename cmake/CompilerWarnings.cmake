function(project_set_warnings target)

  target_compile_options(${target}
    PRIVATE

      $<$<CXX_COMPILER_ID:MSVC>:
        /W4
        /permissive-
      >

      $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:
        -Wall
        -Wextra
        -Wpedantic
      >
  )

endfunction()