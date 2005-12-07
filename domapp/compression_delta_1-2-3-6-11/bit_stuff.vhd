-------------------------------------------------------------------------------
-- IceCube
-- DOM Data Compression Submodule
--
-- Author:  N. Kitamura
-- Version:	0.06	11/7/2005
--
-- File:	bit_stuff.vhd
--
-------------------------------------------------------------------------------
-- Ver 0.00		7/14/2005	Created
-- Ver 0.01		9/8/2005	Corrected the timing violations.
-- Ver 0.02		10/3/2005	Removed some of the changes in the last version.  
--							(The removed latches were functionally necessary.)
-- Ver 0.03		10/5/2005	Now runs at 290MHz
-- Ver 0.04		10/13/2005	Added channel_done signal to the entity declaration
-- Ver 0.05		10/20/2005	Bug fix in state_machine_comb (delete flush1, flush2, etc.).
--							Updated comments below.
-- Ver 0.06		11/7/2005	Fixed the error condition that produces an extraneous zero
--							output when ovf=true and tail2=0 at the end of channel.
--							This is accomplished by introducing the signal 'no_excess'.
--							Also, synchronized the boolean flags to meet speed reqirement.
-------------------------------------------------------------------------------
-- Notes:
--	This module packs (stuffs) the valid bits of the incoming words into the 32-bit 
--	wide words.
--
--	DX is the encoded word coming from the entity "map_word".  Within DX, only the
--	lowest BPS bits contain valid information.  The rest of the bits are discarded.
--
--	DX is permanently connected to the internal register IB. (An earlier version
--	used to latch DX on wreq.)
--	
-- 	When "wreq" (write request) becomes high, the signals "tail2" and "ovf" are
--	updated based on the current state and the value of "BPS" (latch operation).
--	The state machine then waits until "wreq" returns low to begin processing
--	the word.
--
--	The entity map_word is allowed to raise "wreq" only when "busy" is low.
-- 	When "wreq" goes high, "busy" becomes high on the following rising clock edge.
--	"busy" stays high until the module is ready to accept the next word.
--
--	Once "busy" goes high, it returns to low in two clock cycles, if no whole 32-bit
--	word is created.  When a whole 32-bit word is created, "word_ready" becomes high
--	in two clock cycles after "busy" going high.  At this point, the module waits
--	for "word_ack" is raised high by the process receiving the output of this
--	module (i.e., entity word_counter), after which "busy" returns low in two clock
--	cycles.
--
--	The writing process (map_word) must raise "last_input" high when it raises
--	"wreq" for writing the last input word.
--
--	When the module finishes processing the last input word, it raisesg "channel_done".
--	At this point, "busy" remains high.  "busy" goes back to low only when "reset"
--	is made high. ("reset" acts as a "channel start" signal.)
-------------------------------------------------------------------------------

library IEEE, lpm;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

USE lpm.lpm_components.all;
use work.cw_data_types.all;


entity bit_stuff is
    Port ( 	DX           	: in std_logic_vector(10 downto 0);
           	BPS          	: in unsigned(3 downto 0);
           	wreq         	: in std_logic;
           	clock        	: in std_logic;
           	reset        	: in std_logic;
           	op_reset		  :in std_logic;
		   	word_ack		: in std_logic;
		   	last_input		: in std_logic; -- This signal is needed to flush the buffer at the end of channel.
           	DY           	: out word32;
           	busy         	: out std_logic;
           	word_ready   	: out std_logic;
			channel_done	: out std_logic	);
end bit_stuff;


architecture Behav of bit_stuff is

	constant L : integer := DX'left + 1; -- L = 11
	constant M : integer := 5;
	constant N : integer := 2**M; --N = 32

   	type 	state is (	init, accept, accept2, stuff,
						hold, hold2, 
						flush,
						finish	);
						
--	attribute enum_encoding : string;
--	attribute enum_encoding of state : type is "one-hot";

   	signal 	state_now, state_next :   state;

	signal	tail	: integer range 0 to N+L-2;
	signal	tail2	: integer range 0 to N+L-2;
   	signal 	ovf     : boolean;
   	signal 	IB      : std_logic_vector(N+L-2 downto 0); -- Input buffer
   	signal 	IR      : std_logic_vector(N+L-2 downto 0); -- Intermediate register
   	signal 	IR2     : std_logic_vector(L-2 downto 0); 	-- Intermediate registger 2
   	signal 	OB      : std_logic_vector(N-1 downto 0); 	-- Output buffer

	signal shift_dist		: std_logic_vector(M-1 downto 0);
	signal shift_result 	: std_logic_vector(N+L-2 downto 0);
	signal this_is_last 	: boolean;
	signal sig_word_ready 	: std_logic;
	signal no_excess		: boolean;
	
