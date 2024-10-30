# Instrumentation using IREE and OPT Plugins

This repo works as an example on how to instrument iree kernels using OPT Plugins. The repo relies on IREE via submodules. This is to be able to properly link the plugin to the IREECompiler.

## Reference
This example is inspired by Corbin Robeck in [his repo](https://github.com/CRobeck/instrument-amdgpu-kernels).

## Getting started
The first thing we need to do is to clone this repo, and its submodules. After cloning this repo use:

```
git submodule update --init --recursive
```

Then, let's build it. I will use the command that has worked for me. There are many flags here that can be omitted, but I will leave them here for reference.

```
mkdir build
cd build
cmake -G Ninja \
-S ../iree     \
-DCMAKE_BUILD_TYPE=RelWithDebInfo \
-DIREE_ENABLE_ASSERTIONS=ON \
-DIREE_ENABLE_SPLIT_DWARF=ON \
-DIREE_ENABLE_THIN_ARCHIVES=ON \
-DCMAKE_C_COMPILER=clang \
-DCMAKE_CXX_COMPILER=clang++ \
-DIREE_ENABLE_LLD=ON \
-DCMAKE_C_COMPILER_LAUNCHER=ccache \
-DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
-DIREE_HAL_DRIVER_CUDA=OFF \
-DIREE_HAL_DRIVER_HIP=ON \
-DIREE_TARGET_BACKEND_CUDA=OFF \
-DIREE_TARGET_BACKEND_ROCM=ON \
-DIREE_TARGET_BACKEND_LLVM_CPU=ON \
-DIREE_ROCM_PATH=/opt/rocm/ \
-DIREE_BUILD_PYTHON_BINDINGS=ON \
-DPython3_EXECUTABLE="$(which python3)" \
-DIREE_ENABLE_WERROR_FLAG=OFF \
-DCMAKE_INSTALL_PREFIX=/home/jmonsalv/develop/IREE/install_10222024 -DIREE_CMAKE_PLUGIN_PATHS=../

ninja
```

Some notes on the flags:
- `IREE_ENABLE_ASSERTIONS=ON`: This is useful for debugging, but it can be omitted.
- `IREE_ENABLE_WERROR_FLAG=OFF`: This is necessary because of possible warnings in the plugin code at the moment of writing this.
- `IREE_HAL_DRIVER_HIP=ON`: This is necessary to enable the HIP backend, which is the one back end that supports instrumentation at the moment.

There is another flag to control the gfx architecture to be used during the generation of the instrumentation function:
- `IREE_INSTRUMENTATION_GFX_ARCH`. By default it is set to `gfx90a`, which corresponds to MI210. 


## Let's run the example
After building the project, two files will be generated:

- libAMDGCNMemTrace.so
- MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-gfx90a.bc

We are ready to run the example. The example is under the `sample` folder. To run it, use the following command:

```
cd sample
make instrument
make run
```

This code is a simple point-wise multiplication of two tensors. The instrumentation will generate a trace of memory accesses per kernel.

During instrumentation, a table of anotated locations is generated:

```
$ make instrument
Instrumenting test.vmfb
export AMDCGN_INSTRUMENTATION_FUNCTIONS_FILE=../build/MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-gfx90a.bc && \
iree-compile --mlir-disable-threading --iree-hal-executable-debug-level=3 --iree-hal-target-device=hip --iree-hip-target=gfx90a test.mlir -o test.vmfb --iree-hip-pass-plugin-path=../build/libAMDGCNMemTrace.so
0     simple_mul_dispatch_0_elementwise_4096_i16     unknown:0:0     GLOBAL     LOAD
Instrumentation Function found: _Z8memTracePvj
1     simple_mul_dispatch_0_elementwise_4096_i16     unknown:1:0     GLOBAL     LOAD
Instrumentation Function found: _Z8memTracePvj
2     simple_mul_dispatch_0_elementwise_4096_i16     unknown:2:0     GLOBAL     STORE
Instrumentation Function found: _Z8memTracePvj
Instrumenting done
```

After running the example, a trace file will be generated. I am showing just a few lines of the end of the output.

```
7275450669713,2,0,2,9,0,0x7f1915805580,0x7f1915805582,0x7f1915805584,0x7f1915805586,0x7f1915805588,0x7f191580558a,0x7f191580558c,0x7f191580558e,0x7f1915805590,0x7f1915805592,0x7f1915805594,0x7f1915805596,0x7f1915805598,0x7f191580559a,0x7f191580559c,0x7f191580559e,0x7f19158055a0,0x7f19158055a2,0x7f19158055a4,0x7f19158055a6,0x7f19158055a8,0x7f19158055aa,0x7f19158055ac,0x7f19158055ae,0x7f19158055b0,0x7f19158055b2,0x7f19158055b4,0x7f19158055b6,0x7f19158055b8,0x7f19158055ba,0x7f19158055bc,0x7f19158055be,0x7f19158055c0,0x7f19158055c2,0x7f19158055c4,0x7f19158055c6,0x7f19158055c8,0x7f19158055ca,0x7f19158055cc,0x7f19158055ce,0x7f19158055d0,0x7f19158055d2,0x7f19158055d4,0x7f19158055d6,0x7f19158055d8,0x7f19158055da,0x7f19158055dc,0x7f19158055de,0x7f19158055e0,0x7f19158055e2,0x7f19158055e4,0x7f19158055e6,0x7f19158055e8,0x7f19158055ea,0x7f19158055ec,0x7f19158055ee,0x7f19158055f0,0x7f19158055f2,0x7f19158055f4,0x7f19158055f6,0x7f19158055f8,0x7f19158055fa,0x7f19158055fc,0x7f19158055fe
7275450727109,2,0,3,3,3,0x7f1915804980,0x7f1915804982,0x7f1915804984,0x7f1915804986,0x7f1915804988,0x7f191580498a,0x7f191580498c,0x7f191580498e,0x7f1915804990,0x7f1915804992,0x7f1915804994,0x7f1915804996,0x7f1915804998,0x7f191580499a,0x7f191580499c,0x7f191580499e,0x7f19158049a0,0x7f19158049a2,0x7f19158049a4,0x7f19158049a6,0x7f19158049a8,0x7f19158049aa,0x7f19158049ac,0x7f19158049ae,0x7f19158049b0,0x7f19158049b2,0x7f19158049b4,0x7f19158049b6,0x7f19158049b8,0x7f19158049ba,0x7f19158049bc,0x7f19158049be,0x7f19158049c0,0x7f19158049c2,0x7f19158049c4,0x7f19158049c6,0x7f19158049c8,0x7f19158049ca,0x7f19158049cc,0x7f19158049ce,0x7f19158049d0,0x7f19158049d2,0x7f19158049d4,0x7f19158049d6,0x7f19158049d8,0x7f19158049da,0x7f19158049dc,0x7f19158049de,0x7f19158049e0,0x7f19158049e2,0x7f19158049e4,0x7f19158049e6,0x7f19158049e8,0x7f19158049ea,0x7f19158049ec,0x7f19158049ee,0x7f19158049f0,0x7f19158049f2,0x7f19158049f4,0x7f19158049f6,0x7f19158049f8,0x7f19158049fa,0x7f19158049fc,0x7f19158049fe
7275450729321,2,0,1,3,3,0x7f1915804900,0x7f1915804902,0x7f1915804904,0x7f1915804906,0x7f1915804908,0x7f191580490a,0x7f191580490c,0x7f191580490e,0x7f1915804910,0x7f1915804912,0x7f1915804914,0x7f1915804916,0x7f1915804918,0x7f191580491a,0x7f191580491c,0x7f191580491e,0x7f1915804920,0x7f1915804922,0x7f1915804924,0x7f1915804926,0x7f1915804928,0x7f191580492a,0x7f191580492c,0x7f191580492e,0x7f1915804930,0x7f1915804932,0x7f1915804934,0x7f1915804936,0x7f1915804938,0x7f191580493a,0x7f191580493c,0x7f191580493e,0x7f1915804940,0x7f1915804942,0x7f1915804944,0x7f1915804946,0x7f1915804948,0x7f191580494a,0x7f191580494c,0x7f191580494e,0x7f1915804950,0x7f1915804952,0x7f1915804954,0x7f1915804956,0x7f1915804958,0x7f191580495a,0x7f191580495c,0x7f191580495e,0x7f1915804960,0x7f1915804962,0x7f1915804964,0x7f1915804966,0x7f1915804968,0x7f191580496a,0x7f191580496c,0x7f191580496e,0x7f1915804970,0x7f1915804972,0x7f1915804974,0x7f1915804976,0x7f1915804978,0x7f191580497a,0x7f191580497c,0x7f191580497e
result[0]: hal.buffer_view
64x64xi16=[2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2 2][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...][...]
Running done
```