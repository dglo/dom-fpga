LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

USE WORK.ctrl_data_types.ALL;


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
END LC_abort;

ARCHITECTURE arch_LC_abort OF LC_abort IS

    TYPE PRE_TIME_TYPE IS ARRAY (0 TO 3) OF INTEGER RANGE 0 TO 64;

    SIGNAL got_post_lc_up   : STD_LOGIC;
    SIGNAL got_post_lc_down : STD_LOGIC;
    SIGNAL got_pre_lc_up    : STD_LOGIC;
    SIGNAL got_pre_lc_down  : STD_LOGIC;

    SIGNAL abort_test  : STD_LOGIC;	-- for testing
    SIGNAL abort_clear : STD_LOGIC;	-- for testing
    
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

            -- do the abort
            IF (launch_timer = (cable_length_up(CONV_INTEGER(lc_length))+CONV_INTEGER(lc_post_window)+1) AND (cable_length_up(CONV_INTEGER(lc_length)) >= cable_length_down(CONV_INTEGER(lc_length)))) OR
                (launch_timer = (cable_length_down(CONV_INTEGER(lc_length))+CONV_INTEGER(lc_post_window)+1) AND (cable_length_up(CONV_INTEGER(lc_length)) <= cable_length_down(CONV_INTEGER(lc_length)))) THEN
                IF got_post_lc_up = '0' AND got_post_lc_down = '0' AND got_pre_lc_up = '0' AND got_pre_lc_down = '0' THEN
                    abort            <= '1';
                    got_post_lc_up   <= '0';
                    got_post_lc_down <= '0';
                    got_pre_lc_up    <= '0';
                    got_pre_lc_down  <= '0';
                ELSE
                    abort            <= '0';
                    got_post_lc_up   <= '0';
                    got_post_lc_down <= '0';
                    got_pre_lc_up    <= '0';
                    got_pre_lc_down  <= '0';
                END IF;
                abort_test <= '1';
      --      ELSIF launch = '0' AND launch_old = '1' THEN
      --          abort            <= '0';
      --          got_post_lc_up   <= '0';
      --          got_post_lc_down <= '0';
      --          got_pre_lc_up    <= '0';
      --          got_pre_lc_down  <= '0';
      --          abort_clear      <= '1';
            ELSE
				abort       <= '0';
                abort_test  <= '0';
                abort_clear <= '0';
            END IF;

            launch_old := launch;
        END IF;
    END PROCESS;

END arch_LC_abort;
