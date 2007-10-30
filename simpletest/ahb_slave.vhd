-------------------------------------------------
--- slave interface on the STRIPE to PLD bridge
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY ahb_slave IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- connections to the stripe
		masterhready		: OUT	STD_LOGIC;
		masterhgrant		: OUT	STD_LOGIC;
		masterhrdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		masterhresp			: OUT	STD_LOGIC_VECTOR(1 downto 0);
		masterhwrite		: IN	STD_LOGIC;
		masterhlock			: IN	STD_LOGIC;
		masterhbusreq		: IN	STD_LOGIC;
		masterhaddr			: IN	STD_LOGIC_VECTOR(31 downto 0);
		masterhburst		: IN	STD_LOGIC_VECTOR(2 downto 0);
		masterhsize			: IN	STD_LOGIC_VECTOR(1 downto 0);
		masterhtrans		: IN	STD_LOGIC_VECTOR(1 downto 0);
		masterhwdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
		-- local bus signals
		reg_write		: OUT	STD_LOGIC;
		reg_address		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		reg_wdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		reg_rdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
		reg_enable		: OUT	STD_LOGIC;
		reg_wait_sig	: IN	STD_LOGIC
	);
END ahb_slave;


ARCHITECTURE ahb_slave_arch OF ahb_slave IS

	-- AHB transfer types
	CONSTANT IDLE	: STD_LOGIC_VECTOR (1 downto 0) := "00";
	CONSTANT BUSY	: STD_LOGIC_VECTOR (1 downto 0) := "01";
	CONSTANT NONSEQ	: STD_LOGIC_VECTOR (1 downto 0) := "10";
	CONSTANT SEQ	: STD_LOGIC_VECTOR (1 downto 0) := "11";
	-- AHB burst types
	CONSTANT SINGLE	: STD_LOGIC_VECTOR (2 downto 0) := "000";
	CONSTANT INCR	: STD_LOGIC_VECTOR (2 downto 0) := "001";
	-- AHB hresp types
	CONSTANT OKAY	: STD_LOGIC_VECTOR (1 downto 0) := "00";
	CONSTANT ERROR_AHB	: STD_LOGIC_VECTOR (1 downto 0) := "01";
	-- AHB transfer size
	CONSTANT AHB_WORD	: STD_LOGIC_VECTOR (2 downto 0) := "010";
	-- AHB hwrite
	CONSTANT AHB_WRITE	: STD_LOGIC := '1';
	CONSTANT AHB_READ	: STD_LOGIC := '0';
	
	CONSTANT MAX_ADDR	: integer := 65535;
	

	TYPE STATE_TYPE IS (address_phase, data_phase, burst_phase, error_phase, read_wait);
	SIGNAL slave_state: STATE_TYPE;

BEGIN

	masterhgrant <= '1';
	
	reg_wdata		<= masterhwdata;
	masterhrdata	<= reg_rdata;

	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			slave_state		<= address_phase;
			masterhresp		<= OKAY;
			reg_enable		<= '0';
			masterhready	<= '1';
			reg_address		<= (others=>'0');
			reg_write		<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			CASE slave_state IS
				WHEN address_phase =>
					IF reg_wait_sig = '0' THEN		-- slave not selected
						slave_state		<= address_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					ELSIF masterhtrans = IDLE THEN
						slave_state		<= address_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					ELSIF masterhsize /= AHB_WORD THEN	-- only word transactions
						slave_state		<= error_phase;
						masterhready	<= '0';
						masterhresp		<= ERROR_AHB;
						reg_enable		<= '0';
					ELSIF masterhburst > INCR THEN		-- only unspecified INCR and single transactions
						slave_state		<= error_phase;
						masterhready	<= '0';
						masterhresp		<= ERROR_AHB;
						reg_enable		<= '0';
					ELSIF masterhaddr(17 downto 2) > MAX_ADDR THEN			-- out of address range
						slave_state		<= error_phase;
						masterhready	<= '0';
						masterhresp		<= ERROR_AHB;
						reg_enable		<= '0';
					ELSIF masterhtrans = NONSEQ THEN	-- single transaction
						reg_address	<= masterhaddr;
						reg_write	<= masterhwrite;
						masterhresp		<= OKAY;
						IF masterhwrite = AHB_READ THEN		-- read
							slave_state		<= read_wait;
							masterhready	<= '0';
							reg_enable		<= '1';
						ELSE								-- write
							slave_state		<= data_phase;
							masterhready	<= '1';
							reg_enable		<= '1';
						END IF;
					END IF;
					
				WHEN burst_phase =>
					IF masterhaddr(17 downto 2) > MAX_ADDR THEN		-- out of address range
						slave_state		<= error_phase;
						masterhready	<= '0';
						masterhresp		<= ERROR_AHB;
						reg_enable		<= '0';
					ELSIF masterhtrans = NONSEQ OR masterhtrans = SEQ THEN
						IF masterhwrite = AHB_WRITE THEN
							reg_address	<= masterhaddr;
							reg_write	<= masterhwrite;
							slave_state		<= burst_phase;
							masterhready	<= '1';
							masterhresp		<= OKAY;
							reg_enable		<= '1';
						ELSE
							reg_address	<= masterhaddr;
							reg_write	<= masterhwrite;
							slave_state		<= read_wait;
							masterhready	<= '0';
							masterhresp		<= OKAY;
							reg_enable		<= '1';
						END IF;
					ELSIF masterhtrans = BUSY THEN
						slave_state		<= burst_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					ELSE
						slave_state		<= address_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					END IF;
					
				WHEN error_phase =>
					slave_state		<= address_phase;
					masterhready	<= '1';
					masterhresp		<= ERROR_AHB;
					reg_enable		<= '0';
					
				WHEN read_wait =>
					reg_address	<= masterhaddr;
					slave_state		<= burst_phase;
					masterhready	<= '1';
					masterhresp		<= OKAY;
					reg_enable		<= '1';
					
				WHEN data_phase =>
					IF masterhtrans = IDLE THEN
						slave_state		<= address_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					ELSIF masterhaddr(17 downto 2) > MAX_ADDR THEN		-- out of address range
						slave_state		<= error_phase;
						masterhready	<= '0';
						masterhresp		<= ERROR_AHB;
						reg_enable		<= '0';
					ELSIF masterhtrans = BUSY THEN
						slave_state		<= burst_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '1';
					ELSIF masterhburst = INCR THEN
						IF masterhwrite = AHB_WRITE THEN
							reg_address	<= masterhaddr;
							reg_write	<= masterhwrite;
							slave_state		<= burst_phase;
							masterhready	<= '1';
							masterhresp		<= OKAY;
							reg_enable		<= '1';
						ELSE
							reg_address	<= masterhaddr;
							reg_write	<= masterhwrite;
							slave_state		<= read_wait;
							masterhready	<= '0';
							masterhresp		<= OKAY;
							reg_enable		<= '1';
						END IF;
					ELSIF masterhtrans /= NONSEQ THEN
						slave_state		<= address_phase;
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					ELSE
						masterhready	<= '1';
						masterhresp		<= OKAY;
						reg_enable		<= '0';
					END IF;
					
			END CASE;	
		END IF;
	END PROCESS;

END;
