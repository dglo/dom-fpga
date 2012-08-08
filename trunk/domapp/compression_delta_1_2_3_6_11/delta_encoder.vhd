-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : delta_encoder.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-03-21
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module encodes the deltas based on the delta compression
--              specified in:
--              http://docushare.icecube.wisc.edu/docushare/dsweb/Get/Document-20568/delta_123611_format_and_processes.pdf
--
-- Input timing:
--                   ___     ___     ___     ___
-- CLK          |___|   |___|   |___|   |___|
--                   _______
-- delta_next   ____|       |______
--              ________ _______ ______
-- delta in     ________X valid X______
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-03-    V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_signed.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY delta_encoder IS
    PORT (
        CLK            : IN  STD_LOGIC;
        RST            : IN  STD_LOGIC;
        -- control
        next_wf        : IN  STD_LOGIC;
        encodeing      : OUT STD_LOGIC;
        -- deltas in
        delta_in       : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
        next_delta_in  : OUT STD_LOGIC;
        delta_avail    : IN  STD_LOGIC;
        -- encoded deltas out
        delta_out      : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
        bits_per_delta : OUT INTEGER RANGE 1 TO 11;
        next_delta_out : OUT STD_LOGIC;
        -- test connector
        TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END delta_encoder;

ARCHITECTURE delta_encoder_arch OF delta_encoder IS

    TYPE   bpw_type IS (bpw1, bpw2, bpw3, bpw6, bpw11);
    SIGNAL bpw_state     : bpw_type;
    SIGNAL increment_bpw : STD_LOGIC;

BEGIN  -- delta_encoder_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            bpw_state     <= bpw3;
            increment_bpw <= '0';
            delta_out     <= (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            next_delta_in  <= '0';
            next_delta_out <= '0';
            IF next_wf = '1' THEN
                increment_bpw <= '0';
                bpw_state     <= bpw3;
                encodeing     <= '0';
                -- next_delta_in <= '1';
            ELSIF delta_avail = '1' OR increment_bpw = '1' THEN
                CASE bpw_state IS
                    WHEN bpw1 =>
                        bits_per_delta <= 1;
                        IF conv_integer(delta_in) = 0 THEN
                            delta_out      <= "00000000000";
                            next_delta_out <= '1';
                            next_delta_in  <= '1';
                            increment_bpw  <= '0';
                        ELSE
                            delta_out      <= "00000000001";
                            next_delta_out <= '1';
                            increment_bpw  <= '1';
                            bpw_state      <= bpw2;
                        END IF;
                    WHEN bpw2 =>
                        bits_per_delta <= 2;
                        IF conv_integer(ABS(delta_in)) < 2 THEN
                            delta_out              <= "00000000000";
                            delta_out (1 DOWNTO 0) <= delta_in (1 DOWNTO 0);
                            next_delta_out         <= '1';
                            next_delta_in          <= '1';
                            increment_bpw          <= '0';
                            IF conv_integer(ABS(delta_in)) < 1 THEN
                                bpw_state <= bpw1;
                            END IF;
                        ELSE
                            delta_out      <= "00000000010";
                            next_delta_out <= '1';
                            increment_bpw  <= '1';
                            bpw_state      <= bpw3;
                        END IF;
                    WHEN bpw3 =>
                        bits_per_delta <= 3;
                        IF conv_integer(ABS(delta_in)) < 4 THEN
                            delta_out              <= "00000000000";
                            delta_out (2 DOWNTO 0) <= delta_in (2 DOWNTO 0);
                            next_delta_out         <= '1';
                            next_delta_in          <= '1';
                            increment_bpw          <= '0';
                            IF conv_integer(ABS(delta_in)) < 2 THEN
                                bpw_state <= bpw2;
                            END IF;
                        ELSE
                            delta_out      <= "00000000100";
                            next_delta_out <= '1';
                            increment_bpw  <= '1';
                            bpw_state      <= bpw6;
                        END IF;
                    WHEN bpw6 =>
                        bits_per_delta <= 6;
                        IF conv_integer(ABS(delta_in)) < 32 THEN
                            delta_out              <= "00000000000";
                            delta_out (5 DOWNTO 0) <= delta_in (5 DOWNTO 0);
                            next_delta_out         <= '1';
                            next_delta_in          <= '1';
                            increment_bpw          <= '0';
                            IF conv_integer(ABS(delta_in)) < 4 THEN
                                bpw_state <= bpw3;
                            END IF;
                        ELSE
                            delta_out      <= "00000100000";
                            next_delta_out <= '1';
                            increment_bpw  <= '1';
                            bpw_state      <= bpw11;
                        END IF;
                    WHEN bpw11 =>
                        bits_per_delta          <= 11;
                        delta_out               <= "00000000000";
                        delta_out (10 DOWNTO 0) <= delta_in (10 DOWNTO 0);
                        next_delta_out          <= '1';
                        next_delta_in           <= '1';
                        increment_bpw           <= '0';
                        IF conv_integer(ABS(delta_in)) < 32 THEN
                            bpw_state <= bpw6;
                        END IF;
                    WHEN OTHERS =>
                        NULL;
                END CASE;
                encodeing <= '1';
            ELSE
                encodeing <= '0';
            END IF;
        END IF;
    END PROCESS;

END delta_encoder_arch;



