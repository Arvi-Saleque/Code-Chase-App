# Define project-level settings
cmake_minimum_required(VERSION 3.14)
project(code_chase_app LANGUAGES CXX)

# Define the application binary name
set(BINARY_NAME "code_chase_app")

# Enable modern CMake behaviors
cmake_policy(VERSION 3.14...3.25)

# Include directories for Firebase (if required)
include_directories(${CMAKE_SOURCE_DIR}/firebase/include)
link_directories(${CMAKE_SOURCE_DIR}/firebase/lib)

# Add Flutter's subdirectory
set(FLUTTER_MANAGED_DIR "${CMAKE_CURRENT_SOURCE_DIR}/flutter")
add_subdirectory(${FLUTTER_MANAGED_DIR})

# Add the runner subdirectory for the app target
add_subdirectory("runner")

# Include Flutter-generated plugins
include(flutter/generated_plugins.cmake)

# Define custom installation settings
set(BUILD_BUNDLE_DIR "$<TARGET_FILE_DIR:${BINARY_NAME}>")
set(CMAKE_VS_INCLUDE_INSTALL_TO_DEFAULT_BUILD 1)
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
  set(CMAKE_INSTALL_PREFIX "${BUILD_BUNDLE_DIR}" CACHE PATH "..." FORCE)
endif()

# Install runtime files
install(TARGETS ${BINARY_NAME} RUNTIME DESTINATION "${CMAKE_INSTALL_PREFIX}" COMPONENT Runtime)

# Install ICU and Flutter runtime files
install(FILES "${FLUTTER_ICU_DATA_FILE}" DESTINATION "${BUILD_BUNDLE_DIR}/data" COMPONENT Runtime)
install(FILES "${FLUTTER_LIBRARY}" DESTINATION "${BUILD_BUNDLE_DIR}" COMPONENT Runtime)

# Copy assets
install(DIRECTORY "${PROJECT_BUILD_DIR}/flutter_assets" DESTINATION "${BUILD_BUNDLE_DIR}/data" COMPONENT Runtime)

# Install AOT library for non-Debug builds
install(FILES "${AOT_LIBRARY}" DESTINATION "${BUILD_BUNDLE_DIR}/data" CONFIGURATIONS Profile;Release COMPONENT Runtime)
