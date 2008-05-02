-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : minimum_bias.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2008-04-30
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module counts the ATWD/FADC launches and vetoes LC of
--              every ~1000th launch to generate a full waveform readout.
--              veto_LC_A/B IS also TO be used TO flag the waveform
-------------------------------------------------------------------------------
-- Copyright (c) 2008
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten 
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY minimum_bias IS
    PORT (
        CLK               : IN  STD_LOGIC;
        RST               : IN  STD_LOGIC;
        -- enable
        enable            : IN  STD_LOGIC;
        -- ATWD launch link
        ATWDTrigger_A_sig : IN  STD_LOGIC;
        rst_trig_A        : IN  STD_LOGIC;
        LC_abort_A        : IN  STD_LOGIC;
        ATWDTrigger_B_sig : IN  STD_LOGIC;
        rst_trig_B        : IN  STD_LOGIC;
        LC_abort_B        : IN  STD_LOGIC;
        -- min bias hit tag
        minimum_bias_hit  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- LC veto
        veto_LC_A         : OUT STD_LOGIC;
        veto_LC_B         : OUT STD_LOGIC;
        -- test connector
        TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END minimum_bias;

ARCHITECTURE minimum_bias_arch OF minimum_bias IS

    CONSTANT CNT_RST : INTEGER   := 1;
    SIGNAL   hit_cnt : INTEGER RANGE 0 TO 1024;
    SIGNAL   last_A  : STD_LOGIC := '0';
    SIGNAL   do_next : STD_LOGIC := '0';

    SIGNAL veto_LC_A_int : STD_LOGIC;
    SIGNAL veto_LC_B_int : STD_LOGIC;

    SIGNAL ATWDTrigger_A_shift : STD_LOGIC;
    SIGNAL ATWDTrigger_B_shift : STD_LOGIC;

    
BEGIN  -- minimum_bias_arch

    veto_LC_A <= veto_LC_A_int;
    veto_LC_B <= veto_LC_B_int;

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            last_A        <= '0';
            hit_cnt       <= CNT_RST;
            do_next       <= '0';
            veto_LC_A_int <= '0';
            veto_LC_B_int <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            ATWDTrigger_A_shift <= ATWDTrigger_A_sig;
            ATWDTrigger_B_shift <= ATWDTrigger_B_sig;
            IF enable = '1' THEN
                -- count launches 
                IF (ATWDTrigger_A_sig = '1' AND ATWDTrigger_A_shift = '0') OR
                    (ATWDTrigger_B_sig = '1' AND ATWDTrigger_B_shift = '0') THEN
                    IF hit_cnt >= 1024 THEN
                        do_next <= '1';
                        hit_cnt <= CNT_RST;
                    ELSE
                        hit_cnt <= hit_cnt + 1;
                    END IF;
                END IF;
                -- alternating veto the LC abort for A and B
                IF do_next = '1' AND last_A = '0' THEN
                    IF ATWDTrigger_A_sig = '1' THEN
                        veto_LC_A_int <= '1';
                        -- if no LC abort, wait for the next hit
                        IF LC_abort_A = '1' THEN
                            last_A  <= '1';
                            do_next <= '0';
                        END IF;
                    END IF;
                END IF;
                IF do_next = '1' AND last_A = '1' THEN
                    IF ATWDTrigger_B_sig = '1' THEN
                        veto_LC_B_int <= '1';
                        -- if no LC abort, wait for the next hit
                        IF LC_abort_B = '1' THEN
                            last_A  <= '0';
                            do_next <= '0';
                        END IF;
                    END IF;
                END IF;
                -- reset the veto flag when we reset the ATWD
                IF rst_trig_A = '1' THEN
                    veto_LC_A_int <= '0';
                END IF;
                IF rst_trig_B = '1' THEN
                    veto_LC_B_int <= '0';
                END IF;
            ELSE
                -- enable = 0
                hit_cnt       <= CNT_RST;
                do_next       <= '0';
                veto_LC_A_int <= '0';
                veto_LC_A_int <= '0';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            minimum_bias_hit <= "00";
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            IF veto_LC_A_int = '1' AND LC_abort_A = '1' THEN
                minimum_bias_hit(0) <= '1';
            ELSIF rst_trig_A = '1' THEN
                minimum_bias_hit(0) <= '0';
            END IF;
            IF veto_LC_B_int = '1' AND LC_abort_B = '1' THEN
                minimum_bias_hit(1) <= '1';
            ELSIF rst_trig_B = '1' THEN
                minimum_bias_hit(1) <= '0';
            END IF;
        END IF;
    END PROCESS;

END minimum_bias_arch;
