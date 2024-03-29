-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : slaveregister.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2012-07-09
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides the registers for the CPU inside the FPGA
--              the module is connected to ahb_slave.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten
-- 2006-                   thorsten  Added Comm Threshold registers
-- 2006-02-06              thorsten  commented out Roadgrader registers  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.numeric_std.ALL;

USE WORK.ctrl_data_types.ALL;

ENTITY slaveregister IS
   PORT (
      CLK             : IN  STD_LOGIC;
      CLK40           : IN  STD_LOGIC;
      RST             : IN  STD_LOGIC;
      systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
      -- connections to the stripe
      masterhclk      : OUT STD_LOGIC;
      masterhready    : OUT STD_LOGIC;
      masterhgrant    : OUT STD_LOGIC;
      masterhrdata    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
      masterhresp     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
      masterhwrite    : IN  STD_LOGIC;
      masterhlock     : IN  STD_LOGIC;
      masterhbusreq   : IN  STD_LOGIC;
      masterhaddr     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      masterhburst    : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
      masterhsize     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      masterhtrans    : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
      masterhwdata    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
      intpld          : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
      -- command register
      DAQ_ctrl        : OUT DAQ_STRUCT;
      CS_ctrl         : OUT CS_STRUCT;
      cs_flash_time   : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
      cs_flash_now    : IN  STD_LOGIC;
      LC_ctrl         : OUT LC_STRUCT;
      RM_ctrl         : OUT RM_CTRL_STRUCT;
      RM_stat         : IN  RM_STAT_STRUCT;
      COMM_CTRL       : OUT COMM_CTRL_STRUCT;
      COMM_STAT       : IN  COMM_STAT_STRUCT;
      DOM_status      : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
      COMPR_ctrl      : OUT COMPR_STRUCT;
      debugging       : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
      ICETOP_ctrl     : OUT ICETOP_CTRL_STRUCT;
      INCL_ctrl       : OUT INCLINOMETER_CTRL_STRUCT;
      INCL_stat       : IN  INCLINOMETER_STAT_STRUCT;
      DIM_POLE_ctrl   : OUT DIM_POLE_STRUCT;
      -- Flasher Board
      CS_FL_aux_reset : OUT STD_LOGIC;
      CS_FL_attn      : IN  STD_LOGIC;
      -- pointers
      LBM_ptr         : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
      -- kale communication interface
      -- R2R ladder
      cs_wf_data      : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
      cs_wf_addr      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
      -- ATWD A pedestal
      ATWD_ped_data_A : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      ATWD_ped_addr_A : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
      -- ATWD B pedestal
      ATWD_ped_data_B : OUT STD_LOGIC_VECTOR (9 DOWNTO 0);
      ATWD_ped_addr_B : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
      -- test connector
      TC              : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
      );
END slaveregister;

