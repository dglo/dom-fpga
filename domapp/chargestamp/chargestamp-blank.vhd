-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : chargestamp.vhd
-- Author     : 
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-06-06
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides a charge stamp
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00    
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;


ENTITY chargestamp IS
    GENERIC (
        FADC_WIDTH : INTEGER := 10
        );
    PORT (
        CLK40       : IN  STD_LOGIC;
        RST         : IN  STD_LOGIC;
        systime     : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        -- FADC
        busy_FADC   : IN  STD_LOGIC;
        FADC_D      : IN  STD_LOGIC_VECTOR (FADC_WIDTH-1 DOWNTO 0);
        FADC_NCO    : IN  STD_LOGIC;
        FADC_addr   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        -- charege
        chargestamp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- test connector
        TC          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END chargestamp;

ARCHITECTURE arch_chargestamp OF chargestamp IS

BEGIN
    chargestamp <= (OTHERS=>'0');
END;