begin

----------------------------------------------------------------------------
-- The shift occurs in such a way that the old bits is filled with zeros.
-- The overflow is not a problem.

--inst_barrel_shifter: 
--	component lpm_clshift
--		generic map (	LPM_WIDTH => N+L-1,
--						LPM_WIDTHDIST => M,
--						LPM_SHIFTTYPE  => "LOGICAL"
--					)
--		port map (		data => IB,
--						direction => '0', -- left-shift (towards MSB)
--						distance => shift_dist,
--						result => shift_result
--				);
				
	
inst_barrel_shifter: lpm_clshift 
	generic map (	LPM_WIDTH => N+L-1,
						LPM_WIDTHDIST => M,
						LPM_SHIFTTYPE  => "LOGICAL"
					)
		port map (		data => IB,
						direction => '0', -- left-shift (towards MSB)
						distance => shift_dist,
						result => shift_result
				);
				
	IB <= X"0000000" & B"000" & DX;

	shift_dist <= conv_std_logic_vector(tail, M);
	
	word_ready <= sig_word_ready;
	
	DY <= OB when sig_word_ready = '1' else (others => 'Z');
	
	this_is_last <= last_input = '1';

-------------------------------------------------------------------------
state_transition:
   	process(clock, reset,op_reset)
   	begin
      	if reset = '1' then
        	state_now <= init;
      	elsif clock'event and clock = '1' then
      		if op_reset='1' then
      			state_now <= init;
      		else
         			state_now <= state_next;
         		end if;
      	end if;
   	end process;


sync_flags_proc:
	process (clock, state_now, wreq)
	begin
		if rising_edge(clock) then
			case state_now is
				when init =>
					ovf <= false;
					no_excess <= false;
				when accept =>	
					if wreq = '1' then
						ovf   <= (tail + conv_integer(BPS)) >= N;	-- Latch
						no_excess <= (tail + conv_integer(BPS)) = N; -- Latch
					end if;
				when others => null;
			end case;
		end if;
	end process;


state_machine_comb:
   	process(state_now, wreq, tail, tail2, ovf, shift_result, word_ack,
				IR2, IB, OB, IR, this_is_last, BPS, last_input	)
	
	begin

   		case state_now is

        	when init =>
				busy <= '0';
				sig_word_ready <= '0';
				channel_done <= '0';
               	tail2 <= 0;
				tail <= 0;
                --ovf <= false;
				OB <= (others => '0');
               	state_next <= accept;

			when accept =>
				busy <= '0';
				sig_word_ready <= '0';
				channel_done <= '0';
				if wreq = '1' then
					tail2 <= (tail + conv_integer(BPS)) mod N;	-- Latch
					--ovf   <= (tail + conv_integer(BPS)) >= N;	-- Latch
					IR <= shift_result;							-- Latch
					IR2 <= shift_result(N+L-2 downto N);		-- Latch
						state_next <= accept2;
				else
					state_next <= accept;
				end if;
				       
			when accept2 =>
				busy <= '1';
				sig_word_ready <= '0';
				channel_done <= '0';
				if wreq = '1' then
					state_next <= accept2;
				else
					state_next <= stuff;
				end if;
				  	
			when stuff =>
				busy <= '1';
				sig_word_ready <= '0';
				channel_done <= '0';
				OB <= OB or IR(N-1 downto 0);
				tail <= tail2;
				if ovf or this_is_last then
					state_next <= hold;
				else
					state_next <= accept;
				end if;

			when hold =>
				busy <= '1';
				sig_word_ready <= '1';
				channel_done <= '0';
				if word_ack = '1' then
					state_next <= hold2;
				else
					state_next <= hold;
				end if;
				
			when hold2 =>
				busy <= '1';
				sig_word_ready <= '0';
				channel_done <= '0';
				OB(N-1 downto L-1) <= (others => '0');
				OB(L-2 downto 0) <= IR2;
				if this_is_last and ovf then
					state_next <= flush;
				elsif this_is_last and not ovf then
					state_next <= finish;
				else
					state_next <= accept;
				end if;
							
			when flush =>
				busy <= '1';
				channel_done <= '0';
				if ovf and not no_excess then
					sig_word_ready <= '1';
					if word_ack = '1' then
						state_next <= finish;
					else
						state_next <= flush;
					end if;
				else
					sig_word_ready <= '0';
					state_next <= finish;
				end if;

			when finish =>
				busy <= '1';
				sig_word_ready <= '0';
				channel_done <= '1';
				state_next <= finish;
					
      	end case;
	
	end process;
				
end Behav;