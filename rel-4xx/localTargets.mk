$(BUILD_DIR)/$(PUB_DIR_NAME)/dom-fpga/fpga-versions.h : scripts/sdata.txt scripts/tdata.txt
	@test -d $(@D) || mkdir -p $(@D)
	(cd scripts; ./mkhdr.sh > ../$@)

$(BIN_DIR)/iceboot.sbi.gz : $(SIMPLETEST_SBI_FILE)
	gzip -c $(<) > $(@)

$(BIN_DIR)/stf.sbi.gz : $(SIMPLETEST_SBI_FILE)
	gzip -c $(<) > $(@)

$(BIN_DIR)/domapp.sbi.gz : $(SIMPLETEST_SBI_FILE)
	gzip -c $(<) > $(@)
