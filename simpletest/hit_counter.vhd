-------------------------------------------------
--- hit counter for the two discriminators
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;

ENTITY hit_counter IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- discriminator input
		MultiSPE		: IN STD_LOGIC;
		OneSPE			: IN STD_LOGIC;
		-- discriminator reset
		MultiSPE_nl		: OUT STD_LOGIC;
		OneSPE_nl		: OUT STD_LOGIC;
		-- output
		multiSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		oneSPEcnt		: OUT STD_LOGIC_VECTOR(15 downto 0);
		-- test connector
		TC					: OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END hit_counter;

ARCHITECTURE arch_hit_counter OF hit_counter IS
	
	SIGNAL MultiSPE0	: STD_LOGIC;
	SIGNAL MultiSPE1	: STD_LOGIC;
	SIGNAL MultiSPE2	: STD_LOGIC;
	SIGNAL MultiSPE3	: STD_LOGIC;
	SIGNAL OneSPE0		: STD_LOGIC;
	SIGNAL OneSPE1		: STD_LOGIC;
	SIGNAL OneSPE2		: STD_LOGIC;
	SIGNAL OneSPE3		: STD_LOGIC;
	
BEGIN
	
	PROCESS(RST, CLK)
		VARIABLE cnt100ms	: integer;
		VARIABLE multiSPEcnt_int	: STD_LOGIC_VECTOR (15 downto 0);
		VARIABLE oneSPEcnt_int		: STD_LOGIC_VECTOR (15 downto 0);
	BEGIN
		IF RST='1' THEN
			cnt100ms	:= 2000000;
			MultiSPE_nl	<= '1';
			OneSPE_nl	<= '1';
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF cnt100ms = 0 THEN
				multiSPEcnt	<= multiSPEcnt_int;
				oneSPEcnt	<= oneSPEcnt_int;
				cnt100ms	:= 2000000;
				multiSPEcnt_int	:= (others=>'0');
				oneSPEcnt_int	:= (others=>'0');
			ELSE
				cnt100ms	:= cnt100ms - 1;
				
				IF MultiSPE2='0' AND MultiSPE1='1' THEN
					multiSPEcnt_int	:= multiSPEcnt_int+1;
				END IF;
				IF OneSPE2='0' AND OneSPE1='1' THEN
					oneSPEcnt_int	:= oneSPEcnt_int+1;
				END IF;
				
			END IF;
			
			IF MultiSPE3='1' THEN
				MultiSPE_nl	<= '1';
			ELSE
				MultiSPE_nl	<= '0';
			END IF;
			IF OneSPE3='1' THEN
				OneSPE_nl	<= '1';
			ELSE
				OneSPE_nl	<= '0';
			END IF;
			
			
			MultiSPE3	<= MultiSPE2;
			MultiSPE2	<= MultiSPE1;
			MultiSPE1	<= MultiSPE0;
			MultiSPE0	<= MultiSPE;
			OneSPE3		<= OneSPE2;
			OneSPE2		<= OneSPE1;
			OneSPE1		<= OneSPE0;
			OneSPE0		<= OneSPE;
		END IF;
	END PROCESS;
	
END;