------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ctrl_data_types.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2012-07-09
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
USE IEEE.std_logic_1164.ALL;

PACKAGE ctrl_data_types IS

   -- control data for the DAQ module
   TYPE DAQ_STRUCT IS
   RECORD
      enable_DAQ     : STD_LOGIC;
      enable_AB      : STD_LOGIC_VECTOR (1 DOWNTO 0);
      trigger_enable : STD_LOGIC_VECTOR (15 DOWNTO 0);
      ATWD_mode      : STD_LOGIC_VECTOR (1 DOWNTO 0);
      LC_mode        : STD_LOGIC_VECTOR (1 DOWNTO 0);
      DAQ_mode       : STD_LOGIC_VECTOR (1 DOWNTO 0);
      LBM_mode       : STD_LOGIC_VECTOR (1 DOWNTO 0);
      COMPR_mode     : STD_LOGIC_VECTOR (1 DOWNTO 0);
      LBM_ptr_RST    : STD_LOGIC;
      LC_heart_beat  : STD_LOGIC;
   END RECORD;

   -- control data for the CalibrationSource module
   TYPE CS_STRUCT IS
   RECORD
      CS_enable       : STD_LOGIC_VECTOR (5 DOWNTO 0);
      CS_mode         : STD_LOGIC_VECTOR (2 DOWNTO 0);
      CS_time         : STD_LOGIC_VECTOR (31 DOWNTO 0);
      CS_rate         : STD_LOGIC_VECTOR (4 DOWNTO 0);
      CS_offset       : STD_LOGIC_VECTOR (3 DOWNTO 0);
      CS_CPU          : STD_LOGIC;
      CS_FL_AUX_RESET : STD_LOGIC;
   END RECORD;

   --    TYPE lc_cable_length_int IS INTEGER RANGE 0 TO 127;
   TYPE CABLE_LENGTH_VECTOR IS ARRAY (0 TO 3) OF INTEGER RANGE 0 TO 127;

   -- control data for the LocalCoincidence module
   TYPE LC_STRUCT IS
   RECORD
      LC_disc_source       : STD_LOGIC;
      lc_tx_enable         : STD_LOGIC_VECTOR (1 DOWNTO 0);
      lc_rx_enable         : STD_LOGIC_VECTOR (1 DOWNTO 0);
      lc_length            : STD_LOGIC_VECTOR (1 DOWNTO 0);
      lc_pre_window        : STD_LOGIC_VECTOR (5 DOWNTO 0);
      lc_post_window       : STD_LOGIC_VECTOR (5 DOWNTO 0);
      -- lc_cable_comp        : STD_LOGIC_VECTOR (1 DOWNTO 0);
      lc_cable_length_up   : CABLE_LENGTH_VECTOR;
      lc_cable_length_down : CABLE_LENGTH_VECTOR;
      lc_self_mode         : STD_LOGIC_VECTOR (1 DOWNTO 0);
      lc_self_window       : STD_LOGIC_VECTOR (5 DOWNTO 0);
      LC_up_and_down       : STD_LOGIC;
   END RECORD;

   -- control data for the RateMeter & Supernova module
   TYPE RM_CTRL_STRUCT IS
   RECORD
      rm_rate_enable  : STD_LOGIC_VECTOR (1 DOWNTO 0);
      rm_rate_dead    : STD_LOGIC_VECTOR (9 DOWNTO 0);
      rm_sn_enable    : STD_LOGIC_VECTOR (1 DOWNTO 0);
      rm_sn_dead      : STD_LOGIC_VECTOR (6 DOWNTO 0);
      dead_cnt_en     : STD_LOGIC_VECTOR (1 DOWNTO 0);
      atwd_acq_cnt_en : STD_LOGIC;
   END RECORD;

   TYPE RM_STAT_STRUCT IS
   RECORD
      RM_rate_SPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
      RM_rate_MPE    : STD_LOGIC_VECTOR (31 DOWNTO 0);
      RM_rate_update : STD_LOGIC;
      RM_sn_data     : STD_LOGIC_VECTOR (31 DOWNTO 0);
      dead_cnt       : STD_LOGIC_VECTOR (31 DOWNTO 0);
      atwd_acq_cnt   : STD_LOGIC_VECTOR (31 DOWNTO 0);
      sn_rate_update : STD_LOGIC;
   END RECORD;

   -- control data for the data compression module
   TYPE COMPR_STRUCT IS
   RECORD
      COMPR_mode               : STD_LOGIC_VECTOR (1 DOWNTO 0);
