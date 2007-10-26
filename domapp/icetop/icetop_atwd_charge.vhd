-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : icetop_atwd_charge.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-09-24
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module is specific for IceTop. It sums up all samples of
--              a given ATWD channel. This represents the charge information
--              for this ATWD channel.
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-10-16  V01-01-00   thorsten
-- 2007-09-14              thorsten  updated to real requirements
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY icetop_atwd_charge IS
    PORT (
        CLK         : IN  STD_LOGIC;
        RST         : IN  STD_LOGIC;
        -- setup
        channel_sel : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        -- ATWD data
        ATWD_WE     : IN  STD_LOGIC;
        ATWD_data   : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
        ATWD_addr   : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
        -- charge
        charge      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- test connector
        TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END icetop_atwd_charge;

ARCHITECTURE icetop_atwd_charge_arch OF icetop_atwd_charge IS

    SIGNAL charg            : STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL chan             : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL chan_old         : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL channel          : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL chan_change_flag : STD_LOGIC;
    
BEGIN  -- icetop_atwd_charge_arch

    chan <= ATWD_addr(8 DOWNTO 7);

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            charg            <= (OTHERS => '0');
            chan_old         <= "00";
            channel          <= "00";
            chan_change_flag <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            IF ATWD_WE = '1' AND chan <= channel_sel THEN
                IF chan_change_flag = '1' THEN
                    charg <= "0000000" & ATWD_data;
                ELSE
                    charg <= charg + ATWD_data;
                END IF;
                channel          <= chan;
                chan_change_flag <= '0';
            END IF;

            IF chan /= chan_old THEN
                chan_change_flag <= '1';
            END IF;
            chan_old <= chan;
        END IF;
    END PROCESS;

    charge(16 DOWNTO 0)  <= charg;
    charge(18 DOWNTO 17) <= channel;
    charge(31 DOWNTO 19) <= (OTHERS => '0');

END icetop_atwd_charge_arch;









