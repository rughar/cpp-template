function(project_format_dependency_lines output_variable dependencies)
  set(lines "")

  foreach(dependency ${dependencies})
    string(APPEND lines "    ${dependency}\n")
  endforeach()

  set(${output_variable} "${lines}" PARENT_SCOPE)
endfunction()

function(project_format_link_block output_variable target_name visibility dependencies)
  project_format_dependency_lines(dependency_lines "${dependencies}")

  if(dependency_lines STREQUAL "")
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  set(block
"target_link_libraries(${target_name}
  ${visibility}
${dependency_lines})
"
  )

  set(${output_variable} "${block}" PARENT_SCOPE)
endfunction()

function(project_link_block_header output_variable target_name visibility)
  set(header
"target_link_libraries(${target_name}
  ${visibility}
"
  )

  set(${output_variable} "${header}" PARENT_SCOPE)
endfunction()

function(project_extract_dependencies output_variable dependency_text)
  string(REGEX MATCHALL "[A-Za-z_][A-Za-z0-9_]*" dependencies "${dependency_text}")
  set(${output_variable} "${dependencies}" PARENT_SCOPE)
endfunction()

function(project_read_target_dependencies output_variable file_path target_name visibility)
  file(READ "${file_path}" content)

  project_link_block_header(block_header "${target_name}" "${visibility}")
  string(FIND "${content}" "${block_header}" block_start)

  if(block_start EQUAL -1)
    set(${output_variable} "" PARENT_SCOPE)
    return()
  endif()

  string(LENGTH "${block_header}" block_header_length)
  math(EXPR dependencies_start "${block_start} + ${block_header_length}")

  string(SUBSTRING "${content}" "${dependencies_start}" -1 content_after_dependencies_start)
  string(FIND "${content_after_dependencies_start}" ")" relative_block_end)

  if(relative_block_end EQUAL -1)
    project_fail("Could not parse target_link_libraries block in ${file_path}.")
  endif()

  string(SUBSTRING "${content_after_dependencies_start}" 0 "${relative_block_end}" dependency_text)
  project_extract_dependencies(dependencies "${dependency_text}")

  set(${output_variable} "${dependencies}" PARENT_SCOPE)
endfunction()

function(project_find_link_block output_start_variable output_end_variable file_content target_name visibility)
  project_link_block_header(block_header "${target_name}" "${visibility}")
  string(FIND "${file_content}" "${block_header}" block_start)

  if(block_start EQUAL -1)
    set(${output_start_variable} "-1" PARENT_SCOPE)
    set(${output_end_variable} "-1" PARENT_SCOPE)
    return()
  endif()

  string(LENGTH "${block_header}" block_header_length)
  math(EXPR dependencies_start "${block_start} + ${block_header_length}")

  string(SUBSTRING "${file_content}" "${dependencies_start}" -1 content_after_dependencies_start)
  string(FIND "${content_after_dependencies_start}" ")" relative_block_end)

  if(relative_block_end EQUAL -1)
    project_fail("Could not parse target_link_libraries block.")
  endif()

  math(EXPR block_end "${dependencies_start} + ${relative_block_end} + 2")

  set(${output_start_variable} "${block_start}" PARENT_SCOPE)
  set(${output_end_variable} "${block_end}" PARENT_SCOPE)
endfunction()

function(project_insert_before_warnings output_variable content inserted_text)
  string(FIND "${content}" "project_set_warnings(" insertion_position)

  if(insertion_position EQUAL -1)
    if(NOT content STREQUAL "" AND NOT content MATCHES "\n$")
      string(APPEND content "\n")
    endif()

    string(APPEND content "${inserted_text}")
    set(${output_variable} "${content}" PARENT_SCOPE)
    return()
  endif()

  string(SUBSTRING "${content}" 0 "${insertion_position}" content_before)
  string(SUBSTRING "${content}" "${insertion_position}" -1 content_after)

  set(${output_variable} "${content_before}${inserted_text}${content_after}" PARENT_SCOPE)
endfunction()

function(project_write_target_dependencies file_path target_name visibility dependencies)
  file(READ "${file_path}" content)

  project_format_link_block(new_block "${target_name}" "${visibility}" "${dependencies}")
  project_find_link_block(block_start block_end "${content}" "${target_name}" "${visibility}")

  if(block_start EQUAL -1)
    if(new_block STREQUAL "")
      return()
    endif()

    project_insert_before_warnings(updated_content "${content}" "${new_block}")
    file(WRITE "${file_path}" "${updated_content}")
    return()
  endif()

  string(SUBSTRING "${content}" 0 "${block_start}" content_before)
  string(SUBSTRING "${content}" "${block_end}" -1 content_after)

  file(WRITE "${file_path}" "${content_before}${new_block}${content_after}")
endfunction()

function(project_require_dependencies_absent existing_dependencies requested_dependencies)
  foreach(dependency ${requested_dependencies})
    list(FIND existing_dependencies "${dependency}" dependency_index)

    if(NOT dependency_index EQUAL -1)
      project_fail("Dependency already exists: ${dependency}")
    endif()
  endforeach()
endfunction()

function(project_require_dependencies_present existing_dependencies requested_dependencies)
  foreach(dependency ${requested_dependencies})
    list(FIND existing_dependencies "${dependency}" dependency_index)

    if(dependency_index EQUAL -1)
      project_fail("Dependency does not exist: ${dependency}")
    endif()
  endforeach()
endfunction()

function(project_add_dependencies_to_target file_path target_name visibility dependencies)
  project_read_target_dependencies(existing_dependencies "${file_path}" "${target_name}" "${visibility}")
  project_require_dependencies_absent("${existing_dependencies}" "${dependencies}")

  set(updated_dependencies "${existing_dependencies}")
  list(APPEND updated_dependencies ${dependencies})

  project_write_target_dependencies("${file_path}" "${target_name}" "${visibility}" "${updated_dependencies}")
endfunction()

function(project_remove_dependencies_from_target file_path target_name visibility dependencies)
  project_read_target_dependencies(existing_dependencies "${file_path}" "${target_name}" "${visibility}")
  project_require_dependencies_present("${existing_dependencies}" "${dependencies}")

  set(updated_dependencies "${existing_dependencies}")

  foreach(dependency ${dependencies})
    list(REMOVE_ITEM updated_dependencies "${dependency}")
  endforeach()

  project_write_target_dependencies("${file_path}" "${target_name}" "${visibility}" "${updated_dependencies}")
endfunction()