-------------------------------------------------------------------------------
--IceCube
--DOM Data Compression Submodule
--
--Author:   N. Kitamura
--Version:	0.06	11/7/2005
--
--File:     map_word.vhd
--
--------------------------------------------------------------------------------
--
--Ver 0.00	6/27/2005	Handed over to Dawn Williams (8/22/05)
--Ver 0.01	9/7/2005	Fixed bugs (marked as "Added"/"Deleted")
--Ver 0.011	9/8/2005	More bug fixes
--Ver 0.02	10/5/2005	Simulates okay at 166MHz.  Eliminated synthesys warnings.
--Ver 0.03	10/6/2005	Modified state machine so that wreq goes high only when ready='1'.
--Ver 0.04	10/13/2005	Added processes for handling the end of channel condition.  
--						The processes ensures that the encoding is done before raising
--						last_output.
--Ver 0.05	10/31/2005	Synchronized the signal last_input_wait_state with clock in the 
--						process end_condition_process1 to eliminate a Design Assistant 
--						'High level' warning.
--Ver 0.06	11/7/2005	Modified end_condition_process2 and eliminated the wait state counter.
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
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


--  reset_channel---------+-------------------+---------------------+
--                        |    +-----------...|...---------------...|...--> (stuff_busy)
--  clock--->....         |    |              |                     |
--            [map_word]  v    | [bit_stuff]  v      [word_counter] v
--	          +-------------+  | +--------------+    +----------------+
--  convert-->|convert      |  | |    word_ready|--->|word_ready      |
--            |        ready|<-+-|~busy         |    |       count_out|---> count_out
--	          |             |    |              |    |        word_out|---> word_out
--	  delta-->|delta    dout|--->|DX            |    |                |
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


entity map_word is
    port(   
            clock       : in std_logic;
            reset       : in std_logic; -- Reset on start of channel
            convert     : in std_logic; -- Latch data and start conversion.  busy must be low.
            delta       : in signed(10 downto 0); --11 bits, signed integer
			ready		: in std_logic; -- High when converted word can be written to output port
			last_input  : in std_logic; -- Last word of channel
            dout        : out std_logic_vector(10 downto 0);
            BPS         : out unsigned(3 downto 0);
			wreq		: out std_logic;-- Write request.  Goes high only when ready is high
			last_output : out std_logic;-- Tells bit_stuff when to flush buffer and end
            busy        : out std_logic -- high when in "transition"
         );
end map_word;


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
architecture behave3 of map_word is

						
	type   states is (IDLE, WAIT_RDY, 
						S1, S1_1, S1_2, S1_2a, 
						S2, S2_1, S2_2, S2_3, S2_3a,
						S3, S3_2, S3_3, S3_6, S3_6a,
						S6, S6_3, S6_6, S6_11, S6_11a,
						S11, S11_6, S11_11);
						
    signal state_now, state_next 	: states;
	signal recall_state				: states;
	
	signal sig_wreq : std_logic;
	signal sig_busy : std_logic;

	subtype dx_vector is std_logic_vector(10 downto 0);

    signal dx    : dx_vector;
	signal trans : Boolean; -- "In transition (true when bit length increasing)"
    signal BPSx  : unsigned (3 downto 0);

	signal last_input_wait_state : std_logic;

begin


output_signals:

   	dout <= dx;
   	BPS  <= BPSx;

	wreq <= sig_wreq;

	busy <= '1' when sig_busy = '1' or trans else '0';

-- This process detects the condition last_input = '1'.  This should happen when cw_state_machine
-- is one of the non-transient states {S1, S2, S3, S6, S11}.  The state machine then enters a
-- transient mode in which further outputs may be produced.  The marker bits from the last of these 
-- transient states should be sent to bit_stuff as the 'last_data'.
end_condition_process1:
	process (state_now, last_input, clock) is
	begin
		if rising_edge(clock) then	-- Added to synchronize last_input_wait_state (10/31/2005).
			case state_now is
				when IDLE =>
					last_input_wait_state <= '0';
				when S1|S2|S3|S6|S11 =>
					if last_input = '1' then
						last_input_wait_state <= '1';
					end if;
				when others =>
						last_input_wait_state <= '0';
			end case;
		end if;
	end process;
	
-- This process sets last_output_a to '1' when cw_state_machine returns to a non-transient
-- state after processing the last delta.
end_condition_process2:
	process (state_now, last_input_wait_state)--, clock)
	begin
		if last_input_wait_state = '1' then
			case state_now is
				when S1|S2|S3|S6|S11 =>
					last_output <= '1';
				when others =>
					last_output <= '0';
			end case;
		else
			last_output <= '0';
		end if;
	end process;	
	

state_transition:
    process (clock, reset)
    begin
        if reset='1' then
            state_now <= IDLE;
        elsif clock'event and clock='1' then
            state_now <= state_next;
        end if;
    end process;


