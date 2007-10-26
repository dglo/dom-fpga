-- Copyright (C) 1991-2002 Altera Corporation
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
-- Generated on "06/24/2003 10:59:26"

-- Vhdl Test Bench template for design  :  simpletest
-- 
-- Simulation tool : MODELSIM (VHDL OUTPUT FROM QUARTUS II)
-- 

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY simpletest_vhd_tst IS
END simpletest_vhd_tst;


ARCHITECTURE simpletest_arch OF simpletest_vhd_tst IS
-- constants                                                 
-- signals                                                   
    SIGNAL t_sig_CLK1p                : STD_LOGIC;
    SIGNAL t_sig_CLK2p                : STD_LOGIC;
    SIGNAL t_sig_CLK3p                : STD_LOGIC;
    SIGNAL t_sig_COM_AD_D             : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_COM_AD_OTR           : STD_LOGIC;
    SIGNAL t_sig_HDV_Rx               : STD_LOGIC;
    SIGNAL t_sig_CLK4p                : STD_LOGIC;
    SIGNAL t_sig_OneSPE               : STD_LOGIC;
    SIGNAL t_sig_A_nB                 : STD_LOGIC;
    SIGNAL t_sig_FLASH_AD_D           : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_COINC_DOWN_A         : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_ABAR      : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_B         : STD_LOGIC;
    SIGNAL t_sig_FLASH_NCO            : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_BBAR      : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_A           : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_ABAR        : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_B           : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_BBAR        : STD_LOGIC;
    SIGNAL t_sig_FL_ATTN              : STD_LOGIC;
    SIGNAL t_sig_FL_TDO               : STD_LOGIC;
    SIGNAL t_sig_MultiSPE             : STD_LOGIC;
    SIGNAL t_sig_ATWD1_D              : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_ATWD0_D              : STD_LOGIC_VECTOR(9 DOWNTO 0);
    SIGNAL t_sig_TriggerComplete_0    : STD_LOGIC;
    SIGNAL t_sig_TriggerComplete_1    : STD_LOGIC;
    SIGNAL t_sig_UARTRXD              : STD_LOGIC;
    SIGNAL t_sig_INTEXTPIN            : STD_LOGIC;
    SIGNAL t_sig_UARTDSRN             : STD_LOGIC;
    SIGNAL t_sig_UARTCTSN             : STD_LOGIC;
    SIGNAL t_sig_EBIACK               : STD_LOGIC;
    SIGNAL t_sig_CLK_REF              : STD_LOGIC;
    SIGNAL t_sig_nPOR                 : STD_LOGIC;
    SIGNAL t_sig_CLKLK_OUT2p          : STD_LOGIC;
    SIGNAL t_sig_COM_TX_SLEEP         : STD_LOGIC;
    SIGNAL t_sig_COM_DB               : STD_LOGIC_VECTOR(13 DOWNTO 6);
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
    SIGNAL t_sig_R2BUS                : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL t_sig_SingleLED_TRIGGER    : STD_LOGIC;
    SIGNAL t_sig_COINCIDENCE_OUT_DOWN : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_ALATCH    : STD_LOGIC;
    SIGNAL t_sig_COINC_DOWN_BLATCH    : STD_LOGIC;
    SIGNAL t_sig_COINCIDENCE_OUT_UP   : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_ALATCH      : STD_LOGIC;
    SIGNAL t_sig_COINC_UP_BLATCH      : STD_LOGIC;
    SIGNAL t_sig_FL_Trigger           : STD_LOGIC;
    SIGNAL t_sig_FL_Trigger_bar       : STD_LOGIC;
    SIGNAL t_sig_FL_PRE_TRIG          : STD_LOGIC;
    SIGNAL t_sig_FL_TMS               : STD_LOGIC;
    SIGNAL t_sig_FL_TCK               : STD_LOGIC;
    SIGNAL t_sig_FL_TDI               : STD_LOGIC;
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
    SIGNAL t_sig_SDRAMDQS             : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL t_sig_SDRAMDQ              : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL t_sig_EBIDQ                : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL t_sig_UARTRIN              : STD_LOGIC;
    SIGNAL t_sig_UARTDCDN             : STD_LOGIC;
    SIGNAL t_sig_nRESET               : STD_LOGIC;
    COMPONENT simpletest
        PORT (
            CLK1p                : IN    STD_LOGIC;
            CLK2p                : IN    STD_LOGIC;
            CLK3p                : IN    STD_LOGIC;
            COM_AD_D             : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            COM_AD_OTR           : IN    STD_LOGIC;
            HDV_Rx               : IN    STD_LOGIC;
            CLK4p                : IN    STD_LOGIC;
            OneSPE               : IN    STD_LOGIC;
            A_nB                 : IN    STD_LOGIC;
            FLASH_AD_D           : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            COINC_DOWN_A         : IN    STD_LOGIC;
            COINC_DOWN_ABAR      : IN    STD_LOGIC;
            COINC_DOWN_B         : IN    STD_LOGIC;
            FLASH_NCO            : IN    STD_LOGIC;
            COINC_DOWN_BBAR      : IN    STD_LOGIC;
            COINC_UP_A           : IN    STD_LOGIC;
            COINC_UP_ABAR        : IN    STD_LOGIC;
            COINC_UP_B           : IN    STD_LOGIC;
            COINC_UP_BBAR        : IN    STD_LOGIC;
            FL_ATTN              : IN    STD_LOGIC;
            FL_TDO               : IN    STD_LOGIC;
            MultiSPE             : IN    STD_LOGIC;
            ATWD1_D              : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            ATWD0_D              : IN    STD_LOGIC_VECTOR(9 DOWNTO 0);
            TriggerComplete_0    : IN    STD_LOGIC;
            TriggerComplete_1    : IN    STD_LOGIC;
            UARTRXD              : IN    STD_LOGIC;
            INTEXTPIN            : IN    STD_LOGIC;
            UARTDSRN             : IN    STD_LOGIC;
            UARTCTSN             : IN    STD_LOGIC;
            EBIACK               : IN    STD_LOGIC;
            CLK_REF              : IN    STD_LOGIC;
            nPOR                 : IN    STD_LOGIC;
            CLKLK_OUT2p          : OUT   STD_LOGIC;
            COM_TX_SLEEP         : OUT   STD_LOGIC;
            COM_DB               : OUT   STD_LOGIC_VECTOR(13 DOWNTO 6);
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
            R2BUS                : OUT   STD_LOGIC_VECTOR(6 DOWNTO 0);
            SingleLED_TRIGGER    : OUT   STD_LOGIC;
            COINCIDENCE_OUT_DOWN : OUT   STD_LOGIC;
            COINC_DOWN_ALATCH    : OUT   STD_LOGIC;
            COINC_DOWN_BLATCH    : OUT   STD_LOGIC;
            COINCIDENCE_OUT_UP   : OUT   STD_LOGIC;
            COINC_UP_ALATCH      : OUT   STD_LOGIC;
            COINC_UP_BLATCH      : OUT   STD_LOGIC;
            FL_Trigger           : OUT   STD_LOGIC;
            FL_Trigger_bar       : OUT   STD_LOGIC;
            FL_PRE_TRIG          : OUT   STD_LOGIC;
            FL_TMS               : OUT   STD_LOGIC;
            FL_TCK               : OUT   STD_LOGIC;
            FL_TDI               : OUT   STD_LOGIC;
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
            SDRAMDQS             : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            SDRAMDQ              : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            EBIDQ                : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            UARTRIN              : INOUT STD_LOGIC;
            UARTDCDN             : INOUT STD_LOGIC;
            nRESET               : INOUT STD_LOGIC);
    END COMPONENT;
