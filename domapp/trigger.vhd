-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : trigger.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2012-07-09
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module launched the ATWDs and fADC capture including
--              ping/pong
-------------------------------------------------------------------------------
-- Copyright (c) 2003 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten 
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE WORK.ctrl_data_types.ALL;

ENTITY trigger IS
   PORT (
      CLK40             : IN  STD_LOGIC;
      RST               : IN  STD_LOGIC;
      -- enable
      enable_DAQ        : IN  STD_LOGIC;
      enable_AB         : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
      trigger_enable    : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
      heart_beat_mode   : IN  STD_LOGIC;
      systime           : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
      DIM_POLE_ctrl     : IN  DIM_POLE_STRUCT;
      -- trigger sources
      cs_trigger        : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);  -- calibration sources
      lc_trigger        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);  -- local coincidence
      -- handshake
      busy_A            : IN  STD_LOGIC;
      busy_B            : IN  STD_LOGIC;
      busy_FADC_A       : IN  STD_LOGIC;
      busy_FADC_B       : IN  STD_LOGIC;
      rst_trg_A         : IN  STD_LOGIC;
      rst_trg_B         : IN  STD_LOGIC;
      ATWDTrigger_sig_A : OUT STD_LOGIC;
      ATWDTrigger_sig_B : OUT STD_LOGIC;
      trigger_word      : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      veto_LC_abort_A   : OUT STD_LOGIC;
      veto_LC_abort_B   : OUT STD_LOGIC;
      -- discriminator
      MultiSPE          : IN  STD_LOGIC;
      OneSPE            : IN  STD_LOGIC;
      MultiSPE_nl       : OUT STD_LOGIC;
      OneSPE_nl         : OUT STD_LOGIC;
      -- trigger outputs
      ATWDTrigger_A     : OUT STD_LOGIC;
      ATWDTrigger_B     : OUT STD_LOGIC;
      discSPEpulse      : OUT STD_LOGIC;
      discMPEpulse      : OUT STD_LOGIC;
      SPE_level_stretch : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
      -- test connector
      TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
      );
END trigger;

ARCHITECTURE trigger_arch OF trigger IS

   COMPONENT dim_pole_flag
      PORT (
         CLK40           : IN  STD_LOGIC;
         RST             : IN  STD_LOGIC;
         -- setup
         disc_select     : IN  STD_LOGIC;  -- 0 = SPE; 1 = MPE
         deadtime        : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
         systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
         dim_pole_n0     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);  -- trigger count
         dim_pole_n1     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
         dim_pole_t0     : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);  -- time window
         dim_pole_t1     : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
         -- discriminator
         discSPEpulse    : IN  STD_LOGIC;
         discMPEpulse    : IN  STD_LOGIC;
         -- readout status
         triggered_A     : IN  STD_LOGIC;
         triggered_B     : IN  STD_LOGIC;
         -- dim pole flag
         dim_pole_status : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
         -- test connector
         TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
         );
   END COMPONENT;

   SIGNAL last_A : STD_LOGIC;

   SIGNAL launch_enable_A : STD_LOGIC;
   SIGNAL launch_enable_B : STD_LOGIC;

   SIGNAL   launch_mode_A   : STD_LOGIC_VECTOR (1 DOWNTO 0);
   SIGNAL   launch_mode_B   : STD_LOGIC_VECTOR (1 DOWNTO 0);
   CONSTANT TRIG_ENABLE_SPE : STD_LOGIC_VECTOR (1 DOWNTO 0) := "00";
   CONSTANT TRIG_ENABLE_MPE : STD_LOGIC_VECTOR (1 DOWNTO 0) := "11";
   CONSTANT TRIG_SET        : STD_LOGIC_VECTOR (1 DOWNTO 0) := "01";
   CONSTANT TRIG_RST        : STD_LOGIC_VECTOR (1 DOWNTO 0) := "10";
   SIGNAL   trig_lut_A      : STD_LOGIC;
   SIGNAL   trig_lut_B      : STD_LOGIC;

   SIGNAL discSPE         : STD_LOGIC := '0';
   SIGNAL discMPE         : STD_LOGIC := '0';
   SIGNAL rst_trigger_spe : STD_LOGIC;
   SIGNAL rst_trigger_mpe : STD_LOGIC;

   SIGNAL discSPE_latch : STD_LOGIC;
   SIGNAL discSPE_pulse : STD_LOGIC;
   SIGNAL discMPE_latch : STD_LOGIC;
   SIGNAL discMPE_pulse : STD_LOGIC;

   SIGNAL enable_spe_sig_A : STD_LOGIC;
   SIGNAL enable_mpe_sig_A : STD_LOGIC;
   SIGNAL enable_spe_sig_B : STD_LOGIC;
   SIGNAL enable_mpe_sig_B : STD_LOGIC;
   SIGNAL set_sig_A        : STD_LOGIC;
   SIGNAL rst_sig_A        : STD_LOGIC;
   SIGNAL set_sig_B        : STD_LOGIC;
   SIGNAL rst_sig_B        : STD_LOGIC;
   SIGNAL force_sig        : STD_LOGIC;

   SIGNAL ATWDTrigger_A_sig : STD_LOGIC;
   SIGNAL ATWDTrigger_B_sig : STD_LOGIC;

   SIGNAL triggered_A : STD_LOGIC;
   SIGNAL triggered_B : STD_LOGIC;

   SIGNAL SPE_enable : STD_LOGIC;
   SIGNAL MPE_enable : STD_LOGIC;

   SIGNAL ATWDTrigger_A_shift : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL ATWDTrigger_B_shift : STD_LOGIC_VECTOR (3 DOWNTO 0);
   SIGNAL trig_veto_short_A   : STD_LOGIC;
   SIGNAL trig_veto_short_B   : STD_LOGIC;
   SIGNAL veto_trig           : STD_LOGIC;

   SIGNAL dim_pole_status : STD_LOGIC_VECTOR (1 DOWNTO 0);

