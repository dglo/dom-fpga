-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : slaveregister.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2003-08-01
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module provides the registers for the CPU inside the FPGA
--              the module is connected to ahb_slave.vhd
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-07-17  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY slaveregister IS
	PORT (
		CLK			: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- connections to ahb_slave
		reg_write		: IN	STD_LOGIC;
		reg_address		: IN	STD_LOGIC_VECTOR(31 downto 0);
		reg_wdata		: IN	STD_LOGIC_VECTOR(31 downto 0);
		reg_rdata		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		reg_enable		: IN	STD_LOGIC;
		reg_wait_sig	: OUT	STD_LOGIC;
		-- command register
		command_0		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		response_0		: IN	STD_LOGIC_VECTOR(31 downto 0);
		command_1		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		response_1		: IN	STD_LOGIC_VECTOR(31 downto 0);
		command_2		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		response_2		: IN	STD_LOGIC_VECTOR(31 downto 0);
		command_3		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		response_3		: IN	STD_LOGIC_VECTOR(31 downto 0);
		com_ctrl		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		com_status		: IN	STD_LOGIC_VECTOR(31 downto 0);
		com_tx_data		: OUT	STD_LOGIC_VECTOR(31 downto 0);
		com_rx_data		: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_o	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_m	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_o_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_m_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
		systime			: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
		atwd0_timestamp	: IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
		atwd1_timestamp : IN	STD_LOGIC_VECTOR(47 DOWNTO 0);
		dom_id			: OUT	STD_LOGIC_VECTOR(63 DOWNTO 0);
		-- COM ADC RX interface
		com_adc_wdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
		com_adc_rdata		: IN STD_LOGIC_VECTOR (15 downto 0);
		com_adc_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
		com_adc_write_en	: OUT STD_LOGIC;
		-- FLASH ADC RX interface
		flash_adc_wdata		: OUT STD_LOGIC_VECTOR (15 downto 0);
		flash_adc_rdata		: IN STD_LOGIC_VECTOR (15 downto 0);
		flash_adc_address	: OUT STD_LOGIC_VECTOR (8 downto 0);
		flash_adc_write_en	: OUT STD_LOGIC;
		-- ATWD0 interface
		atwd0_wdata			: OUT STD_LOGIC_VECTOR (15 downto 0);
		atwd0_rdata			: IN STD_LOGIC_VECTOR (15 downto 0);
		atwd0_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
		atwd0_write_en		: OUT STD_LOGIC;
		-- ATWD1 interface
		atwd1_wdata			: OUT STD_LOGIC_VECTOR (15 downto 0);
		atwd1_rdata			: IN STD_LOGIC_VECTOR (15 downto 0);
		atwd1_address		: OUT STD_LOGIC_VECTOR (8 downto 0);
		atwd1_write_en		: OUT STD_LOGIC;
		-- kale communication interface
		tx_fifo_wr			: OUT STD_LOGIC;
		rx_fifo_rd			: OUT STD_LOGIC;
		-- test connector
		TC					: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END slaveregister;

ARCHITECTURE arch_slaveregister OF slaveregister IS

--	TYPE WORD_ARRAY IS ARRAY (0 to 15) OF STD_LOGIC_VECTOR (31 downto 0);
--	SIGNAL registers	: WORD_ARRAY;
	
	-- rom interface
	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 downto 0);
	
	COMPONENT version_rom
		PORT (
			address		: IN STD_LOGIC_VECTOR (6 downto 0);
			q			: OUT STD_LOGIC_VECTOR (15 downto 0)
		);
	END COMPONENT;
	
	--
	SIGNAL command_0_local	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL command_1_local	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL command_2_local	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL command_3_local	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	SIGNAL com_ctrl_local	: STD_LOGIC_VECTOR (31 DOWNTO 0);
	
