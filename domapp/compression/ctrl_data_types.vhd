------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ctrl_data_types.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-01-08
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This package defines data structures for used for control
--              (slaveregister)
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-01-08  V01-01-00   thorsten  
-- 2004-07-01              thorsten  added COMPR_STRUCT
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;

PACKAGE ctrl_data_types IS

	-- control data for the DAQ module
	TYPE DAQ_STRUCT IS
		RECORD
			enable_DAQ		: STD_LOGIC;
			enable_AB		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			trigger_enable		: STD_LOGIC_VECTOR (15 DOWNTO 0);
			ATWD_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			LC_mode			: STD_LOGIC_VECTOR (1 DOWNTO 0);
			DAQ_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			LBM_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			COMPR_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			LBM_ptr_RST		: STD_LOGIC;
		END RECORD;
		
	-- control data for the CalibrationSource module
	TYPE CS_STRUCT IS
		RECORD
			CS_enable		: STD_LOGIC_VECTOR (5 DOWNTO 0);
			CS_mode			: STD_LOGIC_VECTOR (2 DOWNTO 0);
			CS_time			: STD_LOGIC_VECTOR (31 DOWNTO 0);
			CS_rate			: STD_LOGIC_VECTOR (4 DOWNTO 0);
			CS_offset		: STD_LOGIC_VECTOR (3 DOWNTO 0);
			CS_CPU			: STD_LOGIC;
			CS_FL_AUX_RESET	: STD_LOGIC;
		END RECORD;
	
	-- control data for the LocalCoincidence module
	TYPE LC_STRUCT IS
		RECORD
			lc_tx_enable	: STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_rx_enable	: STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_length		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			lc_pre_window	: STD_LOGIC_VECTOR (2 DOWNTO 0);
			lc_post_window	: STD_LOGIC_VECTOR (3 DOWNTO 0);
			lc_cable_comp	: STD_LOGIC_VECTOR (1 DOWNTO 0);
		END RECORD;
		
	-- control data for the RateMeter & Supernova module
	TYPE RM_STRUCT IS
		RECORD
			rm_rate_enable	: STD_LOGIC_VECTOR (1 DOWNTO 0);
			rm_rate_dead	: STD_LOGIC_VECTOR (9 DOWNTO 0);
			rm_sn_enable	: STD_LOGIC_VECTOR (1 DOWNTO 0);
			rm_sn_dead		: STD_LOGIC_VECTOR (2 DOWNTO 0);
		END RECORD;
		
	-- control data for the data compression module
	TYPE COMPR_STRUCT IS
		RECORD
			COMPR_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0);
			ATWDa0thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDa1thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDa2thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDa3thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDb0thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDb1thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDb2thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			ATWDb3thres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			FADCthres		: STD_LOGIC_VECTOR (9 DOWNTO 0);
			threshold0		: STD_LOGIC;
			LASTonly		: STD_LOGIC;
		END RECORD;
	
END ctrl_data_types;
