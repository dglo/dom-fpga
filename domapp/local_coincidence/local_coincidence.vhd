-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : local_coincidence.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-04-21
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Local Coincidence test binary encoded
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2005-03-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;
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

ARCHITECTURE ARCH_local_coincidence OF local_coincidence IS

    COMPONENT LC_slice
        PORT (
            CLK40           : IN  STD_LOGIC;
            CLK80           : IN  STD_LOGIC;
            RST             : IN  STD_LOGIC;
            -- setup
            rx_enable       : IN  STD_LOGIC;
            tx_enable       : IN  STD_LOGIC;
            lc_length       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            -- from DAQ
            disc            : IN  STD_LOGIC;
            -- LC info
            n               : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            update          : OUT STD_LOGIC;
            -- LC hardware
            -- RX
            ALATCH          : OUT STD_LOGIC;
            ABAR            : IN  STD_LOGIC;
            A               : IN  STD_LOGIC;  -- _A is positve discriminator 
            BLATCH          : OUT STD_LOGIC;
            BBAR            : IN  STD_LOGIC;
            B               : IN  STD_LOGIC;  -- _B is negative discriminator
            --TX
            COINCIDENCE_OUT : OUT STD_LOGIC;
            -- test
            TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT LC_abort
        PORT (
            CLK40             : IN  STD_LOGIC;
            RST               : IN  STD_LOGIC;
            -- setup
            lc_length         : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            cable_length_up   : IN  CABLE_LENGTH_VECTOR;
            cable_length_down : IN  CABLE_LENGTH_VECTOR;
            lc_pre_window     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
            lc_post_window    : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
            -- local LC interface
            launch            : IN  STD_LOGIC;
            up_n              : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            lc_update_up      : IN  STD_LOGIC;
            down_n            : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            lc_update_down    : IN  STD_LOGIC;
            -- the result
            abort             : OUT STD_LOGIC;
            -- test signals
            TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL up_n        : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL down_n      : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL update_up   : STD_LOGIC;
    SIGNAL update_down : STD_LOGIC;
    
BEGIN
    -- for testing
    -- lc_daq_trigger <= LC_ctrl.lc_tx_enable;
    -- lc_daq_abort <= LC_ctrl.lc_rx_enable;

    lc_daq_trigger(0) <= update_up;
    lc_daq_trigger(1) <= update_down;

    LC_slice_up2down : LC_slice
        PORT MAP (
            CLK40           => CLK40,
            CLK80           => CLK80,
            rst             => RST,
            -- setup
            rx_enable       => LC_ctrl.lc_rx_enable(1),
            tx_enable       => LC_ctrl.lc_tx_enable(0),
            lc_length       => LC_ctrl.lc_length,
            -- from DAQ
            disc            => lc_daq_disc(0),
            -- LC info
            n               => up_n,
            update          => update_up,
            -- LC hardware
            -- RX
            ALATCH          => COINC_UP_ALATCH,
            ABAR            => COINC_UP_ABAR,
            A               => COINC_UP_A,
            BLATCH          => COINC_UP_BLATCH,
            BBAR            => COINC_UP_BBAR,
            B               => COINC_UP_B,
            --TX
            COINCIDENCE_OUT => COINCIDENCE_OUT_DOWN,
            -- test
            TC              => OPEN
            );

    LC_slice_down2up : LC_slice
        PORT MAP (
            CLK40           => CLK40,
            CLK80           => CLK80,
            rst             => RST,
            -- setup
            rx_enable       => LC_ctrl.lc_rx_enable(0),
            tx_enable       => LC_ctrl.lc_tx_enable(1),
            lc_length       => LC_ctrl.lc_length,
            -- from DAQ
            disc            => lc_daq_disc(0),
            -- LC info
            n               => down_n,
            update          => update_down,
            -- LC hardware
            -- RX
            ALATCH          => COINC_DOWN_ALATCH,
            ABAR            => COINC_DOWN_ABAR,
            A               => COINC_DOWN_A,
            BLATCH          => COINC_DOWN_BLATCH,
            BBAR            => COINC_DOWN_BBAR,
            B               => COINC_DOWN_B,
            --TX
            COINCIDENCE_OUT => COINCIDENCE_OUT_UP,
            -- test
            TC              => OPEN
            );

    LC_abort_ARWD_A : LC_abort
        PORT MAP (
            CLK40             => CLK40,
            RST               => RST,
            -- setup
            lc_length         => LC_ctrl.lc_length,
            cable_length_up   => LC_ctrl.lc_cable_length_up,
            cable_length_down => LC_ctrl.lc_cable_length_down,
            lc_pre_window     => LC_ctrl.lc_pre_window,
            lc_post_window    => LC_ctrl.lc_post_window,
            -- local LC interface
            launch            => lc_daq_launch(0),
            up_n              => up_n,
            lc_update_up      => update_up,
            down_n            => down_n,
            lc_update_down    => update_down,
            -- the result
            abort             => lc_daq_abort(0),
            -- test signals
            TC                => OPEN
            );

    LC_abort_ARWD_B : LC_abort
        PORT MAP (
            CLK40             => CLK40,
            RST               => RST,
            -- setup
            lc_length         => LC_ctrl.lc_length,
            cable_length_up   => LC_ctrl.lc_cable_length_up,
            cable_length_down => LC_ctrl.lc_cable_length_down,
            lc_pre_window     => LC_ctrl.lc_pre_window,
            lc_post_window    => LC_ctrl.lc_post_window,
            -- local LC interface
            launch            => lc_daq_launch(1),
            up_n              => up_n,
            lc_update_up      => update_up,
            down_n            => down_n,
            lc_update_down    => update_down,
            -- the result
            abort             => lc_daq_abort(1),
            -- test signals
            TC                => OPEN
            );

END ARCH_local_coincidence;










