-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : icetop_atwd_charge.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-10-16
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
        busy        : IN  STD_LOGIC;
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

    SIGNAL charg    : STD_LOGIC_VECTOR (16 DOWNTO 0);
    SIGNAL busy_old : STD_LOGIC;
    
BEGIN  -- icetop_atwd_charge_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            charg    <= (OTHERS => '0');
            busy_old <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            busy_old <= busy;
            IF busy = '1' AND busy_old = '0' THEN
                charg <= (OTHERS => '0');
            ELSE
                IF ATWD_WE = '1' THEN
                    IF ATWD_addr(8 DOWNTO 7) = channel_sel THEN
                        charg <= charg + ATWD_data;
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    charge(16 DOWNTO 0)  <= charg;
    charge(31 DOWNTO 17) <= (OTHERS => '0');

END icetop_atwd_charge_arch;
