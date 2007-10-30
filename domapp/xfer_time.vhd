-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : xfer_time.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-07-20
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module measures the time required to transfer waveform
--              data from the FPGA buffers to the external LBM
--              This is debug code to get performance information
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;



ENTITY xfer_time IS
    PORT (
        CLK20      : IN  STD_LOGIC;
        RST        : IN  STD_LOGIC;
        -- the info
        enable_DAQ : IN  STD_LOGIC;
        xfer_eng   : IN  STD_LOGIC;
        xfer_compr : IN  STD_LOGIC;
        -- the xfer time
        AHB_load   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- test comnnector
        TC         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END xfer_time;

ARCHITECTURE xfer_time_arch OF xfer_time IS

BEGIN  -- xfer_time_arch

    -- for xfer_eng
    PROCESS (CLK20, RST)
        VARIABLE eng_cnt        : INTEGER RANGE 0 TO 65535;
        VARIABLE max_cnt        : INTEGER RANGE 0 TO 65535;
        VARIABLE enable_DAQ_old : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            max_cnt        := 0;
            eng_cnt        := 0;
            enable_DAQ_old := '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF enable_DAQ = '1' AND enable_DAQ_old = '0' THEN
                max_cnt := 0;
                eng_cnt := 0;
            ELSIF enable_DAQ = '1' THEN
                IF xfer_eng = '1' THEN
                    IF eng_cnt < 65535 THEN
                        eng_cnt := eng_cnt + 1;
                    END IF;

                    IF eng_cnt > max_cnt THEN
                        max_cnt := eng_cnt;
                    END IF;
                ELSE
                    eng_cnt := 0;
                END IF;
            ELSE
                eng_cnt := 0;
                max_cnt := max_cnt;
            END IF;
            enable_DAQ_old         := enable_DAQ;
            AHB_load (15 DOWNTO 0) <= CONV_STD_LOGIC_VECTOR(max_cnt, 16);
        END IF;
    END PROCESS;

    -- for xfer_compr
    PROCESS (CLK20, RST)
        VARIABLE compr_cnt      : INTEGER RANGE 0 TO 65535;
        VARIABLE max_cnt        : INTEGER RANGE 0 TO 65535;
        VARIABLE enable_DAQ_old : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            max_cnt        := 0;
            compr_cnt      := 0;
            enable_DAQ_old := '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF enable_DAQ = '1' AND enable_DAQ_old = '0' THEN
                max_cnt   := 0;
                compr_cnt := 0;
            ELSIF enable_DAQ = '1' THEN
                IF xfer_compr = '1' THEN
                    IF compr_cnt < 65535 THEN
                        compr_cnt := compr_cnt + 1;
                    END IF;

                    IF compr_cnt > max_cnt THEN
                        max_cnt := compr_cnt;
                    END IF;
                ELSE
                    compr_cnt := 0;
                END IF;
            ELSE
                compr_cnt := 0;
                max_cnt   := max_cnt;
            END IF;
            enable_DAQ_old          := enable_DAQ;
            AHB_load (31 DOWNTO 16) <= CONV_STD_LOGIC_VECTOR(max_cnt, 16);
        END IF;
    END PROCESS;

END xfer_time_arch;
