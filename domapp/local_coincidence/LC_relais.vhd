-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LC_relais.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-05-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module does the relaying of LC messages
-------------------------------------------------------------------------------
-- Copyright (c) 2003 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten
-- 2005-06-08              thorsten  swapped priority relay - local disc  
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;


ENTITY LC_relais IS
    PORT (
        CLK40     : IN  STD_LOGIC;
        CLK80     : IN  STD_LOGIC;
        RST       : IN  STD_LOGIC;
        -- setup
        lc_length : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- local discriminator
        disc      : IN  STD_LOGIC;
        -- from RX
        n_rx      : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        rx        : IN  STD_LOGIC;
        -- to TX
        n_tx      : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        tx        : OUT STD_LOGIC;
        next_lc   : IN  STD_LOGIC;
        -- test
        TC        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_relais;


ARCHITECTURE LC_relais_arch OF LC_relais IS

BEGIN  -- LC_relais_arch

--    -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
--    -- PROBLEM if disc while transmit is going on bacause n_tx will change
--    PROCESS (CLK40, RST)
--    BEGIN  -- PROCESS
--        IF RST = '1' THEN               -- asynchronous reset (active high)
--
--        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
--            IF disc = '1' THEN
--                n_tx <= lc_length;
--                tx   <= '1';
--            ELSIF rx = '1' THEN
--                IF n_rx = "00" THEN
--                    -- last one; we are done
--                    NULL;
--                ELSE
--                    n_tx <= n_rx - 1;
--                    tx   <= '1';
--                END IF;
--            ELSE
--                tx <= '0';
--            END IF;
--        END IF;
--    END PROCESS;


    PROCESS (CLK40, RST)
        VARIABLE got_disc : STD_LOGIC := '0';
        VARIABLE got_rx   : STD_LOGIC := '0';
        VARIABLE got_rx_n : STD_LOGIC_VECTOR (1 DOWNTO 0);
        VARIABLE wait1clk : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            n_tx     <= "00";
            tx       <= '0';
            got_disc := '0';
            got_rx   := '0';
            got_rx_n := "00";
            wait1clk := '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF disc = '1' THEN
                -- put into disc BUFFER
                got_disc := '1';
            END IF;
            IF rx = '1' THEN
                -- put into relais BUFFER
                IF n_rx = "00" THEN
                    -- skip it, we are done
                    NULL;
                ELSE
                    got_rx   := '1';
                    got_rx_n := n_rx - 1;
                END IF;
            END IF;

            -- ready to send the next LC
            IF next_lc = '1' AND wait1clk = '0' THEN
                IF got_disc = '1' THEN
                    -- send disc BUFFER
                    n_tx     <= lc_length;
                    tx       <= '1';
                    got_disc := '0';
                    wait1clk := '1';
				ELSIF got_rx = '1' THEN
                    -- send relais BUFFER
                    n_tx     <= got_rx_n;
                    tx       <= '1';
                    got_rx   := '0';
                    wait1clk := '1';
                ELSE
                    tx       <= '0';
                    wait1clk := '0';
                END IF;
            ELSE
                tx       <= '0';
                wait1clk := '0';
            END IF;
        END IF;
    END PROCESS;

END LC_relais_arch;
