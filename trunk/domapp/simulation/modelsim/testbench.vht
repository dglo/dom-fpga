-- Copyright (C) 1991-2003 Altera Corporation
-- Any  megafunction  design,  and related netlist (encrypted  or  decrypted),
-- support information,  device programming or simulation file,  and any other
-- associated  documentation or information  provided by  Altera  or a partner
-- under  Altera's   Megafunction   Partnership   Program  may  be  used  only
-- to program  PLD  devices (but not masked  PLD  devices) from  Altera.   Any
-- other  use  of such  megafunction  design,  netlist,  support  information,
-- device programming or simulation file,  or any other  related documentation
-- or information  is prohibited  for  any  other purpose,  including, but not
-- limited to  modification,  reverse engineering,  de-compiling, or use  with
-- any other  silicon devices,  unless such use is  explicitly  licensed under
-- a separate agreement with  Altera  or a megafunction partner.  Title to the
-- intellectual property,  including patents,  copyrights,  trademarks,  trade
-- secrets,  or maskworks,  embodied in any such megafunction design, netlist,
-- support  information,  device programming or simulation file,  or any other
-- related documentation or information provided by  Altera  or a megafunction
-- partner, remains with Altera, the megafunction partner, or their respective
-- licensors. No other licenses, including any licenses needed under any third
-- party's intellectual property, are provided herein.

-- ***************************************************************************
-- This file contains a Vhdl test bench template that is freely editable to   
-- suit user's needs .Comments are provided in each section to help the user  
-- fill out necessary details.                                                
-- ***************************************************************************
-- Generated on "12/03/2003 16:25:27"

