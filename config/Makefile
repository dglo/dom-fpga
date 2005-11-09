all: fpga_versions.h iceboot.mif config.mif test.mif domapp.mif

fpga_versions.h: versions.tab mkhdr.awk common.awk
	awk -f common.awk -f mkhdr.awk < versions.tab > fpga_versions.h

iceboot.mif: versions.tab mkmif.awk common.awk iceboot.num
	gawk -f common.awk -f mkmif.awk -vbuild=`cat iceboot.num` \
		-vtype='iceboot' versions.tab > iceboot.mif 

config.mif: versions.tab mkmif.awk common.awk config.num
	gawk -f common.awk -f mkmif.awk -vbuild=`cat config.num` \
		-vtype='config' versions.tab > config.mif 

test.mif: versions.tab mkmif.awk common.awk test.num
	gawk -f common.awk -f mkmif.awk -vbuild=`cat test.num` \
		-vtype='test' versions.tab > test.mif 

domapp.mif: versions.tab mkmif.awk common.awk domapp.num
	gawk -f common.awk -f mkmif.awk -vbuild=`cat domapp.num` \
		-vtype='domapp' versions.tab > domapp.mif 

clean:
	rm -f fpga_versions.h iceboot.mif config.mif test.mif domapp.mif
