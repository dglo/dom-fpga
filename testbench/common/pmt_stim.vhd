-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : pmt_stim.vhd
-- Author     : Rudy Moore
-- Company    : UW-Madison
-- Created    : 2004-08-20
-- Last update: 
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module reads a stimulous file and applies the stimulous
--	to its output pins.  A virtual discriminator!

--	Virtual discriminator signals
--		SPE : out
--		MPE : out

--		Filename : in
--			Format:
--				Trigger
--					0 - none
--					1 - SPE
--					2 - MPE	
--					3 - SPE & MPE
--
--				Width
--					minimum 2 ns
--				Delay
--					time between pulses
--				Loop
--					Count for number of loops
--			Example:
--			    1 25 5000 5
--			    This line would issue a SPE pulse, 25 ns long, wait 5000 ns, then repeat 4 more times
--			    Note: a loop count of 0 will produce NO pulse (but you'll get the delay), 1 gives
--				a single pulse.
--			Hat trick
--				Write a loop syntax that creates a looping
--				structure.

-------------------------------------------------------------------------------
-- Copyright (c) 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version	   Author    Description
-------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

use work.ctrl_data_types.all;


entity pmt_stim is
    generic (
	filename : string
	);
    port (
	ONESPE	    : out std_logic;
	MULTISPE    : out std_logic;
	ONESPE_NL   : in std_logic;
	MULTISPE_NL : in std_logic
	);
end pmt_stim;

architecture pmt_stim1 of pmt_stim is

-- interpretation functions?
--    function 

file STDOUT   : text is out "STD_OUTPUT";

signal CLK	    : std_logic;
signal NOWSIG	    : time;

constant DEBUG	    : integer := 0;

begin

    clkproc : process
	variable LCLK		: std_logic := '0';
	variable DONE		: std_logic := '0';
    begin
	wait for 1 ns;
	while (DONE = '0') loop
	    LCLK := not LCLK;
	    CLK <= LCLK;
	    NOWSIG <= NOW;
	    wait for 1 ns;
	end loop;
    end process;


    stim : process

	file STIMDATA		: text;
	variable GET_LINE	: line;

	variable PULSE		: integer;
	variable PULSEWIDTH	: time;
	variable PULSEDELAY	: time;
	variable PULSELOOPCNT	: integer;

	variable OLDTIME	: time;

	variable OUT_LINE	: line;


    begin
	ONESPE	    <= '0';
	MULTISPE    <= '0';

	wait for 500 ns;				    -- spacing to begin the process
	
	file_open( STIMDATA, filename, READ_MODE );

	OLDTIME := NOWSIG;

	if (DEBUG = 1) then
	    write( OUT_LINE, string'("Opened file."));
	    writeline(STDOUT, OUT_LINE);
	end if;

	while not (endfile(STIMDATA)) loop

	    readline(STIMDATA, GET_LINE);		    -- read a line from the data file
	    if (GET_LINE'length > 0) then
		read(GET_LINE, PULSE);
		read(GET_LINE, PULSEWIDTH);
		read(GET_LINE, PULSEDELAY);
		read(GET_LINE, PULSELOOPCNT);

		if (DEBUG = 1) then
		    write( OUT_LINE, string'("Read Line: "));
		    write( OUT_LINE, PULSE); write( OUT_LINE, string'(" "));
		    write( OUT_LINE, PULSEWIDTH); write( OUT_LINE, string'(" "));
		    write( OUT_LINE, PULSEDELAY); write( OUT_LINE, string'(" "));
		    write( OUT_LINE, PULSELOOPCNT);
		    writeline(STDOUT, OUT_LINE);
		end if;

		if (PULSELOOPCNT = 0) then

		    if (DEBUG = 1) then
			write( OUT_LINE, NOW );
			write( OUT_LINE, string'(": Simple Delay: "));
			write( OUT_LINE, PULSEDELAY );
			writeline(STDOUT, OUT_LINE);

			write( OUT_LINE, NOW );
			write( OUT_LINE, string'(" DelayTime: "));
			write( OUT_LINE, PULSEDELAY );
			write( OUT_LINE, string'(" OLDTIME: "));
			write( OUT_LINE, OLDTIME );
			writeline(STDOUT, OUT_LINE);
		    end if;

		    wait until (NOWSIG > OLDTIME + PULSEDELAY);

		    OLDTIME := NOWSIG;
		else
		    if (DEBUG = 1) then
			write( OUT_LINE, NOW );
			write( OUT_LINE, string'(": PULSE: "));
			write( OUT_LINE, PULSE); write( OUT_LINE, string'(" "));
			write( OUT_LINE, PULSEWIDTH); write( OUT_LINE, string'(" "));
			write( OUT_LINE, PULSEDELAY); write( OUT_LINE, string'(" "));
			write( OUT_LINE, PULSELOOPCNT);
			writeline(STDOUT, OUT_LINE);
		    end if;

		    for i in 0 to PULSELOOPCNT LOOP
			case PULSE is			    -- signal goes high
			    when 0 =>
				-- no signals get changed
			    when 1 =>
				ONESPE	    <= '1';
				
			    when 2 =>
				MULTISPE	    <= '1';

			    when 3 =>
				ONESPE	    <= '1';
				MULTISPE	    <= '1';

			    when others =>
				-- not valid
			end case;

			wait until (NOWSIG > OLDTIME + PULSEWIDTH);-- signal stay high
			OLDTIME := NOWSIG;

			case PULSE is			    -- signal goes low
			    when 0 =>
				-- no signals get changed
			    when 1 =>
				ONESPE	    <= '0';
				
			    when 2 =>
				MULTISPE	    <= '0';

			    when 3 =>
				ONESPE	    <= '0';
				MULTISPE	    <= '0';

			    when others =>
				-- not valid
			end case;

			wait until (NOWSIG > OLDTIME + PULSEDELAY);-- inter-pulse delay
			OLDTIME := NOWSIG;

		    end loop;
		end if;
	    end if;
	    
	end loop;					    -- repeat for all lines in file

	write( OUT_LINE, string'("End of PMT data."));
	writeline(STDOUT, OUT_LINE);

	wait;
	    
    end process stim;

end architecture pmt_stim1;
