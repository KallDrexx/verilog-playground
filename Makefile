VERILOG_DIR := verilog
OUT_DIR     := out

# --- FPGA Verilog Lookup Table ---
video_test_pattern.TOP  := nandland_go_video_test_pattern
video_test_pattern.FILE := video_test_pattern
video_test_pattern.PCF  := constraints/nandland-default.pcf

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

.PHONY: fpga_deploy
fpga_deploy:
ifndef KEY
	$(error Usage: make fpga_deploy KEY=<verilog_project>)
endif
	iceprog $(OUT_DIR)/$($(KEY).FILE).bin
