-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : mem_interface.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-10-17
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module reads the ATWD/FADC and the compressed data and
--              writes it to the SDRAM
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-07  V01-01-00   thorsten  
-- 2005-04-04              thorsten  modified raw header data
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;


ENTITY mem_interface IS
    PORT (
        CLK20        : IN  STD_LOGIC;
        RST          : IN  STD_LOGIC;
        -- enable
        LBM_ptr      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- cdata interface A (ping)
        avail1k      : IN  STD_LOGIC;
        fifo_re      : OUT STD_LOGIC;
        fifo_data    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- ahb_master interface
        start_trans  : OUT STD_LOGIC;
        abort_trans  : OUT STD_LOGIC;
        address      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        ahb_address  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
        wdata        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
        wait_sig     : IN  STD_LOGIC;
        ready        : IN  STD_LOGIC;
        trans_length : OUT INTEGER;
        bus_error    : IN  STD_LOGIC;
        -- test connector
        TC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END mem_interface;

ARCHITECTURE mem_interface_arch OF mem_interface IS

    TYPE   STATE_TYPE IS (IDLE, CHECK_FORMAT, COMP_START, COMP_XFER, COMP_END, DONE);
    SIGNAL state : STATE_TYPE;

    SIGNAL compr_data    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL rdcnt         : STD_LOGIC_VECTOR(8 DOWNTO 0);
    SIGNAL start_address : STD_LOGIC_VECTOR(31 DOWNTO 0);

    SIGNAL LBM_ptr_byte : STD_LOGIC_VECTOR(31 DOWNTO 0);  -- Arthur wants a LWORD pointer


    CONSTANT xfer_size : INTEGER := 256;

    -- SDRAM look back memory
    CONSTANT SDRAM_SIZE : INTEGER                        := 24;  -- log2(size in bytes)
    CONSTANT SDRAM_MASK : STD_LOGIC_VECTOR (31 DOWNTO 0) := CONV_STD_LOGIC_VECTOR((2**SDRAM_SIZE)-1-3, 32);
    CONSTANT SDRAM_BASE : STD_LOGIC_VECTOR (31 DOWNTO 0) := X"01000000";

    
BEGIN

    address <= start_address + SDRAM_BASE;  -- SDRAM base address for look back memory

    -- changed back to byte pointer
    LBM_ptr <= (start_address AND X"0FFFF800") OR (ahb_address AND X"000007FF");

    xfer_machine : PROCESS(CLK20, RST)
    BEGIN
        IF RST = '1' THEN
            state         <= IDLE;
            start_address <= (OTHERS => '0');
            start_trans   <= '0';
            abort_trans   <= '0';
            rdcnt         <= (OTHERS => '0');
            fifo_re       <= '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN
            CASE state IS
                WHEN IDLE =>
                    start_trans <= '0';
                    abort_trans <= '0';
                    fifo_re     <= '0';
                    IF avail1k = '1' THEN
                        state <= CHECK_FORMAT;
                        --              start_trans             <= '1';
                    END IF;
                WHEN CHECK_FORMAT =>
                    state       <= COMP_XFER;
                    start_trans <= '1';
                    abort_trans <= '0';
                    rdcnt       <= (OTHERS => '0');
                    fifo_re     <= '0';
                WHEN COMP_START =>  -- start transfer if eng and compr gets written into LBM
                    start_trans <= '1';
                    abort_trans <= '0';
                    fifo_re     <= '0';
                    state       <= COMP_XFER;
                WHEN COMP_XFER =>
                    IF rdcnt = (xfer_size - 1) THEN
                        abort_trans <= '1';
                        fifo_re     <= '0';
                        IF ready = '1' AND wait_sig = '0' THEN  -- wait for AHB_master to finish
                            state <= COMP_END;
                        END IF;
                    ELSE
                        abort_trans <= '0';
                        IF wait_sig = '0' THEN
                            rdcnt   <= rdcnt+1;
                            fifo_re <= '1';
                        ELSE
                            fifo_re <= '0';
                        END IF;
                    END IF;
                    start_trans <= '0';
                WHEN COMP_END =>
                    state         <= DONE;
                    rdcnt         <= (OTHERS => 'X');
                    fifo_re       <= '0';
                    start_address <= start_address + xfer_size;
                    start_trans   <= '0';
                    abort_trans   <= '1';
                WHEN DONE =>
                    IF start_address(SDRAM_SIZE) = '1' THEN
                        NULL;
                    ELSIF ready = '1' AND wait_sig = '0' THEN
                        state <= IDLE;
                    END IF;
                    start_trans <= '0';
                    abort_trans <= '1';
                    fifo_re     <= '0';
                WHEN OTHERS =>
                    NULL;
            END CASE;

        END IF;
    END PROCESS;

    wdata <= fifo_data;

END mem_interface_arch;













