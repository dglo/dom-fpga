-------------------------------------------------
--- register for the stripe
-------------------------------------------------

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
		hitcounter_o	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_m	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_o_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
		hitcounter_m_ff	: IN	STD_LOGIC_VECTOR(31 downto 0);
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
		-- test connector
		TC					: OUT	STD_LOGIC_VECTOR(7 downto 0)
	);
END slaveregister;

ARCHITECTURE arch_slaveregister OF slaveregister IS

	TYPE WORD_ARRAY IS ARRAY (0 to 15) OF STD_LOGIC_VECTOR (31 downto 0);
	SIGNAL registers	: WORD_ARRAY;
	
	-- rom interface
	SIGNAL rom_data		: STD_LOGIC_VECTOR (15 downto 0);
	
	COMPONENT version_rom
		PORT (
			address		: IN STD_LOGIC_VECTOR (6 downto 0);
			inclock		: IN STD_LOGIC;
			q			: OUT STD_LOGIC_VECTOR (15 downto 0)
		);
	END COMPONENT;
	
BEGIN
	reg_wait_sig <= '1';

	PROCESS(CLK,RST)
	BEGIN
		IF RST='1' THEN
			reg_rdata	<= (others=>'0');
			FOR i IN 0 TO 15 LOOP
				registers(i) <= (others=>'0');
			END LOOP;
			registers(2) <= "00000000000000001111000000000000";
		ELSIF CLK'EVENT AND CLK='1' THEN
	--		com_adc_write_en <= '0';
	--		flash_adc_write_en <= '0';
	--		atwd0_write_en <= '0';
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
							IF reg_write = '1' THEN
								registers(CONV_INTEGER(reg_address(5 downto 2))) <= reg_wdata;
							ELSE
								reg_rdata <= registers(CONV_INTEGER(reg_address(5 downto 2)));
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
				registers(1)(31 downto 0)	<= response_0;
				registers(3)(31 downto 0)	<= response_1;
				registers(4)(31 downto 0)	<= hitcounter_o;
				registers(5)(31 downto 0)	<= hitcounter_m;
				registers(7)(31 downto 0)	<= response_2;
				registers(8)(31 downto 0)	<= hitcounter_o_ff;
				registers(9)(31 downto 0)	<= hitcounter_m_ff;
				registers(11)(31 downto 0)	<= response_3;
				registers(13)(31 downto 0)	<= com_status;
			END IF;	-- reg_enable
		END IF;
	END PROCESS;
	
	command_0	<= registers(0)(31 downto 0);
	command_1	<= registers(2)(31 downto 0);
	command_2	<= registers(6)(31 downto 0);
	command_3	<= registers(10)(31 downto 0);
	com_ctrl	<= registers(12)(31 downto 0);
	TC <= registers(CONV_INTEGER(15))(7 downto 0);
	
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
			inclock		=> CLK,
			q			=> rom_data
		);
	
END;