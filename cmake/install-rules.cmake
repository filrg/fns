if(PROJECT_IS_TOP_LEVEL)
  set(
      CMAKE_INSTALL_INCLUDEDIR "include/fns-${PROJECT_VERSION}"
      CACHE STRING ""
  )
  set_property(CACHE CMAKE_INSTALL_INCLUDEDIR PROPERTY TYPE PATH)
endif()

include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

# find_package(<package>) call for consumers to find this project
set(package fns)

install(
    DIRECTORY
    include/
    "${PROJECT_BINARY_DIR}/export/"
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
    COMPONENT fns_Development
)

install(
    TARGETS fns_fns
    EXPORT fnsTargets
    RUNTIME #
    COMPONENT fns_Runtime
    LIBRARY #
    COMPONENT fns_Runtime
    NAMELINK_COMPONENT fns_Development
    ARCHIVE #
    COMPONENT fns_Development
    INCLUDES #
    DESTINATION "${CMAKE_INSTALL_INCLUDEDIR}"
)

write_basic_package_version_file(
    "${package}ConfigVersion.cmake"
    COMPATIBILITY SameMajorVersion
)

# Allow package maintainers to freely override the path for the configs
set(
    fns_INSTALL_CMAKEDIR "${CMAKE_INSTALL_LIBDIR}/cmake/${package}"
    CACHE STRING "CMake package config location relative to the install prefix"
)
set_property(CACHE fns_INSTALL_CMAKEDIR PROPERTY TYPE PATH)
mark_as_advanced(fns_INSTALL_CMAKEDIR)

install(
    FILES cmake/install-config.cmake
    DESTINATION "${fns_INSTALL_CMAKEDIR}"
    RENAME "${package}Config.cmake"
    COMPONENT fns_Development
)

install(
    FILES "${PROJECT_BINARY_DIR}/${package}ConfigVersion.cmake"
    DESTINATION "${fns_INSTALL_CMAKEDIR}"
    COMPONENT fns_Development
)

install(
    EXPORT fnsTargets
    NAMESPACE fns::
    DESTINATION "${fns_INSTALL_CMAKEDIR}"
    COMPONENT fns_Development
)

if(PROJECT_IS_TOP_LEVEL)
  include(CPack)
endif()
