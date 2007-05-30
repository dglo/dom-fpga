"""
IceCube
Delta Compressor Development Support Program
---------------------------------------------

Assume that all vhdl design files are under
    C:\altera\proj\compr_module
and there is an empty data directory
    C:\altera\proj\compr_module\py\1

Run this program from the command prompt.  Answer 'yes' to select the
default file names.  Whenever there is a mismatch between the simulated
result and the expected result, a set of files are created in the data
directory.

Platform: Windows
File    : random_test.py
Created : 10/4/2005
Last    : 11/7/2005
Author  : Nobuyoshi Kitamura
"""

# ---------------------------------------------------------------------
# --    Globals (= default value)
# ---------------------------------------------------------------------
# Modify the following constants only in the main module

CHANNEL_LENGTH          = 64        # No. of HiWord LowWord pair
RANDOM_THRESHOLD        = 0.5       # For mapping uniform random [0,1] to {'0','1'}
CREATE_RANDOM_INPUT     = True      # Otherwise reads in a data file
MONITOR_ON              = True      # Create intermediate result files with the names below:
MAP_WORD_EXPTCTED_FILE  = 'map_word_expected.txt'        
DELTA_EXPECTED_FILE     = 'delta_expected.txt'
SRC_DIRECTORY           = 'c:\\altera\\proj\\compr_module\\'
WORK_DIRECTORY          = SRC_DIRECTORY + 'py\\1\\'
BS_RESIDUE              = -1        # No. of padded zeros at the end of bit_stuff

# ---------------------------------------------------------------------
# --    Utility functions
# ---------------------------------------------------------------------

def conv(x):
    """
    Convert a string representing an integer into a binary integer
    """
    return int(x,2)


def reverstr(s):
    """
    Reverse the input string
    """
    ss = ''
    n = len(s)
    for i in range(n):
        ss = s[i]+ss
    return ss


def str_copy(s1, s2, i, j):
    """
    Copy s2 into s1 starting at bit i and ending at bit j (j >= i)
    s1 = [                 ]
    s2 =    [     ]
             ^   ^
             i   j
    """
    for k in range(i, j+1):
        s1[k] = s2[k-i]
    return s1


def list2str(L):
    """
    Create a string by concatenating the list elements
    """
    s = ''
    for x in L:
        s += x
    return s


def dec2binary(x,n):
    """
    Convert integer x to an n-bit binary string
    """
    y = x
    s = ''
    for i in range(n-1, -1, -1): # [n-1, n-2, ..., 0]
        if y / 2**i:
            y -= 2**i
            s = s + '1'
        else:
            s = s + '0'
    return s


def binary2hex(b):
    """
    Convert a binary string to a hexadecimal string
    """
    h = ''
    for i in range(len(b)/4):
        x = b[4*i:4*i+4]
        if x == '0000':
            h += '0'
        elif x == '0001':
            h += '1'
        elif x == '0010':
            h += '2'
        elif x == '0011':
            h += '3'
        elif x == '0100':
            h += '4'
        elif x == '0101':
            h += '5'
        elif x == '0110':
            h += '6'
        elif x == '0111':
            h += '7'
        elif x == '1000':
            h += '8'
        elif x == '1001':
            h += '9'
        elif x == '1010':
            h += 'a'
        elif x == '1011':
            h += 'b'
        elif x == '1100':
            h += 'c'
        elif x == '1101':
            h += 'd'
        elif x == '1110':
            h += 'e'
        elif x == '1111':
            h += 'f'

    return h


def add_leading_zeros(s, n):
    """
    Prepend zeros to the input string s to make it n bits wide
    """
    if len(s) < n:
        return '0'*(n - len(s)) + s
    else:
        return s


def read_data32(fn):
    """
    fn is a file containing the 32-bit input words that are arranged such
    that each word contains two sample data.
    Returns a list [lo(0), hi(0), lo(1), hi(1), ...], assuming that [hi(n), lo(n)] is
    the n-th input word.
    """
    f = open(fn, "rt")
    data = []
    for L in f.readlines():
        hilo = L.strip()
        hi = hilo[0:16]
        lo = hilo[16:32]
        data.append(conv(lo))
        data.append(conv(hi))
    f.close()
    return data


