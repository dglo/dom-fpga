-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : disc_in_ATWD.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-05-25
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module checks if the discriminator fired while the ATWD
--              acquired data. The code will err on fase positives as it is
--              used to find pedestal waveforms with accidental pulses.
-------------------------------------------------------------------------------
-- Copyright (c) 2007
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2007-05-17              thorsten  initial code
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY disc_in_ATWD IS
    PORT (
        CLK               : IN  STD_LOGIC;
        RST               : IN  STD_LOGIC;
        -- ATWD status
        ATWDtrigger       : IN  STD_LOGIC;
        TriggerComplete   : IN  STD_LOGIC;
        -- disc status
        SPE_level_stretch : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- status OUT
        ATWD_disc_status  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test connector
        TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END disc_in_ATWD;

ARCHITECTURE disc_in_ATWD_arch OF disc_in_ATWD IS

    SIGNAL ATWDtrigger_old : STD_LOGIC;

    SIGNAL cnt_win  : INTEGER RANGE 0 TO 3;
    
BEGIN  -- disc_in_ATWD_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            ATWDtrigger_old <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            ATWDtrigger_old <= ATWDtrigger;

            -- post acq window
            IF ATWDtrigger = '1' AND TriggerComplete = '1' THEN
                cnt_win <= 3;
            ELSIF cnt_win = 0 THEN
                cnt_win <= cnt_win;
            ELSE
                cnt_win <= cnt_win - 1;
            END IF;

            -- bit 0: SPE; bit 1: MPE
            FOR disc IN 0 TO 1 LOOP
                IF ATWDtrigger = '1' AND ATWDtrigger_old = '0' THEN
                    -- clear status; we have a new launch
                    ATWD_disc_status(disc) <= '0';
                    IF SPE_level_stretch(disc) = '1' THEN  --cnt_disc(disc) /= 0 THEN
                        ATWD_disc_status(disc) <= '1';
                    ELSE
                        ATWD_disc_status(disc) <= '0';
                    END IF;
                ELSIF cnt_win /= 0 THEN
                    -- ATWD is acquiring
                    IF SPE_level_stretch(disc) = '1' THEN  --cnt_disc(disc) /= 0 THEN
                        ATWD_disc_status(disc) <= '1';
                    END IF;
                END IF;
            END LOOP;  -- disc
        END IF;
    END PROCESS;

END disc_in_ATWD_arch;





























