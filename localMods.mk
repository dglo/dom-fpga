BUILT_FILES += $(BUILD_DIR)/$(PUB_DIR_NAME)/dom-fpga/fpga-versions.h

ifeq ("epxa10","$(strip $(PLATFORM))")
  SIMPLETEST_SBI_FILE := resources/$(PLATFORM)/$(shell  cat resources/$(PLATFORM)/simpletest-sbi.txt)
  BIN_EXES += $(BIN_DIR)/iceboot.sbi.gz $(BIN_DIR)/stf.sbi.gz $(BIN_DIR)/domapp.sbi.gz
endif

