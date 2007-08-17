-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : LC_RX_decode.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-05-23
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module decodes the information in a received LC message
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten
-------------------------------------------------------------------------------



LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY LC_RC_decode IS
    PORT (
        CLK40    : IN  STD_LOGIC;
        RST      : IN  STD_LOGIC;
        edge_pos : IN  STD_LOGIC;
        edge_neg : IN  STD_LOGIC;
        n_rx     : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        update   : OUT STD_LOGIC;
        TC       : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_RC_decode;

ARCHITECTURE LC_RX_decode_arch OF LC_RC_decode IS

    TYPE   state_type IS (IDLE, NEXT_EDGE, WAIT1);
    SIGNAL state : state_type;


BEGIN  -- LC_RX_decode_arch


    rx_decode : PROCESS (CLK40, RST)
        VARIABLE edge_cnt   : INTEGER RANGE 0 TO 2;
        VARIABLE time_cnt   : INTEGER RANGE 0 TO 7;
        VARIABLE edge_first : STD_LOGIC;
        VARIABLE edge_last  : STD_LOGIC;
    BEGIN  -- PROCESS rx_decode
        IF RST = '1' THEN               -- asynchronous reset (active high)
            update     <= '0';
            n_rx       <= "00";
            edge_cnt   := 0;
            time_cnt   := 0;
            edge_first := '0';
            edge_last  := '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            CASE state IS
                WHEN IDLE =>
                    edge_cnt := 0;
                    time_cnt := 0;
                    IF edge_pos = '1' OR edge_neg = '1' THEN
                        state <= NEXT_EDGE;
                        IF edge_pos = '1' THEN
                            edge_first := '1';
                        ELSE
                            edge_first := '0';
                        END IF;
                    END IF;
                    update <= '0';
                WHEN NEXT_EDGE =>
                    -- record edges
                    IF edge_pos = '1' THEN
                        edge_last := '1';
                        edge_cnt  := edge_cnt + 1;
                    END IF;
                    IF edge_neg = '1' THEN
                        edge_last := '0';
                        edge_cnt  := edge_cnt + 1;
                    END IF;

                    -- decode length
                    IF time_cnt = 6 THEN
                        update <= '1';
                        n_rx   <= edge_last & edge_first;
                        -- sanity check
                        IF edge_cnt = 1 AND edge_first /= edge_last THEN
                            NULL;       -- no action; 
                        ELSIF edge_cnt = 2 AND edge_first = edge_last THEN
                            NULL;       -- no action;
                        ELSE
                            --                  error <= '1';
                        END IF;
                        state <= IDLE;
                    END IF;
                    time_cnt := time_cnt + 1;
                WHEN WAIT1 =>
                    update <= '1';
                    state  <= IDLE;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS rx_decode;
    

END LC_RX_decode_arch;
