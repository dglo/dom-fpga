fpga_versions.h: versions.tab mkhdr.awk
	awk -f mkhdr.awk < versions.tab > fpga_versions.h

clean:
	rm -f fpga_versions.h
