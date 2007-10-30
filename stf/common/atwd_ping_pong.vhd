-------------------------------------------------------------------------------
-- Title      : STF
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : atwd_ping_pong.vhd
-- Author     : jkelley
-- Company    : UW-Madison
-- Created    : 
-- Last update: 2003-08-08
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module coordinates a ping-pong mode between the two 
--              ATWDs, using the discriminator as trigger for both.  It is
--              designed for testing purposes and not for minimal dead time.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-08  V01-01-00   jkelley
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.std_logic_arith.all;
USE IEEE.std_logic_unsigned.all;


ENTITY atwd_ping_pong IS
	PORT (
		CLK40		: IN STD_LOGIC;
		RST			: IN STD_LOGIC;
		-- single atwd discriminator enables from command register
        cmd_atwd0_enable_disc : IN STD_LOGIC;
        cmd_atwd1_enable_disc : IN STD_LOGIC;
        -- ping-pong mode from command register
        cmd_ping_pong         : IN STD_LOGIC;        
        -- CPU atwd read handshake
        cmd_atwd0_read_done   : IN STD_LOGIC;
        cmd_atwd1_read_done   : IN STD_LOGIC;
        -- atwd interface
        atwd0_trig_doneB      : IN STD_LOGIC;
        atwd1_trig_doneB      : IN STD_LOGIC;
        atwd0_enable_disc     : OUT STD_LOGIC;
        atwd1_enable_disc     : OUT STD_LOGIC;
		-- test connector
		TC					  : OUT STD_LOGIC_VECTOR(7 downto 0)
	);
END atwd_ping_pong;


ARCHITECTURE arch_atwd_ping_pong OF atwd_ping_pong IS
	
	TYPE atwd_state_type IS (st_idle, st_enable, st_triggered, st_reset);
    
	SIGNAL atwd0_state	: atwd_state_type;
	SIGNAL atwd1_state	: atwd_state_type;

    SIGNAL atwd0_pong_enable : STD_LOGIC;
    SIGNAL atwd1_pong_enable : STD_LOGIC;

	SIGNAL atwd0_enable_disc_sig : STD_LOGIC;
	SIGNAL atwd1_enable_disc_sig : STD_LOGIC;

	SIGNAL atwd0_read_done_dly : STD_LOGIC;
	SIGNAL atwd1_read_done_dly : STD_LOGIC;
	
	SIGNAL atwd0_read_done_posedge : STD_LOGIC;
	SIGNAL atwd1_read_done_posedge : STD_LOGIC;
	
BEGIN
	
	PROCESS(CLK40,RST)
	BEGIN
		IF RST='1' THEN
			atwd0_state <= st_idle;
            atwd1_state <= st_idle;
            
		ELSIF CLK40'EVENT AND CLK40='1' THEN

            -- ATWD0 ping-pong state control
			CASE atwd0_state IS

				WHEN st_idle =>
                    atwd0_pong_enable <= '0';
                    -- Enter ping pong mode in enable state for atwd0
                    IF cmd_ping_pong='1' THEN
                        atwd0_state <= st_enable;
                    END IF;
                    
                WHEN st_enable =>
                    atwd0_pong_enable <= '1';
					IF cmd_ping_pong='0' THEN
						atwd0_state <= st_idle;  
                    -- Trigger complete from ATWD is active low
                    ELSIF atwd0_trig_doneB='0' THEN
                        atwd0_state <= st_triggered;
                    END IF;
                    
                WHEN st_triggered =>
					IF cmd_ping_pong='0' THEN
						atwd0_state <= st_idle;  
                    -- Only clear enable after read is finished
                    ELSIF atwd0_read_done_posedge='1' THEN
                        atwd0_state <= st_reset;
                    END IF;
                    
                WHEN st_reset =>
                    atwd0_pong_enable <= '0';
					IF cmd_ping_pong='0' THEN
						atwd0_state <= st_idle;
                    -- Enable this ATWD if the other isn't enabled or is just
                    -- leaving the enable state
                    ELSIF atwd1_state/=st_enable OR atwd1_trig_doneB='0' THEN
                        atwd0_state <= st_enable;
                    END IF;

            END CASE;

            -- ATWD1 ping-pong state control
			CASE atwd1_state IS

				WHEN st_idle =>
                    atwd1_pong_enable <= '0';
                    -- Enter ping pong mode in reset state for atwd1
                    IF cmd_ping_pong='1' THEN
                        atwd1_state <= st_reset;
                    END IF;
                    
                WHEN st_enable =>
                    atwd1_pong_enable <= '1';
					IF cmd_ping_pong='0' THEN
						atwd1_state <= st_idle;                      
                    -- Trigger complete from ATWD is active low
                    ELSIF atwd1_trig_doneB='0' THEN
                        atwd1_state <= st_triggered;
                    END IF;
                    
                WHEN st_triggered =>
					IF cmd_ping_pong='0' THEN
						atwd1_state <= st_idle;
                    -- Only clear enable after read is finished
                    ELSIF atwd1_read_done_posedge='1' THEN
                        atwd1_state <= st_reset;
                    END IF;
                    
                WHEN st_reset =>
                    atwd1_pong_enable <= '0';
					IF cmd_ping_pong='0' THEN
						atwd1_state <= st_idle;
                    -- Enable this ATWD if the other isn't enabled or is just
                    -- leaving the enable state
                    ELSIF atwd0_state/=st_enable OR atwd0_trig_doneB='0' THEN
                        atwd1_state <= st_enable;
                    END IF;

            END CASE;
				
	     	-- Register read done bits for edge detection			
			atwd0_read_done_dly <= cmd_atwd0_read_done;
			atwd1_read_done_dly <= cmd_atwd1_read_done;

		END IF;
	END PROCESS;

	-- Internal read done signals must be edge-based to avoid
	-- retriggering over and over
	atwd0_read_done_posedge <= '1' WHEN cmd_atwd0_read_done='1' AND atwd0_read_done_dly='0'
								   ELSE '0';
			
	atwd1_read_done_posedge <= '1' WHEN cmd_atwd1_read_done='1' AND atwd1_read_done_dly='0'
								   ELSE '0';
								
    -- Mux between original disc enables and ping-pong mode
    -- If cmd_ping_pong is low, this block is disabled
    atwd0_enable_disc_sig <= atwd0_pong_enable WHEN cmd_ping_pong='1' ELSE cmd_atwd0_enable_disc;
    atwd1_enable_disc_sig <= atwd1_pong_enable WHEN cmd_ping_pong='1' ELSE cmd_atwd1_enable_disc;

	atwd0_enable_disc <= atwd0_enable_disc_sig;
	atwd1_enable_disc <= atwd1_enable_disc_sig;
	
	-- test connector for debug purposes
	--TC(0) <= cmd_atwd0_enable_disc;
	--TC(1) <= cmd_atwd1_enable_disc;
	--TC(2) <= cmd_ping_pong;
	--TC(3) <= atwd0_pong_enable;
	--TC(4) <= atwd1_pong_enable;
	--TC(5) <= atwd0_enable_disc_sig;
	--TC(6) <= atwd1_enable_disc_sig;
	
END;
