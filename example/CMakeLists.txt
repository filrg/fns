cmake_minimum_required(VERSION 3.14)

project(fnsExamples C)

include(../cmake/project-is-top-level.cmake)
include(../cmake/folders.cmake)

if(PROJECT_IS_TOP_LEVEL)
  find_package(fns REQUIRED)
endif()


add_custom_target(run-examples)

function(add_c_example NAME)
  add_executable("${NAME}" "${NAME}.c")
  target_link_libraries("${NAME}" PRIVATE fns::fns)
  target_compile_features("${NAME}" PRIVATE c_std_11)
  add_custom_target("run_${NAME}" COMMAND "${NAME}" VERBATIM)
  add_dependencies("run_${NAME}" "${NAME}")
  add_dependencies(run-examples "run_${NAME}")
endfunction()

function(add_cu_example NAME)
  add_executable("${NAME}" "${NAME}.cu")
  target_link_libraries("${NAME}" PRIVATE fns::fns ngp png)
  target_compile_features("${NAME}" PRIVATE c_std_11)
  add_custom_target("run_${NAME}" COMMAND "${NAME}" VERBATIM)
  add_dependencies("run_${NAME}" "${NAME}")
  add_dependencies(run-examples "run_${NAME}")
endfunction()

add_c_example(empty_example)

set(CMAKE_CUDA_ARCHITECTURES native)

add_cu_example(gui)

add_folders(Example)
