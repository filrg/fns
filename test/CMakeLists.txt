cmake_minimum_required(VERSION 3.14)

project(fnsTests LANGUAGES C)

include(../cmake/project-is-top-level.cmake)
include(../cmake/folders.cmake)

# ---- Dependencies ----

if(PROJECT_IS_TOP_LEVEL)
  find_package(fns REQUIRED)
  enable_testing()
endif()

# ---- Tests ----

add_executable(fns_test source/fns_test.c)
target_link_libraries(fns_test PRIVATE fns::fns)
target_compile_features(fns_test PRIVATE c_std_11)

add_test(NAME fns_test COMMAND fns_test)

# ---- End-of-file commands ----

add_folders(Test)