--            ATWDa0thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDa1thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDa2thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDa3thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDb0thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDb1thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDb2thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            ATWDb3thres : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            FADCthres   : STD_LOGIC_VECTOR (9 DOWNTO 0);
--            threshold0  : STD_LOGIC;
      all_chan_for_forced_trig : STD_LOGIC;
      LASTonly                 : STD_LOGIC;
   END RECORD;

   TYPE COMM_CTRL_STRUCT IS
   RECORD
      reboot_req       : STD_LOGIC;
      id               : STD_LOGIC_VECTOR(47 DOWNTO 0);
      id_avail         : STD_LOGIC;
      tx_packet_ready  : STD_LOGIC;     -- tx packet written to DPM
      rx_dpr_raddr_stb : STD_LOGIC;     -- rx_dpr_radr updated
      tx_head          : STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_tail          : STD_LOGIC_VECTOR(15 DOWNTO 0);
      comm_threshold   : STD_LOGIC_VECTOR(7 DOWNTO 0);  -- Comm parameters
      DAC_max          : STD_LOGIC_VECTOR(1 DOWNTO 0);
      RX_delay         : STD_LOGIC_VECTOR(7 DOWNTO 0);
      TX_delay         : STD_LOGIC_VECTOR(7 DOWNTO 0);
      level_adapt_min  : STD_LOGIC_VECTOR(9 DOWNTO 0);
      level_adapt_max  : STD_LOGIC_VECTOR(9 DOWNTO 0);
      thres_delay_wr   : STD_LOGIC;
      clev_wr          : STD_LOGIC;
   END RECORD;

   TYPE COMM_STAT_STRUCT IS
   RECORD
      com_avail       : STD_LOGIC;
      reboot_gnt      : STD_LOGIC;
      rx_error        : STD_LOGIC_VECTOR(15 DOWNTO 0);
      tx_error        : STD_LOGIC_VECTOR(15 DOWNTO 0);
      com_reset_rcvd  : STD_LOGIC;
      rx_packets      : STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_dpr_aff      : STD_LOGIC;
      tx_almost_empty : STD_LOGIC;
      tx_pack_sent    : STD_LOGIC;      -- packet successfully sent
      rx_pack_rcvd    : STD_LOGIC;      -- at least one packet in rx buffer
      tx_tail         : STD_LOGIC_VECTOR(15 DOWNTO 0);
      rx_head         : STD_LOGIC_VECTOR(15 DOWNTO 0);
   END RECORD;

   -- control data for IceTop modifications
   TYPE ICETOP_CTRL_STRUCT IS
   RECORD
      IceTop_mode         : STD_LOGIC;
      IT_atwd_charge_chan : STD_LOGIC_VECTOR (1 DOWNTO 0);
      IT_scan_mode        : STD_LOGIC;
      minimum_bias        : STD_LOGIC;
   END RECORD;


   -- data type for the SPI inclinometer
   TYPE INCLINOMETER_CTRL_STRUCT IS
   RECORD
      incl_en             : STD_LOGIC;
      incl_data_tx        : STD_LOGIC_VECTOR (15 DOWNTO 0);
      incl_data_tx_update : STD_LOGIC;
   END RECORD;

   TYPE INCLINOMETER_STAT_STRUCT IS
   RECORD
      incl_data_rx : STD_LOGIC_VECTOR (15 DOWNTO 0);
      incl_busy    : STD_LOGIC;
      incl_DIO     : STD_LOGIC_VECTOR (1 DOWNTO 0);
   END RECORD;

   TYPE DIM_POLE_STRUCT IS
   RECORD
      disc_select : STD_LOGIC;                       -- 0 = SPE; 1 = MPE
      deadtime    : STD_LOGIC_VECTOR (6 DOWNTO 0);
      dim_pole_n0 : STD_LOGIC_VECTOR (5 DOWNTO 0);   -- trigger count
      dim_pole_n1 : STD_LOGIC_VECTOR (5 DOWNTO 0);
      dim_pole_t0 : STD_LOGIC_VECTOR (14 DOWNTO 0);  -- time window
      dim_pole_t1 : STD_LOGIC_VECTOR (14 DOWNTO 0);
   END RECORD;
   
END ctrl_data_types;












