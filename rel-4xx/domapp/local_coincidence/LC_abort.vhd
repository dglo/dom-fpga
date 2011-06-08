-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LC_abort.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-05-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module checks if LC is satisfied and initiates an abort
--              if not satisfied. The module corrects for the delays in the LC
--              cables
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

USE WORK.ctrl_data_types.ALL;
USE WORK.constants.ALL;


ENTITY LC_abort IS
    PORT (
        CLK40             : IN  STD_LOGIC;
        RST               : IN  STD_LOGIC;
        -- setup
        lc_length         : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        cable_length_up   : IN  CABLE_LENGTH_VECTOR;
        cable_length_down : IN  CABLE_LENGTH_VECTOR;
        lc_pre_window     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
        lc_post_window    : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
        selfLCmode        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        selfLC_window     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
        LC_up_and_down    : IN  STD_LOGIC;
        -- local LC interface
        launch            : IN  STD_LOGIC;
        disc              : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        up_n              : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_update_up      : IN  STD_LOGIC;
        down_n            : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        lc_update_down    : IN  STD_LOGIC;
        -- the result
        abort             : OUT STD_LOGIC;
		LC                : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test signals
        TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_abort;

ARCHITECTURE arch_LC_abort OF LC_abort IS

    TYPE PRE_TIME_TYPE IS ARRAY (0 TO 3) OF INTEGER RANGE 0 TO 64;

    SIGNAL got_post_lc_up   : STD_LOGIC;
    SIGNAL got_post_lc_down : STD_LOGIC;
    SIGNAL got_pre_lc_up    : STD_LOGIC;
    SIGNAL got_pre_lc_down  : STD_LOGIC;

    SIGNAL got_selfLC : STD_LOGIC;

    SIGNAL abort_test  : STD_LOGIC;     -- for testing
    SIGNAL abort_clear : STD_LOGIC;     -- for testing

BEGIN  -- arch_LC_abort

    PROCESS (CLK40, RST)
        VARIABLE launch_timer   : INTEGER RANGE 0 TO 192;
        VARIABLE launch_old     : STD_LOGIC;
        VARIABLE pre_timer_up   : PRE_TIME_TYPE;
        VARIABLE pre_timer_down : PRE_TIME_TYPE;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            abort            <= '0';
            got_post_lc_up   <= '0';
            got_post_lc_down <= '0';
            got_pre_lc_up    <= '0';
            got_pre_lc_down  <= '0';
            launch_timer     := 192;
            FOR i IN 0 TO 3 LOOP
                pre_timer_up(i)   := 64;
                pre_timer_down(i) := 64;
            END LOOP;  -- i
            launch_old := '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF launch = '1' AND launch_old = '0' THEN
                launch_timer := 0;
            ELSIF launch_timer /= 192 THEN
                launch_timer := launch_timer + 1;
            ELSE
                launch_timer := launch_timer;
            END IF;


            -- Check post window
            IF lc_update_up = '1' THEN
                IF launch_timer >= cable_length_Up(CONV_INTEGER(lc_length - up_n)) AND
                    launch_timer   <= (cable_length_up(CONV_INTEGER(lc_length - up_n)) + CONV_INTEGER(lc_post_window)) THEN
                    got_post_lc_up <= '1';
                END IF;
            END IF;
            IF lc_update_down = '1' THEN
                IF launch_timer >= cable_length_down(CONV_INTEGER(lc_length - down_n)) AND
                    launch_timer     <= (cable_length_down(CONV_INTEGER(lc_length - down_n)) + CONV_INTEGER(lc_post_window)) THEN
                    got_post_lc_down <= '1';
                END IF;
            END IF;

            -- check pre window
            -- LC from above
            FOR i IN 0 TO 3 LOOP
                IF lc_update_up = '1' AND CONV_INTEGER(lc_length - up_n) = i THEN
                    pre_timer_up(i) := 0;
                ELSIF pre_timer_up(i) /= 64 THEN
                    pre_timer_up(i) := pre_timer_up(i) + 1;
                ELSE
                    pre_timer_up(i) := pre_timer_up(i);
                END IF;
                IF launch_timer = cable_length_up(i) THEN
                    IF pre_timer_up(i) <= (CONV_INTEGER(lc_pre_window)) THEN
                        got_pre_lc_up <= '1';
                    END IF;
                END IF;
            END LOOP;  -- i
            -- LC from below
            FOR i IN 0 TO 3 LOOP
                IF lc_update_down = '1' AND CONV_INTEGER(lc_length - down_n) = i THEN
                    pre_timer_down(i) := 0;
                ELSIF pre_timer_down(i) /= 64 THEN
                    pre_timer_down(i) := pre_timer_down(i) + 1;
                ELSE
                    pre_timer_down(i) := pre_timer_down(i);
                END IF;
                IF launch_timer = cable_length_down(i) THEN
                    IF pre_timer_down(i) <= (CONV_INTEGER(lc_pre_window)) THEN
                        got_pre_lc_down <= '1';
                    END IF;
                END IF;
            END LOOP;  -- i

            -- Self Local Coincidence
            CASE selfLCmode IS
                WHEN LC_SELF_OFF =>
                    got_selfLC <= '0';
                WHEN LC_SELF_SPE =>
                    IF disc(0) = '1' AND launch_timer <= (CONV_INTEGER(selfLC_window)) THEN
                        got_selfLC <= '1';
                    END IF;
                WHEN LC_SELF_MPE =>
                    IF disc(1) = '1' AND launch_timer <= (CONV_INTEGER(selfLC_window)) THEN
                        got_selfLC <= '1';
                    END IF;
                WHEN OTHERS =>
                    got_selfLC <= '0';
            END CASE;

            -- do the abort
            IF (launch_timer = (cable_length_up(CONV_INTEGER(lc_length))+CONV_INTEGER(lc_post_window)+1) AND (cable_length_up(CONV_INTEGER(lc_length)) >= cable_length_down(CONV_INTEGER(lc_length)))) OR
                (launch_timer = (cable_length_down(CONV_INTEGER(lc_length))+CONV_INTEGER(lc_post_window)+1) AND (cable_length_up(CONV_INTEGER(lc_length)) <= cable_length_down(CONV_INTEGER(lc_length)))) THEN
--                IF got_post_lc_up = '0' AND got_post_lc_down = '0' AND got_pre_lc_up = '0' AND got_pre_lc_down = '0' AND got_selfLC = '0'THEN
--                    abort <= '1';
--                ELSE
--                    abort <= '0';
--                END IF;
                IF (LC_up_and_down = '1' AND (got_post_lc_up = '1' OR got_pre_lc_up = '1') AND (got_post_lc_down = '1' OR got_pre_lc_down = '1')) OR  --
                    -- for Mark
                    (LC_up_and_down = '0' AND (got_post_lc_up = '1' OR got_pre_lc_up = '1' OR got_post_lc_down = '1' OR got_pre_lc_down = '1')) OR  --
                    -- normal mode
                    got_selfLC = '1'THEN
                    abort <= '0';
                ELSE
                    abort <= '1';
                END IF;
                got_post_lc_up   <= '0';
                got_post_lc_down <= '0';
                got_pre_lc_up    <= '0';
                got_pre_lc_down  <= '0';
                got_selfLC       <= '0';
                abort_test       <= '1';

                LC(0) <= got_pre_lc_down OR got_post_lc_down;
                LC(1) <= got_pre_lc_up OR got_post_lc_up;
            ELSE
                abort       <= '0';
                abort_test  <= '0';
                abort_clear <= '0';
            END IF;

            launch_old := launch;
        END IF;
    END PROCESS;

END arch_LC_abort;
