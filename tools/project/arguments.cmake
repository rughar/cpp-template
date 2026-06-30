function(project_get_required_argument output_variable argument_index error_message)
  if(CMAKE_ARGC LESS_EQUAL ${argument_index})
    project_fail("${error_message}")
  endif()

  set(${output_variable} "${CMAKE_ARGV${argument_index}}" PARENT_SCOPE)
endfunction()

function(project_get_dependencies output_variable)
  set(dependencies "")

  if(CMAKE_ARGC GREATER 6)
    math(EXPR last_argument_index "${CMAKE_ARGC} - 1")

    foreach(argument_index RANGE 6 ${last_argument_index})
      list(APPEND dependencies "${CMAKE_ARGV${argument_index}}")
    endforeach()
  endif()

  set(${output_variable} "${dependencies}" PARENT_SCOPE)
endfunction()

function(project_read_arguments action_variable type_variable name_variable dependencies_variable)
  project_get_required_argument(action 3 "Missing action.")
  project_get_required_argument(component_type 4 "Missing component type.")
  project_get_required_argument(component_name 5 "Missing component name.")
  project_get_dependencies(dependencies)

  set(${action_variable} "${action}" PARENT_SCOPE)
  set(${type_variable} "${component_type}" PARENT_SCOPE)
  set(${name_variable} "${component_name}" PARENT_SCOPE)
  set(${dependencies_variable} "${dependencies}" PARENT_SCOPE)
endfunction()