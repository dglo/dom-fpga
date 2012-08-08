-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : interrupts.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-11-30
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module manages the interrupts to the STRIPE
-------------------------------------------------------------------------------
-- Copyright (c) 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-11-30  V01-01-00   thorsten
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


ENTITY interrupts IS
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
END interrupts;


ARCHITECTURE interrupts_arch OF interrupts IS

    SIGNAL int : STD_LOGIC_VECTOR (5 DOWNTO 0);
    
BEGIN  -- interrupts_arch

    int(0) <= int0;
    int(1) <= int1;
    int(2) <= int2;
    int(3) <= int3;
    int(4) <= int4;
    int(5) <= int5;

    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)

        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            FOR i IN 0 TO 5 LOOP
                IF int_enable(i) = '0' THEN
                    intpld(i)      <= '0';
                    int_pending(i) <= '0';
                ELSIF int_clr(i) = '1' THEN
                    intpld(i)      <= '0';
                    int_pending(i) <= '0';
                ELSIF int(i) = '1' THEN
                    intpld(i)      <= '1';
                    int_pending(i) <= '1';
                END IF;
            END LOOP;  -- i
        END IF;
    END PROCESS;

END interrupts_arch;
