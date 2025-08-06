cmake_minimum_required(VERSION 3.14)

include(cmake/prelude.cmake)

project(
    fns
    VERSION 0.1.0
    DESCRIPTION "A library for streaming nerfs video."
    HOMEPAGE_URL "https://filrg.github.io/fns/"
    LANGUAGES C CXX CUDA
)

include(cmake/project-is-top-level.cmake)
include(cmake/variables.cmake)

# set(CMAKE_CUDA_ARCHITECTURES native)
set(CMAKE_CUDA_ARCHITECTURES 75)

option(FNS_BUILD_WITH_INSTANT_NGP "Build with instant-ngp to render NERFS?" ON)

if(FNS_BUILD_WITH_INSTANT_NGP)
    include(cmake/dependencies/instant-ngp.cmake)
endif()

# ---- Declare library ----


file(GLOB FNS_SHARED_SOURCE ${CMAKE_CURRENT_SOURCE_DIR}/source/*)

add_library(
    fns_fns
    ${FNS_SHARED_SOURCE}
)
add_library(fns::fns ALIAS fns_fns)

if(USE_INSTANT_NGP EQUAL ON)
    target_compile_definitions(fns_fns PRIVATE FNS_BUILD_WITH_INSTANT_NGP)
    target_link_libraries(fns_fns PUBLIC ngp)
endif()

include(GenerateExportHeader)
generate_export_header(
    fns_fns
    BASE_NAME fns
    EXPORT_FILE_NAME export/fns/fns_export.h
)

if(NOT BUILD_SHARED_LIBS)
  target_compile_definitions(fns_fns PUBLIC FNS_STATIC_DEFINE)
endif()

set_target_properties(
    fns_fns PROPERTIES
    C_VISIBILITY_PRESET hidden
    VERSION "${PROJECT_VERSION}"
    SOVERSION "${PROJECT_VERSION_MAJOR}"
    EXPORT_NAME fns
    OUTPUT_NAME fns
)

target_include_directories(
    fns_fns ${warning_guard}
    PUBLIC
    "\$<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>"
)

target_include_directories(
    fns_fns SYSTEM
    PUBLIC
    "\$<BUILD_INTERFACE:${PROJECT_BINARY_DIR}/export>"
)

target_compile_features(fns_fns PUBLIC c_std_11)

# ---- Install rules ----

if(NOT CMAKE_SKIP_INSTALL_RULES)
  include(cmake/install-rules.cmake)
endif()

# ---- Examples ----

if(PROJECT_IS_TOP_LEVEL)
  option(BUILD_EXAMPLES "Build examples tree." "${fns_DEVELOPER_MODE}")
  if(BUILD_EXAMPLES)
    add_subdirectory(example)
  endif()
endif()

# ---- Developer mode ----

if(NOT fns_DEVELOPER_MODE)
  return()
elseif(NOT PROJECT_IS_TOP_LEVEL)
  message(
      AUTHOR_WARNING
      "Developer mode is intended for developers of fns"
  )
endif()

include(cmake/dev-mode.cmake)
