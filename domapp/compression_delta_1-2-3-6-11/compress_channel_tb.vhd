----------------------------------------------------------------------------
--File               : compress_channel_tb.vhd
--Author             : Nobuyoshi Kitamura
--Company            : IceCube
--Created            :
--Last Update        : August 21, 2005
----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.cw_data_types.all;
use work.str21_data.all;

entity compress_channel_tb is
end compress_channel_tb;

architecture behav of compress_channel_tb is

	component compress_channel 
    Port ( din          	: in word32;
           size_in      	: in unsigned(7 downto 0);
           clock        	: in std_logic;
           reset        	: in std_logic;
           start        	: in std_logic;
           addr_start_read  : in unsigned(7 downto 0);
           addr_start_write : in unsigned(8 downto 0);
           dout         	: out word32;
           addr_read    	: out unsigned(7 downto 0);
           addr_write   	: out unsigned(8 downto 0);
           wren         	: out std_logic;
           size_out     	: out unsigned(8 downto 0);
           errors       	: out std_logic_vector(7 downto 0);
           done         	: out std_logic		);
	end component;

	constant Tclk : time := 25 ns;

	signal reset, clock					: std_logic;
	
	signal start, wren, done 			: std_logic;
	
	signal size_in			 			: unsigned(7 downto 0);
	signal size_out						: unsigned(8 downto 0);
	signal addr_read, addr_start_read 	: unsigned(7 downto 0);
	signal addr_write, addr_start_write	: unsigned(8 downto 0);
	signal din, dout 					: word32;
	signal errors 						: std_logic_vector(7 downto 0);


begin

UUT: compress_channel
	port map ( 	
				din 				=> din,
				size_in 			=> size_in,
				clock 				=> clock,
				reset 				=> reset,
				start 				=> start,
				addr_start_read 	=> addr_start_read,
				addr_start_write 	=> addr_start_write,
				dout 				=> dout,		
				addr_read 			=> addr_read,
				addr_write 			=> addr_write,
				wren 				=> wren,
				size_out 			=> size_out,
				errors 				=> errors,
				done 				=> done
				
				);


clock_and_reset: 
   	process
   	begin
    	clock <= '1' after Tclk, '0' after 2*Tclk;
    	wait until clock = '0';
   	end process;
		
	din <= SIMU_DATA(conv_integer(addr_read)) when addr_read <= 63 else (others => '0');
			
	process
		use std.textio.all;
		variable LL: line;
		variable old_addr : unsigned(7 downto 0);
		variable cnt : integer := 0;
	begin
		reset <= '1', '0' after 140 ns;	

		addr_start_read 	<= (others => '0');
		addr_start_write 	<= (others => '0');
		old_addr := X"FF";

		size_in <= conv_unsigned(ATWD_SIZE_IN, 8);

		start <= '0', '1' after 200 ns, '0' after 300 ns;
		write(LL, string'("=== start ==="));
		writeline(output, LL);
		
		wait on wren, done;
		
		loop
			if addr_read = 63 then
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
				wait until wren = '0';
			end if;
			
			if done = '1' then 
				write(LL, string'("=== finish ==="));
				writeline(output, LL);
				write(LL, string'("time = "));
				write(LL, now);
				writeline(output, LL);
				write(LL, string'("size = "));
				write(LL, conv_integer(size_out));
				writeline(output, LL);
				wait;
			end if;
			--	wait until wren = '0';
			--end if;
			wait until rising_edge(clock);
		end loop;
	end process;
	
end behav;


