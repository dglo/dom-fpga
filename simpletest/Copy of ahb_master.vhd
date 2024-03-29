-------------------------------------------------
--- master interface on the PLD to STRIPE bridge
-------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;


ENTITY ahb_master IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- connections to the stripe
		slavehclk		: IN	STD_LOGIC;
		slavehwrite		: OUT	STD_LOGIC;
		slavehreadyi	: OUT	STD_LOGIC;
		slavehselreg	: OUT	STD_LOGIC;
		slavehsel		: OUT	STD_LOGIC;
		slavehmastlock	: OUT	STD_LOGIC;
		slavehaddr		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		slavehtrans		: OUT	STD_LOGIC_VECTOR(1 downto 0);
		slavehsize		: OUT	STD_LOGIC_VECTOR(1 downto 0);
		slavehburst		: OUT	STD_LOGIC_VECTOR(2 downto 0);
		slavehwdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		slavehreadyo	: IN	STD_LOGIC;
		slavebuserrint	: IN	STD_LOGIC;
		slavehresp		: IN	STD_LOGIC_VECTOR(1 downto 0);
		slavehrdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
		-- local bus signals
		start_trans		: IN	STD_LOGIC;
		address			: IN	STD_LOGIC_VECTOR(31 downto 0);
		wdata			: IN	STD_LOGIC_VECTOR(31 downto 0);
		wait_sig		: OUT	STD_LOGIC;
		trans_length	: IN	INTEGER;
		bus_error		: OUT	STD_LOGIC
	);
END ahb_master;


ARCHITECTURE ahb_ahb_master OF ahb_master IS

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
	CONSTANT AHB_WORD	: STD_LOGIC_VECTOR (1 downto 0) := "10";
	-- AHB hwrite
	CONSTANT AHB_WRITE	: STD_LOGIC := '1';
	CONSTANT AHB_READ	: STD_LOGIC := '0';
	
	
	TYPE STATE_TYPE IS (address_phase, burst_phase, error_phase);
	SIGNAL master_state: STATE_TYPE;

	SIGNAL hready		: STD_LOGIC;
	SIGNAL haddr		: STD_LOGIC_VECTOR(31 downto 0);
	SIGNAL beat_count	: INTEGER;
	SIGNAL start_trans_reg	: STD_LOGIC;
BEGIN

	slavehmastlock	<= '0';
	slavehsel		<= '1';
	slavehselreg	<= '0';
	hready			<= slavehreadyo;
	slavehreadyi	<= hready;

	slavehaddr	<= haddr;

	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			master_state	<= address_phase;
			slavehtrans		<= IDLE;
			haddr			<= address;
			slavehwrite		<= AHB_READ;
			slavehsize		<= AHB_WORD;
			slavehburst		<= SINGLE;
			slavehwdata		<= (others=>'0');
			bus_error		<= '0';
			wait_sig		<= '0';
		ELSIF CLK'EVENT AND CLK='1' THEN
			CASE master_state IS
				WHEN address_phase =>
					IF start_trans_reg='1' AND hready='1' THEN
						master_state	<= burst_phase;
						slavehtrans		<= SEQ;
						haddr			<= haddr + 4;
						slavehwrite		<= AHB_WRITE;
						slavehsize		<= AHB_WORD;
						slavehburst		<= INCR;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '0';
					ELSIF start_trans_reg='1' THEN
						master_state	<= address_phase;
						slavehtrans		<= NONSEQ;
						haddr			<= address;
						slavehwrite		<= AHB_WRITE;
						slavehsize		<= AHB_WORD;
						slavehburst		<= INCR;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '1';
					ELSE
						master_state	<= address_phase;
						slavehtrans		<= IDLE;
						haddr			<= address;
						slavehwrite		<= AHB_READ;
						slavehsize		<= AHB_WORD;
						slavehburst		<= SINGLE;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '0';
					END IF;
				WHEN burst_phase =>
					IF slavehresp=ERROR_AHB THEN
						master_state	<= error_phase;
						slavehtrans		<= IDLE;
						haddr			<= address;
						slavehwrite		<= AHB_READ;
						slavehsize		<= AHB_WORD;
						slavehburst		<= SINGLE;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '1';
					ELSIF hready='0' THEN
						master_state	<= burst_phase;
						slavehtrans		<= SEQ;
						haddr			<= haddr;
						slavehwrite		<= AHB_WRITE;
						slavehsize		<= AHB_WORD;
						slavehburst		<= INCR;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '1';
					ELSIF beat_count < trans_length THEN
						master_state	<= burst_phase;
						slavehtrans		<= SEQ;
						haddr			<= haddr + 4;
						slavehwrite		<= AHB_WRITE;
						slavehsize		<= AHB_WORD;
						slavehburst		<= INCR;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '0';
					ELSE
						master_state	<= address_phase;
						slavehtrans		<= IDLE;
						haddr			<= haddr;
						slavehwrite		<= AHB_READ;
						slavehsize		<= AHB_WORD;
						slavehburst		<= SINGLE;
						slavehwdata		<= wdata;
						bus_error		<= '0';
						wait_sig		<= '0';
					END IF;
				WHEN error_phase =>
					IF hready='1' THEN
						master_state	<= address_phase;
						slavehtrans		<= IDLE;
						haddr			<= haddr;
						slavehwrite		<= AHB_READ;
						slavehsize		<= AHB_WORD;
						slavehburst		<= SINGLE;
						slavehwdata		<= wdata;
						bus_error		<= '1';
						wait_sig		<= '0';
					ELSE
						master_state	<= error_phase;
						slavehtrans		<= IDLE;
						haddr			<= haddr;
						slavehwrite		<= AHB_READ;
						slavehsize		<= AHB_WORD;
						slavehburst		<= SINGLE;
						slavehwdata		<= wdata;
						bus_error		<= '1';
						wait_sig		<= '0';
					END IF;
				WHEN OTHERS =>
			END CASE;	
		END IF;
	END PROCESS;
	
	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			beat_count <= 0;
		ELSIF CLK'EVENT AND CLK='1' THEN
			IF master_state=burst_phase AND slavehresp=OKAY AND hready='1' THEN
				beat_count <= beat_count + 1;
			ELSIF master_state=burst_phase AND slavehresp=OKAY AND hready='0' THEN
				beat_count <= beat_count;
			ELSE
				beat_count <= 0;
			END IF;
		END IF;
	END PROCESS;
	
	PROCESS(RST,start_trans,master_state)
	BEGIN
		IF RST='1' THEN
			start_trans_reg	<= '0';
		ELSIF start_trans='1' THEN
			start_trans_reg	<= '1';
		ELSIF master_state=burst_phase THEN
			start_trans_reg	<= '0';
		ELSE
			start_trans_reg	<= start_trans_reg;
		END IF;
	END PROCESS;

END;
