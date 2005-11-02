#!/bin/bash

#
# layout of file (everything is a 16bit word):
#   fpga_type (from current dir fpga_type file...)
#   build_num0 (from current dir build_num file...)
#   build_num1 (from current dir build_num file...)
#   versions:
#      1: com_fifo
#      2: com_dp
#      3: daq (atwd, fadc)
#      4: pulsers
#      5: discriminator_rate
#      6: local_coinc
#      7: flasher_board
#      8: trigger
#      9: local_clock
#     10: supernova
#     11: unassigned
#     12: unassigned
#     13: unassigned
#     14: unassigned
#     15: unassigned
#     16: unassigned
#
