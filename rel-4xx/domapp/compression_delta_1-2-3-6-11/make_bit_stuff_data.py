"""
Make input data for bit_stuff using the map_word monitor file.
"""
from random_test2 import *

M = open(".\\py\\1\\fail_1_map_word_out.txt", 'rt').readlines()
fout1 = open("DX_input.txt", 'wt')
fout2 = open("BPS_input.txt", 'wt')

L = []

for d in M:
    L.append(d.strip())

fout1.write(str(len(L)) + "\n")
fout2.write(str(len(L)) + "\n")

for d in L:
    fout1.write(str(int(d, 2))+"\n")
    fout2.write(str(len(d))+"\n")

fout1.close()
fout2.close()

from random_test2 import *

bso = bit_stuff2(L)

for b in bso:
    print binary2hex(b)
