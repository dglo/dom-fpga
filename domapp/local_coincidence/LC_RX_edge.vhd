-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LC_RX_edge.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-10-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module receives the LC signals from the hardware
--              comparators and finds the signal edges
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten 
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


ENTITY LC_RX_edge IS
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
        A        : IN  STD_LOGIC;       -- _A is positve discriminator 
        BLATCH   : OUT STD_LOGIC;
        BBAR     : IN  STD_LOGIC;
        B        : IN  STD_LOGIC;       -- _B is negative discriminator
        -- test
        TC       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_RX_edge;

ARCHITECTURE LC_RX_edge_arch OF LC_RX_edge IS

    SIGNAL A_srg : STD_LOGIC_VECTOR (5 DOWNTO 0);
    SIGNAL B_srg : STD_LOGIC_VECTOR (5 DOWNTO 0);

BEGIN  -- LC_RX_arch

    -- make discriminators transparent
    ALATCH <= '0';
    BLATCH <= '0';

    SRG : PROCESS (CLK40, RST)
        VARIABLE neg       : STD_LOGIC_VECTOR (2 DOWNTO 0);
        VARIABLE neg_delay : STD_LOGIC;
        VARIABLE pos       : STD_LOGIC_VECTOR (2 DOWNTO 0);
        VARIABLE pos_delay : STD_LOGIC;
    BEGIN  -- PROCESS SRG
        IF RST = '1' THEN               -- asynchronous reset (active high)
            A_srg     <= (OTHERS => '0');
            B_srg     <= (OTHERS => '0');
            neg       := (OTHERS => '0');
            neg_delay := '0';
            pos       := (OTHERS => '0');
            pos_delay := '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
			IF rx_enable = '1' THEN
	            A_srg (4 DOWNTO 0) <= A_srg (5 DOWNTO 1);
    	        A_srg (5)          <= A;
        	    B_srg (4 DOWNTO 0) <= B_srg (5 DOWNTO 1);
            	B_srg (5)          <= B;
			ELSE
				A_srg <= (OTHERS => '0');
				B_srg <= (OTHERS => '0');
			END IF;

            neg_delay := neg(0) OR neg(1) OR neg(2);
            neg(0)    := A_srg(1) AND B_srg(2) AND (NOT A_srg(2) AND NOT B_srg(1));
            neg(1)    := A_srg(1) AND B_srg(3) AND (NOT A_srg(2) AND NOT B_srg(2));
            -- neg(0)    := A_srg(0) AND A_srg(1) AND B_srg(2) AND B_srg(3) AND (NOT A_srg(2) AND NOT B_srg(1));
            -- neg(1)    := A_srg(0) AND A_srg(1) AND B_srg(3) AND B_srg(4) AND (NOT A_srg(2) AND NOT B_srg(2));
            neg(2)    := A_srg(0) AND A_srg(1) AND B_srg(1) AND B_srg(2) AND (NOT A_srg(2) AND NOT B_srg(0));
            edge_neg  <= neg(0) OR neg(1) OR neg(2);
            pos_delay := pos(0) OR pos(1) OR pos(2);
            pos(0)    := B_srg(1) AND A_srg(2) AND (NOT B_srg(2) AND NOT A_srg(1));
            pos(1)    := B_srg(1) AND A_srg(3) AND (NOT B_srg(2) AND NOT A_srg(2));
            -- pos(0)    := B_srg(0) AND B_srg(1) AND A_srg(2) AND A_srg(3) AND (NOT B_srg(2) AND NOT A_srg(1));
            -- pos(1)    := B_srg(0) AND B_srg(1) AND A_srg(3) AND A_srg(4) AND (NOT B_srg(2) AND NOT A_srg(2));
            pos(2)    := B_srg(0) AND B_srg(1) AND A_srg(1) AND A_srg(2) AND (NOT B_srg(2) AND NOT A_srg(0));
            edge_pos  <= pos(0) OR pos(1) OR pos(2);
        END IF;
    END PROCESS SRG;
    
    
END LC_RX_edge_arch;