-- Vhdl Test Bench template for design  :  dom
-- 
-- Simulation tool : ModelSim (VHDL output from Quartus II)
-- 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dom_vhd_tst IS
END dom_vhd_tst;
ARCHITECTURE dom_arch OF dom_vhd_tst IS
-- constants                                                 
-- signals                                                   
    SIGNAL t_sig_CLK1p                : STD_LOGIC;
    SIGNAL t_sig_CLK2p                : STD_LOGIC;
    SIGNAL t_sig_CLK3p                : STD_LOGIC;
    SIGNAL t_sig_CLK4p                : STD_LOGIC;
    SIGNAL t_sig_A_nB                 : STD_LOGIC;
    SIGNAL t_sig_COM_AD_D             : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL t_sig_COM_AD_OTR           : STD_LOGIC;
    SIGNAL t_sig_HDV_Rx               : STD_LOGIC;
    SIGNAL t_sig_FLASH_AD_D           : STD_LOGIC_VECTOR(11 DOWNTO 0);
    SIGNAL t_sig_FL_ATTN              : STD_LOGIC;
    SIGNAL t_sig_FL_TDO               : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_ABAR      : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_A         : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_BBAR      : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_B         : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_ABAR        : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_A           : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_BBAR        : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_B           : STD_LOGIC;
    SIGNAL t_sig_PLD_FPGA_nOE         : STD_LOGIC;
    SIGNAL t_sig_PLD_FPGA_nWE         : STD_LOGIC;
    SIGNAL t_sig_OneSPE               : STD_LOGIC;
    SIGNAL t_sig_MultiSPE             : STD_LOGIC;
    SIGNAL t_sig_FLASH_NCO            : STD_LOGIC;
    SIGNAL t_sig_ATWD1_D              : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_ATWD0_D              : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_TriggerComplete_1    : STD_LOGIC;
    SIGNAL t_sig_TriggerComplete_0    : STD_LOGIC;
    SIGNAL t_sig_UARTRXD              : STD_LOGIC;
    SIGNAL t_sig_INTEXTPIN            : STD_LOGIC;
    SIGNAL t_sig_UARTDSRN             : STD_LOGIC;
    SIGNAL t_sig_UARTCTSN             : STD_LOGIC;
    SIGNAL t_sig_EBIACK               : STD_LOGIC;
    SIGNAL t_sig_CLK_REF              : STD_LOGIC;
    SIGNAL t_sig_nPOR                 : STD_LOGIC;
    SIGNAL t_sig_CLKLK_OUT2p          : STD_LOGIC;
    SIGNAL t_sig_COMM_RESET           : STD_LOGIC;
    SIGNAL t_sig_FPGA_LOADED          : STD_LOGIC;
    SIGNAL t_sig_COM_TX_SLEEP         : STD_LOGIC;
    SIGNAL t_sig_COM_DB               : STD_LOGIC_VECTOR(13 DOWNTO 0);
    SIGNAL t_sig_HDV_RxENA            : STD_LOGIC;
    SIGNAL t_sig_HDV_TxENA            : STD_LOGIC;
    SIGNAL t_sig_HDV_IN               : STD_LOGIC;
    SIGNAL t_sig_FLASH_AD_STBY        : STD_LOGIC;
    SIGNAL t_sig_ATWDTrigger_0        : STD_LOGIC;
    SIGNAL t_sig_OutputEnable_0       : STD_LOGIC;
    SIGNAL t_sig_CounterClock_0       : STD_LOGIC;
    SIGNAL t_sig_ShiftClock_0         : STD_LOGIC;
    SIGNAL t_sig_RampSet_0            : STD_LOGIC;
    SIGNAL t_sig_ChannelSelect_0      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL t_sig_ReadWrite_0          : STD_LOGIC;
    SIGNAL t_sig_AnalogReset_0        : STD_LOGIC;
    SIGNAL t_sig_DigitalReset_0       : STD_LOGIC;
    SIGNAL t_sig_DigitalSet_0         : STD_LOGIC;
    SIGNAL t_sig_ATWD0VDD_SUP         : STD_LOGIC;
    SIGNAL t_sig_ATWDTrigger_1        : STD_LOGIC;
    SIGNAL t_sig_OutputEnable_1       : STD_LOGIC;
    SIGNAL t_sig_CounterClock_1       : STD_LOGIC;
    SIGNAL t_sig_ShiftClock_1         : STD_LOGIC;
    SIGNAL t_sig_RampSet_1            : STD_LOGIC;
    SIGNAL t_sig_ChannelSelect_1      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL t_sig_ReadWrite_1          : STD_LOGIC;
    SIGNAL t_sig_AnalogReset_1        : STD_LOGIC;
    SIGNAL t_sig_DigitalReset_1       : STD_LOGIC;
    SIGNAL t_sig_DigitalSet_1         : STD_LOGIC;
    SIGNAL t_sig_ATWD1VDD_SUP         : STD_LOGIC;
    SIGNAL t_sig_MultiSPE_nl          : STD_LOGIC;
    SIGNAL t_sig_OneSPE_nl            : STD_LOGIC;
    SIGNAL t_sig_FE_TEST_PULSE        : STD_LOGIC;
    SIGNAL t_sig_FE_PULSER_P          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_FE_PULSER_N          : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_R2BUS                : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL t_sig_SingleLED_TRIGGER    : STD_LOGIC;
    SIGNAL t_sig_FL_Trigger           : STD_LOGIC;
    SIGNAL t_sig_FL_Trigger_bar       : STD_LOGIC;
    SIGNAL t_sig_FL_AUX_RESET         : STD_LOGIC;
    SIGNAL t_sig_FL_TMS               : STD_LOGIC;
    SIGNAL t_sig_FL_TCK               : STD_LOGIC;
    SIGNAL t_sig_FL_TDI               : STD_LOGIC;
    SIGNAL t_sig_COINCIDENCE_OUT_DOWN : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_ALATCH    : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_BLATCH    : STD_LOGIC;
    SIGNAL t_sig_COINCIDENCE_OUT_UP   : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_ALATCH      : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_BLATCH      : STD_LOGIC;
    SIGNAL t_sig_PLD_FPGA_BUSY        : STD_LOGIC;
    SIGNAL t_sig_FPGA_D               : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL t_sig_FPGA_DA              : STD_LOGIC;
    SIGNAL t_sig_FPGA_CE              : STD_LOGIC;
    SIGNAL t_sig_FPGA_RW              : STD_LOGIC;
    SIGNAL t_sig_PGM                  : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL t_sig_UARTDTRN             : STD_LOGIC;
    SIGNAL t_sig_UARTRTSN             : STD_LOGIC;
    SIGNAL t_sig_UARTTXD              : STD_LOGIC;
    SIGNAL t_sig_EBIBE                : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL t_sig_EBICSN               : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_EBIADDR              : STD_LOGIC_VECTOR(24 DOWNTO 0);
    SIGNAL t_sig_EBICLK               : STD_LOGIC;
    SIGNAL t_sig_EBIOEN               : STD_LOGIC;
    SIGNAL t_sig_EBIWEN               : STD_LOGIC;
    SIGNAL t_sig_SDRAMADDR            : STD_LOGIC_VECTOR(14 DOWNTO 0);
    SIGNAL t_sig_SDRAMCSN             : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL t_sig_SDRAMDQM             : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_SDRAMRASN            : STD_LOGIC;
    SIGNAL t_sig_SDRAMCASN            : STD_LOGIC;
    SIGNAL t_sig_SDRAMWEN             : STD_LOGIC;
    SIGNAL t_sig_SDRAMCLKE            : STD_LOGIC;
    SIGNAL t_sig_SDRAMCLKN            : STD_LOGIC;
    SIGNAL t_sig_SDRAMCLK             : STD_LOGIC;
    SIGNAL t_sig_PLD_FPGA             : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL t_sig_SDRAMDQS             : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_SDRAMDQ              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL t_sig_EBIDQ                : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL t_sig_UARTRIN              : STD_LOGIC;
    SIGNAL t_sig_UARTDCDN             : STD_LOGIC;
    SIGNAL t_sig_nRESET               : STD_LOGIC;
    COMPONENT domapp
        PORT (
            CLK1p                : IN    STD_LOGIC;
            CLK2p                : IN    STD_LOGIC;
            CLK3p                : IN    STD_LOGIC;
            CLK4p                : IN    STD_LOGIC;
            A_nB                 : IN    STD_LOGIC;
            COM_AD_D             : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            COM_AD_OTR           : IN    STD_LOGIC;
            HDV_Rx               : IN    STD_LOGIC;
            FLASH_AD_D           : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            FL_ATTN              : IN    STD_LOGIC;
            FL_TDO               : IN    STD_LOGIC;
            COINC_DOWN_ABAR      : IN    STD_LOGIC;
            COINC_DOWN_A         : IN    STD_LOGIC;
            COINC_DOWN_BBAR      : IN    STD_LOGIC;
            COINC_DOWN_B         : IN    STD_LOGIC;
            COINC_UP_ABAR        : IN    STD_LOGIC;
            COINC_UP_A           : IN    STD_LOGIC;
            COINC_UP_BBAR        : IN    STD_LOGIC;
            COINC_UP_B           : IN    STD_LOGIC;
            PLD_FPGA_nOE         : IN    STD_LOGIC;
            PLD_FPGA_nWE         : IN    STD_LOGIC;
            OneSPE               : IN    STD_LOGIC;
            MultiSPE             : IN    STD_LOGIC;
            FLASH_NCO            : IN    STD_LOGIC;
            ATWD1_D              : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            ATWD0_D              : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            TriggerComplete_1    : IN    STD_LOGIC;
            TriggerComplete_0    : IN    STD_LOGIC;
            UARTRXD              : IN    STD_LOGIC;
            INTEXTPIN            : IN    STD_LOGIC;
            UARTDSRN             : IN    STD_LOGIC;
            UARTCTSN             : IN    STD_LOGIC;
            EBIACK               : IN    STD_LOGIC;
            CLK_REF              : IN    STD_LOGIC;
            nPOR                 : IN    STD_LOGIC;
            CLKLK_OUT2p          : OUT   STD_LOGIC;
            COMM_RESET           : OUT   STD_LOGIC;
            FPGA_LOADED          : OUT   STD_LOGIC;
            COM_TX_SLEEP         : OUT   STD_LOGIC;
            COM_DB               : OUT   STD_LOGIC_VECTOR(13 DOWNTO 0);
            HDV_RxENA            : OUT   STD_LOGIC;
            HDV_TxENA            : OUT   STD_LOGIC;
            HDV_IN               : OUT   STD_LOGIC;
            FLASH_AD_STBY        : OUT   STD_LOGIC;
            ATWDTrigger_0        : OUT   STD_LOGIC;
            OutputEnable_0       : OUT   STD_LOGIC;
            CounterClock_0       : OUT   STD_LOGIC;
            ShiftClock_0         : OUT   STD_LOGIC;
            RampSet_0            : OUT   STD_LOGIC;
            ChannelSelect_0      : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            ReadWrite_0          : OUT   STD_LOGIC;
            AnalogReset_0        : OUT   STD_LOGIC;
            DigitalReset_0       : OUT   STD_LOGIC;
            DigitalSet_0         : OUT   STD_LOGIC;
            ATWD0VDD_SUP         : OUT   STD_LOGIC;
            ATWDTrigger_1        : OUT   STD_LOGIC;
            OutputEnable_1       : OUT   STD_LOGIC;
            CounterClock_1       : OUT   STD_LOGIC;
            ShiftClock_1         : OUT   STD_LOGIC;
            RampSet_1            : OUT   STD_LOGIC;
            ChannelSelect_1      : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            ReadWrite_1          : OUT   STD_LOGIC;
            AnalogReset_1        : OUT   STD_LOGIC;
            DigitalReset_1       : OUT   STD_LOGIC;
            DigitalSet_1         : OUT   STD_LOGIC;
            ATWD1VDD_SUP         : OUT   STD_LOGIC;
            MultiSPE_nl          : OUT   STD_LOGIC;
            OneSPE_nl            : OUT   STD_LOGIC;
            FE_TEST_PULSE        : OUT   STD_LOGIC;
            FE_PULSER_P          : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            FE_PULSER_N          : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            R2BUS                : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            SingleLED_TRIGGER    : OUT   STD_LOGIC;
            FL_Trigger           : OUT   STD_LOGIC;
            FL_Trigger_bar       : OUT   STD_LOGIC;
            FL_AUX_RESET         : OUT   STD_LOGIC;
            FL_TMS               : OUT   STD_LOGIC;
            FL_TCK               : OUT   STD_LOGIC;
            FL_TDI               : OUT   STD_LOGIC;
            COINCIDENCE_OUT_DOWN : OUT   STD_LOGIC;
            COINC_DOWN_ALATCH    : OUT   STD_LOGIC;
            COINC_DOWN_BLATCH    : OUT   STD_LOGIC;
            COINCIDENCE_OUT_UP   : OUT   STD_LOGIC;
            COINC_UP_ALATCH      : OUT   STD_LOGIC;
            COINC_UP_BLATCH      : OUT   STD_LOGIC;
            PLD_FPGA_BUSY        : OUT   STD_LOGIC;
            --FPGA_D               : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            --FPGA_DA              : OUT   STD_LOGIC;
            --FPGA_CE              : OUT   STD_LOGIC;
            FPGA_RW              : OUT   STD_LOGIC;
            PGM                  : OUT   STD_LOGIC_VECTOR(15 DOWNTO 0);
            UARTDTRN             : OUT   STD_LOGIC;
            UARTRTSN             : OUT   STD_LOGIC;
            UARTTXD              : OUT   STD_LOGIC;
            EBIBE                : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            EBICSN               : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            EBIADDR              : OUT   STD_LOGIC_VECTOR(24 DOWNTO 0);
            EBICLK               : OUT   STD_LOGIC;
            EBIOEN               : OUT   STD_LOGIC;
            EBIWEN               : OUT   STD_LOGIC;
            SDRAMADDR            : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
            SDRAMCSN             : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            SDRAMDQM             : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            SDRAMRASN            : OUT   STD_LOGIC;
            SDRAMCASN            : OUT   STD_LOGIC;
            SDRAMWEN             : OUT   STD_LOGIC;
            SDRAMCLKE            : OUT   STD_LOGIC;
            SDRAMCLKN            : OUT   STD_LOGIC;
            SDRAMCLK             : OUT   STD_LOGIC;
            PLD_FPGA             : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            SDRAMDQS             : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            SDRAMDQ              : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EBIDQ                : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            UARTRIN              : INOUT STD_LOGIC;
            UARTDCDN             : INOUT STD_LOGIC;
            -- inclinometer SPI
      adis16209_RST        : OUT   STD_LOGIC;  -- V1
      adis16209_nCS        : OUT   STD_LOGIC;  -- Y2
      adis16209_SCLK       : OUT   STD_LOGIC;  -- F3
      adis16209_DOUT       : IN    STD_LOGIC;  -- AC2
      adis16209_DIN        : OUT   STD_LOGIC;  -- AA2
      adis16209_PWR        : OUT   STD_LOGIC;  -- E3
            nRESET               : INOUT STD_LOGIC);
    END COMPONENT;

    SIGNAL CLK : STD_LOGIC := '0';      -- 20MHz clock

    COMPONENT atwd_model
        PORT (
            TriggerComplete : OUT STD_LOGIC;
            CounterClock    : IN  STD_LOGIC;
            ShiftClock      : IN  STD_LOGIC;
            RampReset       : IN  STD_LOGIC;
            Channel         : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            ReadWrite       : IN  STD_LOGIC;
            AnalogReset     : IN  STD_LOGIC;
            DigitalReset    : IN  STD_LOGIC;
            DigitalSet      : IN  STD_LOGIC;
            TriggerInput    : IN  STD_LOGIC;
            OE              : IN  STD_LOGIC;
            D               : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT FADC_model
        GENERIC (
            width : INTEGER := 10);
        PORT (
            CLK : IN  STD_LOGIC;
            D   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0));
    END COMPONENT;


