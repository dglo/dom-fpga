----------------------------------------------------------------------------
--File               : delta_encoder_tb.vhd
--Author             : Nobuyoshi Kitamura
--Company            : IceCube
--Created            :
--Last Update        : August 7, 2005
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;
use work.cw_data_types.all;


entity delta_encoder_tb is
end delta_encoder_tb;

architecture behave of delta_encoder_tb is
	component delta_encoder
	    port ( 	clock           : in std_logic;
	          	reset_channel   : in std_logic;
			   	convert			: in std_logic;
	           	delta_in        : in signed(10 downto 0);
				last_data		: in std_logic;
	           	word_out        : out word32;
				count_out		: out unsigned(8 downto 0);
				have_word		: out std_logic;
				encoder_busy	: out std_logic;
				errors			: out std_logic_vector(7 downto 0)		
				);
	end component;

	signal clock, reset	: std_logic;
	signal convert, have_word, encoder_busy : std_logic;
	signal count_out : unsigned(8 downto 0);
	signal word_out : word32;
	signal delta_in : signed(10 downto 0);


--=======================================
	constant max_index : integer := 134; -- value for debug only
--=======================================	
	type simu_data_type is array(integer range 0 to max_index) of integer;

	signal data_index : integer range 0 to max_index;

	constant Tclk : time := 12.5 ns;

	constant simu_data : simu_data_type := 
		(	1023, 0, -1, 2, -1023, 1, -1, -1, 2, 0, 0, 1, -1, 0, 1, 1, -1, -1, 
			0, 0, 0, 0, 0, 0, 0, -1, 0, 1, 0, 1, -2, 1, -2, 1, -1, 1, -1, 
			0, 2, 0, -1, 1, 1, 0, -1, -1, 0, 0, 0, -1, 0, 1, 1, 0, -1, 1, 
			0, 0, -1, 1, -1, 0, 0, 0, 0, 0, 0, 1, -1, 1, 0, -1, 0, -1, 0, 
			2, -1, -2, 2, -1, 1, 2, -1, 0, 0, 1, -1, 3, 0, 5, 5, 6, -2, -7, 
			-5, 2, 2, 1, -6, -3, -2, 2, -1, 1, -2, 0, 0, 1, 0, 1, -1, 0, 1, 
			3, 0, 2, 7, 8, 15, 22, 11, -16, -34, -17, -2, -1, 1		,0, -5, 8, 2, -1, 0, 0, 1);


    file disk_output : text open write_mode is "encoded_data.txt";

	signal high_word, low_word : std_logic_vector(15 downto 0);

	signal end_of_data : boolean;
	
	signal last_data : std_logic;
	signal errors : std_logic_vector(7 downto 0);

begin

inst_delta_encoder: delta_encoder
	port map (	clock			=> clock,
				reset_channel	=> reset,
				convert			=> convert,
				delta_in		=> delta_in,
				last_data		=> last_data,
				word_out		=> word_out,
				count_out		=> count_out,
				have_word		=> have_word,
				errors			=> errors,
				encoder_busy	=> encoder_busy	);
				
	high_word <= word_out(31 downto 16);
	low_word  <= word_out(15 downto 0);

clock_generator:
   	process
   	begin
    	clock <= '1' after Tclk, '0' after 2*Tclk;
    	wait until clock = '0';
   	end process;	
	
	
have_word_process:
	process
		variable LL: line;
		variable had_word : Boolean := False;
	begin
		wait until rising_edge(clock);
		
		if have_word = '1' and not had_word then
			had_word := True;
				
			write(LL, string'("Word ("));
			write(LL, conv_integer(count_out));
			write(LL, string'(") = "));
			write(LL, to_bitvector(high_word));
			write(LL, string'(" : "));
			write(LL, to_bitvector(low_word));
			write(LL, string'(" (Dec "));
			write(LL, conv_integer('0' & high_word));
			write(LL, string'(" : "));
			write(LL, conv_integer('0' & low_word));
			write(LL, string'(" )"));
			writeline(output, LL);
			
			write(LL, conv_integer(low_word));
			writeline(disk_output, LL);
			write(LL, conv_integer(high_word));
			writeline(disk_output, LL);
			if end_of_data then
				write(LL, string'("========End of Output======"));
				writeline(output, LL);
				write(LL, string'("Time : "));
				write(LL, now);
				writeline(output, LL);
				write(LL, string'("Tclk : "));
				write(LL, 2*Tclk);
				writeline(output, LL);
				wait;
			end if;
		elsif have_word = '1' and had_word then
			null;
		else
			had_word := False;
		end if;
	end process;
	
	
	
do_simulation:
	process
		variable LL: line;
		variable temp: signed(10 downto 0);
	begin
		reset <= '0', '1' after 10 ns, '0' after 100 ns;
		last_data <= '0';
		data_index <= 0;
		end_of_data <= False;
		convert <= '0';
		wait for 30 ns;
		write(LL, string'("=====Start Channel====="));
		writeline(output, LL);		
		loop
			wait until rising_edge(clock);
			if encoder_busy = '0' then
				delta_in <= conv_signed(simu_data(data_index), 11);
				convert <= '1';
				--write(LL, string'("delta("));
				--write(LL, data_index);
				--write(LL, string'(") = "));
				--write(LL, simu_data(data_index));
				--writeline(output, LL);
				wait until rising_edge(clock);
				convert <= '0';
				if data_index < max_index then
					data_index <= data_index + 1;
				else
					last_data <= '1';
					end_of_data <= True;
				end if;
			else
				write(LL, string'("---busy---"));
				writeline(output, LL);
			end if;
			if end_of_data then
				write(LL, string'("=======End of Input Data======="));
				writeline(output, LL);
			
				wait until have_word = '1';
				
				wait until rising_edge(clock);
				end_of_data <= False;				
				exit;
			end if;
		end loop;
		--file_close(disk_output);
		wait;
	end process;

	
	
end behave;

--configuration simulation_only of delta_encoder_tb is
--	for behave
--		for inst_delta_encoder: delta_encoder
--			use configuration work.delta_encoder_experimental;
--		end for;
--	end for;
--end configuration simulation_only;
