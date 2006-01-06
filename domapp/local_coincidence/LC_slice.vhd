-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LC_slice.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-05-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module sends, receives and relays LC signals for one
--              direction
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten 
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY LC_slice IS
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
END LC_slice;


ARCHITECTURE LC_slice_arch OF LC_slice IS

    COMPONENT LC_RX_edge
        PORT (
            CLK40    : IN  STD_LOGIC;
            RST      : IN  STD_LOGIC;
			-- setup
            rx_enable : IN  STD_LOGIC;
            -- LC edges
            edge_pos : OUT STD_LOGIC;
            edge_neg : OUT STD_LOGIC;
            -- LC I/O
            ALATCH   : OUT STD_LOGIC;
            ABAR     : IN  STD_LOGIC;
            A        : IN  STD_LOGIC;   -- _A is positve discriminator 
            BLATCH   : OUT STD_LOGIC;
            BBAR     : IN  STD_LOGIC;
            B        : IN  STD_LOGIC;   -- _B is negative discriminator
            -- test
            TC       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT LC_RC_decode
        PORT (
            CLK40    : IN  STD_LOGIC;
            RST      : IN  STD_LOGIC;
            edge_pos : IN  STD_LOGIC;
            edge_neg : IN  STD_LOGIC;
            n_rx     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            update   : OUT STD_LOGIC;
            TC       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT LC_relais
        PORT (
            CLK40     : IN  STD_LOGIC;
            CLK80     : IN  STD_LOGIC;
            RST       : IN  STD_LOGIC;
            -- setup
            lc_length : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            -- local discriminator
            disc      : IN  STD_LOGIC;
            -- from RX
            n_rx      : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            rx        : IN  STD_LOGIC;
            -- to TX
            n_tx      : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            tx        : OUT STD_LOGIC;
            next_lc   : IN  STD_LOGIC;
            -- test
            TC        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT LC_TX
        PORT (
            CLK40           : IN  STD_LOGIC;
            RST             : IN  STD_LOGIC;
            -- setup
            tx_enable       : IN  STD_LOGIC;
            -- internal LC signals
            n               : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            tx              : IN  STD_LOGIC;
            next_lc         : OUT STD_LOGIC;
            -- LC hardware
            COINCIDENCE_OUT : OUT STD_LOGIC;
            -- test
            TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;


    SIGNAL edge_pos : STD_LOGIC;
    SIGNAL edge_neg : STD_LOGIC;

    SIGNAL n_rx    : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL rx      : STD_LOGIC;
    SIGNAL n_tx    : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL tx      : STD_LOGIC;
    SIGNAL next_lc : STD_LOGIC;
    
BEGIN  -- LC_slice_arch


    update <= rx;
    n      <= n_rx;

    LC_RX_edge_inst : LC_RX_edge
        PORT MAP (
            CLK40    => CLK40,
            RST      => RST,
			-- setup
            rx_enable => rx_enable,
            -- LC edges
            edge_pos => edge_pos,
            edge_neg => edge_neg,
            -- LC I/O
            ALATCH   => ALATCH,
            ABAR     => ABAR,
            A        => A,
            BLATCH   => BLATCH,
            BBAR     => BBAR,
            B        => B,
            -- test
            TC       => OPEN
            );

    LC_RC_decode_inst : LC_RC_decode
        PORT MAP (
            CLK40    => CLK40,
            RST      => RST,
            edge_pos => edge_pos,
            edge_neg => edge_neg,
            n_rx     => n_rx,
            update   => rx,
            TC       => OPEN
            );

    LC_relais_inst : LC_relais
        PORT MAP (
            CLK40     => CLK40,
            CLK80     => CLK80,
            RST       => RST,
            -- setup
            lc_length => lc_length,
            -- local discriminator
            disc      => disc,
            -- from RX
            n_rx      => n_rx,
            rx        => rx,
            -- to TX
            n_tx      => n_tx,
            tx        => tx,
            next_lc   => next_lc,
            -- test
            TC        => OPEN
            );

    LC_TX_inst : LC_TX
        PORT MAP (
            CLK40           => CLK40,
            RST             => RST,
            -- setup
            tx_enable       => tx_enable,
            -- internal LC signals
            n               => n_tx,
            tx              => tx,
            next_lc         => next_lc,
            -- LC hardware
            COINCIDENCE_OUT => COINCIDENCE_OUT,
            -- test
            TC              => OPEN
            );



END LC_slice_arch;
