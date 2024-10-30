## This project is a fork from
## https://github.com/CRobeck/instrument-amdgpu-kernels
## Most of the code is a modification from Corbin Robeck's work

cmake_minimum_required(VERSION 3.13)
project(IREEInstrumentation)

# Set the GFX architecture variable
if(NOT DEFINED GFX_ARCH)
    set(GFX_ARCH "gfx90a")
endif()

include_directories(include)

## -fvisibility=hidden
message(STATUS "Using -fvisibility=hidden")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fvisibility=hidden")
set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fvisibility=hidden")
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

add_library(AMDGCNMemTrace SHARED AMDGCNMemTrace.cpp)

## Add Library Directory -L
target_link_directories(AMDGCNMemTrace PRIVATE /home/jmonsalv/develop/IREE/iree/build/lib)

## Add static library linking 


# Add the first target: AMDGCNMemTrace
target_link_libraries(AMDGCNMemTrace 
    PRIVATE
    IREECompiler
    "$<$<PLATFORM_ID:Darwin>:-undefined dynamic_lookup>"
)

# Set the output directory for the shared library
set_target_properties(AMDGCNMemTrace PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
)

# Add the second target: MemTraceInstrumentationKernel
add_custom_command(
    OUTPUT ${CMAKE_BINARY_DIR}/MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.bc
    COMMAND hipcc --save-temps -o ${CMAKE_BINARY_DIR}/MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.o ${CMAKE_SOURCE_DIR}/MemTraceInstrumentationKernel.cpp -c
    DEPENDS MemTraceInstrumentationKernel.cpp
    COMMENT "Building MemTraceInstrumentationKernel with hipcc"
)

add_custom_target(MemTraceInstrumentationKernel ALL
    DEPENDS ${CMAKE_BINARY_DIR}/MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-${GFX_ARCH}.bc
)