def _convert(x,n):
    """
    Convert integer x into a n-bit representation defined in map_word.vhd
    [][  abs(x) in n-1 bits   ]
     ^ sign bit
    """
    xx = abs(x)
    v = []
    for i in range(n-2, -1, -1):
        d = xx/2**i
        v.append(d)
        xx = xx - d*2**i
    if x>=0:
        v = [0] + v
    else:
        v = [1] + v
    s = ''
    for i in v:
        s = s + str(i)
    return s


# ---------------------------------------------------------------------
# --    make_dela
# ---------------------------------------------------------------------

def make_delta(data):
    """
    Create delta's from the inupt vector
    """
    delta = [data[0]]
    for i in range(len(data)-1):
        delta.append(data[i+1] - data[i])

    if MONITOR_ON:
        cc = []
        for c in delta:
            cc.append(str(c)+"\n")
        open(DELTA_EXPECTED_FILE, 'wt').writelines(cc)

    return delta
    


# ---------------------------------------------------------------------
# --    map_word.vhd
# ---------------------------------------------------------------------


def map_word(delta):
    """
    Create a list containing the encoded output.
    """

    code = []
    state_next = 's3'
    i = 0
    while i < len(delta):
        state = state_next
        x = delta[i]
        if state == 's1':
            if x==0:
                code.append("0")
                state_next = 's1'
                i += 1
            else:
                code.append("1")
                state_next = 's2'
        elif state == 's2':
            if x==0:
                code.append(_convert(x,2))
                state_next = 's1'
                i += 1
            elif abs(x)<=1:
                code.append(_convert(x,2))
                state_next = 's2'
                i += 1
            else:
                code.append("10")
                state_next = 's3'
        elif state == 's3':
            if abs(x)<=1:
                code.append(_convert(x,3))
                state_next = 's2'
                i += 1
            elif abs(x)>1 and abs(x)<4:
                code.append(_convert(x,3))
                state_next = 's3'
                i += 1            
            else:
                code.append("100")
                state_next = 's6'
        elif state == 's6':
            if abs(x)<=3:
                code.append(_convert(x,6))
                state_next = 's3'
                i += 1
            elif abs(x)>=4 and abs(x)<=31:
                code.append(_convert(x, 6))
                state_next = 's6'
                i += 1
            else:
                code.append("100000")
                state_next = 's11'
        elif state == 's11':
            if abs(x)<=31:
                code.append(_convert(x,11))
                state_next = 's6'
                i += 1
            else:
                code.append(_convert(x,11))
                state_next = 's11'
                i += 1

    if MONITOR_ON:
        cc = []
        for c in code:
            cc.append(c+"\n")
        open(MAP_WORD_EXPTCTED_FILE, 'wt').writelines(cc)
    return code


# ---------------------------------------------------------------------
# --    bit_stuff.vhd
# ---------------------------------------------------------------------

def bit_stuff(code):
    """
    Stuff the bits into 32-bit words
    """
    out = []
    s = ''
    for cc in code:
        s = cc + s

    n = len(s)
    N = n / 32
    R = n % 32
    for i in range(N):
        out.append( s[n - 32*(i + 1) : n - 32*i] )

    global BS_RESIDUE
    BS_RESIDUE = R

    if R != 0:  # Bug fix -- this was needed!!!
        out.append('0'*(32-R) + s[0: R])
    return out


# ---------------------------------------------------------------------
# --    Random data functions
# ---------------------------------------------------------------------

import random

def my_random():
    if random.randrange(0,2) > RANDOM_THRESHOLD:
        return 1
    else:
        return 0

def make_random32():
    """
    Return a random 32-bit binary string
    """
    s = ''
    for i in range(32):
        s = s + str(my_random())
    return s
    
def make_random32_file(fn, n):
    """
    Create a file named fn, containing n lines of random32 words 
    """
    f = open(fn, 'wt')
    for i in range(n):
        f.write(make_random32()+'\n')
    f.close()


def make_random_test(binary_in, integer_out, expected_out):
    """
    Read the file binary_in containing lines of random32 words
    and create:
    (1) integer_out, containing the binary values converted to integer
    (2) expected_out, containing expected encoded words in hex
    Create a file named fn, containing n lines of integers
    each representing a random 32-bit binary value.
    """
    f = open(binary_in, 'rt')
    g = open(integer_out, 'wt')
    h = open(expected_out, 'wt')
    eof = False
    n = -1
    while (not eof):
        n += 1
        data = []
        for i in range(CHANNEL_LENGTH):
            s = f.readline()
            s = s.strip()
            eof = s==''
            if not eof:
                hilo = s
                hi = "000000"+hilo[0:10]
                lo = "000000"+hilo[16:26]
                hilo = hi+lo
                data.append(conv(lo))
                data.append(conv(hi))
                g.write(str(int(hilo,2))+'\n')
        
        if not eof:
            h.write("OUT["+str(n)+"]\n")
            encoded = bit_stuff(map_word(make_delta(data)))
            for c in encoded:
                h.write(binary2hex(c)+'\n');

    f.close()
    g.close()
    h.close()


