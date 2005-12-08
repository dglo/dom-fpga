----------------------------------------------------------------------------
--File               : compress_channel.vhd
--Author             : Nobuyoshi Kitamura
--Company            : IceCube
--Created            :
--Version			 : 0.06
--Last Update        : November 7, 2005
--
--Notes
--Ver 0.01	9/2/2005	Fixed bug reported by Dawn
--Ver 0.02	10/3/2005	Made changes to accommodate 10-bit unsigned pedestal-subtracted values.
--Ver 0.03	10/10/2005	Corrected initial delta to be data(0) rather than just 0.
--						Corrected misbehavior at end of channel.
--Ver 0.04	10/13/2005	The state machine makes use of channel_done originating in bit_stuff.
--Ver 0.05	10/19/2005	When last_data is set to 1, delta is set to 0 at the same time.  This should
--						take care of the garbage in the upper half of the last output word (subject to
--						verification).
--Ver 0.051	10/19/2005	Correct delta and enable_encode in FINISHa and FINISHb.
--Ver 0.052	10/20/2005	Updated comments
--Ver 0.06	11/7/2005	Detects the 'read_counter = 1' condition earlier to fix the end-of-the-channel bug.

----------------------------------------------------------------------------
----------------------------------------
-- Single Channel Compression Submodule
----------------------------------------
-- The main function of this submodule is to feed "delta_encoder" with "deltas"
-- that are computed from the 32-bit incoming words.
--
-- The input channel is any one of the ATWD channels or the FADC channel.
--
-- Each incoming 32-bit word contains two **10 bit unsigned data** such that the 
-- high word "H" is the data word sampled following the low word "L".
-- For the ATWD data, the half-words H and L are "pedestral-subtracted and biased":
--			ATWD_PS_BIAS = 100
--			ATWD_ped_sub = max(ATWD - pedestral + ATWD_PS_BIAS, 0)
-- cf Kael Hanson's email (9/28/2005)
--
--------------------------
-- How To Use This Module
--------------------------
--	1. 	Connect the data channel to din
--		Connect address_read to the data channel address
--		Connect address_write to output RAM address
--	2. 	Specify the number of 32-bit words to be encoded in size_in (See Notes below)
--		(This is the # of words minus one to be read from input.)
--	3. 	Specify the address of the first word in the input channel (addr_start_read)
--	4.	Set rese t <= '1' to signal the beginning of the channel.
--	5.	Set start <= '1' to start encoding
--	6.	Wait until done = '1'
--		At this point, you are left with size_out words of compressed words in the RAM
--		starting from the address addr_start_write.
--		The 8-bit word "errors" is a place holder and not implemented yet.
--

--                     |<--------------------[compress_channel]---------------------------->|
--  addr_start_read--->| ...                                                            ... |--->done
--          size_in--->| ...                                                            ... |--->errors
--            start--->| ...                                                            ... |--->addr_read
--            clock--->| ...  (Below are connections internal to compress_channel)          |
--            reset--->| ...                           |  |                                 |
--              din--->| ...                          _|  |_                                |
--                     |                              \    /                                |
--                                                     \  /
--                                                      \/
--
--                       |<--------------------- [delta_encoder] ----------------------->|
--	                     +----------------+     +----------------+      +----------------+
--                       |  [map_word]    |     |  [bit_stuff]   |      | [word_counter] | 
--                       |                |     |                |      |                |
--       enable_encode-->|convert         |     |      word_ready|----->|word_ready      |
--                       |           ready|<----|~busy           |      |       count_out|---> size_out
--	                     |                |     |                |      |        word_out|---> dout
--	            delta--->|delta       dout|---->|DX              |      |                |
--                       |             BPS|---->|BPS           DY|----->|word_in         |
--                       |            wreq|---->|wreq    word_ack|<---+-|word_ack        |
--           last_data-->|last_input      |     |                |    | |                |
--                       |                |     |                |    | |                |
--                       |     last_output|---->|last_input      |    | |                |
--                       |            busy|--+  |    channel_done|--+ | |                |
--                       +----------------+  |  +----------------+  | | +----------------+
--                                           |                      | +----------------------> have_word
--                                           |                      +------------------------> channel_done
--                                           +-----------------------------------------------> encoder_busy
--  
--
-----------------------------
-- File Dependency
-----------------------------
--
--	compress_channel.vhd
--		+----cw_data_types.vhd
--		+----delta_encoder.vhd
--				+----map_word.vhd
--				+----word_counter.vhd
--				|		+----cw_data_types.vhd
--				+----bit_stuff.vhd
--						+----cw_data_types.vhd
--						+----lpm_pack.vhd (Altera implementation of a barrel shifter)
--
--
-------------------------------------------------
-- Notes on Number of Words, Input Address, etc.
-------------------------------------------------
-- N          = no. of words to be encoded
-- size_in    = N - 1
-- addr_read  = addr_start_read + size_in - read_counter
-- -------------------------+---------------+-----------------
--		addr_read			|	data_in		|	read_counter (WORD_DONE)
-- -------------------------+---------------+-----------------
-- addr_start_read			|	word(0)		|	N - 1
-- addr_start_read + 1		|	word(1)		|	N - 2
-- addr_start_read + 2		|	word(2)		|	N - 3
-- 		....				|	....		|	....
-- addr_start_read + N - 1	|	word(N-1)	|	0
-- -------------------------+---------------+-----------------
--
-- size_out	= M (*not* M - 1), where M is the number of words to be output.

-------------------------
-- How This Module Works
-------------------------
--
--	In the following pseudocode, the intermediate states are omitted.
-- 	Let A, B, C, and delta be signed 11-bit integers.
--
--	@Always:
--		A <= high(din)
--		B <= low(din)
--		addr_read <= addr_start_read + size_in - read_counter
--		
-- 	1.  Idle:
--			Wait until start = '1'
--			read_counter <= size_in
--	2.	Encode0:
--			delta <= B
--			encode_delta()
--			goto Encode2
--	3.	Encode1:
--			delta <= B - C
--			encode_delta()
--	4.	Encode2:
--			delta <= A - B
--			encode_delta()
--			C <= A
--			read_counter <= read_counter - 1
--
--	5.	If read_counter = 0 then
--			goto Finish
--		else
--			goto Encode1
--		end if
--	6.	Finish:
--			done <= '1'
--			goto Idle
--
---------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.cw_data_types.all;


entity compress_channel is
    port ( din          : in word32;
           size_in      : in unsigned(7 downto 0); -- size_in = N - 1, where N = No. of words to encode.
           clock        : in std_logic;
           reset        : in std_logic;
           start        : in std_logic;
           addr_start_read  : in unsigned(7 downto 0);
           dout         : out word32;
           addr_read    : out unsigned(7 downto 0);
           wren         : out std_logic;
           size_out     : out unsigned(8 downto 0); -- No of encoded words (1, 2, 3, ...)
           errors       : out std_logic_vector(7 downto 0);
           done         : out std_logic		);
end compress_channel;


architecture Behavioral of compress_channel is

	type states is (	IDLE, 
						ENCODE0, ENCODE0a, ENCODE0b,
					 	ENCODE1, ENCODE1a, ENCODE1b,   
					 	ENCODE2, ENCODE2a, ENCODE2b,
						WORD_DONE, 
						FINISH, FINISHa, FINISHb	);
					
	signal state_now, state_next : states;

	constant L : integer := 11;

	signal A, B, C	           	: signed(L-1 downto 0);
	signal delta               	: signed(L-1 downto 0);
	signal read_counter        	: unsigned(7 downto 0);
	signal new_read_counter	   	: unsigned(7 downto 0);

	signal enable_encode       	: std_logic;
	signal encode_size         	: unsigned(8 downto 0);
	
	signal encoder_busy		   	: std_logic;
	signal have_word		   	: std_logic;
	signal stuff_done			: std_logic;

	component delta_encoder
	    Port ( 	clock           : in std_logic;
	          	reset_channel   : in std_logic;
			   	convert			: in std_logic;
	           	delta_in        : in signed(10 downto 0);
				last_data		: in std_logic;
	           	word_out        : out word32;
				count_out		: out unsigned(8 downto 0);
				have_word		: out std_logic;
				encoder_busy	: out std_logic;
				stuff_done		: out std_logic;
				errors			: out std_logic_vector(7 downto 0)	);
	end component;

	signal last_data			: std_logic;
	
	signal delta_encoder_errors : std_logic_vector(7 downto 0);

begin

 
Inst_delta_encoder: delta_encoder
	port map (
			    clock       		=> clock,
			    reset_channel       => reset,
			    convert      		=> enable_encode,
			    delta_in       		=> delta,
				last_data			=> last_data,
			    word_out        	=> dout,
			    have_word   		=> have_word,
			    count_out        	=> encode_size,
				errors			    => delta_encoder_errors,
				encoder_busy		=> encoder_busy,
				stuff_done			=> stuff_done
			);
 
	
	errors <= delta_encoder_errors;
			
	size_out <= encode_size;

	A <= '0' & signed( din (16 + L - 2 downto 16) );
	B <= '0' & signed( din (L - 2 downto 0) );
	
	addr_read <= (addr_start_read + size_in) - read_counter; -- Added the parentheses (...)

output_ram_write_strobe:

	process (clock, reset, have_word)
	begin
		if reset = '1' then
			wren <= '0';
		elsif rising_edge(clock) then
			if have_word = '1' then
				wren <= '1';
			else
				wren <= '0';
			end if;
		end if;
	end process;


comp_channel_state_machine:

	process(clock, reset)
   	begin
    	if reset = '1' then
			state_now <= IDLE;
      	elsif rising_edge(clock) then
         	state_now <= state_next;
      	end if;
   	end process;


	process( clock, reset,state_now, start, read_counter, new_read_counter, 
			 A, B, C, encoder_busy, have_word, stuff_done, size_in)
			
	begin		

	if reset = '1' then
			state_next <= IDLE;
      	elsif rising_edge(clock) then

		case state_now is
	
	
			when IDLE =>
	           	enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= (others => '0');
				read_counter <= size_in;
	            if start = '1' then
	               	state_next <= ENCODE0;
	            else
	               	state_next <= IDLE;
	            end if;
	
	
			when ENCODE0 =>
				enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= B;
				if encoder_busy = '1' then
					state_next <= ENCODE0;
				else
					state_next <= ENCODE0a;
				end if;


			when ENCODE0a =>
				enable_encode <= '1';
				last_data <= '0';
				done <= '0';
				delta <= B;
				state_next <= ENCODE0b;
				

			when ENCODE0b =>
				enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= B;
				if encoder_busy = '1' then
					state_next <= ENCODE0b;
				else
					state_next <= ENCODE2;
				end if;
								

	        when ENCODE1 =>
				enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= B - C;
				if encoder_busy = '1' then
					state_next <= ENCODE1;
				else
					state_next <= ENCODE1a;
				end if;
				
				
			when ENCODE1a =>
				enable_encode <= '1';
				last_data <= '0';
				done <= '0';
				delta <= B - C;
				state_next <= ENCODE1b;


			when ENCODE1b =>
				enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= B - C;
				if encoder_busy = '1' then
					state_next <= ENCODE1b;
				else
					state_next <= ENCODE2;
				end if;
				
				
			when ENCODE2 =>
				enable_encode <= '0';
				last_data <= '0';
				done <= '0';
				delta <= A - B;
				C <= A;
				if encoder_busy = '1' then
					state_next <= ENCODE2;
				else
					state_next <= ENCODE2a;
				end if;

	
			when ENCODE2a =>
				enable_encode <= '1';
				if read_counter = 1 then--------
					last_data <= '1';
				else--------
					last_data <= '0';
				end if;--------
				done <= '0';
				delta <= A - B;
		        state_next <= ENCODE2b;
		
		
			when ENCODE2b =>
				enable_encode <= '0';
				if read_counter = 1 then--------
					last_data <= '1';
				else--------
					last_data <= '0';
				end if;--------
				done <= '0';
				delta <= A - B;
				if encoder_busy = '1' then
					state_next <= ENCODE2b;
				else
					state_next <= WORD_DONE;
				end if;
				new_read_counter <= read_counter - 1;


			when WORD_DONE =>
				enable_encode <= '0';
				done <= '0';
				delta <= A - B;
				read_counter <= new_read_counter;
				if new_read_counter = 0 then
					last_data <= '1';--------------------
					state_next <= FINISHa;
				else
					last_data <= '0';
					state_next <= ENCODE1;
				end if;
				

			when FINISHa =>
				enable_encode <= '0';
				last_data <= '1';
				done <= '0';
				delta <= A - B;-----------------
				state_next <= FINISHb;

			when FINISHb =>
				enable_encode <= '0';
				last_data <= '1';
				done <= '0';
				delta <= (others => '0');
				if stuff_done = '0' then
					state_next <= FINISHb;
				else
					state_next <= FINISH;
				end if;


	        when FINISH =>
				enable_encode <= '0';
				last_data <= '1';
				done <= '1';
				delta <= (others => '0');
	            state_next <= IDLE;

			when others =>
				null;


		end case;
		end if;
	end process;


end Behavioral;