BEGIN
    tb : simpletest PORT MAP (
-- list connections between master ports and signals
        CLK1p                => t_sig_CLK1p,
        CLK2p                => t_sig_CLK2p,
        CLK3p                => t_sig_CLK3p,
        COM_AD_D             => t_sig_COM_AD_D,
        COM_AD_OTR           => t_sig_COM_AD_OTR,
        HDV_Rx               => t_sig_HDV_Rx,
        CLK4p                => t_sig_CLK4p,
        OneSPE               => t_sig_OneSPE,
        A_nB                 => t_sig_A_nB,
        FLASH_AD_D           => t_sig_FLASH_AD_D,
        COINC_DOWN_A         => t_sig_COINC_DOWN_A,
        COINC_DOWN_ABAR      => t_sig_COINC_DOWN_ABAR,
        COINC_DOWN_B         => t_sig_COINC_DOWN_B,
        FLASH_NCO            => t_sig_FLASH_NCO,
        COINC_DOWN_BBAR      => t_sig_COINC_DOWN_BBAR,
        COINC_UP_A           => t_sig_COINC_UP_A,
        COINC_UP_ABAR        => t_sig_COINC_UP_ABAR,
        COINC_UP_B           => t_sig_COINC_UP_B,
        COINC_UP_BBAR        => t_sig_COINC_UP_BBAR,
        FL_ATTN              => t_sig_FL_ATTN,
        FL_TDO               => t_sig_FL_TDO,
        MultiSPE             => t_sig_MultiSPE,
        ATWD1_D              => t_sig_ATWD1_D,
        ATWD0_D              => t_sig_ATWD0_D,
        TriggerComplete_0    => t_sig_TriggerComplete_0,
        TriggerComplete_1    => t_sig_TriggerComplete_1,
        UARTRXD              => t_sig_UARTRXD,
        INTEXTPIN            => t_sig_INTEXTPIN,
        UARTDSRN             => t_sig_UARTDSRN,
        UARTCTSN             => t_sig_UARTCTSN,
        EBIACK               => t_sig_EBIACK,
        CLK_REF              => t_sig_CLK_REF,
        nPOR                 => t_sig_nPOR,
        CLKLK_OUT2p          => t_sig_CLKLK_OUT2p,
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
        COINCIDENCE_OUT_DOWN => t_sig_COINCIDENCE_OUT_DOWN,
        COINC_DOWN_ALATCH    => t_sig_COINC_DOWN_ALATCH,
        COINC_DOWN_BLATCH    => t_sig_COINC_DOWN_BLATCH,
        COINCIDENCE_OUT_UP   => t_sig_COINCIDENCE_OUT_UP,
        COINC_UP_ALATCH      => t_sig_COINC_UP_ALATCH,
        COINC_UP_BLATCH      => t_sig_COINC_UP_BLATCH,
        FL_Trigger           => t_sig_FL_Trigger,
        FL_Trigger_bar       => t_sig_FL_Trigger_bar,
        FL_PRE_TRIG          => t_sig_FL_PRE_TRIG,
        FL_TMS               => t_sig_FL_TMS,
        FL_TCK               => t_sig_FL_TCK,
        FL_TDI               => t_sig_FL_TDI,
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
        SDRAMDQS             => t_sig_SDRAMDQS,
        SDRAMDQ              => t_sig_SDRAMDQ,
        EBIDQ                => t_sig_EBIDQ,
        UARTRIN              => t_sig_UARTRIN,
        UARTDCDN             => t_sig_UARTDCDN,
        nRESET               => t_sig_nRESET
        );
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
END simpletest_arch;
