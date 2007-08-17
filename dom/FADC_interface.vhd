-------------------------------------------------
-- FADC
-- 
-- This module writes 256 samples from the FADC
-- into a buffer memory
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

ENTITY FADC_interface IS
	GENERIC (
		FADC_WIDTH		: INTEGER := 10
	);
	PORT (
		CLK40			: IN STD_LOGIC;
		RST				: IN STD_LOGIC;
		-- enable
		
		-- test connector
		TC				: OUT STD_LOGIC_VECTOR (7 downto 0)
	);
END FADC_interface;

ARCHITECTURE FADC_interface_arch OF FADC_interface IS


BEGIN

	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
		ELSIF CLK40'EVENT AND CLK40='0' THEN
			IF trigger='1' AND localcincidence='0' THEN	-- acquire data
				IF wr_addr=255 AND fadc_busy THEN	-- memory full
					we	<= '0';
					wr_addr	<= -1;
					fadc_busy	<= '0';
					done	<= '1';
				ELSE	-- filling memory
					we	<= '1';
					wr_addr	<= wr_addr + 1;
					fadc_busy	<= '1';
					done	<= '0';
				END IF;
			ELSE	-- idle
				we	<= '0';
				wr_addr	<= -1;
				fadc_busy	<= '0';
				done		<= '0';
			END IF;
		END IF;
	END PROCESS;
	
	wr_data(FADC_WIDTH-1 DOWNTO 0)	<= fADC_D;
	wr_data(FADC_WIDTH)	<= overflow;
	wr_data(15 DOWNTO FADC_WIDTH+1)	<= (others='0');

END FADC_interface_arch;