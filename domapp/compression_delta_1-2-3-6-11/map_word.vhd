-------------------------------------------------------------------------------
--IceCube
--DOM Data Compression Submodule
--
--Author:   N. Kitamura
--Version:      0.06    11/7/2005
--
--File:     map_word.vhd
--
--------------------------------------------------------------------------------
--
--Ver 0.00      6/27/2005       Handed over to Dawn Williams (8/22/05)
--Ver 0.01      9/7/2005        Fixed bugs (marked as "Added"/"Deleted")
--Ver 0.011     9/8/2005        More bug fixes
--Ver 0.02      10/5/2005       Simulates okay at 166MHz.  Eliminated synthesys warnings.
--Ver 0.03      10/6/2005       Modified state machine so that wreq goes high only when ready='1'.
--Ver 0.04      10/13/2005      Added processes for handling the end of channel condition.  
--                                              The processes ensures that the encoding is done before raising
--                                              last_output.
--Ver 0.05      10/31/2005      Synchronized the signal last_input_wait_state with clock in the 
--                                              process end_condition_process1 to eliminate a Design Assistant 
--                                              'High level' warning.
--Ver 0.06      11/7/2005       Modified end_condition_process2 and eliminated the wait state counter.
--------------------------------------------------------------------------------
--Notes:
-- This module implements the main encoder state machine based on CW's algorithm.
--
-- * reset = (input) the module *must* be reset at the beginning of each channel.
-- * delta = (input) signed integer
-- * convert = (input) "delta" is latched when convert is high (allowed only when not busy)
-- * busy = (output) goes high during bit-length "transition"
-- * dout = (output) encoded pattern for delta.  Only the BPS bits starting from LSB
--        are valid.
-- * BPS = "Bits per Sample" (output) unsigned integer.

-- How To Use map_word.vhd
-- T1. Set reset=1 at the beginning of the channel
-- T2. if not end_of_channel and busy=0 then
--         Write delta, set convert=1
--     else if end_of_channel then
--         Finish channel
--     end if
-- T3. Read data, goto T3

-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;


--  reset_channel---------+-------------------+---------------------+
--                        |    +-----------...|...---------------...|...--> (stuff_busy)
--  clock--->....         |    |              |                     |
--            [map_word]  v    | [bit_stuff]  v      [word_counter] v
--                +-------------+  | +--------------+    +----------------+
--  convert-->|convert      |  | |    word_ready|--->|word_ready      |
--            |        ready|<-+-|~busy         |    |       count_out|---> count_out
--                |             |    |              |    |        word_out|---> word_out
--        delta-->|delta    dout|--->|DX            |    |                |
--            |          BPS|--->|BPS         DY|--->|word_in         |
--         +--|busy     wreq|-+->|wreq  word_ack|<-+-|word_ack        |
--         |  |             | |  |              |  | |                |
--         |  +-------------+ |  +--------------+  | +----------------+
--         |                  |                    +----------------------> have_word
--         |                  +-------------------------------------------> (map_done)
--         +--------------------------------------------------------------> encoder_busy


-- Signals for debugging only: "stuff_busy", "map_done"

-- 1. "reset_channel" must go high at the beginning of each channel.
-- 2. "convert" may go high only when "encoder_busy" is low.
-- 3. "delta" is latched on the rising edge of "clock" when "convert" is high.
-- 4. "wreq" ("map_done") goes high whenever the output is valid.
-- 5. "DX" and "BPS" latches the respective input when "wreq" goes high.
-- 6. "word_ack" ("have_word") goes high on the rising edge of "clock" following 
--    "word_ready" going high.
-- 7. "DY" is latched and connected to "word_out" when "word_ack" goes high.
-- 8. "word_out" and "count_out" are valid only when "have_word" is high.


