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
-- 2003-07-17  V01-01-00    
-------------------------------------------------------------------------------
-- Description: this module provides a charge stamp
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;USE IEEE.std_logic_unsigned.ALL;


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

COMPONENT charge_stamp_generator
    PORT
        (
            Clk40       : IN  STD_LOGIC;
            Rst         : IN  STD_LOGIC;
--              systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
--FADC
            Busy_Fadc   : IN  STD_LOGIC;
            Fadc_D      : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
--      FADC_NCO        : IN  STD_LOGIC;
            FADC_addr   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
-- charge
            ChargeStamp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

            PkRange        : OUT STD_LOGIC;
            PkSampleNumber : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
            FadcPrePeak    : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
            FadcPeak       : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
            FadcPostPeak   : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
------                  
-- test connector
            TC             : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
            );
	END COMPONENT;


BEGIN
	-- chargestamp <= (OTHERS=>'0');

	inst_charge_stamp_generator : charge_stamp_generator
	    PORT MAP
	        (
	            Clk40       => CLK40,
	            Rst         => RST,
	--              systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
	--FADC
	            Busy_Fadc   => busy_FADC,
	            Fadc_D      => FADC_D,
	--      FADC_NCO        : IN  STD_LOGIC;
	            FADC_addr   => FADC_addr,
	-- charge
	            ChargeStamp => chargestamp,
	
	            PkRange        => open,
	            PkSampleNumber => open,
	            FadcPrePeak    => open,
	            FadcPeak       => open,
	            FadcPostPeak   => open,
	------                  
	-- test connector
	            TC             => open
        );

END;
