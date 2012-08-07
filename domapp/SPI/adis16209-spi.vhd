-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : adis16209-spi.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2010-04-21
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module intefaces the inclinometer ADIS16209 which uses a
--              16 bit SPI interface.
--              Tee DIO pins of teh inclinometer are not connected to the FPGA
--              (series resistor are DNL)
-------------------------------------------------------------------------------
-- Copyright (c) 2010 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2010-03-25  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

USE WORK.ctrl_data_types.all;


ENTITY adis16209_spi IS
    PORT (
        CLK40          : IN  STD_LOGIC;
        RST            : IN  STD_LOGIC;
        -- internal
        INCL_ctrl      : IN  INCLINOMETER_CTRL_STRUCT;
        INCL_stat      : OUT INCLINOMETER_STAT_STRUCT;
        -- enable         : IN  STD_LOGIC;
        -- data_tx        : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        -- data_rx        : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        -- data_tx_update : IN  STD_LOGIC;
        -- dio            : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- busy           : OUT STD_LOGIC;
        -- SPI
        adis16209_RST  : OUT STD_LOGIC;  -- V1
        adis16209_nCS  : OUT STD_LOGIC;  -- Y2
        adis16209_SCLK : OUT STD_LOGIC;  -- F3
        adis16209_DOUT : IN  STD_LOGIC;  -- AC2
        adis16209_DIN  : OUT STD_LOGIC;  -- AA2
        adis16209_PWR  : OUT STD_LOGIC;  -- E3
        -- adis16209_DIO1 : IN  STD_LOGIC;  -- Y1
        -- adis16209_DIO2 : IN  STD_LOGIC;  -- V2
        -- TC
        TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END adis16209_spi;


ARCHITECTURE adis16209_spi_arch OF adis16209_spi IS

    -- mapping from the INCLINOMETER data types
    SIGNAL enable         : STD_LOGIC;
    SIGNAL data_tx        : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL data_rx        : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL data_tx_update : STD_LOGIC;
    SIGNAL dio            : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL busy           : STD_LOGIC;


    SIGNAL clk_cnt : INTEGER RANGE 0 TO 31;
    SIGNAL tick    : STD_LOGIC;

    SIGNAL loop_cnt : INTEGER RANGE -1 TO 15;
    TYPE   state_type IS (IDLE, CS_LOW, SCLK_LOW, SCLK_HIGH, CS_HIGH);
    SIGNAL state    : state_type;
    SIGNAL srg_tx   : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL srg_rx   : STD_LOGIC_VECTOR (15 DOWNTO 0);

    SIGNAL nCS  : STD_LOGIC;
    SIGNAL SCLK : STD_LOGIC;
    SIGNAL DIN  : STD_LOGIC;
    SIGNAL DOUT : STD_LOGIC;
    
BEGIN  -- adis16209_spi_arch

    -- mapping from the INCLINOMETER data types
    enable                 <= INCL_ctrl.incl_en;
    data_tx                <= INCL_ctrl.incl_data_tx;
    data_tx_update         <= INCL_ctrl.incl_data_tx_update;
    INCL_stat.incl_data_rx <= data_rx;
    INCL_stat.incl_DIO     <= dio;
    INCL_stat.incl_busy    <= busy;


    clock_divide : PROCESS (CLK40, RST)
    BEGIN  -- PROCESS clock_divide
        IF RST = '1' THEN               -- asynchronous reset (active high)
            clk_cnt <= 0;
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF state /= IDLE THEN
                IF clk_cnt = 0 THEN
                    clk_cnt <= 25;
                    tick    <= '1';
                ELSE
                    clk_cnt <= clk_cnt - 1;
                    tick    <= '0';
                END IF;
            ELSE
                clk_cnt <= 25;
                tick    <= '0';
            END IF;
        END IF;
    END PROCESS clock_divide;

    data_rx <= srg_rx;

    SPI : PROCESS (CLK40, RST)
    BEGIN  -- PROCESS SPI
        IF RST = '1' THEN               -- asynchronous reset (active high)

        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            DIN <= srg_tx(15);
            CASE state IS
                WHEN IDLE =>
                    nCS      <= '1';
                    SCLK     <= '1';
                    loop_cnt <= 15;
                    srg_tx   <= data_tx;
                    IF data_tx_update = '1' THEN
                        state <= CS_LOW;
                    END IF;
                WHEN CS_LOW =>
                    nCS  <= '0';
                    SCLK <= '1';
                    IF tick = '1' THEN
                        srg_rx <= srg_rx(14 DOWNTO 0) & DOUT;
                        state  <= SCLK_LOW;
                    END IF;
                WHEN SCLK_LOW =>
                    nCS  <= '0';
                    SCLK <= '0';
                    IF tick = '1' THEN
                        state  <= SCLK_HIGH;
                        srg_rx <= srg_rx(14 DOWNTO 0) & DOUT;
                    END IF;
                WHEN SCLK_HIGH =>
                    nCS  <= '0';
                    SCLK <= '1';
                    IF tick = '1' THEN
                        srg_tx <= srg_tx(14 DOWNTO 0) & '0';
                        IF loop_cnt = 0 THEN
                            state <= CS_HIGH;
                        ELSE
                            state <= SCLK_LOW;
                        END IF;
                        loop_cnt <= loop_cnt - 1;
                    END IF;
                WHEN CS_HIGH =>
                    nCS  <= '1';
                    SCLK <= '1';
                    IF tick = '1' THEN
                        state <= IDLE;
                    END IF;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS SPI;

    busy <= '1' WHEN state /= IDLE ELSE '0';

    adis16209_nCS  <= nCS  WHEN enable = '1' ELSE 'Z';
    adis16209_SCLK <= SCLK WHEN enable = '1' ELSE 'Z';
    adis16209_DIN  <= DIN  WHEN enable = '1' ELSE 'Z';
    DOUT           <= adis16209_DOUT;

    SPI_POWER : PROCESS (CLK40, RST)
    BEGIN  -- PROCESS SPI_POWER
        IF RST = '1' THEN               -- asynchronous reset (active high)
            adis16209_PWR <= '0';       -- inclinometer power switch
            adis16209_RST <= '0';       -- inclinometer reset
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            -- 0: off
            -- 1: on
            adis16209_PWR <= enable;
            -- build in reset so just follow the power
            adis16209_RST <= enable;
        END IF;
    END PROCESS SPI_POWER;
    
END adis16209_spi_arch;
