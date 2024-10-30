## This project is a fork from
## https://github.com/CRobeck/instrument-amdgpu-kernels
## Most of the code is a modification from Corbin Robeck's work

if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  return()
endif()

# Set the GFX architecture variable
if(NOT DEFINED IREE_INSTRUMENTATION_GFX_ARCH)
    set(GFX_ARCH "gfx90a") # Default to MI210
endif()

include_directories(${CMAKE_CURRENT_LIST_DIR}/include)

# Only run if ROCM backend is enabled.
if(NOT IREE_TARGET_BACKEND_ROCM)
return()
endif()

set(_NAME "AMDGCNMemTrace")
## Find inside the location of this CMakeLists.txt file
add_library(${_NAME} SHARED ${CMAKE_CURRENT_LIST_DIR}/AMDGCNMemTrace.cpp)

target_link_libraries(${_NAME}
  iree_compiler_API_SharedImpl
)

# NOTE: this is only required because we want this sample to run on all
# platforms without needing to change the library name (libfoo.so/foo.dll).
set_target_properties(${_NAME}
  PROPERTIES
    WINDOWS_EXPORT_ALL_SYMBOLS ON
    PREFIX "lib"
    OUTPUT_NAME "AMDGCNMemTrace"
)

target_compile_options(${_NAME} PRIVATE ${IREE_DEFAULT_COPTS})

# Set the output directory for the shared library
set_target_properties(${_NAME} PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Add the second target: MemTraceInstrumentationKernel
add_custom_command(
    OUTPUT MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.bc
    COMMAND hipcc --save-temps -o MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.o ${CMAKE_CURRENT_LIST_DIR}/MemTraceInstrumentationKernel.cpp -c
    COMMAND mv MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.bc ${CMAKE_BINARY_DIR}
    DEPENDS ${CMAKE_CURRENT_LIST_DIR}/MemTraceInstrumentationKernel.cpp
    COMMENT "Building MemTraceInstrumentationKernel with hipcc"
)


add_custom_target(MemTraceInstrumentationKernel ALL
    DEPENDS MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.bc
)
