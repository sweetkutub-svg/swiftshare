cmake_minimum_required(VERSION 3.10)
project(swiftshare LANGUAGES CXX)

set(BINARY_NAME "swiftshare")
set(APPLICATION_ID "com.swiftshare.app")

cmake_policy(SET CMP0063 NEW)

set(CMAKE_INSTALL_RPATH "$ORIGIN/lib")

# Root files for the application.
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")

# Flutter build.
include(${FLUTTER_MANAGED_DIR}/generated_plugins.cmake)

# Application build.
add_executable(${BINARY_NAME}
  "main.cc"
  "my_application.cc"
  "${FLUTTER_MANAGED_DIR}/generated_plugin_registrant.cc"
)
apply_standard_settings(${BINARY_NAME})
target_link_libraries(${BINARY_NAME} PRIVATE flutter)
target_link_libraries(${BINARY_NAME} PRIVATE PkgConfig::GTK)
add_dependencies(${BINARY_NAME} flutter_assemble)

# Generated plugin build rules.
set_target_properties(${BINARY_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET "hidden"
)

cpdef (${BINARY_NAME} "swiftshare" "swiftshare.desktop" "${APPLICATION_ID}")
