-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : delta_calc.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-03-21
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module reads the FADC and ATWD data and then computes the
--              deltas. The modeule employes a "look ahead" for speed reasons.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-03-    V01-01-00   thorsten  
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY delta_calc IS
    PORT (
        CLK         : IN  STD_LOGIC;
        RST         : IN  STD_LOGIC;
        -- control
        next_wf     : IN  STD_LOGIC;
        FADC_nATWD  : IN  STD_LOGIC;
        ATWD_CH     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        wf_done     : OUT STD_LOGIC;
        -- to delta encoder
        delta_avail : OUT STD_LOGIC;
        delta       : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        next_delta  : IN  STD_LOGIC;
        -- raw data buffer interface
        atwd_addr   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        atwd_data   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        fadc_addr   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        fadc_data   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END delta_calc;

ARCHITECTURE delta_calc_arch OF delta_calc IS

    TYPE   state_type IS (ADDR0, ADDR1, ADDR2, ADDRx, IDLE);
    SIGNAL state : state_type;

    SIGNAL addr_cnt    : STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL sample      : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL last_sample : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL wf_end      : STD_LOGIC;

    SIGNAL fadc_data_word : STD_LOGIC_VECTOR (9 DOWNTO 0);
    SIGNAL atwd_data_word : STD_LOGIC_VECTOR (9 DOWNTO 0);

BEGIN  -- delta_arch


    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            addr_cnt <= (OTHERS=>'0');
            delta <= (OTHERS=>'0');
            state <= IDLE;
        ELSIF CLK'EVENT AND CLK = '0' THEN           -- falling clock edge
            CASE state IS
                WHEN ADDR0 =>
                    addr_cnt    <= (OTHERS => '0');
                    last_sample <= (OTHERS => '0');
                    delta_avail <= '0';
                    state       <= ADDR1;
                WHEN ADDR1 =>
                    addr_cnt    <= addr_cnt + 1;
                    last_sample <= (OTHERS => '0');
                    delta_avail <= '0';
                    delta       <= '0'&sample;
                    state       <= ADDR2;
                WHEN ADDR2 =>
                    addr_cnt    <= addr_cnt + 1;
                    last_sample <= sample;
                    delta_avail <= '0';
                    delta       <= '0'&sample;
                    state       <= ADDRx;
                WHEN ADDRx =>
                    delta_avail <= '1';
                    IF wf_end = '1' THEN
                        state       <= IDLE;
                        delta_avail <= '0';
                    ELSIF next_delta = '1' THEN
                        addr_cnt    <= addr_cnt + 1;
                        last_sample <= sample;
                        delta       <= ('0'&sample) -('0'&last_sample);
                    END IF;
                WHEN IDLE =>
                    addr_cnt    <= (OTHERS => '0');
                    last_sample <= (OTHERS => '0');
                    delta_avail <= '0';
                WHEN OTHERS =>
                    NULL;
            END CASE;
            IF next_wf = '1' THEN
                delta_avail <= '0';
                state       <= ADDR0;
            END IF;
        END IF;
    END PROCESS;

    -- debugging!!! use only a few samples, makes it easier on paper
--  wf_end <= '1' WHEN addr_cnt(7 DOWNTO 0) = "00001001" AND FADC_nATWD = '1' ELSE
--              '1' WHEN addr_cnt(6 DOWNTO 0) = "0001001" AND FADC_nATWD = '0' AND state = ADDRx ELSE
--              '0';                      -- placeholder

    -- correct
    wf_end <= '1' WHEN addr_cnt(7 DOWNTO 0) = "00000001" AND FADC_nATWD = '1' ELSE
              '1' WHEN addr_cnt(6 DOWNTO 0) = "0000001" AND FADC_nATWD = '0' ELSE --
              --AND state=ADDRx ELSE
              '0';                      -- placeholder

    wf_done <= wf_end WHEN state = ADDRx ELSE '0';

    -- select the current data sample
    fadc_data_word <= fadc_data (9 DOWNTO 0) WHEN addr_cnt(0) = '0' ELSE fadc_data (25 DOWNTO 16);
    atwd_data_word <= atwd_data (9 DOWNTO 0) WHEN addr_cnt(0) = '0' ELSE atwd_data (25 DOWNTO 16);

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            sample <= (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '0' THEN  -- falling clock edge
            IF next_delta = '1' OR state = ADDR1 OR state = ADDR2 THEN
                IF FADC_nATWD = '1' THEN
                    sample <= fadc_data_word;
                ELSE
                    sample <= atwd_data_word;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    fadc_addr <= addr_cnt (7 DOWNTO 1);
    atwd_addr <= ATWD_CH&addr_cnt (6 DOWNTO 1);

END delta_calc_arch;