BEGIN
    tb : domapp PORT MAP (
-- list connections between master ports and signals
        CLK1p                => t_sig_CLK1p,
        CLK2p                => t_sig_CLK2p,
        CLK3p                => t_sig_CLK3p,
        CLK4p                => t_sig_CLK4p,
        A_nB                 => t_sig_A_nB,
        COM_AD_D             => t_sig_COM_AD_D,
        COM_AD_OTR           => t_sig_COM_AD_OTR,
        HDV_Rx               => t_sig_HDV_Rx,
        FLASH_AD_D           => t_sig_FLASH_AD_D,
        FL_ATTN              => t_sig_FL_ATTN,
        FL_TDO               => t_sig_FL_TDO,
        COINC_DOWN_ABAR      => t_sig_COINC_DOWN_ABAR,
        COINC_DOWN_A         => t_sig_COINC_DOWN_A,
        COINC_DOWN_BBAR      => t_sig_COINC_DOWN_BBAR,
        COINC_DOWN_B         => t_sig_COINC_DOWN_B,
        COINC_UP_ABAR        => t_sig_COINC_UP_ABAR,
        COINC_UP_A           => t_sig_COINC_UP_A,
        COINC_UP_BBAR        => t_sig_COINC_UP_BBAR,
        COINC_UP_B           => t_sig_COINC_UP_B,
        PLD_FPGA_nOE         => t_sig_PLD_FPGA_nOE,
        PLD_FPGA_nWE         => t_sig_PLD_FPGA_nWE,
        OneSPE               => t_sig_OneSPE,
        MultiSPE             => t_sig_MultiSPE,
        FLASH_NCO            => t_sig_FLASH_NCO,
        ATWD1_D              => t_sig_ATWD1_D,
        ATWD0_D              => t_sig_ATWD0_D,
        TriggerComplete_1    => t_sig_TriggerComplete_1,
        TriggerComplete_0    => t_sig_TriggerComplete_0,
        UARTRXD              => t_sig_UARTRXD,
        INTEXTPIN            => t_sig_INTEXTPIN,
        UARTDSRN             => t_sig_UARTDSRN,
        UARTCTSN             => t_sig_UARTCTSN,
        EBIACK               => t_sig_EBIACK,
        CLK_REF              => t_sig_CLK_REF,
        nPOR                 => t_sig_nPOR,
        CLKLK_OUT2p          => t_sig_CLKLK_OUT2p,
        COMM_RESET           => t_sig_COMM_RESET,
        FPGA_LOADED          => t_sig_FPGA_LOADED,
        COM_TX_SLEEP         => t_sig_COM_TX_SLEEP,
        COM_DB               => t_sig_COM_DB,
        HDV_RxENA            => t_sig_HDV_RxENA,
        HDV_TxENA            => t_sig_HDV_TxENA,
        HDV_IN               => t_sig_HDV_IN,
        FLASH_AD_STBY        => t_sig_FLASH_AD_STBY,
        ATWDTrigger_0        => t_sig_ATWDTrigger_0,
        OutputEnable_0       => t_sig_OutputEnable_0,
        CounterClock_0       => t_sig_CounterClock_0,
        ShiftClock_0         => t_sig_ShiftClock_0,
        RampSet_0            => t_sig_RampSet_0,
        ChannelSelect_0      => t_sig_ChannelSelect_0,
        ReadWrite_0          => t_sig_ReadWrite_0,
        AnalogReset_0        => t_sig_AnalogReset_0,
        DigitalReset_0       => t_sig_DigitalReset_0,
        DigitalSet_0         => t_sig_DigitalSet_0,
        ATWD0VDD_SUP         => t_sig_ATWD0VDD_SUP,
        ATWDTrigger_1        => t_sig_ATWDTrigger_1,
        OutputEnable_1       => t_sig_OutputEnable_1,
        CounterClock_1       => t_sig_CounterClock_1,
        ShiftClock_1         => t_sig_ShiftClock_1,
        RampSet_1            => t_sig_RampSet_1,
        ChannelSelect_1      => t_sig_ChannelSelect_1,
        ReadWrite_1          => t_sig_ReadWrite_1,
        AnalogReset_1        => t_sig_AnalogReset_1,
        DigitalReset_1       => t_sig_DigitalReset_1,
        DigitalSet_1         => t_sig_DigitalSet_1,
        ATWD1VDD_SUP         => t_sig_ATWD1VDD_SUP,
        MultiSPE_nl          => t_sig_MultiSPE_nl,
        OneSPE_nl            => t_sig_OneSPE_nl,
        FE_TEST_PULSE        => t_sig_FE_TEST_PULSE,
        FE_PULSER_P          => t_sig_FE_PULSER_P,
        FE_PULSER_N          => t_sig_FE_PULSER_N,
        R2BUS                => t_sig_R2BUS,
        SingleLED_TRIGGER    => t_sig_SingleLED_TRIGGER,
        FL_Trigger           => t_sig_FL_Trigger,
        FL_Trigger_bar       => t_sig_FL_Trigger_bar,
        FL_AUX_RESET         => t_sig_FL_AUX_RESET,
        FL_TMS               => t_sig_FL_TMS,
        FL_TCK               => t_sig_FL_TCK,
        FL_TDI               => t_sig_FL_TDI,
        COINCIDENCE_OUT_DOWN => t_sig_COINCIDENCE_OUT_DOWN,
        COINC_DOWN_ALATCH    => t_sig_COINC_DOWN_ALATCH,
        COINC_DOWN_BLATCH    => t_sig_COINC_DOWN_BLATCH,
        COINCIDENCE_OUT_UP   => t_sig_COINCIDENCE_OUT_UP,
        COINC_UP_ALATCH      => t_sig_COINC_UP_ALATCH,
        COINC_UP_BLATCH      => t_sig_COINC_UP_BLATCH,
        PLD_FPGA_BUSY        => t_sig_PLD_FPGA_BUSY,
        --FPGA_D               => t_sig_FPGA_D,
        --FPGA_DA              => t_sig_FPGA_DA,
        --FPGA_CE              => t_sig_FPGA_CE,
        FPGA_RW              => t_sig_FPGA_RW,
        PGM                  => t_sig_PGM,
        UARTDTRN             => t_sig_UARTDTRN,
        UARTRTSN             => t_sig_UARTRTSN,
        UARTTXD              => t_sig_UARTTXD,
        EBIBE                => t_sig_EBIBE,
        EBICSN               => t_sig_EBICSN,
        EBIADDR              => t_sig_EBIADDR,
        EBICLK               => t_sig_EBICLK,
        EBIOEN               => t_sig_EBIOEN,
        EBIWEN               => t_sig_EBIWEN,
        SDRAMADDR            => t_sig_SDRAMADDR,
        SDRAMCSN             => t_sig_SDRAMCSN,
        SDRAMDQM             => t_sig_SDRAMDQM,
        SDRAMRASN            => t_sig_SDRAMRASN,
        SDRAMCASN            => t_sig_SDRAMCASN,
        SDRAMWEN             => t_sig_SDRAMWEN,
        SDRAMCLKE            => t_sig_SDRAMCLKE,
        SDRAMCLKN            => t_sig_SDRAMCLKN,
        SDRAMCLK             => t_sig_SDRAMCLK,
        PLD_FPGA             => t_sig_PLD_FPGA,
        SDRAMDQS             => t_sig_SDRAMDQS,
        SDRAMDQ              => t_sig_SDRAMDQ,
        EBIDQ                => t_sig_EBIDQ,
        UARTRIN              => t_sig_UARTRIN,
        UARTDCDN             => t_sig_UARTDCDN,
        -- inclinometer SPI
      adis16209_RST        => open,
      adis16209_nCS        => open,
      adis16209_SCLK       => open,
      adis16209_DOUT       => '0',
      adis16209_DIN        => open,
      adis16209_PWR        => open,
        nRESET               => t_sig_nRESET
        );

    t_sig_nPOR    <= '1' , '0' AFTER 100 ns;
    t_sig_nRESET  <= '1' , '0' AFTER 100 ns;
    CLK           <= NOT CLK   AFTER 25 ns;
    t_sig_CLK1p   <= CLK;
    t_sig_CLK2p   <= CLK;
    t_sig_CLK3p   <= CLK;
    t_sig_CLK4p   <= CLK;
    t_sig_CLK_REF <= CLK;


