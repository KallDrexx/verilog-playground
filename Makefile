VERILOG_DIR := verilog
OUT_DIR     := out

# --- FPGA Verilog Lookup Table ---
video_test_pattern.TOP  := nandland_go_video_test_pattern
video_test_pattern.FILE := video_test_pattern
video_test_pattern.PCF  := constraints/nandland-default.pcf

.PHONY: help
help:
	@echo "Usage: make <target> [KEY=<verilog_project>]"
	@echo ""
	@echo "Simulation:"
	@echo "  sim_build              Build the simulation with CMake (Debug mode)"
	@echo "  sim_test_pattern       Run the test pattern simulation"
	@echo ""
	@echo "FPGA (requires KEY=<verilog_project>):"
	@echo "  fpga_build             Synthesize Verilog with Yosys -> .json"
	@echo "  fpga_pnr               Place and route with nextpnr -> .asc"
	@echo "  fpga_pack              Pack bitstream with icepack -> .bin"
	@echo "  fpga_full_build        Run fpga_build + fpga_pnr + fpga_pack"
	@echo "  fpga_deploy            Flash bitstream to FPGA with iceprog"
	@echo ""
	@echo "Available KEY values:"
	@echo "  video_test_pattern     Nandland GO board video test pattern"
	@echo ""
	@echo "Examples:"
	@echo "  make sim_build"
	@echo "  make fpga_full_build KEY=video_test_pattern"
	@echo "  make fpga_deploy KEY=video_test_pattern"

.PHONY: build
sim_build:
	cmake -DCMAKE_BUILD_TYPE=Debug -S sim -B sim/cmake-build-debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build sim/cmake-build-debug --target all -j ${shell nproc}

sim_test_pattern: build
	sim/cmake-build-debug/test_pattern

$(OUT_DIR):
	mkdir -p $(OUT_DIR)

.PHONY: fpga_build
fpga_build: $(OUT_DIR)
ifndef KEY
	$(error Usage: make fpga_build KEY=<verilog_project>)
endif
	yosys -p "synth_ice40 -top $($(KEY).TOP) -json $(OUT_DIR)/$($(KEY).FILE).json" $(VERILOG_DIR)/$($(KEY).FILE).v

.PHONY: fpga_pnr
fpga_pnr:
ifndef KEY
	$(error Usage: make fpga_pnr KEY=<verilog_project>)
endif
	nextpnr-ice40 \
	    --hx1k \
	    --package vq100 \
	    --json  $(OUT_DIR)/$($(KEY).FILE).json \
	    --pcf   $($(KEY).PCF) \
	    --asc   $(OUT_DIR)/$($(KEY).FILE).asc \
	    --freq  25

.PHONY: fpga_pack
fpga_pack:
ifndef KEY
	$(error Usage: make fpga_pack KEY=<verilog_project>)
endif
	icepack $(OUT_DIR)/$($(KEY).FILE).asc $(OUT_DIR)/$($(KEY).FILE).bin

.PHONY: fpga_full_build
fpga_full_build:
ifndef KEY
	$(error Usage: make fpga_full_build KEY=<verilog_project>)
endif
	$(MAKE) fpga_build KEY=$(KEY)
	$(MAKE) fpga_pnr KEY=$(KEY)
	$(MAKE) fpga_pack KEY=$(KEY)

.PHONY: fpga_deploy
fpga_deploy:
ifndef KEY
	$(error Usage: make fpga_deploy KEY=<verilog_project>)
endif
	iceprog $(OUT_DIR)/$($(KEY).FILE).bin