BEGIN

   MultiSPE_nl <= '1';
   OneSPE_nl   <= '1';

--      veto_trig       <= '1' WHEN trig_veto_short_A='1' OR trig_veto_short_B='1' ELSE '0'; -- busy_FADC_A='1' OR busy_FADC_B='1' ELSE '0'; -- modify for timestamp mode !!!!
   veto_trig <= '1' WHEN trig_veto_short_A = '1' OR trig_veto_short_B = '1' OR busy_FADC_A = '1' OR busy_FADC_B = '1' ELSE '0';
--      veto_trig       <= '1' WHEN busy_FADC_A='1' OR busy_FADC_B='1' ELSE '0'; -- modify for timestamp mode !!!!


   SPE_enable <= '1' WHEN trigger_enable(1 DOWNTO 0) = "01" OR  -- SPE enable
                 trigger_enable(1 DOWNTO 0) = "11" ELSE  -- SPE and MPE anabled => SPE superseds
                 '0';
   MPE_enable <= '1' WHEN trigger_enable(1 DOWNTO 0) = "10" ELSE '0';

   launch_enable_A <= enable_AB(0) AND enable_DAQ AND ((NOT last_A AND NOT busy_A AND NOT triggered_A) OR (last_A AND (busy_B OR triggered_B) AND NOT busy_A AND NOT triggered_A) OR NOT enable_AB(1)) AND NOT veto_trig;
   launch_enable_B <= enable_AB(1) AND enable_DAQ AND ((last_A AND NOT busy_B AND NOT triggered_B) OR (NOT last_A AND (busy_A OR triggered_A) AND NOT busy_B AND NOT triggered_B) OR NOT enable_AB(0)) AND NOT veto_trig;

   -- Discriminator latch FFs
   disc_FF_SPE : PROCESS(OneSPE, rst_trigger_spe)
   BEGIN
      IF rst_trigger_spe = '1' THEN
         discSPE <= '0';
      ELSIF OneSPE'EVENT AND OneSPE = '1' THEN
         discSPE <= '1';
      END IF;
   END PROCESS;

   disc_FF_SPE_reset : PROCESS(RST, CLK40)
   BEGIN
      IF RST = '1' THEN
         discSPE_latch   <= '1';
         discSPE_pulse   <= '0';
         rst_trigger_spe <= '0';
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         discSPE_latch   <= discSPE;
         discSPE_pulse   <= discSPE_latch AND NOT rst_trigger_spe;
         rst_trigger_spe <= discSPE_pulse AND discSPE_latch AND NOT rst_trigger_spe;
      END IF;
   END PROCESS;
   -- rst_trigger_spe    <= NOT discSPE_pulse AND discSPE_latch;
   discSPEpulse <= NOT discSPE_pulse AND discSPE_latch;

   disc_FF_MPE : PROCESS(MultiSPE, rst_trigger_mpe)
   BEGIN
      IF rst_trigger_mpe = '1' THEN
         discMPE <= '0';
      ELSIF MultiSPE'EVENT AND MultiSPE = '1' THEN
         discMPE <= '1';
      END IF;
   END PROCESS;

   disc_FF_MPE_reset : PROCESS(RST, CLK40)
   BEGIN
      IF RST = '1' THEN
         discMPE_latch   <= '1';
         discMPE_pulse   <= '0';
         rst_trigger_mpe <= '0';
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         discMPE_latch   <= discMPE;
         discMPE_pulse   <= discMPE_latch AND NOT rst_trigger_mpe;
         rst_trigger_mpe <= discMPE_pulse AND discMPE_latch AND NOT rst_trigger_mpe;
      END IF;
   END PROCESS;
   -- rst_trigger_mpe    <= NOT discMPE_pulse AND discMPE_latch;
   discMPEpulse <= NOT discMPE_pulse AND discMPE_latch;


   -- Launchmode
   enable_spe_sig_A <= launch_enable_A AND SPE_enable;
   enable_mpe_sig_A <= launch_enable_A AND MPE_enable;
   set_sig_A        <= triggered_A
                       OR (force_sig AND launch_enable_A);
   rst_sig_A <= rst_trg_A;

   enable_spe_sig_B <= launch_enable_B AND SPE_enable;
   enable_mpe_sig_B <= launch_enable_B AND MPE_enable;
   set_sig_B        <= triggered_B
                       OR (force_sig AND launch_enable_B);
   rst_sig_B <= rst_trg_B;

   force_sig <= '1' WHEN ((cs_trigger AND trigger_enable(7 DOWNTO 2)) /= "000000")
                OR ((lc_trigger AND trigger_enable(9 DOWNTO 8)) /= "00")
                ELSE '0';
   
   launchmode_A : PROCESS(CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         launch_mode_A <= TRIG_RST;
      ELSIF CLK40'EVENT AND CLK40 = '0' THEN
         IF rst_sig_A = '1' THEN
            launch_mode_A <= TRIG_RST;
         ELSIF set_sig_A = '1' THEN
            launch_mode_A <= TRIG_SET;
         ELSIF enable_spe_sig_A = '1' THEN
            launch_mode_A <= TRIG_ENABLE_SPE;
         ELSIF enable_mpe_sig_A = '1' THEN
            launch_mode_A <= TRIG_ENABLE_MPE;
         ELSE
            launch_mode_A <= TRIG_RST;
         END IF;
      END IF;
   END PROCESS;

   launchmode_B : PROCESS(CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         launch_mode_B <= TRIG_RST;
      ELSIF CLK40'EVENT AND CLK40 = '0' THEN
         IF rst_sig_B = '1' THEN
            launch_mode_B <= TRIG_RST;
         ELSIF set_sig_B = '1' THEN
            launch_mode_B <= TRIG_SET;
         ELSIF enable_spe_sig_B = '1' THEN
            launch_mode_B <= TRIG_ENABLE_SPE;
         ELSIF enable_mpe_sig_B = '1' THEN
            launch_mode_B <= TRIG_ENABLE_MPE;
         ELSE
            launch_mode_B <= TRIG_RST;
         END IF;
      END IF;
   END PROCESS;

   -- LUT before ATWD Launch FF
   trig_lut_A <= discSPE WHEN launch_mode_A = TRIG_ENABLE_SPE ELSE
                 discMPE WHEN launch_mode_A = TRIG_ENABLE_MPE ELSE
                 '0'     WHEN launch_mode_A = TRIG_RST        ELSE
                 '1'     WHEN launch_mode_A = TRIG_SET        ELSE
                 'X';
   
   trig_lut_B <= discSPE WHEN launch_mode_B = TRIG_ENABLE_SPE ELSE
                 discMPE WHEN launch_mode_B = TRIG_ENABLE_MPE ELSE
                 '0'     WHEN launch_mode_B = TRIG_RST        ELSE
                 '1'     WHEN launch_mode_B = TRIG_SET        ELSE
                 'X';

   -- ATWD Launch FF
   ATWD_TriggerInput_A : PROCESS(CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         ATWDTrigger_A_sig <= '0';
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         ATWDTrigger_A_sig <= trig_lut_A;
      END IF;
   END PROCESS;
   ATWDTrigger_A     <= ATWDTrigger_A_sig;
   triggered_A       <= ATWDTrigger_A_sig;
   ATWDTrigger_sig_A <= ATWDTrigger_A_sig;

   ATWD_TriggerInput_B : PROCESS(CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         ATWDTrigger_B_sig <= '0';
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         ATWDTrigger_B_sig <= trig_lut_B;
      END IF;
   END PROCESS;
   ATWDTrigger_B     <= ATWDTrigger_B_sig;
   triggered_B       <= ATWDTrigger_B_sig;
   ATWDTrigger_sig_B <= ATWDTrigger_B_sig;

   last_ATWD_used_and_veto : PROCESS(CLK40, RST)
   BEGIN
      IF RST = '1' THEN
         last_A              <= '0';
         ATWDTrigger_A_shift <= (OTHERS => '0');
         ATWDTrigger_B_shift <= (OTHERS => '0');
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         IF ATWDTrigger_A_sig = '1' THEN
            ATWDTrigger_A_shift(3 DOWNTO 1) <= ATWDTrigger_A_shift(2 DOWNTO 0);
            ATWDTrigger_A_shift(0)          <= '1';
         ELSE
            ATWDTrigger_A_shift <= (OTHERS => '0');
         END IF;
         IF ATWDTrigger_B_sig = '1' THEN
            ATWDTrigger_B_shift(3 DOWNTO 1) <= ATWDTrigger_B_shift(2 DOWNTO 0);
            ATWDTrigger_B_shift(0)          <= '1';
         ELSE
            ATWDTrigger_B_shift <= (OTHERS => '0');
         END IF;

         IF ATWDTrigger_A_sig = '1' AND ATWDTrigger_A_shift(0) = '0' THEN
            last_A <= '1';
         ELSIF ATWDTrigger_B_sig = '1' AND ATWDTrigger_B_shift(0) = '0' THEN
            last_A <= '0';
         END IF;
      END IF;
   END PROCESS;
   trig_veto_short_A <= '1' WHEN ATWDTrigger_A_sig = '1' AND ATWDTrigger_A_shift(3) = '0' ELSE '0';
   trig_veto_short_B <= '1' WHEN ATWDTrigger_B_sig = '1' AND ATWDTrigger_B_shift(3) = '0' ELSE '0';


   -- trigger_word (15 DOWNTO 10) <= (OTHERS => '0');
   trigger_word (15 DOWNTO 12) <= (OTHERS => '0');
   trigger_word (11 DOWNTO 10) <= dim_pole_status;
   -- trigger_word (9 DOWNTO 8)  <= LC_trigger;
   -- trigger_word (7 DOWNTO 2)  <= CS_trigger;
   PROCESS (RST, CLK40)                 -- to adjust the timing for ADC_control
   BEGIN
      IF RST = '1' THEN
         trigger_word (1)          <= '0';
         trigger_word (0)          <= '0';
         trigger_word (9 DOWNTO 8) <= (OTHERS => '0');
         trigger_word (7 DOWNTO 2) <= (OTHERS => '0');
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         trigger_word (1)          <= discMPE;
         trigger_word (0)          <= discSPE;
         trigger_word (9 DOWNTO 8) <= LC_trigger;
         trigger_word (7 DOWNTO 2) <= CS_trigger;

      END IF;
   END PROCESS;

   VETO_LC : PROCESS (CLK40, RST)
      VARIABLE cs_trigger_hold : STD_LOGIC_VECTOR (5 DOWNTO 0);
      --VARIABLE cs_trigger_hold1 : STD_LOGIC_VECTOR (5 DOWNTO 0);
   BEGIN
      IF RST = '1' THEN
         veto_LC_abort_A <= '0';
         veto_LC_abort_B <= '0';
         cs_trigger_hold := (OTHERS => '0');
         --cs_trigger_hold1 := (OTHERS=>'0');
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         IF ATWDTrigger_A_sig = '1' AND ATWDTrigger_A_shift(0) = '0' AND heart_beat_mode = '1' AND ((cs_trigger_hold AND trigger_enable(7 DOWNTO 2)) /= "000000") THEN
            veto_LC_abort_A <= '1';
         END IF;
         IF rst_trg_A = '1' THEN
            veto_LC_abort_A <= '0';
         END IF;
         IF ATWDTrigger_B_sig = '1' AND ATWDTrigger_B_shift(0) = '0' AND heart_beat_mode = '1' AND ((cs_trigger_hold AND trigger_enable(7 DOWNTO 2)) /= "000000") THEN
            veto_LC_abort_B <= '1';
         END IF;
         IF rst_trg_B = '1' THEN
            veto_LC_abort_B <= '0';
         END IF;

         cs_trigger_hold := cs_trigger;
         --cs_trigger_hold  := cs_trigger_hold1;
         --cs_trigger_hold1 := cs_trigger;
      END IF;
   END PROCESS;

   -- synchronize and stretch the incomming discriminator signals
   -- used to tag ATWD waveforms (PMT signal present in waveform)
   PROCESS (CLK40, RST)
      VARIABLE OneSPE_sync      : STD_LOGIC_VECTOR (1 DOWNTO 0);
      VARIABLE MultiSPE_sync    : STD_LOGIC_VECTOR (1 DOWNTO 0);
      VARIABLE OneSPE_stretch   : STD_LOGIC_VECTOR (2 DOWNTO 0);
      VARIABLE MultiSPE_stretch : STD_LOGIC_VECTOR (2 DOWNTO 0);
   BEGIN
      IF RST = '1' THEN
         OneSPE_sync       := "00";
         MultiSPE_sync     := "00";
         OneSPE_stretch    := "000";
         MultiSPE_stretch  := "000";
         SPE_level_stretch <= "00";
      ELSIF CLK40'EVENT AND CLK40 = '1' THEN
         SPE_level_stretch(0)         <= OneSPE_sync(0) OR OneSPE_stretch(2) OR OneSPE_stretch(1) OR OneSPE_stretch(0);
         SPE_level_stretch(1)         <= MultiSPE_sync(0) OR MultiSPE_stretch(2) OR MultiSPE_stretch(1) OR MultiSPE_stretch(0);
         -- strech discriminator signals
         OneSPE_stretch(1 DOWNTO 0)   := OneSPE_stretch(2 DOWNTO 1);
         OneSPE_stretch(2)            := OneSPE_sync(0) OR discSPE_pulse;
         MultiSPE_stretch(1 DOWNTO 0) := MultiSPE_stretch(2 DOWNTO 1);
         MultiSPE_stretch(2)          := MultiSPE_sync(0) OR discMPE_pulse;
         -- synchronize inputs
         OneSPE_sync(0)               := OneSPE_sync(1);
         OneSPE_sync(1)               := OneSPE;
         MultiSPE_sync(0)             := MultiSPE_sync(1);
         MultiSPE_sync(1)             := MultiSPE;
      END IF;
   END PROCESS;

   dim_pole_flag_inst : dim_pole_flag
      PORT MAP (
         CLK40           => CLK40,
         RST             => RST,
         -- setup
         disc_select     => DIM_POLE_ctrl.disc_select,
         deadtime        => DIM_POLE_ctrl.deadtime,
         systime         => systime,
         dim_pole_n0     => DIM_POLE_ctrl.dim_pole_n0,
         dim_pole_n1     => DIM_POLE_ctrl.dim_pole_n1,
         dim_pole_t0     => DIM_POLE_ctrl.dim_pole_t0,
         dim_pole_t1     => DIM_POLE_ctrl.dim_pole_t1,
         -- discriminator
         discSPEpulse    => discSPE_pulse,
         discMPEpulse    => discMPE_pulse,
         -- readout status
         triggered_A     => triggered_A,
         triggered_B     => triggered_B,
         -- dim pole flag
         dim_pole_status => dim_pole_status,
         -- test connector
         TC              => OPEN
         );

END trigger_arch;