ENTITY map_word IS
    PORT(
        clock       : IN  STD_LOGIC;
        reset       : IN  STD_LOGIC;    -- Reset on start of channel
        op_reset    : IN  STD_LOGIC;
        convert     : IN  STD_LOGIC;  -- Latch data and start conversion.  busy must be low.
        delta       : IN  SIGNED(10 DOWNTO 0);  --11 bits, signed integer
        ready       : IN  STD_LOGIC;  -- High when converted word can be written to output port
        last_input  : IN  STD_LOGIC;    -- Last word of channel
        dout        : OUT STD_LOGIC_VECTOR(10 DOWNTO 0);
        BPS         : OUT UNSIGNED(3 DOWNTO 0);
        wreq        : OUT STD_LOGIC;  -- Write request.  Goes high only when ready is high
        last_output : OUT STD_LOGIC;  -- Tells bit_stuff when to flush buffer and end
        busy        : OUT STD_LOGIC     -- high when in "transition"
        );
END map_word;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
ARCHITECTURE behave3 OF map_word IS

    
    TYPE states IS (IDLE, WAIT_RDY,
                      S1, S1_1, S1_2, S1_2a,
                      S2, S2_1, S2_2, S2_3, S2_3a,
                      S3, S3_2, S3_3, S3_6, S3_6a,
                      S6, S6_3, S6_6, S6_11, S6_11a,
                      S11, S11_6, S11_11);

    SIGNAL state_now, state_next : states;
    SIGNAL recall_state          : states;

    SIGNAL sig_wreq : STD_LOGIC;
    SIGNAL sig_busy : STD_LOGIC;

    SUBTYPE dx_vector IS STD_LOGIC_VECTOR(10 DOWNTO 0);

    SIGNAL dx    : dx_vector;
    SIGNAL trans : BOOLEAN;  -- "In transition (true when bit length increasing)"
    SIGNAL BPSx  : UNSIGNED (3 DOWNTO 0);

    SIGNAL last_input_wait_state : STD_LOGIC;

BEGIN


    output_signals :

        dout <= dx;
    BPS <= BPSx;

    wreq <= sig_wreq;

    busy <= '1' WHEN sig_busy = '1' OR trans ELSE '0';

-- This process detects the condition last_input = '1'.  This should happen when cw_state_machine
-- is one of the non-transient states {S1, S2, S3, S6, S11}.  The state machine then enters a
-- transient mode in which further outputs may be produced.  The marker bits from the last of these 
-- transient states should be sent to bit_stuff as the 'last_data'.
    end_condition_process1 :
    PROCESS (state_now, last_input, clock) IS
    BEGIN
        IF rising_edge(clock) THEN  -- Added to synchronize last_input_wait_state (10/31/2005).
            CASE state_now IS
                WHEN IDLE =>
                    last_input_wait_state <= '0';
                WHEN S1|S2|S3|S6|S11 =>
                    IF last_input = '1' THEN
                        last_input_wait_state <= '1';
                    END IF;
                WHEN OTHERS =>
                    last_input_wait_state <= '0';
            END CASE;
        END IF;
    END PROCESS;

-- This process sets last_output_a to '1' when cw_state_machine returns to a non-transient
-- state after processing the last delta.
    end_condition_process2 :
    PROCESS (state_now, last_input_wait_state)  --, clock)
    BEGIN
        IF last_input_wait_state = '1' THEN
            CASE state_now IS
                WHEN S1|S2|S3|S6|S11 =>
                    last_output <= '1';
                WHEN OTHERS =>
                    last_output <= '0';
            END CASE;
        ELSE
            last_output <= '0';
        END IF;
    END PROCESS;


    state_transition :
    PROCESS (clock, reset, op_reset)
    BEGIN
        IF reset = '1' THEN
            state_now <= IDLE;
        ELSIF clock'EVENT AND clock = '1' THEN
            IF op_reset = '1' THEN
                
                state_now <= IDLE;
                
            ELSE
                state_now <= state_next;
            END IF;
        END IF;
    END PROCESS;


    cw_state_machine :

    PROCESS (state_now, convert, trans, delta, ready, recall_state) IS

        FUNCTION make_dx_vector(d : IN INTEGER; n : IN INTEGER) RETURN dx_vector IS
            VARIABLE dd : STD_LOGIC_VECTOR(10 DOWNTO 0);
        BEGIN  -- Output format
            IF n = 1 THEN  --                         |<--------11 bits---------->|
                IF d = 0 THEN  --  make_dx_vector(x, n):  [0....0][s][     abs(x)     ]
                    dd := "00000000000";  --                                    |<-- n-1 bits -->|
                ELSE
                    dd := "00000000001";
                END IF;
            ELSE
                IF n < 11 THEN          -- Pad MSBs with zeros.
                    dd(10 DOWNTO n) := (OTHERS => '0');
                END IF;
                dd(n-1)          := conv_std_logic_vector(d, 11)(10);  -- sign bit
                dd(n-2 DOWNTO 0) := conv_std_logic_vector(ABS(d), n-1);
            END IF;
            RETURN dx_vector(dd);
        END FUNCTION;


