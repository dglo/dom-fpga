-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : ADC_control.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2010-04-16
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module controls the ATWD and FADC based on the selected
--              mode and coordinates handshake to trigger and the data buffer.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-08-26  V01-01-00   thorsten  
-- 2004-11-09              thorsten  added flabby local coincidence
-- 2007-03-22              thorsten  added ATWD dead flag
-- 2020-04-16              thorsten  added Hagar's ATWD acq counter
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

USE WORK.constants.ALL;
USE WORK.icecube_data_types.ALL;


ENTITY ADC_control IS
    PORT (
        CLK40             : IN  STD_LOGIC;
        RST               : IN  STD_LOGIC;
        systime           : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        -- enable
        busy              : OUT STD_LOGIC;
        lc_mode           : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        daq_mode          : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        ATWD_AB           : IN  STD_LOGIC;  -- indicates if ping or pong
        abort_ATWD        : OUT STD_LOGIC;
        abort_FADC        : OUT STD_LOGIC;
        -- some status bits
        dead_flag         : OUT STD_LOGIC;
        SPE_level_stretch : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        got_ATWD_WF       : OUT STD_LOGIC;
        -- trigger
        ATWDtrigger       : IN  STD_LOGIC;
        rst_trig          : OUT STD_LOGIC;
        TriggerComplete   : IN  STD_LOGIC;
        trigger_word      : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
        minimum_bias_hit  : IN  STD_LOGIC;
        -- local coincidence
        LC_abort          : IN  STD_LOGIC;
        LC                : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- calibration sources
        -- ATWD
        ATWD_enable       : OUT STD_LOGIC;
        ATWD_busy         : IN  STD_LOGIC;
        ATWD_n_chan       : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- FADC
        FADC_enable       : OUT STD_LOGIC;
        FADC_busy         : IN  STD_LOGIC;
        -- data output
        buffer_full       : IN  STD_LOGIC;
        HEADER_data       : OUT HEADER_VECTOR;
        HEADER_we         : OUT STD_LOGIC;
        -- test connector
        TC                : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END ADC_control;


ARCHITECTURE arch_ADC_control OF ADC_control IS

    COMPONENT disc_in_ATWD IS
        PORT (
            CLK               : IN  STD_LOGIC;
            RST               : IN  STD_LOGIC;
            -- ATWD status
            ATWDtrigger       : IN  STD_LOGIC;
            TriggerComplete   : IN  STD_LOGIC;
            -- disc status
            SPE_level_stretch : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            -- status OUT
            ATWD_disc_status  : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
            -- test connector
            TC                : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    TYPE   STATE_TYPE IS (IDLE, WAIT_DONE, WR_HEADER, RESET_TRIG, WAIT_LC_SOFT, WAIT_LC_FLABBY, CLEAR_LC_HARD, GOT_LC, WAIT_BUFFER);
    SIGNAL state : STATE_TYPE;

    SIGNAL enable : STD_LOGIC;

    SIGNAL eventtype : STD_LOGIC_VECTOR (1 DOWNTO 0);

    SIGNAL deadtime_cnt : STD_LOGIC_VECTOR (15 DOWNTO 0);

    SIGNAL flabby_LC_flag : STD_LOGIC;
    
    SIGNAL abort_ATWD_int : STD_LOGIC;
BEGIN

    PROCESS(CLK40, RST)
    BEGIN
        IF RST = '1' THEN
            state          <= IDLE;
            enable         <= '0';
            busy           <= '0';
            flabby_LC_flag <= '0';
            eventtype      <= eventEngineering;
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN
            CASE state IS
                WHEN IDLE =>
                    IF ATWDtrigger = '1' THEN
                        state <= WAIT_DONE;
                    END IF;
                    enable         <= '1';
                    busy           <= '0';
                    eventtype      <= "XX";
                    flabby_LC_flag <= '0';
                WHEN WAIT_DONE =>
                    IF lc_mode = LC_HARD AND LC_abort = '1' THEN  --AND trigger_word(15 DOWNTO 2)="00000000000000" THEN
                        state <= CLEAR_LC_HARD;
                    ELSIF lc_mode = LC_SOFT AND LC_abort = '1' THEN  --AND trigger_word(15 DOWNTO 2)="00000000000000" THEN
                        state <= WAIT_LC_SOFT;
                    ELSIF lc_mode = LC_FLABBY AND LC_abort = '1' THEN  --AND trigger_word(15 DOWNTO 2)="00000000000000" THEN
                        state <= WAIT_LC_FLABBY;
                    ELSIF LC_abort = '1' THEN
                        state <= GOT_LC;
                    ELSIF ATWD_busy = '0' AND FADC_busy = '0' THEN
                        state <= WAIT_BUFFER;
                    END IF;
                    enable    <= '0';
                    busy      <= '1';
                    eventtype <= eventEngineering;
                WHEN CLEAR_LC_HARD =>
                    IF ATWD_busy = '0' AND FADC_busy = '0' THEN
                        state <= RESET_TRIG;
                    END IF;
                    eventtype      <= "XX";
                    flabby_LC_flag <= '0';
                WHEN WAIT_LC_SOFT =>
                    IF ATWD_busy = '0' AND FADC_busy = '0' THEN
                        state <= WAIT_BUFFER;
                    END IF;
                    eventtype      <= eventTimestamp;
                    flabby_LC_flag <= '0';
                WHEN WAIT_LC_FLABBY =>
                    IF ATWD_busy = '0' AND FADC_busy = '0' THEN
                        state <= WAIT_BUFFER;
                    END IF;
                    flabby_LC_flag <= '1';
                WHEN GOT_LC =>
                    IF ATWD_busy = '0' AND FADC_busy = '0' THEN
                        state <= WAIT_BUFFER;
                    END IF;
                    flabby_LC_flag <= '0';
                WHEN WAIT_BUFFER =>
                    IF buffer_full = '0' THEN
                        state <= WR_HEADER;
                    END IF;
                WHEN WR_HEADER =>
                    state     <= RESET_TRIG;
                    eventtype <= "XX";
                WHEN RESET_TRIG =>  -- reset ATWD & ATWD clear run if necessary : Not need I think
                    IF TriggerComplete = '1' THEN
                        state <= IDLE;
                    END IF;
                    enable         <= '0';
                    busy           <= '1';
                    eventtype      <= "XX";
                    flabby_LC_flag <= '0';
                WHEN OTHERS =>
                    state          <= IDLE;
                    enable         <= '0';
                    busy           <= '1';
                    eventtype      <= "XX";
                    flabby_LC_flag <= '0';
            END CASE;
        END IF;
    END PROCESS;

    FADC_enable <= '1' WHEN enable = '1' AND (daq_mode = FADC_ONLY OR daq_mode = ATWD_FADC) ELSE '0';
    ATWD_enable <= '1' WHEN enable = '1' AND daq_mode = ATWD_FADC                           ELSE '0';

    abort_ATWD <= '1' WHEN state = CLEAR_LC_HARD OR state = WAIT_LC_SOFT OR state = WAIT_LC_FLABBY ELSE '0';
    abort_ATWD_int <= '1' WHEN state = CLEAR_LC_HARD OR state = WAIT_LC_SOFT OR state = WAIT_LC_FLABBY ELSE '0';
    abort_FADC <= '1' WHEN state = CLEAR_LC_HARD OR state = WAIT_LC_SOFT                           ELSE '0';
    rst_trig   <= '1' WHEN state = WR_HEADER OR state = RESET_TRIG                                 ELSE '0';

    --write header
    PROCESS(CLK40, RST)
    BEGIN
        IF RST = '1' THEN
            deadtime_cnt              <= (OTHERS => '0');
            HEADER_data.forced_launch <= '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN
            IF state = IDLE THEN
                HEADER_data.timestamp    <= systime;
                HEADER_data.trigger_word <= trigger_word;
                IF trigger_word(15 DOWNTO 2) = "00000000000000" THEN
                    HEADER_data.forced_launch <= '0';
                ELSE
                    HEADER_data.forced_launch <= '1';
                END IF;
            END IF;
            IF state = WAIT_DONE THEN
                HEADER_data.LC <= LC;
            END IF;
            IF state = IDLE THEN
                deadtime_cnt <= (OTHERS => '0');
            ELSE
                deadtime_cnt <= deadtime_cnt + 1;
            END IF;
        END IF;
    END PROCESS;
    HEADER_data.ATWD_AB          <= ATWD_AB;
    HEADER_data.deadtime         <= deadtime_cnt;
    HEADER_data.ATWDsize         <= ATWD_n_chan;
    HEADER_data.minimum_bias_hit <= minimum_bias_hit;

    HEADER_we <= '1' WHEN state = WR_HEADER ELSE '0';

    HEADER_data.eventtype <= eventtype;
    --!! add ATWD FADC available ----- !!!!!!!!!!!!!
    HEADER_data.ATWDavail <= '1' WHEN eventtype = eventEngineering AND daq_mode = ATWD_FADC AND lc_mode /= LC_FLABBY  ELSE '0';
    HEADER_data.FADCavail <= '1' WHEN eventtype = eventEngineering AND (daq_mode = ATWD_FADC OR daq_mode = FADC_ONLY) ELSE '0';

    dead_flag <= '1' WHEN (state = WAIT_DONE AND FADC_busy = '0')
                 OR state = CLEAR_LC_HARD OR state = WAIT_LC_SOFT
                 OR (state = WAIT_LC_FLABBY AND FADC_busy = '0')
                 OR (state = GOT_LC AND FADC_busy = '0')
                 OR state = WAIT_BUFFER OR state = WR_HEADER OR state = RESET_TRIG ELSE '0';


    inst_disc_in_ATWD : disc_in_ATWD
        PORT MAP (
            CLK               => CLK40,
            RST               => RST,
            -- ATWD status
            ATWDtrigger       => ATWDtrigger,
            TriggerComplete   => TriggerComplete,
            -- disc status
            SPE_level_stretch => SPE_level_stretch,
            -- status OUT
            ATWD_disc_status  => HEADER_data.ATWD_disc_status,
            -- test connector
            TC                => OPEN
            );

    -- purpose: for Hagar to count finished ATWD acqusitions (generated waveform)
    --          generate a pulse for counting in the rate meter module
    --          a finished ATWD acq is at the end of AWTD_busy without a abort_ATWD
    PROCESS (CLK40, RST)
        VARIABLE ATWD_busy_old : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            ATWD_busy_old := '0';
            got_ATWD_WF   <= '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF ATWD_busy = '0' AND ATWD_busy_old = '1' AND abort_ATWD_int = '0' THEN
                got_ATWD_WF <= '1';
            ELSE
                got_ATWD_WF <= '0';
            END IF;
            ATWD_busy_old := ATWD_busy;
        END IF;
    END PROCESS;

END;

