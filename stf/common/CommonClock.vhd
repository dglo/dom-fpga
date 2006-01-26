-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : .CommonClockvhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-01-25
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module emulates the latching of the systimer in the DOR
--              card for Bob Stokstad's common clokc test to verify local
--              coincidence
-------------------------------------------------------------------------------
-- Copyright (c) 2006
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2005-01-25  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


ENTITY CommonClock IS
    PORT (
        CLK20        : IN  STD_LOGIC;
        RST          : IN  STD_LOGIC;
        systime      : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        PPS          : IN  STD_LOGIC;
        systime_1PPS : OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
        TC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END CommonClock;

ARCHITECTURE CommonClock_arch OF CommonClock IS

    SIGNAL pps_x       : STD_LOGIC_VECTOR (4 DOWNTO 0);
    SIGNAL time_shl_en : STD_LOGIC;
    SIGNAL time_lat    : STD_LOGIC_VECTOR (47 DOWNTO 0);
    
BEGIN  -- CommonClock_arch

    -- If possible, I will try to copy Kalles code as close a possible and use the same names as kalle uses

-------------------------------------------------------------------------------
-- Code in comm_regs.tdf
-------------------------------------------------------------------------------

--    pps_[].clk = CLK_LOC;  -- synchronized PPS signal to avoid undefined state machine behavior
--    pps_[].clrn = !res_loc;
--
--    pps_[0].d = PPS;
--    pps_[1].d = pps_[0].q;
--    pps_[2].d = pps_[1].q;
--    pps_[3].d = pps_[2].q;
--
--    pps_[4].d = (pps_[3..1] ==B"011") # (pps_[3..1]==B"100");

    PROCESS (CLK20, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            pps_x <= (OTHERS => '0');
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            pps_x(0) <= PPS;
            pps_x(1) <= pps_x(0);
            pps_x(2) <= pps_x(1);
            pps_x(3) <= pps_x(2);

            -- only the leading edge of the modulated 1PPS
            IF pps_x(3 DOWNTO 1) = "011" THEN
                pps_x(4) <= '1';
            ELSE
                pps_x(4) <= '0';
            END IF;
        END IF;
    END PROCESS;


-------------------------------------------------------------------------------
-- Code in TSTRG_W2 state machine
-------------------------------------------------------------------------------

    PROCESS (CLK20, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            time_shl_en <= '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            time_shl_en <= NOT pps_x(4);
        END IF;
    END PROCESS;

-------------------------------------------------------------------------------
-- Code in GPS_tstrg_04
-------------------------------------------------------------------------------

    PROCESS (CLK20, RST)
    BEGIN  -- PROCESS CLK20
        IF RST = '1' THEN               -- asynchronous reset (active high)
            time_lat <= (OTHERS => '0');
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF time_shl_en = '1' THEN
                time_lat <= systime;
            END IF;
        END IF;
    END PROCESS;

-------------------------------------------------------------------------------
-- My code: present to registers
-------------------------------------------------------------------------------

    PROCESS (CLK20, RST)
        VARIABLE time_shl_en_delay : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            systime_1PPS      <= (OTHERS => '0');
            time_shl_en_delay := '1';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF time_shl_en_delay = '0' THEN
                systime_1PPS <= time_lat;
            END IF;
            time_shl_en_delay := time_shl_en;
        END IF;
    END PROCESS;
    
END CommonClock_arch;