--        PROCEDURE wait_and_goto(target_state : states) IS
--        BEGIN
--            sig_busy     <= '1';
--            sig_wreq     <= '0';
--            recall_state <= target_state;
--            IF ready = '1' THEN
--                state_next <= target_state;
--            ELSE
--                state_next <= WAIT_RDY;
--            END IF;
--        END PROCEDURE;


        VARIABLE idata : INTEGER RANGE -2**10 TO 2**10-1;

    BEGIN

        idata    := conv_integer(delta);
        dx       <= (OTHERS => '0');
        BPSx     <= (OTHERS => '0');
        trans    <= false;
        sig_busy <= '0';
        sig_wreq <= '0';

        CASE state_now IS

            WHEN WAIT_RDY =>
                sig_busy <= '1';
                sig_wreq <= '0';
                IF ready = '1' THEN
                    state_next <= recall_state;
                ELSE
                    state_next <= WAIT_RDY;
                END IF;


            WHEN IDLE =>
                BPSx       <= B"0000";
                dx         <= "00000000000";
                trans      <= false;
                sig_busy   <= '1';
                sig_wreq   <= '0';
                state_next <= S3;


            WHEN S1 =>
                BPSx <= B"0001";
                IF convert = '0' THEN
                    dx         <= "00000000000";
                    trans      <= false;
                    sig_busy   <= '0';
                    sig_wreq   <= '0';
                    state_next <= S1;
                ELSIF convert = '1' THEN
                    IF idata = 0 THEN
                        dx       <= "00000000000";
                        trans    <= false;
                        sig_busy <= '1';
                        sig_wreq <= '0';
                        -- wait_and_goto(S1_1);
                        IF ready='1' THEN
                            state_next <= S1_1;
                        END IF;
                    ELSE
                        dx       <= "00000000001";
                        trans    <= true;  -- Start upward transition
                        sig_busy <= '1';
                        sig_wreq <= '0';
                        --wait_and_goto(S1_2);
                        IF ready='1' THEN
                            state_next <= S1_2;
                        END IF;
                    END IF;
                END IF;
                

            WHEN S1_1 =>
                BPSx     <= B"0001";
                dx       <= "00000000000";
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN  -- In case the input process is still holding
                    state_next <= S1;   -- the value of convert high.
                ELSE
                    state_next <= S1_1;
                END IF;
                
                
            WHEN S1_2 =>
                BPSx     <= B"0001";
                dx       <= "00000000001";
                trans    <= true;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S1_2a;
                ELSE
                    state_next <= S1_2;
                END IF;
                
                
            WHEN S1_2a =>  -- The states "S...a" create the down going strobe of sig_wreq.
                BPSx       <= B"0001";
                dx         <= "00000000001";
                sig_busy   <= '1';
                sig_wreq   <= '0';
                trans      <= true;
                state_next <= S2;


            WHEN S2 =>
                BPSx <= B"0010";
                IF convert = '0' AND NOT trans THEN
                    dx         <= "00000000000";
                    sig_busy   <= '0';
                    sig_wreq   <= '0';
                    trans      <= false;
                    state_next <= S2;
                ELSIF convert = '1' OR trans THEN
                    sig_busy <= '1';
                    sig_wreq <= '0';
                    IF idata = 0 THEN
                        dx    <= "00000000000";
                        trans <= false;
                        --wait_and_goto(S2_1);
                        IF ready='1' THEN
                            state_next <= S2_1;
                        END IF;
                    ELSIF ABS(idata) = 1 THEN
                        dx <= make_dx_vector(idata, 2);
                        IF trans THEN   -- Avoid a latch by coding this way.
                            trans <= true;
                        ELSE
                            trans <= false;
                        END IF;
                        --wait_and_goto(S2_2);
                        IF ready='1' THEN
                            state_next <= S2_2;
                        END IF;
                    ELSE
                        dx    <= "00000000010";
                        trans <= true;
                        --wait_and_goto(S2_3);
                        IF ready='1' THEN
                            state_next <= S2_3;
                        END IF;
                    END IF;
                END IF;

                
            WHEN S2_1 =>
                BPSx     <= B"0010";
                dx       <= "00000000000";
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S1;
                ELSE
                    state_next <= S2_1;
                END IF;

                
            WHEN S2_2 =>
                BPSx     <= B"0010";
                dx       <= make_dx_vector(idata, 2);
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S2;
                ELSE
                    state_next <= S2_2;
                END IF;


            WHEN S2_3 =>
                BPSx     <= B"0010";
                dx       <= "00000000010";
                sig_busy <= '1';
                trans    <= true;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S2_3a;
                ELSE
                    state_next <= S2_3;
                END IF;
                
            WHEN S2_3a =>
                BPSx       <= B"0010";
                dx         <= "00000000010";
                sig_busy   <= '1';
                sig_wreq   <= '0';
                trans      <= true;
                state_next <= S3;
                

            WHEN S3 =>
                BPSx <= B"0011";
                IF convert = '0' AND NOT trans THEN
                    dx         <= "00000000000";
                    sig_busy   <= '0';
                    sig_wreq   <= '0';
                    trans      <= false;
                    state_next <= S3;
                ELSIF convert = '1' OR trans THEN
                    sig_busy      <= '1';
                    sig_wreq      <= '0';
                    IF ABS(idata) <= 1 THEN
                        dx    <= make_dx_vector(idata, 3);
                        trans <= false;
                        --wait_and_goto(S3_2);
                        IF ready='1' THEN
                            state_next <= S3_2;
                        END IF;
                    ELSIF ABS(idata) >= 4 THEN
                        dx    <= "00000000100";
                        trans <= true;
                        --wait_and_goto(S3_6);
                        IF ready='1' THEN
                            state_next <= S3_6;
                        END IF;
                    ELSE
                        dx <= make_dx_vector(idata, 3);
                        IF trans THEN
                            trans <= true;
                        ELSE
                            trans <= false;
                        END IF;
                        --wait_and_goto(S3_3);
                        IF ready='1' THEN
                            state_next <= S3_3;
                        END IF;
                    END IF;
                END IF;
                
                
            WHEN S3_2 =>
                BPSx     <= B"0011";
                dx       <= make_dx_vector(idata, 3);
                sig_busy <= '1';
                trans    <= false;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S2;
                ELSE
                    state_next <= S3_2;
                END IF;
                
                
            WHEN S3_3 =>
                BPSx     <= B"0011";
                dx       <= make_dx_vector(idata, 3);
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S3;
                ELSE
                    state_next <= S3_3;
                END IF;
                
                
            WHEN S3_6 =>
                BPSx     <= B"0011";
                dx       <= "00000000100";
                sig_busy <= '1';
                trans    <= true;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S3_6a;
                ELSE
                    state_next <= S3_6;
                END IF;

                
            WHEN S3_6a =>
                BPSx       <= B"0011";
                dx         <= "00000000100";
                sig_busy   <= '1';
                sig_wreq   <= '0';
                trans      <= true;
                state_next <= S6;
                

            WHEN S6 =>
                BPSx <= "0110";
                IF convert = '0' AND NOT trans THEN
                    dx         <= "00000000000";
                    sig_busy   <= '0';
                    sig_wreq   <= '0';
                    trans      <= false;
                    state_next <= S6;
                ELSIF convert = '1' OR trans THEN
                    sig_busy      <= '1';
                    sig_wreq      <= '0';
                    IF ABS(idata) <= 3 THEN
                        dx    <= make_dx_vector(idata, 6);
                        trans <= false;
                        --wait_and_goto(S6_3);
                        IF ready='1' THEN
                            state_next <= S6_3;
                        END IF;
                    ELSIF ABS(idata) >= 32 THEN
                        dx    <= "00000100000";
                        trans <= true;
                        --wait_and_goto(S6_11);
                        IF ready='1' THEN
                            state_next <= S6_11;
                        END IF;
                    ELSE
                        dx <= make_dx_vector(idata, 6);
                        IF trans THEN
                            trans <= true;
                        ELSE
                            trans <= false;
                        END IF;
                        --wait_and_goto(S6_6);
                        IF ready='1' THEN
                            state_next <= S6_6;
                        END IF;
                    END IF;
                END IF;
                
                
            WHEN S6_11 =>
                BPSx     <= "0110";
                dx       <= "00000100000";
                sig_busy <= '1';
                trans    <= true;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S6_11a;
                ELSE
                    state_next <= S6_11;
                END IF;

                
            WHEN S6_11a =>
                BPSx       <= B"0110";
                dx         <= "00000100000";
                sig_busy   <= '1';
                sig_wreq   <= '0';
                trans      <= true;
                state_next <= S11;
                

            WHEN S6_6 =>
                BPSx     <= B"0110";
                dx       <= make_dx_vector(idata, 6);
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S6;
                ELSE
                    state_next <= S6_6;
                END IF;

                
            WHEN S6_3 =>
                BPSx     <= B"0110";
                dx       <= make_dx_vector(idata, 6);
                sig_busy <= '1';
                trans    <= false;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S3;
                ELSE
                    state_next <= S6_3;
                END IF;

                
            WHEN S11 =>
                BPSx <= "1011";
                IF convert = '0' AND NOT trans THEN
                    dx         <= "00000000000";
                    sig_busy   <= '0';
                    sig_wreq   <= '0';
                    trans      <= false;
                    state_next <= S11;
                ELSIF convert = '1' OR trans THEN
                    sig_busy      <= '1';
                    sig_wreq      <= '0';
                    dx            <= make_dx_vector(idata, 11);
                    IF ABS(idata) <= 31 THEN
                        trans <= false;
                        --wait_and_goto(S11_6);
                        IF ready='1' THEN
                            state_next <= S11_6;
                        END IF;
                    ELSE
                        IF trans THEN
                            trans <= true;
                        ELSE
                            trans <= false;
                        END IF;
                        --wait_and_goto(S11_11);
                        IF ready='1' THEN
                            state_next <= S11_11;
                        END IF;
                    END IF;
                END IF;


            WHEN S11_6 =>
                BPSx     <= B"1011";
                dx       <= make_dx_vector(idata, 11);
                sig_busy <= '1';
                trans    <= false;
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S6;
                ELSE
                    state_next <= S11_6;
                END IF;
                
                
            WHEN S11_11 =>
                BPSx     <= B"1011";
                dx       <= make_dx_vector(idata, 11);
                trans    <= false;
                sig_busy <= '1';
                sig_wreq <= '1';
                IF convert = '0' THEN
                    state_next <= S11;
                ELSE
                    state_next <= S11_11;
                END IF;

                
            WHEN OTHERS =>
                BPSx       <= B"0000";
                dx         <= (OTHERS => '0');
                sig_busy   <= '0';
                sig_wreq   <= '0';
                trans      <= false;
                state_next <= IDLE;

        END CASE;

    END PROCESS;


END behave3;