def compare_results(python_expected, vhdl_expected):
    """
    Returns true iff the two files are identical
    """
    f = open(python_expected, 'rt')
    g = open(vhdl_expected, 'rt')
    len1 = len(f.readlines())
    len2 = len(g.readlines())
    if len1 != len2:
        print "=== Error: Unequal file size ==="
        print "\tpython: " + str(len1) + " words"
        print "\t  vhdl: " + str(len2) + " words"
        return False
    f.close()
    g.close()
    f = open(python_expected, 'rt')
    g = open(vhdl_expected, 'rt')
    
    i = -1
    while(True):
        i += 1
        fs = f.readline()
        gs = g.readline()
        fs = fs.strip()
        gs = gs.strip()
        if fs=='' or gs=='':
            break
        else:
            ans = (fs == gs)
            if not ans:
                print "=== Error["+str(i)+"] ==="
                print "\tpython: ", fs
                print "\tvhdl  : ", gs
                break
    return ans
    


if __name__ == "__main__":

    import sys
    import os

    print "--- " + sys.argv[0] + " ---"

# Override the global constant values here.    
    CHANNEL_LENGTH = 192        # No. of input words
    NUMBER_OF_RECORDS = 1000    # How many sets of input channel data?
    RANDOM_THRESHOLD = 0.5
    CREATE_RANDOM_INPUT = True
    MONITOR_ON = True
    
    f1 = 'random_binary.txt'    # 32-bit input words 0..CHANNEL_LENGTH-1
    f2 = 'random_integer.txt'   # f1 contents converted to long integers
    f3 = 'random_expected.txt'  # Expected output by this program
    f4 = 'random_simulated.txt' # Simulated elsewhere to be compared with f3

    f = open('random_test_dump.txt', 'wt')
    f.close()

    fail_count = 0

    for RANDOM_THRESHOLD in [0.1, 0.25, 0.5, 0.75, 0.9]:
        f = open('random_test_dump.txt', 'at')
        f.write("RANDOM_THRESHOLD = " + str(RANDOM_THRESHOLD) + "\n")
        f.close()

        for run_number in range(1, NUMBER_OF_RECORDS + 1):
            print "\n--- Run # " + str(run_number) + "---"
            
            if CREATE_RANDOM_INPUT:
                print "Creating random data..."
                make_random32_file(f1, CHANNEL_LENGTH)
                print "...done"

            print "Computing expected output..."
            make_random_test(f1, f2, f3)
            print "...done"
            print "Running simulation..."

    # Run ModelSim from the command line.  Before running this, you must have
    # a macro random_test.do that runs the simulation for a sufficiently long
    # period of time, terminates, and then exists.  All the screen output of the
    # simulation is written to temp and discarded.
            os.system("vsim -c -do random_test.do work.compress_channel_tb3 > temp")
            print "...done"

            f = open('random_test_dump.txt', 'at')
            print "R = " + str(BS_RESIDUE)

            ans = compare_results(f3, f4)
            if ans:
                print "=== Sucess ! ==="
                f.write("Run[" + str(run_number) + "] : success" + " R = " + str(BS_RESIDUE) + "\n")
            else:
                import winsound
                winsound.PlaySound('SystemExclamation', winsound.SND_ALIAS)
                print "=== There are errors ==="
                f.write("Run[" + str(run_number) + "] : failure\n")
                fail_count += 1
                os.system('copy ' + f1 + ' ' + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_' + f1)
                os.system('copy ' + f2 + ' ' + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_' + f2)
                os.system('copy ' + f3 + ' ' + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_' + f3)
                os.system('copy ' + f4 + ' ' + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_' + f4)
                os.system('copy map_word_expected.txt ' + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_map_word_expected.txt')
                os.system('copy map_word_out.txt '      + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_map_word_out.txt')
                os.system('copy delta_expected.txt '    + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_delta_expected.txt')
                os.system('copy delta_out.txt '         + WORK_DIRECTORY + 'fail_' + str(fail_count) + '_delta_out.txt')

            f.close()
