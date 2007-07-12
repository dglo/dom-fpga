----------------------------------------------------------------------------
--File               : compress_channel_tb.vhd
--Author             : Nobuyoshi Kitamura
--Company            : IceCube
--Created            :
--Last Update        : October 10, 2005
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.cw_data_types.all;
--use work.str21_data.all;
--use work.fake_input.all;

use std.textio.all;


entity compress_channel_tb3 is
end compress_channel_tb3;

architecture behav of compress_channel_tb3 is

	component compress_channel 
    Port ( din          	: in word32;
           size_in      	: in unsigned(7 downto 0);
           clock        	: in std_logic;
           reset        	: in std_logic;
           start        	: in std_logic;
           addr_start_read  : in unsigned(7 downto 0);
           dout         	: out word32;
           addr_read    	: out unsigned(7 downto 0);
           wren         	: out std_logic;
           size_out     	: out unsigned(8 downto 0);
           errors       	: out std_logic_vector(7 downto 0);
           done         	: out std_logic		);
	end component;

	constant Tclk : time := 25 ns;

	signal reset, clock				: std_logic;
	
	signal start, wren, done				: std_logic;
	
	signal size_in			 	: unsigned(7 downto 0);
	signal size_out				: unsigned(8 downto 0);
	signal addr_read, addr_start_read			: unsigned(7 downto 0);
	signal addr_write, addr_start_write	: unsigned(8 downto 0);
	signal din, dout					: word32;
	signal errors 					: std_logic_vector(7 downto 0);



	--constant ATWD_SIZE_IN : integer := 64;
	constant ATWD_SIZE_IN : integer := 64*3;
	

--	type simu_atwd_data_type is array (integer range 0 to ATWD_SIZE_IN - 1) of word32;
	type simu_atwd_data_type is array (integer range 0 to ATWD_SIZE_IN - 1) of integer;
	signal SIMU_DATA : simu_atwd_data_type;

--	constant input_file_name : string := "atwd012_flasher_run.dat";
	constant input_file_name : string := "random_integer.txt";

	constant output_file_name : string := "random_simulated.txt";
		
	file input_file : text open read_mode is input_file_name;
	file output_file : text open write_mode is output_file_name;
	

	function get_data_word32(file f: text)  return integer is
		variable val : word32;
		variable bval: bit_vector(31 downto 0);
		variable L : line;
		variable ival: integer;
	begin
		if endfile(f) then
			val := (others => '0');
		else
			readline(f, L);
			--read(L, bval);
			--val := to_X01(bval);
			read(L, ival);
		end if;
		--return val;
		return ival;
	end function;
	
	--type hexdigit is ('0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f');
	--type hex8 is array(7 downto 0) of hexdigit;
	type hex8 is array(7 downto 0) of character;
	
	function word32_to_hex(x : in word32) return string is
		variable i: integer range 31 downto 0;
		variable m: std_logic_vector(3 downto 0);
		variable h: hex8;
		variable k: string(8 downto 1);
	begin
		for i in 8 downto 1 loop
			m := x(4*i-1 downto 4*i-4);
			case m is
				when "0000" => k(i) := '0';
				when "0001" => k(i) := '1';
				when "0010" => k(i) := '2';
				when "0011" => k(i) := '3';
				when "0100" => k(i) := '4';
				when "0101" => k(i) := '5';
				when "0110" => k(i) := '6';
				when "0111" => k(i) := '7';
				when "1000" => k(i) := '8';
				when "1001" => k(i) := '9';
				when "1010" => k(i) := 'a';
				when "1011" => k(i) := 'b';
				when "1100" => k(i) := 'c';
				when "1101" => k(i) := 'd';
				when "1110" => k(i) := 'e';
				when "1111" => k(i) := 'f';
				when others => k(i) := '-';
			end case;
		end loop;
		return k;
	end function;
	
	
	
	
	
begin

UUT: compress_channel
	port map ( 	
				din			=> din,
				size_in			=> size_in,
				clock 			=> clock,
				reset			=> reset,
				start			=> start,
				addr_start_read			=> addr_start_read,
				dout			=> dout,		
				addr_read			=> addr_read,
				wren			=> wren,
				size_out			=> size_out,
				errors			=> errors,
				done			=> done
				);


clock_and_reset: 
   	process
   	begin
    	clock <= '1' after Tclk, '0' after 2*Tclk;
    	wait until clock = '0';
   	end process;
		
--	din <= SIMU_DATA(conv_integer(addr_read)) when addr_read <= 63 else (others => '0');
--	din <= SIMU_DATA(conv_integer(addr_read)) when addr_read <= 63;--  else (others => '0');
	din <= word32( conv_std_logic_vector( SIMU_DATA(conv_integer(addr_read)),32) ) 
		when addr_read <= ATWD_SIZE_IN - 1;
			
	process
		variable LL: line;
		variable old_addr : unsigned(7 downto 0);
		variable cnt : integer := 0;
		
		variable hit_index : integer := 0;
				
	variable i : integer;
	
	begin
	
	
	
		hit_index := -1;

		LOOP
				hit_index := hit_index + 1;				
								
				for i in 0 to ATWD_SIZE_IN - 1 loop
					SIMU_DATA(i) <= get_data_word32(input_file);
				end loop;

				reset <= '1', '0' after 2*Tclk;	
				
				cnt := 0;

				addr_start_read 	<= (others => '0');
				old_addr := X"FF";

				size_in <= conv_unsigned(ATWD_SIZE_IN, 8);

				start <= '0', '1' after 2*Tclk, '0' after 4*Tclk;
				write(LL, string'("=== start["));
				write(LL, hit_index);
				write(LL, string'("] ==="));
				writeline(output, LL);

				write(LL, string'("OUT["));
				write(LL, hit_index);
				write(LL, string'("]"));				
				writeline(output_file, LL);
								
				wait on wren, done, clock;
				
				loop	-- beginning of a channel
					if addr_read = ATWD_SIZE_IN - 1 then
						write(LL, string'("----last word-----"));
						writeline(output, LL);
					end if;
				
					if addr_read /= old_addr then
						write(LL, string'("input addr = "));
						write(LL, to_bitvector(std_logic_vector(addr_read)));
						write(LL, string'(" : "));
						write(LL, to_bitvector(din));
						writeline(output, LL);
						old_addr := addr_read;
					end if;
				
					if wren = '1' then
						cnt := cnt + 1;
						write(LL, string'("==============================> WORD("));
						write(LL, conv_integer(cnt));
						write(LL, string'(") = "));
						write(LL, to_bitvector(dout));
						writeline(output, LL);
						
						--write(LL, to_bitvector(dout));
						write(LL, string'(word32_to_hex(dout)) );
						writeline(output_file, LL);
						
						wait until wren = '0';
						
					end if;
					
					if done = '1' then 
						--wait for 500 ns;
						write(LL, string'("=== finish ==="));
						writeline(output, LL);
						write(LL, string'("time = "));
						write(LL, now);
						writeline(output, LL);
						write(LL, string'("size = "));
						write(LL, conv_integer(size_out));
						writeline(output, LL);
						wait for 500 ns;
						exit;
						
					end if;
					
					wait until rising_edge(clock);
					
				end loop;
				
				if endfile(input_file) then
					file_close(input_file);
					write(LL, string'("=== End of File ==="));
					writeline(output, LL);
					file_close(output_file);
					wait;
				end if;
		
		END LOOP;
		
	end process;
	
end behav;