--    t_sig_OneSPE   <= '0', '1' AFTER 500 ns, '0' AFTER 510 ns, '1' AFTER 5500 ns, '0' AFTER 5505 ns, '1' AFTER 150000 ns, '0' AFTER 150005 ns, '1' AFTER 200000 ns, '0' AFTER 200005 ns, '1' AFTER 300000 ns, '0' AFTER 300005 ns, '1' AFTER 350000 ns, '0' AFTER 350010 ns, '1' AFTER 500000 ns, '0' AFTER 500010 ns, '1' AFTER 501000 ns, '0' AFTER 501010 ns;
process
  begin
    wait for 1000 ns;
    t_sig_OneSPE <= '1';
    wait for 10 ns;
    t_sig_OneSPE <= '0';
  end process;

    t_sig_MultiSPE <= '0';


    -- ATWD
    atwd_A : atwd_model
        PORT MAP(
            TriggerComplete => t_sig_TriggerComplete_0,
            CounterClock    => t_sig_CounterClock_0,
            ShiftClock      => t_sig_ShiftClock_0,
            RampReset       => t_sig_RampSet_0,
            Channel         => t_sig_ChannelSelect_0,
            ReadWrite       => t_sig_ReadWrite_0,
            AnalogReset     => t_sig_AnalogReset_0,
            DigitalReset    => t_sig_DigitalReset_0,
            DigitalSet      => t_sig_DigitalSet_0,
            TriggerInput    => t_sig_ATWDTrigger_0,
            OE              => t_sig_OutputEnable_0,
            D               => t_sig_ATWD0_D
            );
    atwd_B : atwd_model
        PORT MAP(
            TriggerComplete => t_sig_TriggerComplete_1,
            CounterClock    => t_sig_CounterClock_1,
            ShiftClock      => t_sig_ShiftClock_1,
            RampReset       => t_sig_RampSet_1,
            Channel         => t_sig_ChannelSelect_1,
            ReadWrite       => t_sig_ReadWrite_1,
            AnalogReset     => t_sig_AnalogReset_1,
            DigitalReset    => t_sig_DigitalReset_1,
            DigitalSet      => t_sig_DigitalSet_1,
            TriggerInput    => t_sig_ATWDTrigger_1,
            OE              => t_sig_OutputEnable_1,
            D               => t_sig_ATWD1_D
            );

    -- FADC
    FADC : FADC_model
        GENERIC MAP (
            width => 10)
        PORT MAP (
            CLK => t_sig_CLKLK_OUT2p,
            D   => t_sig_FLASH_AD_D (11 DOWNTO 2)
            );
    t_sig_FLASH_NCO <= '0';
    t_sig_FLASH_AD_D (1 DOWNTO 0) <= "UU";



    init : PROCESS
-- variable declarations
    BEGIN
        -- code that executes only once
        WAIT;
    END PROCESS init;

    always : PROCESS
-- optional sensitivity list                                  
-- (        )                                                 
-- variable declarations                                      
    BEGIN
        -- code executes for every event on sensitivity list  
        WAIT;
    END PROCESS always;
END dom_arch;