ARCHITECTURE arch_slaveregister OF slaveregister IS

   -- hex2addr is a function to format a 16 bit address for the comparison
   FUNCTION hex2addr (CONSTANT hex : STD_LOGIC_VECTOR(15 DOWNTO 0))
      RETURN STD_LOGIC_VECTOR IS
   BEGIN
      RETURN hex(13 DOWNTO 2);
   END hex2addr;

   CONSTANT READBACK : INTEGER := 1;    -- enable readback of write registers

   COMPONENT ahb_slave
      PORT (
         CLK           : IN  STD_LOGIC;
         RST           : IN  STD_LOGIC;
         -- connections to the stripe
         masterhclk    : OUT STD_LOGIC;
         masterhready  : OUT STD_LOGIC;
         masterhgrant  : OUT STD_LOGIC;
         masterhrdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         masterhresp   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
         masterhwrite  : IN  STD_LOGIC;
         masterhlock   : IN  STD_LOGIC;
         masterhbusreq : IN  STD_LOGIC;
         masterhaddr   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
         masterhburst  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
         masterhsize   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
         masterhtrans  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
         masterhwdata  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
         -- local bus signals
         reg_write     : OUT STD_LOGIC;
         reg_address   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         reg_wdata     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
         reg_rdata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
         reg_enable    : OUT STD_LOGIC;
         reg_wait_sig  : IN  STD_LOGIC
         );
   END COMPONENT;

   SIGNAL reg_write    : STD_LOGIC;
   SIGNAL reg_address  : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL reg_wdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL reg_rdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);
   SIGNAL reg_enable   : STD_LOGIC;
   SIGNAL reg_wait_sig : STD_LOGIC;

   -- rom interface
   SIGNAL rom_data : STD_LOGIC_VECTOR (15 DOWNTO 0);

   COMPONENT interrupts
      PORT (
         CLK40       : IN  STD_LOGIC;
         RST         : IN  STD_LOGIC;
         -- Handshake (ACK)
         int_enable  : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
         int_clr     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
         int_pending : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
         -- Interrupt to Stripe
         intpld      : OUT STD_LOGIC_VECTOR (5 DOWNTO 0);
         -- Interrupt sources
         int0        : IN  STD_LOGIC;
         int1        : IN  STD_LOGIC;
         int2        : IN  STD_LOGIC;
         int3        : IN  STD_LOGIC;
         int4        : IN  STD_LOGIC;
         int5        : IN  STD_LOGIC;
         -- Test Connector
         TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT version_rom
      PORT (
         address : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
         q       : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT R2Rram
      PORT (
         data      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         wraddress : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         rdaddress : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
         wren      : IN  STD_LOGIC;
         clock     : IN  STD_LOGIC;
         q         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   COMPONENT ATWDped
      PORT (
         data      : IN  STD_LOGIC_VECTOR (9 DOWNTO 0);
         wraddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
         rdaddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
         wren      : IN  STD_LOGIC;
         clock     : IN  STD_LOGIC;
         q         : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
         );
   END COMPONENT;

   SIGNAL DAQ_ctrl_local      : DAQ_STRUCT;
   SIGNAL CS_ctrl_local       : CS_STRUCT;
   SIGNAL LC_ctrl_local       : LC_STRUCT;
   SIGNAL RM_ctrl_local       : RM_CTRL_STRUCT;
   SIGNAL COMM_ctrl_local     : COMM_CTRL_STRUCT;
   SIGNAL COMPR_ctrl_local    : COMPR_STRUCT;
   SIGNAL ICETOP_ctrl_local   : ICETOP_CTRL_STRUCT;
   SIGNAL INCL_ctrl_local     : INCLINOMETER_CTRL_STRUCT;
   SIGNAL DIM_POLE_ctrl_local : DIM_POLE_STRUCT;

   SIGNAL CS_FL_aux_reset_local : STD_LOGIC;

   -- memory write enable signals
   SIGNAL R2Rwe      : STD_LOGIC;
   SIGNAL ATWDApedwe : STD_LOGIC;
   SIGNAL ATWDBpedwe : STD_LOGIC;

   -- setting DOM ID
   SIGNAL id_set : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";

   -- Interrupts
   SIGNAL int_enable  : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL int_clr     : STD_LOGIC_VECTOR (5 DOWNTO 0);
   SIGNAL int_pending : STD_LOGIC_VECTOR (5 DOWNTO 0);
   
BEGIN
   reg_wait_sig <= '1';


   -- Implementation comments:
   -- For read only registers it is not necessary to check the RW signal
   -- This saves resources. It doesn't matter if the read bus gets set.
   -- Actually we can do the same thing for RW registers to save resources.
   PROCESS(CLK, RST)
   BEGIN
      IF RST = '1' THEN
         DAQ_ctrl_local.LBM_ptr_RST <= '0';
         CS_ctrl_local.CS_CPU       <= '0';
         DAQ_ctrl_local             <= ('0', "00", (OTHERS => '0'), "00", "00", "00", "00", "00", '0', '1');
         CS_ctrl_local              <= ((OTHERS            => '0'), "000", (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), '0', '0');
         -- LC_ctrl_local       <= ('0', (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (1,2,3,4), (1,2,3,4));
         LC_ctrl_local              <= ('0', (OTHERS       => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (1, 2, 3, 4), (1, 2, 3, 4), (OTHERS => '0'), (OTHERS => '0'), '0');
         RM_ctrl_local              <= ((OTHERS            => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), '0');
         COMM_ctrl_local            <= ('0', (OTHERS       => '0'), 'X', '0', '0', (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), '0', '0');
         id_set                     <= "00";
         --             COMPR_ctrl_local        <= ((OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), (OTHERS=>'0'), '0', '0');
         INCL_ctrl_local            <= ('0', (OTHERS       => '0'), '0');
         int_clr                    <= (OTHERS             => '0');
         DIM_POLE_ctrl_local        <= ('0', (OTHERS       => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'), (OTHERS => '0'));
      ELSIF CLK'EVENT AND CLK = '1' THEN
         DAQ_ctrl_local.LBM_ptr_RST          <= '0';
         CS_ctrl_local.CS_CPU                <= '0';
         COMM_ctrl_local.tx_packet_ready     <= '0';
         COMM_ctrl_local.rx_dpr_raddr_stb    <= '0';
         COMM_ctrl_local.thres_delay_wr      <= '0';
         COMM_ctrl_local.clev_wr             <= '0';
         INCL_ctrl_local.incl_data_tx_update <= '0';
         int_clr                             <= (OTHERS => '0');
         reg_rdata                           <= (OTHERS => 'X');  -- to make sure we don't create a latch
         IF reg_enable = '1' THEN
            IF std_match(reg_address(13 DOWNTO 2) , "00000-------") THEN  -- version ROM
               reg_rdata(15 DOWNTO 0)  <= rom_data;
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0400")) THEN  -- STD_LOGIC_VECTOR(hex2addr(x"0400")) ) THEN --"000100000000" ) THEN -- Trigger Source
               IF reg_write = '1' THEN
                  DAQ_ctrl_local.trigger_enable <= reg_wdata(15 DOWNTO 0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(15 DOWNTO 0)  <= DAQ_ctrl_local.trigger_enable;
                  reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0404")) THEN  -- Trigger Setup
               NULL;                    -- no function defined yet
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0410")) THEN  -- DAQ
               IF reg_write = '1' THEN
                  DAQ_ctrl_local.enable_DAQ      <= reg_wdata(0);
                  DAQ_ctrl_local.enable_AB       <= reg_wdata(2 DOWNTO 1);
                  DAQ_ctrl_local.DAQ_mode        <= reg_wdata(9 DOWNTO 8);
                  DAQ_ctrl_local.ATWD_mode       <= reg_wdata(13 DOWNTO 12);
                  DAQ_ctrl_local.LC_mode         <= reg_wdata(17 DOWNTO 16);
                  DAQ_ctrl_local.LC_heart_beat   <= NOT reg_wdata(19);
                  DAQ_ctrl_local.LBM_mode        <= reg_wdata(21 DOWNTO 20);
                  DAQ_ctrl_local.COMPR_mode      <= reg_wdata(25 DOWNTO 24);
                  COMPR_ctrl_local.COMPR_mode    <= reg_wdata(25 DOWNTO 24);  -- Joshua needs this
                  ICETOP_ctrl_local.IceTop_mode  <= reg_wdata(28);  -- for IceTop
                  ICETOP_ctrl_local.minimum_bias <= reg_wdata(29);  -- for IceTop
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0)  <= (OTHERS => '0');
                  reg_rdata(0)            <= DAQ_ctrl_local.enable_DAQ;
                  reg_rdata(2 DOWNTO 1)   <= DAQ_ctrl_local.enable_AB;
                  reg_rdata(9 DOWNTO 8)   <= DAQ_ctrl_local.DAQ_mode;
                  reg_rdata(13 DOWNTO 12) <= DAQ_ctrl_local.ATWD_mode;
                  reg_rdata(17 DOWNTO 16) <= DAQ_ctrl_local.LC_mode;
                  reg_rdata(19)           <= NOT DAQ_ctrl_local.LC_heart_beat;
                  reg_rdata(21 DOWNTO 20) <= DAQ_ctrl_local.LBM_mode;
                  reg_rdata(25 DOWNTO 24) <= DAQ_ctrl_local.COMPR_mode;
                  reg_rdata(28)           <= ICETOP_ctrl_local.IceTop_mode;
                  reg_rdata(29)           <= ICETOP_ctrl_local.minimum_bias;
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0420")) THEN  -- LBM control
               IF reg_write = '1' THEN
                  DAQ_ctrl_local.LBM_ptr_RST <= reg_wdata(0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0424")) THEN  -- LBM pointer
               reg_rdata(31 DOWNTO 0) <= LBM_ptr;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0430")) THEN  -- DOM status
               reg_rdata(31 DOWNTO 0) <= DOM_status;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0440")) THEN  -- systime LSB
               reg_rdata(31 DOWNTO 0) <= systime (31 DOWNTO 0);
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0444")) THEN  -- systime MSB
               reg_rdata(15 DOWNTO 0)  <= systime (47 DOWNTO 32);
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0450")) THEN  -- Local Coincidence Control
               IF reg_write = '1' THEN
                  LC_ctrl_local.LC_tx_enable   <= reg_wdata(1 DOWNTO 0);
                  LC_ctrl_local.LC_rx_enable   <= reg_wdata(3 DOWNTO 2);
                  LC_ctrl_local.LC_length      <= reg_wdata(5 DOWNTO 4);
                  LC_ctrl_local.LC_disc_source <= reg_wdata(7);
                  -- LC_ctrl_local.LC_cable_comp          <= reg_wdata(9 downto 8);
                  LC_ctrl_local.LC_pre_window  <= reg_wdata(21 DOWNTO 16);
                  LC_ctrl_local.LC_post_window <= reg_wdata(29 DOWNTO 24);
                  LC_ctrl_local.lc_self_mode   <= reg_wdata(9 DOWNTO 8);
                  LC_ctrl_local.lc_self_window <= reg_wdata(15 DOWNTO 10);
                  LC_ctrl_local.LC_up_and_down <= reg_wdata(6);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0)  <= (OTHERS => '0');
                  reg_rdata(1 DOWNTO 0)   <= LC_ctrl_local.LC_tx_enable;
                  reg_rdata(3 DOWNTO 2)   <= LC_ctrl_local.LC_rx_enable;
                  reg_rdata(5 DOWNTO 4)   <= LC_ctrl_local.LC_length;
                  reg_rdata(7)            <= LC_ctrl_local.LC_disc_source;
                  -- reg_rdata(9 downto 8)        <= LC_ctrl_local.LC_cable_comp;
                  reg_rdata(21 DOWNTO 16) <= LC_ctrl_local.LC_pre_window;
                  reg_rdata(29 DOWNTO 24) <= LC_ctrl_local.LC_post_window;
                  reg_rdata(9 DOWNTO 8)   <= LC_ctrl_local.lc_self_mode;
                  reg_rdata(15 DOWNTO 10) <= LC_ctrl_local.lc_self_window;
                  reg_rdata(6)            <= LC_ctrl_local.LC_up_and_down;
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0454")) THEN  -- LC Cable Length Up
               IF reg_write = '1' THEN
                  LC_ctrl_local.LC_cable_length_up(0) <= CONV_INTEGER(reg_wdata(6 DOWNTO 0));
                  LC_ctrl_local.LC_cable_length_up(1) <= CONV_INTEGER(reg_wdata(14 DOWNTO 8));
                  LC_ctrl_local.LC_cable_length_up(2) <= CONV_INTEGER(reg_wdata(22 DOWNTO 16));
                  LC_ctrl_local.LC_cable_length_up(3) <= CONV_INTEGER(reg_wdata(30 DOWNTO 24));
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0)  <= (OTHERS => '0');
                  reg_rdata(6 DOWNTO 0)   <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_up(0), 7);
                  reg_rdata(14 DOWNTO 8)  <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_up(1), 7);
                  reg_rdata(22 DOWNTO 16) <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_up(2), 7);
                  reg_rdata(30 DOWNTO 24) <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_up(3), 7);
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0458")) THEN  -- LC Cable Length Down
               IF reg_write = '1' THEN
                  LC_ctrl_local.LC_cable_length_down(0) <= CONV_INTEGER(reg_wdata(6 DOWNTO 0));
                  LC_ctrl_local.LC_cable_length_down(1) <= CONV_INTEGER(reg_wdata(14 DOWNTO 8));
                  LC_ctrl_local.LC_cable_length_down(2) <= CONV_INTEGER(reg_wdata(22 DOWNTO 16));
                  LC_ctrl_local.LC_cable_length_down(3) <= CONV_INTEGER(reg_wdata(30 DOWNTO 24));
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0)  <= (OTHERS => '0');
                  reg_rdata(6 DOWNTO 0)   <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_down(0), 7);
                  reg_rdata(14 DOWNTO 8)  <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_down(1), 7);
                  reg_rdata(22 DOWNTO 16) <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_down(2), 7);
                  reg_rdata(30 DOWNTO 24) <= CONV_STD_LOGIC_VECTOR(LC_ctrl_local.LC_cable_length_down(3), 7);
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0460")) THEN  -- Calibration Source Control
               IF reg_write = '1' THEN
                  CS_ctrl_local.CS_enable <= reg_wdata(5 DOWNTO 0);
                  CS_ctrl_local.CS_mode   <= reg_wdata(14 DOWNTO 12);
                  CS_ctrl_local.CS_offset <= reg_wdata(19 DOWNTO 16);
                  CS_ctrl_local.CS_rate   <= reg_wdata(28 DOWNTO 24);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0)  <= (OTHERS => '0');
                  reg_rdata(5 DOWNTO 0)   <= CS_ctrl_local.CS_enable;
                  reg_rdata(14 DOWNTO 12) <= CS_ctrl_local.CS_mode;
                  reg_rdata(19 DOWNTO 16) <= CS_ctrl_local.CS_offset;
                  reg_rdata(28 DOWNTO 24) <= CS_ctrl_local.CS_rate;
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0464")) THEN  -- Calibration Time
               IF reg_write = '1' THEN
                  CS_ctrl_local.CS_time <= reg_wdata(31 DOWNTO 0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0) <= CS_ctrl_local.CS_time;
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0468")) THEN  -- Calibration CPU launch
               IF reg_write = '1' THEN
                  IF reg_wdata(7 DOWNTO 0) = X"A5" THEN
                     CS_ctrl_local.CS_CPU <= '1';
                  END IF;
               END IF;
               reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"046c")) THEN  -- Calibration Flash Time LSB
               reg_rdata(31 DOWNTO 0) <= cs_flash_time (31 DOWNTO 0);
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0470")) THEN  -- Calibration Flash Time MSB
               reg_rdata(15 DOWNTO 0)  <= cs_flash_time (47 DOWNTO 32);
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0480")) THEN  -- Rate Monitor Control
               IF reg_write = '1' THEN
                  RM_ctrl_local.RM_rate_enable  <= reg_wdata(1 DOWNTO 0);
                  RM_ctrl_local.atwd_acq_cnt_en <= reg_wdata(4);
                  RM_ctrl_local.dead_cnt_en     <= reg_wdata(9 DOWNTO 8);
                  RM_ctrl_local.RM_rate_dead    <= reg_wdata(25 DOWNTO 16);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(1 DOWNTO 0)   <= RM_ctrl_local.RM_rate_enable;
                  reg_rdata(4)            <= RM_ctrl_local.atwd_acq_cnt_en;
                  reg_rdata(7 DOWNTO 2)   <= (OTHERS => '0');
                  reg_rdata(9 DOWNTO 8)   <= RM_ctrl_local.dead_cnt_en;
                  reg_rdata(15 DOWNTO 10) <= (OTHERS => '0');
                  reg_rdata(25 DOWNTO 16) <= RM_ctrl_local.RM_rate_dead;
                  reg_rdata(31 DOWNTO 26) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0484")) THEN  -- Rate Monitor SPE
               reg_rdata(31 DOWNTO 0) <= RM_stat.rm_rate_SPE;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0488")) THEN  -- Rate Monitor MPE
               reg_rdata(31 DOWNTO 0) <= RM_stat.rm_rate_MPE;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"048C")) THEN  -- ATWD ACQ cnt
               reg_rdata(31 DOWNTO 0) <= RM_stat.atwd_acq_cnt;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0490")) THEN  -- ATWD dead time count
               reg_rdata(31 DOWNTO 0) <= RM_stat.dead_cnt;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04A0")) THEN  -- Supernove Meter Control
               IF reg_write = '1' THEN
                  RM_ctrl_local.RM_sn_enable <= reg_wdata(1 DOWNTO 0);
                  RM_ctrl_local.RM_sn_dead   <= reg_wdata(22 DOWNTO 16);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(1 DOWNTO 0)   <= RM_ctrl_local.RM_sn_enable;
                  reg_rdata(15 DOWNTO 2)  <= (OTHERS => '0');
                  reg_rdata(22 DOWNTO 16) <= RM_ctrl_local.RM_sn_dead;
                  reg_rdata(31 DOWNTO 23) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04A4")) THEN  -- Supernove Data
               reg_rdata(31 DOWNTO 0) <= RM_stat.RM_sn_data;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04C0")) THEN  -- Interrupt Enable
               IF reg_write = '1' THEN
                  int_enable <= reg_wdata(5 DOWNTO 0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(5 DOWNTO 0)  <= int_enable;
                  reg_rdata(31 DOWNTO 6) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04C4")) THEN  -- Interrupt ACK
               IF reg_write = '1' THEN
                  int_clr <= reg_wdata(5 DOWNTO 0);
               END IF;
               reg_rdata(5 DOWNTO 0)  <= int_pending;
               reg_rdata(31 DOWNTO 6) <= (OTHERS => '0');
               -- ELSIF communication
               
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04E0")) THEN  -- Flasher Board Control
               IF reg_write = '1' THEN
                  CS_FL_aux_reset_local <= reg_wdata(0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(0)           <= CS_FL_aux_reset_local;
                  reg_rdata(31 DOWNTO 1) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"04E4")) THEN  -- Flasher Board Status
               reg_rdata(0)           <= CS_FL_attn;
               reg_rdata(31 DOWNTO 1) <= (OTHERS => '0');
               
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0500")) THEN  -- Communication Control
               IF reg_write = '1' THEN
                  COMM_ctrl_local.reboot_req <= reg_wdata(0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(0)           <= COMM_ctrl_local.reboot_req;
                  reg_rdata(31 DOWNTO 1) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0504")) THEN  -- Communication Control Response
               reg_rdata(0)           <= COMM_stat.reboot_gnt;
               reg_rdata(1)           <= COMM_stat.tx_pack_sent;
               reg_rdata(2)           <= COMM_stat.tx_almost_empty;
               reg_rdata(3)           <= COMM_stat.rx_pack_rcvd;
               reg_rdata(4)           <= COMM_stat.com_reset_rcvd;
               reg_rdata(5)           <= COMM_stat.rx_dpr_aff;
               reg_rdata(6)           <= COMM_stat.com_avail;
               reg_rdata(31 DOWNTO 7) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0508")) THEN  -- Communication tx_dpr_wadr
               IF reg_write = '1' THEN
                  COMM_ctrl_local.tx_packet_ready <= '1';
                  COMM_ctrl_local.tx_head         <= reg_wdata(15 DOWNTO 0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(15 DOWNTO 0)  <= COMM_ctrl_local.tx_head;
                  reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"050C")) THEN  -- Communication tx_wadr_radr
               reg_rdata(15 DOWNTO 0)  <= COMM_stat.tx_tail;
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0510")) THEN  -- Communication rx_dpr_radr
               IF reg_write = '1' THEN
                  COMM_ctrl_local.rx_dpr_raddr_stb <= '1';
                  COMM_ctrl_local.rx_tail          <= reg_wdata(15 DOWNTO 0);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(15 DOWNTO 0)  <= COMM_ctrl_local.rx_tail;
                  reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0514")) THEN  -- Communication rx_addr
               reg_rdata(15 DOWNTO 0)  <= COMM_stat.rx_head;
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0518")) THEN  -- Communication Packets in RX buffer
               reg_rdata(15 DOWNTO 0)  <= COMM_stat.rx_packets;
               reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"051C")) THEN  -- Communication Error
               reg_rdata(15 DOWNTO 0)  <= COMM_stat.rx_error;
               reg_rdata(31 DOWNTO 16) <= COMM_stat.tx_error;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0520")) THEN  -- Communication Level adaption limits
               IF reg_write = '1' THEN
                  COMM_ctrl_local.clev_wr         <= '1';
                  COMM_ctrl_local.level_adapt_min <= reg_wdata(9 DOWNTO 0);
                  COMM_ctrl_local.level_adapt_max <= reg_wdata(25 DOWNTO 16);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(9 DOWNTO 0)   <= COMM_ctrl_local.level_adapt_min;
                  reg_rdata(25 DOWNTO 16) <= COMM_ctrl_local.level_adapt_max;
                  reg_rdata(16 DOWNTO 10) <= (OTHERS => '0');
                  reg_rdata(31 DOWNTO 26) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0524")) THEN  -- Communication Thresholds and Delays
               IF reg_write = '1' THEN
                  COMM_ctrl_local.thres_delay_wr <= '1';
                  COMM_ctrl_local.comm_threshold <= reg_wdata(7 DOWNTO 0);
                  COMM_ctrl_local.DAC_max        <= reg_wdata(9 DOWNTO 8);
                  COMM_ctrl_local.RX_delay       <= reg_wdata(23 DOWNTO 16);
                  COMM_ctrl_local.TX_delay       <= reg_wdata(31 DOWNTO 24);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(7 DOWNTO 0)   <= COMM_ctrl_local.comm_threshold;
                  reg_rdata(9 DOWNTO 8)   <= COMM_ctrl_local.DAC_max;
                  reg_rdata(23 DOWNTO 16) <= COMM_ctrl_local.RX_delay;
                  reg_rdata(31 DOWNTO 24) <= COMM_ctrl_local.TX_delay;
                  reg_rdata(15 DOWNTO 10) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0530")) THEN  -- DOM ID LSB
               IF reg_write = '1' THEN
                  COMM_ctrl_local.id(31 DOWNTO 0) <= reg_wdata(31 DOWNTO 0);
                  id_set (0)                      <= '1';
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(31 DOWNTO 0) <= COMM_ctrl_local.id(31 DOWNTO 0);
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0534")) THEN  -- DOM ID MSB
               IF reg_write = '1' THEN
                  COMM_ctrl_local.id(47 DOWNTO 32) <= reg_wdata(15 DOWNTO 0);
                  id_set (1)                       <= '1';
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(15 DOWNTO 0)  <= COMM_ctrl_local.id(47 DOWNTO 32);
                  reg_rdata(31 DOWNTO 16) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0540")) THEN  -- Compression Control
               IF reg_write = '1' THEN
                  --                                    COMPR_ctrl_local.threshold0     <= reg_wdata(0);
                  COMPR_ctrl_local.LASTonly                 <= reg_wdata(0);
                  COMPR_ctrl_local.all_chan_for_forced_trig <= reg_wdata(1);
               END IF;
               IF READBACK = 1 THEN
                  --                                    reg_rdata(0)                    <= COMPR_ctrl_local.threshold0;
                  reg_rdata(0)           <= COMPR_ctrl_local.LASTonly;
                  reg_rdata(1)           <= COMPR_ctrl_local.all_chan_for_forced_trig;
                  reg_rdata(31 DOWNTO 2) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
               --                       ELSIF std_match( reg_address(13 downto 2) , hex2addr(x"0544") ) THEN    -- Compression FADC
               --                               IF reg_write = '1' THEN
               --                                       COMPR_ctrl_local.FADCthres      <= reg_wdata(9 DOWNTO 0);
               --                               END IF;
               --                               IF READBACK=1 THEN
               --                                       reg_rdata(9 DOWNTO 0)   <= COMPR_ctrl_local.FADCthres;
               --                                       reg_rdata(31 downto 10) <= (OTHERS=>'0');
               --                               ELSE
               --                                       reg_rdata(31 downto 0)  <= (OTHERS=>'0');
               --                               END IF;
               --                       ELSIF std_match( reg_address(13 downto 2) , hex2addr(x"0548") ) THEN    -- Compression ATWD A 1/0
               --                               IF reg_write = '1' THEN
               --                                       COMPR_ctrl_local.ATWDa0thres    <= reg_wdata(9 DOWNTO 0);
               --                                       COMPR_ctrl_local.ATWDa1thres    <= reg_wdata(25 DOWNTO 16);
               --                               END IF;
               --                               IF READBACK=1 THEN
               --                                       reg_rdata(9 DOWNTO 0)   <= COMPR_ctrl_local.ATWDa0thres;
               --                                       reg_rdata(25 DOWNTO 16) <= COMPR_ctrl_local.ATWDa1thres;
               --                                       reg_rdata(16 downto 10) <= (OTHERS=>'0');
               --                                       reg_rdata(31 downto 26) <= (OTHERS=>'0');
               --                               ELSE
               --                                       reg_rdata(31 downto 0)  <= (OTHERS=>'0');
               --                               END IF;
               --                       ELSIF std_match( reg_address(13 downto 2) , hex2addr(x"054C") ) THEN    -- Compression ATWD A 3/2
               --                               IF reg_write = '1' THEN
               --                                       COMPR_ctrl_local.ATWDa2thres    <= reg_wdata(9 DOWNTO 0);
               --                                       COMPR_ctrl_local.ATWDa3thres    <= reg_wdata(25 DOWNTO 16);
               --                               END IF;
               --                               IF READBACK=1 THEN
               --                                       reg_rdata(9 DOWNTO 0)   <= COMPR_ctrl_local.ATWDa2thres;
               --                                       reg_rdata(25 DOWNTO 16) <= COMPR_ctrl_local.ATWDa3thres;
               --                                       reg_rdata(16 downto 10) <= (OTHERS=>'0');
               --                                       reg_rdata(31 downto 26) <= (OTHERS=>'0');
               --                               ELSE
               --                                       reg_rdata(31 downto 0)  <= (OTHERS=>'0');
               --                               END IF;
               --                       ELSIF std_match( reg_address(13 downto 2) , hex2addr(x"0550") ) THEN    -- Compression ATWD B 1/0
               --                               IF reg_write = '1' THEN
               --                                       COMPR_ctrl_local.ATWDb0thres    <= reg_wdata(9 DOWNTO 0);
               --                                       COMPR_ctrl_local.ATWDb1thres    <= reg_wdata(25 DOWNTO 16);
               --                               END IF;
               --                               IF READBACK=1 THEN
               --                                       reg_rdata(9 DOWNTO 0)   <= COMPR_ctrl_local.ATWDb0thres;
               --                                       reg_rdata(25 DOWNTO 16) <= COMPR_ctrl_local.ATWDb1thres;
               --                                       reg_rdata(16 downto 10) <= (OTHERS=>'0');
               --                                       reg_rdata(31 downto 26) <= (OTHERS=>'0');
               --                               ELSE
               --                                       reg_rdata(31 downto 0)  <= (OTHERS=>'0');
               --                               END IF;
               --                       ELSIF std_match( reg_address(13 downto 2) , hex2addr(x"0554") ) THEN    -- Compression ATWD B 3/2
               --                               IF reg_write = '1' THEN
               --                                       COMPR_ctrl_local.ATWDb2thres    <= reg_wdata(9 DOWNTO 0);
               --                                       COMPR_ctrl_local.ATWDb3thres    <= reg_wdata(25 DOWNTO 16);
               --                               END IF;
               --                               IF READBACK=1 THEN
               --                                       reg_rdata(9 DOWNTO 0)   <= COMPR_ctrl_local.ATWDb2thres;
               --                                       reg_rdata(25 DOWNTO 16) <= COMPR_ctrl_local.ATWDb3thres;
               --                                       reg_rdata(16 downto 10) <= (OTHERS=>'0');
               --                                       reg_rdata(31 downto 26) <= (OTHERS=>'0');
               --                               ELSE
               --                                       reg_rdata(31 downto 0)  <= (OTHERS=>'0');
               --                               END IF;
               
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0560")) THEN  -- IceTop specific
               IF reg_write = '1' THEN
                  ICETOP_ctrl_local.IT_atwd_charge_chan <= reg_wdata(1 DOWNTO 0);
                  ICETOP_ctrl_local.IT_scan_mode        <= reg_wdata(4);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(1 DOWNTO 0)  <= ICETOP_ctrl_local.IT_atwd_charge_chan;
                  reg_rdata(3 DOWNTO 2)  <= (OTHERS => '0');
                  reg_rdata(4)           <= ICETOP_ctrl_local.IT_scan_mode;
                  reg_rdata(31 DOWNTO 5) <= (OTHERS => '0');
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0580")) THEN  -- Inclinometer specific
               IF reg_write = '1' THEN
                  INCL_ctrl_local.incl_data_tx_update <= '1';
                  INCL_ctrl_local.incl_data_tx        <= reg_wdata(15 DOWNTO 0);
                  INCL_ctrl_local.incl_en             <= reg_wdata(31);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(15 DOWNTO 0)  <= INCL_ctrl_local.incl_data_tx;
                  reg_rdata(15 DOWNTO 30) <= (OTHERS => '0');
                  reg_rdata(31)           <= INCL_ctrl_local.incl_en;
               ELSE
                  reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0584")) THEN  -- Inclinometer specific
               reg_rdata(15 DOWNTO 0)  <= INCL_stat.incl_data_rx;
               reg_rdata(27 DOWNTO 16) <= (OTHERS => '0');
               reg_rdata(29 DOWNTO 28) <= INCL_stat.incl_DIO;
               reg_rdata(30)           <= '0';
               reg_rdata(31)           <= INCL_stat.incl_busy;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0590")) THEN  --DIM POLE setup
               IF reg_write = '1' THEN
                  DIM_POLE_ctrl_local.disc_select <= reg_wdata(0);
                  DIM_POLE_ctrl_local.deadtime    <= reg_wdata(14 DOWNTO 8);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata              <= (OTHERS => '0');
                  reg_rdata(0)           <= DIM_POLE_ctrl_local.disc_select;
                  reg_rdata(14 DOWNTO 8) <= DIM_POLE_ctrl_local.deadtime;
               ELSE
                  reg_rdata <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0594")) THEN  --DIM POLE 0
               IF reg_write = '1' THEN
                  DIM_POLE_ctrl_local.dim_pole_n0 <= reg_wdata(5 DOWNTO 0);
                  DIM_POLE_ctrl_local.dim_pole_t0 <= reg_wdata(30 DOWNTO 16);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(5 DOWNTO 0)   <= DIM_POLE_ctrl_local.dim_pole_n0;
                  reg_rdata(15 DOWNTO 6)  <= (OTHERS => '0');
                  reg_rdata(30 DOWNTO 16) <= DIM_POLE_ctrl_local.dim_pole_t0;
                  reg_rdata(31)           <= '0';
               ELSE
                  reg_rdata <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0598")) THEN  --DIM POLE 1
               IF reg_write = '1' THEN
                  DIM_POLE_ctrl_local.dim_pole_n1 <= reg_wdata (5 DOWNTO 0);
                  DIM_POLE_ctrl_local.dim_pole_t1 <= reg_wdata(30 DOWNTO 16);
               END IF;
               IF READBACK = 1 THEN
                  reg_rdata(5 DOWNTO 0)   <= DIM_POLE_ctrl_local.dim_pole_n1;
                  reg_rdata(15 DOWNTO 6)  <= (OTHERS => '0');
                  reg_rdata(30 DOWNTO 16) <= DIM_POLE_ctrl_local.dim_pole_t1;
                  reg_rdata(31)           <= '0';
               ELSE
                  reg_rdata <= (OTHERS => '0');
               END IF;
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"07F8")) THEN  -- PONG (just in case we want to implement a 3D PONG game with IceCubeA) 
               reg_rdata(31 DOWNTO 0) <= X"504F4E47";  -- ASCII PONG
            ELSIF std_match(reg_address(13 DOWNTO 2) , hex2addr(x"07FC")) THEN  -- Firmware Debugging
               reg_rdata(31 DOWNTO 0) <= debugging;
            ELSIF std_match(reg_address(13 DOWNTO 2) , "0010--------") THEN  -- Supernova
            ELSIF std_match(reg_address(13 DOWNTO 2) , "0011--------") THEN  -- R2R Pattern
               NULL;
            ELSIF std_match(reg_address(13 DOWNTO 2) , "010---------") THEN  -- ATWD A pedestal
               NULL;
            ELSIF std_match(reg_address(13 DOWNTO 2) , "011---------") THEN  -- ATWD B pedestal
               NULL;
            ELSE
               reg_rdata(31 DOWNTO 0) <= (OTHERS => '0');
            END IF;
         ELSE                           -- reg_enable='0'
            reg_rdata <= (OTHERS => 'X');
         END IF;  -- reg_enable

         -- reset communications pointers when comm reset
         IF COMM_stat.com_reset_rcvd = '1' THEN
            COMM_ctrl_local.tx_head <= (OTHERS => '0');
            COMM_ctrl_local.rx_tail <= (OTHERS => '0');
         END IF;
      END IF;  -- CLK
   END PROCESS;

   -- setting DOM ID
   COMM_ctrl_local.id_avail <= '1' WHEN id_set = "11" ELSE '0';


   -- map local signals to the ENTITY PORTS     
   DAQ_ctrl      <= DAQ_ctrl_local;
   CS_ctrl       <= CS_ctrl_local;
   LC_ctrl       <= LC_ctrl_local;
   RM_ctrl       <= RM_ctrl_local;
   COMM_ctrl     <= COMM_ctrl_local;
   COMPR_ctrl    <= COMPR_ctrl_local;
   -- COMPR_ctrl.COMPR_mode     <= DAQ_ctrl_local.COMPR_mode; moved to register
   ICETOP_ctrl   <= ICETOP_ctrl_local;
   INCL_ctrl     <= INCL_ctrl_local;
   DIM_POLE_ctrl <= DIM_POLE_ctrl_local;

   CS_FL_aux_reset <= CS_FL_aux_reset_local;


   -- create write enable for the memory blocks (pedestal & R2R)
   R2Rwe      <= '1' WHEN reg_write = '1' AND reg_enable = '1' AND std_match(reg_address(13 DOWNTO 2) , "0011--------") ELSE '0';
   ATWDApedwe <= '1' WHEN reg_write = '1' AND reg_enable = '1' AND std_match(reg_address(13 DOWNTO 2) , "010---------") ELSE '0';
   ATWDBpedwe <= '1' WHEN reg_write = '1' AND reg_enable = '1' AND std_match(reg_address(13 DOWNTO 2) , "011---------") ELSE '0';


   -- stripe interface
   inst_ahb_slave : ahb_slave
      PORT MAP (
         CLK           => CLK,
         RST           => RST,
         -- connections to the stripe
         masterhclk    => masterhclk,
         masterhready  => masterhready,
         masterhgrant  => masterhgrant,
         masterhrdata  => masterhrdata,
         masterhresp   => masterhresp,
         masterhwrite  => masterhwrite,
         masterhlock   => masterhlock,
         masterhbusreq => masterhbusreq,
         masterhaddr   => masterhaddr,
         masterhburst  => masterhburst,
         masterhsize   => masterhsize,
         masterhtrans  => masterhtrans,
         masterhwdata  => masterhwdata,
         -- local bus signals
         reg_write     => reg_write,
         reg_address   => reg_address,
         reg_wdata     => reg_wdata,
         reg_rdata     => reg_rdata,
         reg_enable    => reg_enable,
         reg_wait_sig  => reg_wait_sig
         );

   -- Interrupts
   inst_interrupts : interrupts
      PORT MAP (
         CLK40       => CLK40,
         RST         => RST,
         -- Handshake (ACK)
         int_enable  => int_enable,
         int_clr     => int_clr,
         int_pending => int_pending,
         -- Interrupt to Stripe
         intpld      => intpld,
         -- Interrupt sources
         int0        => cs_flash_now,
         int1        => RM_stat.RM_rate_update,
         int2        => RM_stat.SN_rate_update,
         int3        => '0',
         int4        => '0',
         int5        => '0',
         -- Test Connector
         TC          => OPEN
         );

   -- MEMORYs
   inst_version_rom : version_rom
      PORT MAP (
         address => reg_address(8 DOWNTO 2),
         q       => rom_data
         );

   inst_R2R : R2Rram
      PORT MAP (
         data      => reg_wdata(7 DOWNTO 0),
         wraddress => reg_address(9 DOWNTO 2),
         rdaddress => cs_wf_addr,
         wren      => R2Rwe,
         clock     => CLK,
         q         => cs_wf_data
         );

   inst_ATWDAped : ATWDped
      PORT MAP (
         data      => reg_wdata(9 DOWNTO 0),
         wraddress => reg_address(10 DOWNTO 2),
         rdaddress => ATWD_ped_addr_A,
         wren      => ATWDApedwe,
         clock     => CLK,
         q         => ATWD_ped_data_A
         );

   inst_ATWDBped : ATWDped
      PORT MAP (
         data      => reg_wdata(9 DOWNTO 0),
         wraddress => reg_address(10 DOWNTO 2),
         rdaddress => ATWD_ped_addr_B,
         wren      => ATWDBpedwe,
         clock     => CLK,
         q         => ATWD_ped_data_B
         );

   --debugging
   TC(0) <= int_enable(2);
   TC(1) <= int_clr(2);
   TC(2) <= int_pending(2);
   TC(3) <= RM_stat.SN_rate_update;
   TC(4) <= reg_enable;
   TC(5) <= reg_write;
   TC(6) <= '1' WHEN std_match(reg_address(13 DOWNTO 2) , hex2addr(x"07F8")) ELSE '0';  -- PONG
   TC(7) <= '1' WHEN std_match(reg_address(13 DOWNTO 2) , hex2addr(x"0514")) ELSE '0';  -- rx_addr
   --TC(15 downto 8) <= reg_wdata(7 downto 0);
   PROCESS(CLK, RST)
   BEGIN
      IF RST = '1' THEN
         TC(15 DOWNTO 8) <= (OTHERS => '0');
      ELSIF CLK'EVENT AND CLK = '1' THEN
         IF reg_enable = '1' AND reg_write = '1' AND std_match(reg_address(13 DOWNTO 2) , hex2addr(x"07F8")) THEN
            TC(15 DOWNTO 8) <= reg_wdata(7 DOWNTO 0);
         END IF;
      END IF;
   END PROCESS;
   
END;








