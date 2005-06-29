-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : atwd_timestamp.vhd
-- Author     : jkelley
-- Company    : UW-Madison
-- Created    : 
-- Last update: 2003-08-01
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module registers the system time using the triggers from
--              each ATWD as a timestamp for the waveform.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-01  V01-01-00   jkelley
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd_timestamp IS
	PORT (
		CLK40		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
        -- ATWD triggers
        atwd0_trigger   : IN    STD_LOGIC;
        atwd1_trigger   : IN    STD_LOGIC;        
        -- system time
		systime			: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
        -- timestamps
		atwd0_timestamp : OUT	STD_LOGIC_VECTOR(47 DOWNTO 0);
		atwd1_timestamp : OUT	STD_LOGIC_VECTOR(47 DOWNTO 0)
	);
END atwd_timestamp;


ARCHITECTURE arch_atwd_timestamp OF atwd_timestamp IS

  SIGNAL atwd0_trigger_last : STD_LOGIC;
  SIGNAL atwd1_trigger_last : STD_LOGIC;    

BEGIN
	
  PROCESS(CLK40,RST)
  BEGIN
    IF RST='1' THEN
      atwd0_timestamp <= (OTHERS => '0');
      atwd1_timestamp <= (OTHERS => '0');
            
    ELSIF CLK40'EVENT AND CLK40='1' THEN

      IF atwd0_trigger='1' AND atwd0_trigger_last='0' THEN
        atwd0_timestamp <= systime;        
      END IF;

      IF atwd1_trigger='1' AND atwd1_trigger_last='0' THEN
        atwd1_timestamp <= systime;
      END IF;      

      -- Register trigger for edge detection
      atwd0_trigger_last <= atwd0_trigger;
      atwd1_trigger_last <= atwd1_trigger;
      
    END IF;
  END PROCESS;

END;
