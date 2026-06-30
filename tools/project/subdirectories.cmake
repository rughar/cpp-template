function(project_ensure_file_ends_with_newline file_path)
  file(READ "${file_path}" content)

  if(NOT content STREQUAL "" AND NOT content MATCHES "\n$")
    file(APPEND "${file_path}" "\n")
  endif()
endfunction()

function(project_add_subdirectory_once file_path directory_name)
  file(READ "${file_path}" content)

  if(content MATCHES "(^|\n)add_subdirectory\\(${directory_name}\\)($|\n)")
    return()
  endif()

  project_ensure_file_ends_with_newline("${file_path}")
  file(APPEND "${file_path}" "add_subdirectory(${directory_name})\n")
endfunction()

function(project_remove_subdirectory file_path directory_name)
  file(READ "${file_path}" content)

  string(REPLACE "add_subdirectory(${directory_name})\n" "" content "${content}")
  string(REPLACE "add_subdirectory(${directory_name})" "" content "${content}")

  file(WRITE "${file_path}" "${content}")
endfunction()