-------------------------------------------------------------------------------
-- Title      : ATWD model
-- Project    : 
-------------------------------------------------------------------------------
-- File       : atwd_model.vhd
-- Author     : Thorsten
-- Company    : 
-- Last update: 2003-12-12
-- Platform   : 
-------------------------------------------------------------------------------
-- Description: This is a testbench model for the ATWD
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author    Description
-- 2003/06/28  1.0      Thorsten  Created
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY atwd_model IS

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

END atwd_model;


ARCHITECTURE atwd_model_arch OF atwd_model IS

    FUNCTION BIN2GRAY (BIN : STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
        VARIABLE GRAY : STD_LOGIC_VECTOR (9 DOWNTO 0);
    BEGIN
        GRAY(9) := BIN(9);
        GRAY(8) := BIN(8) XOR BIN(9);
        GRAY(7) := BIN(7) XOR BIN(8);
        GRAY(6) := BIN(6) XOR BIN(7);
        GRAY(5) := BIN(5) XOR BIN(6);
        GRAY(4) := BIN(4) XOR BIN(5);
        GRAY(3) := BIN(3) XOR BIN(4);
        GRAY(2) := BIN(2) XOR BIN(3);
        GRAY(1) := BIN(1) XOR BIN(2);
        GRAY(0) := BIN(0) XOR BIN(1);
        RETURN GRAY;
    END FUNCTION BIN2GRAY;



    SIGNAL CounterClockCounter : INTEGER;
    SIGNAL ShiftClockCounter   : INTEGER;
--    SIGNAL D_bin               : STD_LOGIC_VECTOR (9 DOWNTO 0);

BEGIN  -- atwd_model_arch

    -- do the trigger complete response
    trigger : PROCESS (TriggerInput)
    BEGIN
        IF TriggerInput'EVENT AND TriggerInput = '1' THEN
            TriggerComplete <= '0' AFTER 400 ns;
        ELSIF TriggerInput'EVENT AND TriggerInput = '0' THEN
            TriggerComplete <= '1' AFTER 90 ns;
        END IF;
    END PROCESS;



    -- check counter clock cycles
    CCLK : PROCESS (CounterClock, DigitalReset, DigitalSet, ReadWrite, CounterClockCounter)
    BEGIN  -- PROCESS
        IF DigitalReset = '1' THEN
            CounterClockCounter <= 0;
        END IF;
        IF CounterClockCounter >= 1024 THEN
            --error too many counts
        END IF;
        IF ReadWrite = '0' THEN         -- acqure mode
            IF CounterClock'EVENT THEN
                -- error counting while acquire
            END IF;
        ELSE
            -- digitize redout mode
            IF DigitalReset = '0' AND DigitalSet = '0' THEN
                -- digitize mode
                IF CounterClock'EVENT THEN
                    CounterClockCounter <= CounterClockCounter+1;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- check shiftclock cycles and output data
    SCLK : PROCESS (ShiftClock, ShiftClockCounter, OE, Channel, DigitalReset, DigitalSet)
        VARIABLE D_bin : STD_LOGIC_VECTOR (9 DOWNTO 0);
    BEGIN  -- PROCESS SCLK
        IF OE = '1' THEN
            IF DigitalReset = '0' AND DigitalSet = '1' THEN
                IF ReadWrite = '0' THEN
                    -- error, we are in acquire mode
                END IF;

                IF ShiftClock'EVENT AND ShiftClock = '0' THEN
                    D_bin(7 DOWNTO 0) := conv_std_logic_vector(ShiftClockCounter, 8);
                    D_bin(9 DOWNTO 8) := Channel;
                    D                 <= BIN2GRAY (D_bin) AFTER 20 ns;
                ELSIF ShiftClock'EVENT AND ShiftClock = '1' THEN
                    D <= (OTHERS => 'Z') AFTER 5 ns;
                END IF;

                IF ShiftClock'EVENT AND ShiftClock = '0' THEN
                    ShiftClockCounter <= ShiftClockCounter + 1;
                END IF;
            ELSE
                D_bin := (OTHERS => '0');
                D     <= BIN2GRAY (D_bin) AFTER 10 ns;
            END IF;
        ELSE
            D                 <= (OTHERS => 'Z') AFTER 10 ns;
            ShiftClockCounter <= 0;
        END IF;
        IF OE'EVENT AND OE = '1' THEN
            D_bin(7 DOWNTO 0) := conv_std_logic_vector(ShiftClockCounter, 8);
            D_bin(9 DOWNTO 8) := Channel;
            D                 <= BIN2GRAY (D_bin) AFTER 10 ns;
            ShiftClockCounter <= ShiftClockCounter + 1;
        END IF;
    END PROCESS SCLK;

    -- purpose: converts to the gray output of the ATWD
    -- type   : combinational
    -- inputs : D_bin
    -- outputs: D
--     bin2gray : PROCESS (D_bin, OE)
--     BEGIN  -- PROCESS bin2gray
--         IF OE = '1' THEN
--             D(9) <= D_bin(9);
--             D(8) <= D_bin(8) XOR D_bin(9);
--             D(7) <= D_bin(7) XOR D_bin(8);
--             D(6) <= D_bin(6) XOR D_bin(7);
--             D(5) <= D_bin(5) XOR D_bin(6);
--             D(4) <= D_bin(4) XOR D_bin(5);
--             D(3) <= D_bin(3) XOR D_bin(4);
--             D(2) <= D_bin(2) XOR D_bin(3);
--             D(1) <= D_bin(1) XOR D_bin(2);
--             D(0) <= D_bin(0) XOR D_bin(1);
--         ELSE
--             D <= (OTHERS => 'Z') AFTER 10 ns;
--         END IF;
--     END PROCESS bin2gray;

END atwd_model_arch;