cw_state_machine:

    process (state_now, convert, trans, delta, ready, recall_state) is

		function make_dx_vector(d: in integer; n: in integer) return dx_vector is
			variable dd   : std_logic_vector(10 downto 0);
		begin								-- Output format
			if n = 1 then					--                         |<--------11 bits---------->|
				if d = 0 then				--  make_dx_vector(x, n):  [0....0][s][     abs(x)     ]
					dd := "00000000000";	--                                    |<-- n-1 bits -->|
				else
					dd := "00000000001";
				end if;
			else
				if n < 11 then -- Pad MSBs with zeros.
					dd(10 downto n) := (others => '0');
				end if;
				dd(n-1) := conv_std_logic_vector(d, 11)(10); -- sign bit
				dd(n-2 downto 0) := conv_std_logic_vector(abs(d), n-1); 
			end if;
			return dx_vector(dd);
		end function;
		
		
		procedure wait_and_goto( target_state : states ) is
		begin
			sig_busy <= '1';
			sig_wreq <= '0';
			recall_state <= target_state;
			if ready = '1' then
				state_next <= target_state;
			else
				state_next <= WAIT_RDY;
			end if;
		end procedure;
			
		
		variable idata : integer range -2**10 to 2**10-1;

    begin

		idata := conv_integer(delta);
		dx <= (others => '0');
		BPSx <= (others => '0');
		trans <= False;
		sig_busy <= '0';
		sig_wreq <= '0';
		
        case state_now is

			when WAIT_RDY =>
				sig_busy <= '1';
				sig_wreq <= '0';
				if ready = '1' then
					state_next <= recall_state;
				else
					state_next <= WAIT_RDY;
				end if;


            when IDLE =>
               	BPSx <= B"0000";
               	dx <= "00000000000";
				trans <= False;
			    sig_busy <= '1';
				sig_wreq <= '0';
			   	state_next <= S3;


            when S1 =>
               	BPSx <= B"0001";
			   	if convert = '0' then
					dx <= "00000000000";
					trans <= False;
					sig_busy <= '0';
					sig_wreq <= '0';
			    	state_next <= S1;
			   	elsif convert = '1' then
	               	if idata = 0 then
						dx <= "00000000000";
	                  	trans <= False;
						sig_busy <= '1';
						sig_wreq <= '0';
						wait_and_goto(S1_1);
	               	else
					  	dx <= "00000000001";
	                  	trans <= True;		-- Start upward transition
						sig_busy <= '1';
						sig_wreq <= '0';
						wait_and_goto(S1_2);
	               	end if;
			   	end if;
			

			when S1_1 =>
				BPSx <= B"0001";
				dx <= "00000000000";
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then	-- In case the input process is still holding
					state_next <= S1;	-- the value of convert high.
				else
					state_next <= S1_1;
				end if;
			
			
			when S1_2 =>
				BPSx <= B"0001";
				dx <= "00000000001";
				trans <= True;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S1_2a;
				else
					state_next <= S1_2;
				end if;
				
				
			when S1_2a =>	-- The states "S...a" create the down going strobe of sig_wreq.
				BPSx <= B"0001";
				dx <= "00000000001";
				sig_busy <= '1';
				sig_wreq <= '0';
				trans <= True;
				state_next <= S2;


            when S2 =>
               	BPSx <= B"0010";
			   	if convert = '0' and not trans then
					dx <= "00000000000";
					sig_busy <= '0';
					sig_wreq <= '0';
					trans <= False;
					state_next <= S2;
				elsif convert = '1' or trans then
					sig_busy <= '1';
					sig_wreq <= '0';
					if idata = 0 then
						dx <= "00000000000";
						trans <= False;
						wait_and_goto(S2_1);
					elsif abs(idata) = 1 then
						dx <= make_dx_vector(idata, 2);
						if trans then	-- Avoid a latch by coding this way.
							trans <= True;
						else
							trans <= False;
						end if;
						wait_and_goto(S2_2);
					else
						dx <= "00000000010";
						trans <= True;
						wait_and_goto(S2_3);
					end if;
				end if;

				
			when S2_1 =>
				BPSx <= B"0010";
				dx <= "00000000000";
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S1;
				else
					state_next <= S2_1;
				end if;

				
			when S2_2 =>
				BPSx <= B"0010";
				dx <= make_dx_vector(idata, 2);
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S2;
				else
					state_next <= S2_2;
				end if;


			when S2_3 =>
				BPSx <= B"0010";
				dx <= "00000000010";
				sig_busy <= '1';
				trans <= True;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S2_3a;
				else
					state_next <= S2_3;
				end if;
				
			when S2_3a =>
				BPSx <= B"0010";
				dx <= "00000000010";
				sig_busy <= '1';
				sig_wreq <= '0';
				trans <= True;
				state_next <= S3;
			

            when S3 =>
               	BPSx <= B"0011";
			   	if convert = '0' and not trans then 
					dx <= "00000000000";
					sig_busy <= '0';
					sig_wreq <= '0';
					trans <= False;
					state_next <= S3;
			   	elsif convert = '1' or trans then
					sig_busy <= '1';
					sig_wreq <= '0';
	               	if abs(idata) <= 1 then
					  	dx <= make_dx_vector(idata, 3);
						trans <= False;
						wait_and_goto(S3_2);
	               	elsif abs(idata) >= 4 then
					  	dx <= "00000000100";
	                  	trans <= True;
						wait_and_goto(S3_6);
	                else
						dx <= make_dx_vector(idata, 3);
						if trans then
							trans <= True;
						else
							trans <= False;
						end if;
						wait_and_goto(S3_3);
					end if;
				end if;
				
				
			when S3_2 =>
				BPSx <= B"0011";
				dx <= make_dx_vector(idata, 3);
				sig_busy <= '1';
				trans <= False;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S2;
				else
					state_next <= S3_2;
				end if;
				
				
			when S3_3 =>
				BPSx <= B"0011";
				dx <= make_dx_vector(idata, 3);
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S3;
				else
					state_next <= S3_3;
				end if;
				
				
			when S3_6 =>
				BPSx <= B"0011";
				dx <= "00000000100";
				sig_busy <= '1';
				trans <= True;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S3_6a;
				else
					state_next <= S3_6;
				end if;

			
			when S3_6a =>
				BPSx <= B"0011";
				dx <= "00000000100";
				sig_busy <= '1';
				sig_wreq <= '0';
				trans <= True;
				state_next <= S6;
			

            when S6 =>
               	BPSx <= "0110";
			   	if convert = '0' and not trans then
					dx <= "00000000000";
					sig_busy <= '0';
					sig_wreq <= '0';
					trans <= False;
					state_next <= S6;
			   	elsif convert = '1' or trans then
					sig_busy <= '1';
					sig_wreq <= '0';
	               	if abs(idata) <= 3 then
						dx <= make_dx_vector(idata, 6);
						trans <= False;
						wait_and_goto(S6_3);
	               	elsif abs(idata) >= 32 then
						dx <= "00000100000";
	                  	trans <= True;
						wait_and_goto(S6_11);
	               	else
					  	dx <= make_dx_vector(idata, 6);
						if trans then
							trans <= True;
						else
							trans <= False;
						end if;
						wait_and_goto(S6_6);
	               end if;
			   	end if;
			
			
			when S6_11 =>
				BPSx <= "0110";
				dx <= "00000100000";
				sig_busy <= '1';
				trans <= True;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S6_11a;
				else
					state_next <= S6_11;
				end if;

				
			when S6_11a =>
				BPSx <= B"0110";
				dx <= "00000100000";
				sig_busy <= '1';
				sig_wreq <= '0';
				trans <= True;
				state_next <= S11;
			

			when S6_6 =>
				BPSx <= B"0110";
				dx <= make_dx_vector(idata, 6);
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S6;
				else
					state_next <= S6_6;
				end if;

				
			when S6_3 =>
				BPSx <= B"0110";
				dx <= make_dx_vector(idata, 6);
				sig_busy <= '1';
				trans <= False;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S3;
				else
					state_next <= S6_3;
				end if;

				
            when S11 =>
               	BPSx <= "1011";
			   	if convert = '0' and not trans then
					dx <= "00000000000";
					sig_busy <= '0';
					sig_wreq <= '0';
					trans <= False;
					state_next <= S11;
			   	elsif convert = '1' or trans then
					sig_busy <= '1';
					sig_wreq <= '0';
					dx <= make_dx_vector(idata, 11);
	               	if abs(idata) <= 31 then
						trans <= False;
						wait_and_goto(S11_6);
	               	else
						if trans then
							trans <= True;
						else
							trans <= False;
						end if;
						wait_and_goto(S11_11);
	               	end if;
          		end if;


			when S11_6 =>
				BPSx <= B"1011";
				dx <= make_dx_vector(idata, 11);
				sig_busy <= '1';
				trans <= False;
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S6;
				else
					state_next <= S11_6;
				end if;
				
			
			when S11_11 =>
				BPSx <= B"1011";
				dx <= make_dx_vector(idata, 11);
				trans <= False;
				sig_busy <= '1';
				sig_wreq <= '1';
				if convert = '0' then
					state_next <= S11;
				else
					state_next <= S11_11;
				end if;

				
			when others =>			
				BPSx <= B"0000";
				dx <= (others => '0');
				sig_busy <= '0';
				sig_wreq <= '0';
				trans <= False;
				state_next <= IDLE;

          end case;

    end process;


end behave3;

