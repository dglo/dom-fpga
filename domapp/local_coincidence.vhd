-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : local_coincidence.vhd
-- Author     : yaver/thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-02-27
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Local Coincidence dummy
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-11-11  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
LIBRARY WORK;
USE WORK.ctrl_data_types.ALL;


ENTITY local_coincidence IS
    PORT (
        -- Common Inputs
        CLK20                : IN  STD_LOGIC;
        CLK40                : IN  STD_LOGIC;
        CLK80                : IN  STD_LOGIC;
        RST                  : IN  STD_LOGIC;
        systime              : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        -- slaveregister
        LC_ctrl              : IN  LC_STRUCT;
        -- DAQ interface
        lc_daq_trigger       : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_daq_abort         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_daq_disc          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_daq_launch        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- I/O
        COINCIDENCE_OUT_DOWN : OUT STD_LOGIC;
        COINC_DOWN_ALATCH    : OUT STD_LOGIC;
        COINC_DOWN_ABAR      : IN  STD_LOGIC;
        COINC_DOWN_A         : IN  STD_LOGIC;
        COINC_DOWN_BLATCH    : OUT STD_LOGIC;
        COINC_DOWN_BBAR      : IN  STD_LOGIC;
        COINC_DOWN_B         : IN  STD_LOGIC;
        COINCIDENCE_OUT_UP   : OUT STD_LOGIC;
        COINC_UP_ALATCH      : OUT STD_LOGIC;
        COINC_UP_ABAR        : IN  STD_LOGIC;
        COINC_UP_A           : IN  STD_LOGIC;
        COINC_UP_BLATCH      : OUT STD_LOGIC;
        COINC_UP_BBAR        : IN  STD_LOGIC;
        COINC_UP_B           : IN  STD_LOGIC;
        -- test
        TC                   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END local_coincidence;

architecture ARCH_local_coincidence of local_coincidence is

begin

	lc_daq_trigger	<= LC_ctrl.lc_tx_enable;
	lc_daq_abort	<= LC_ctrl.lc_rx_enable;

end ARCH_local_coincidence;