BEGIN
	reg_wait_sig <= '1';

	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			reg_rdata	<= (others=>'0');
		--	FOR i IN 0 TO 15 LOOP
		--		registers(i) <= (others=>'0');
		--	END LOOP;
		--	registers(2) <= "00000000000000001111000000000000";
		--	registers(12) <= "00000000000000000001011000000000";
			
			command_0_local	<= (others=>'0');
			command_1_local	<= "00000000000000001111000000000000";
			command_2_local	<= (others=>'0');
			command_3_local	<= (others=>'0');
			com_ctrl_local	<= "00000001010000000001011000000000";
			
			dom_id			<= (others=>'0');
			
		ELSIF CLK'EVENT AND CLK='1' THEN
	--		com_adc_write_en <= '0';
	--		flash_adc_write_en <= '0';
	--		atwd0_write_en <= '0';
			tx_fifo_wr	<= '0';
			rx_fifo_rd	<= '0';
			reg_rdata <= (others=>'X');
			IF reg_enable = '1' THEN
				IF reg_address(19 downto 18) = "00" THEN	-- map into the domapp addr space for the number
					IF reg_address(15 downto 12) = "0000" THEN
						IF reg_write = '1' THEN
							NULL;			-- read only
						ELSE
							reg_rdata(15 downto 0) <= rom_data;
							reg_rdata(31 downto 16) <= (others=>'0');
						END IF;
					END IF;
				ELSIF reg_address(19 downto 18) = "10" THEN	-- map into the simple test addr space
					CASE reg_address(15 downto 12) IS
						WHEN "0000" =>	-- ROM read only
							IF reg_write = '1' THEN
								NULL;			-- read only
							ELSE
								reg_rdata(15 downto 0) <= rom_data;
								reg_rdata(31 downto 16) <= (others=>'0');
							END IF;
						WHEN "0001" =>	-- register
							CASE reg_address(6 downto 2) IS
								WHEN "00000" =>	-- command 0
									IF reg_write = '1' THEN
										command_0_local <= reg_wdata;
									ELSE
										reg_rdata <= command_0_local;
									END IF;
								WHEN "00001" =>	-- response 0
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= response_0;
									END IF;
								WHEN "00010" =>	-- command 1
									IF reg_write = '1' THEN
										command_1_local <= reg_wdata;
									ELSE
										reg_rdata <= command_1_local;
									END IF;
								WHEN "00011" =>	-- response 1
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= response_1;
									END IF;
								WHEN "00100" =>	-- hitcounter SPE
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= hitcounter_o;
									END IF;
								WHEN "00101" =>	-- hitcounter MPE
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= hitcounter_m;
									END IF;
								WHEN "00110" =>	-- command 2
									IF reg_write = '1' THEN
										command_2_local <= reg_wdata;
									ELSE
										reg_rdata <= command_2_local;
									END IF;
								WHEN "00111" =>	-- response 2
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= response_2;
									END IF;
								WHEN "01000" =>	-- hitcounter SPE FF
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= hitcounter_o_ff;
									END IF;
								WHEN "01001" =>	-- hitcounter MPE FF
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= hitcounter_m_ff;
									END IF;
								WHEN "01010" =>	-- command 3
									IF reg_write = '1' THEN
										command_3_local <= reg_wdata;
									ELSE
										reg_rdata <= command_3_local;
									END IF;
								WHEN "01011" =>	-- response 3
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= response_3;
									END IF;
								WHEN "01100" =>	-- com control
									IF reg_write = '1' THEN
										com_ctrl_local <= reg_wdata;
									ELSE
										reg_rdata <= com_ctrl_local;
									END IF;
								WHEN "01101" => -- com status
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= com_status;
									END IF;
								WHEN "01110" =>	-- com TX data
									IF reg_write = '1' THEN
										com_tx_data <= reg_wdata;
									ELSE
										reg_rdata <= (OTHERS=>'0');
									END IF;
								WHEN "01111" =>	-- com RX data
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= com_rx_data;
									END IF;
								WHEN "10000" =>	-- time lower 32 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= systime (31 DOWNTO 0);
									END IF;
								WHEN "10001" =>	-- time upper 16 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata (15 DOWNTO 0) <= systime (47 DOWNTO 32);
										reg_rdata (31 DOWNTO 16) <= (OTHERS=>'0');
									END IF;
								WHEN "10010" =>	-- atwd0 timestamp lower 32 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= atwd0_timestamp (31 DOWNTO 0);
									END IF;
								WHEN "10011" =>	-- atwd0 timestamp upper 16 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata (15 DOWNTO 0) <= atwd0_timestamp (47 DOWNTO 32);
										reg_rdata (31 DOWNTO 16) <= (OTHERS=>'0');
									END IF;
								WHEN "10100" =>	-- atwd1 timestamp lower 32 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= atwd1_timestamp (31 DOWNTO 0);
									END IF;
								WHEN "10101" =>	-- atwd1 timestamp upper 16 bit
									IF reg_write = '1' THEN
									ELSE
										reg_rdata (15 DOWNTO 0) <= atwd1_timestamp (47 DOWNTO 32);
										reg_rdata (31 DOWNTO 16) <= (OTHERS=>'0');
									END IF;
								WHEN "10110" => -- dom_id low 32 bit
									IF reg_write = '1' THEN
										dom_id (31 DOWNTO 0) <= reg_wdata;
									ELSE
									--	reg_rdata	<= dom_id (31 DOWNTO 0);
									END IF;
								WHEN "10111" => -- dom_id high 32 bit
									IF reg_write = '1' THEN
										dom_id (63 DOWNTO 32) <= reg_wdata;
									ELSE
									--	reg_rdata	<= dom_id (63 DOWNTO 32);
									END IF;
								WHEN OTHERS =>
									IF reg_write = '1' THEN
									ELSE
										reg_rdata <= (OTHERS=>'0');
									END IF;
							END CASE;
							
							--IF reg_write = '1' THEN
							--	registers(CONV_INTEGER(reg_address(5 downto 2))) <= reg_wdata;
							--ELSE
							--	reg_rdata <= registers(CONV_INTEGER(reg_address(5 downto 2)));
							--END IF;
							
							-- kalle communications fifo interface
							IF reg_address(6 downto 2)="01110" AND reg_write = '1' THEN
								tx_fifo_wr	<= '1';
							END IF;
							IF reg_address(6 downto 2)="01111" AND reg_write = '0' THEN
								rx_fifo_rd	<= '1';
							END IF;
						WHEN "0010" =>	-- com ADC
							IF reg_write = '1' THEN
				--				com_adc_write_en <= '1';
							ELSE
								reg_rdata(15 downto 0) <= com_adc_rdata;
								reg_rdata(31 downto 16) <= (others=>'0');
							END IF;
						WHEN "0011" =>	-- flash ADC
							IF reg_write = '1' THEN
				--				flash_adc_write_en <= '1';
							ELSE
								reg_rdata(15 downto 0) <= flash_adc_rdata;
								reg_rdata(31 downto 16) <= (others=>'0');
							END IF;
						WHEN "0100" =>
							IF reg_write = '1' THEN
				--				atwd0_write_en <= '1';
							ELSE
								reg_rdata(15 downto 0) <= atwd0_rdata;
								reg_rdata(31 downto 16) <= (others=>'0');
							END IF;
						WHEN "0101" =>
							IF reg_write = '1' THEN
				--				atwd0_write_en <= '1';
							ELSE
								reg_rdata(15 downto 0) <= atwd1_rdata;
								reg_rdata(31 downto 16) <= (others=>'0');
							END IF;
						WHEN others =>
							NULL;
					END CASE;
				END IF;	-- reg_address(19 downto 18) = "10"
			ELSE	-- reg_enable='0'
			--	registers(1)(31 downto 0)	<= response_0;
			--	registers(3)(31 downto 0)	<= response_1;
			--	registers(4)(31 downto 0)	<= hitcounter_o;
			--	registers(5)(31 downto 0)	<= hitcounter_m;
			--	registers(7)(31 downto 0)	<= response_2;
			--	registers(8)(31 downto 0)	<= hitcounter_o_ff;
			--	registers(9)(31 downto 0)	<= hitcounter_m_ff;
			--	registers(11)(31 downto 0)	<= response_3;
			--	registers(13)(31 downto 0)	<= com_status;
			--	registers(15)(31 downto 0)	<= com_rx_data;
			END IF;	-- reg_enable
		END IF;
	END PROCESS;
	
	command_0	<= command_0_local; --registers(0)(31 downto 0);
	command_1	<= command_1_local; --registers(2)(31 downto 0);
	command_2	<= command_2_local; --registers(6)(31 downto 0);
	command_3	<= command_3_local; --registers(10)(31 downto 0);
	com_ctrl	<= com_ctrl_local; --registers(12)(31 downto 0);
	-- com_tx_data	<= registers(14)(31 downto 0);
	-- TC <= registers(CONV_INTEGER(15))(7 downto 0);
	
	com_adc_write_en <= '1' WHEN reg_write='1' AND reg_enable = '1' AND reg_address(15 downto 12)="0010" ELSE '0';
	flash_adc_write_en <= '1' WHEN reg_write='1' AND reg_enable = '1' AND reg_address(15 downto 12)="0011" ELSE '0';
	atwd0_write_en <= '1' WHEN reg_write='1' AND reg_enable = '1' AND reg_address(15 downto 12)="0100" ELSE '0';
	atwd1_write_en <= '1' WHEN reg_write='1' AND reg_enable = '1' AND reg_address(15 downto 12)="0101" ELSE '0';
	
	-- COM ADC RX interface
	com_adc_address	<= reg_address(10 downto 2);
	com_adc_wdata	<= reg_wdata(15 downto 0);
	-- FLASH ADC RX interface
	flash_adc_address	<= reg_address(10 downto 2);
	flash_adc_wdata	<= reg_wdata(15 downto 0);
	-- ATWD0 interface
	atwd0_address	<= reg_address(10 downto 2);
	atwd0_wdata	<= reg_wdata(15 downto 0);
	-- ATWD0 interface
	atwd1_address	<= reg_address(10 downto 2);
	atwd1_wdata	<= reg_wdata(15 downto 0);
	
	
	inst_version_rom : version_rom
		PORT MAP (
			address		=> reg_address(8 downto 2),
			q			=> rom_data
		);
	
END;