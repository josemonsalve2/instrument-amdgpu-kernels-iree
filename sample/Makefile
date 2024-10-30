## Command iree-compile --mlir-disable-threading --iree-hal-executable-debug-level=3 --iree-hal-target-device=hip --iree-hip-target=gfx90a test.mlir -o test.vmfb
## command iree-run-module --device=hip --module=test.vmfb --input="64x64xi16=1" --input="64x64xi16=2"

TEST_FILE = test.mlir
TARGET = test.vmfb
ARCH = gfx90a
DEVICE = hip

AMDCGN_INSTRUMENTATION_FUNCTIONS_FILE?=../build/MemTraceInstrumentationKernel-hip-amdgcn-amd-amdhsa-gfx90a.bc

PASS_PLUGIN_PATH ?= ../build/libAMDGCNMemTrace.so

.PHONY: all
	

$(TARGET): $(TEST_FILE)
	@echo "Compiling $(TEST_FILE) to $(TARGET) for $(ARCH)"
	iree-compile --mlir-disable-threading --iree-hal-executable-debug-level=3 --iree-hal-target-device=$(DEVICE) --iree-hip-target=$(ARCH) $(TEST_FILE) -o $(TARGET)
	@echo "Compiling done"

all: $(TARGET)
	@echo "All done"

instrument: $(PASS_PLUGIN_PATH)
	@echo "Instrumenting $(TARGET)"
	export AMDCGN_INSTRUMENTATION_FUNCTIONS_FILE=$(AMDCGN_INSTRUMENTATION_FUNCTIONS_FILE) && \
	iree-compile --mlir-disable-threading --iree-hal-executable-debug-level=3 --iree-hal-target-device=$(DEVICE) --iree-hip-target=$(ARCH) $(TEST_FILE) -o $(TARGET) --iree-hip-pass-plugin-path=$(PASS_PLUGIN_PATH)
	@echo "Instrumenting done"

run:
	@echo "Running $(TARGET)"
	iree-run-module --device=$(DEVICE) --module=$(TARGET) --input="64x64xi16=1" --input="64x64xi16=2"
	@echo "Running done"

clean:
	rm -f $(TARGET)
	@echo "Clean done"