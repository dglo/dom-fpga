$(BUILD_DIR)/$(PUB_DIR_NAME)/dom-fpga/fpga-versions.h : scripts/sdata.txt scripts/tdata.txt
	@test -d $(@D) || mkdir -p $(@D)
	(cd scripts; ./mkhdr.sh > ../$@)
