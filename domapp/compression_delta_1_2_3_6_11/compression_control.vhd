-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : compression_control.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-05-15
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module control the cmpressen. It initiated the compression
--              of FADC and ATWD based on acailable information; generates the
--              compressed header and wait for the read handshake
-------------------------------------------------------------------------------
-- Copyright (c) 2006
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-03-    V01-01-00   thorsten
-- 2007-05-15              thorsten  added compr all 4 chan for forced launch
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

USE WORK.icecube_data_types.ALL;
USE WORK.ctrl_data_types.ALL;
USE WORK.constants.ALL;

ENTITY compression_control IS
    PORT (
        CLK              : IN  STD_LOGIC;
        RST              : IN  STD_LOGIC;
        -- enable
        COMPR_ctrl       : IN  COMPR_STRUCT;
        -- compr control interface
        FADC_nATWD       : OUT STD_LOGIC;
        ATWD_CH          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        next_hit         : OUT STD_LOGIC;
        next_wf          : OUT STD_LOGIC;
        wf_done          : IN  STD_LOGIC;
        delta_busy       : IN  STD_LOGIC;
        write_last_short : OUT STD_LOGIC;
        buffer2delta     : OUT STD_LOGIC;
        data_bits        : IN  STD_LOGIC_VECTOR (18 DOWNTO 0);
        -- raw data BUFFER
        data_avail_in    : IN  STD_LOGIC;
        read_done_in     : OUT STD_LOGIC;
        HEADER_in        : IN  HEADER_VECTOR;
        -- 2LBM interface
        data_avail_out   : OUT STD_LOGIC;
        read_done_out    : IN  STD_LOGIC;
        compr_avail_out  : OUT STD_LOGIC;
        compr_size       : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        -- compr data buffer
        ram_header_sel   : OUT STD_LOGIC;
        ram_data         : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        ram_addr         : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test connector
        TC               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END compression_control;


ARCHITECTURE compression_control_arch OF compression_control IS

    TYPE   state_type IS (IDLE, EVAL_HEADER, INIT_FADC, XFER_FADC, INIT_ATWD, XFER_ATWD, WAIT_XFER_DONE, FLUSH_WF, WAIT_FLUSH0, WAIT_FLUSH1, HEADER0, HEADER1, HEADER2, HEADER3, ACK_BUFFER0, WAIT_2LBM_ACK, ACK_BUFFER1);
    SIGNAL state : state_type;

    SIGNAL ATWD_chanel : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL LASTonly    : STD_LOGIC := '0';

    SIGNAL HEADER_0 : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL HEADER_1 : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL HEADER_2 : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL HEADER_3 : STD_LOGIC_VECTOR (31 DOWNTO 0);

    SIGNAL hit_size    : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL wf_finished : STD_LOGIC;


BEGIN  -- compression_control_arch

    ATWD_CH <= ATWD_chanel;

    LASTonly <= COMPR_ctrl.LASTonly;

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            ATWD_chanel <= "00";
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            read_done_in     <= '0';
            data_avail_out   <= '0';
            compr_avail_out  <= '0';
            FADC_nATWD       <= '1';
            write_last_short <= '0';
            CASE state IS
                WHEN IDLE =>
                    next_hit <= '1';
                    next_wf  <= '0';
                    IF data_avail_in = '1' AND COMPR_ctrl.compr_mode = COMPR_OFF THEN
                        state <= WAIT_2LBM_ACK;
                    ELSIF data_avail_in = '1' THEN
                        state <= EVAL_HEADER;
                    END IF;
                WHEN EVAL_HEADER =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    IF LASTonly = '1' THEN
                        IF COMPR_ctrl.all_chan_for_forced_trig = '1' AND HEADER_in.forced_launch = '1' THEN
                            ATWD_chanel <= "00";
                        ELSE
                            ATWD_chanel <= HEADER_in.ATWDsize;
                        END IF;
                    ELSE
                        ATWD_chanel <= "00";
                    END IF;
                    IF HEADER_in.FADCavail = '1' THEN
                        state <= INIT_FADC;
                    ELSE
                        state <= HEADER0;
                    END IF;
                WHEN INIT_FADC =>
                    next_hit <= '0';
                    next_wf  <= '1';
                    -- set FADC size
                    state    <= XFER_FADC;
                WHEN XFER_FADC =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    IF wf_finished = '1' THEN
                        IF HEADER_in.ATWDavail = '1' THEN
                            state <= INIT_ATWD;
                        ELSE
                            state <= WAIT_XFER_DONE;
                        END IF;
                    END IF;
                WHEN INIT_ATWD =>
                    FADC_nATWD <= '0';
                    next_hit   <= '0';
                    next_wf    <= '1';
                    -- set ATWD size
                    state      <= XFER_ATWD;
                WHEN XFER_ATWD =>
                    FADC_nATWD <= '0';
                    next_hit   <= '0';
                    next_wf    <= '0';
                    IF wf_finished = '1' THEN
                        IF ATWD_chanel = HEADER_in.ATWDsize THEN
                            state <= WAIT_XFER_DONE;
                        ELSE
                            ATWD_chanel <= ATWD_chanel + 1;
                            state       <= INIT_ATWD;
                        END IF;
                    END IF;
                WHEN WAIT_XFER_DONE =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    -- wait delta_encode and delta2word not busy
                    IF delta_busy = '0' THEN
                        state <= FLUSH_WF;
                    END IF;
                WHEN FLUSH_WF =>
                    next_hit         <= '0';
                    next_wf          <= '0';
                    -- issue flush signal to delta2word for last unfinished byte
                    write_last_short <= '1';
                    state            <= WAIT_FLUSH0;
                WHEN WAIT_FLUSH0 =>
                    state <= WAIT_FLUSH1;
                WHEN WAIT_FLUSH1 =>
                    state <= HEADER0;
                WHEN HEADER0 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    state    <= HEADER1;
                WHEN HEADER1 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    state    <= HEADER2;
                WHEN HEADER2 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    state    <= HEADER3;
                WHEN HEADER3 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    state    <= ACK_BUFFER0;
                WHEN ACK_BUFFER0 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    -- if compr_only ack BUFFER
                    IF COMPR_ctrl.compr_mode = COMPR_ON THEN
                        read_done_in <= '1';
                    END IF;
                    state <= WAIT_2LBM_ACK;
                WHEN WAIT_2LBM_ACK =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    -- set adata_avail_out and compr_avail_out
                    IF COMPR_ctrl.compr_mode = COMPR_OFF THEN
                        data_avail_out <= '1';
                    ELSE
                        data_avail_out  <= '1';
                        compr_avail_out <= '1';
                    END IF;
                    IF read_done_out = '1' THEN
                        -- if compr both or off ack BUFFER
                        IF COMPR_ctrl.compr_mode = COMPR_OFF OR COMPR_ctrl.compr_mode = COMPR_BOTH THEN
                            read_done_in <= '1';
                        END IF;
                        state <= ACK_BUFFER1;
                    END IF;
                WHEN ACK_BUFFER1 =>
                    next_hit <= '0';
                    next_wf  <= '0';
                    state    <= IDLE;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- wf_done is only one clock cycle long and next waveform has to wait for the
    -- delta_encoder to finish before the next waveform starts
    PROCESS(CLK, RST)
        VARIABLE queued : STD_LOGIC := '0';
    BEGIN
        IF RST = '1' THEN
            queued      := '0';
            wf_finished <= '0';
        ELSIF CLK'EVENT AND CLK = '1' THEN
            IF wf_done = '1' THEN
                queued := '1';
            END IF;
            IF delta_busy = '0' AND queued = '1' THEN
                wf_finished <= '1';
                queued      := '0';
            ELSE
                wf_finished <= '0';
            END IF;
        END IF;
    END PROCESS;




    -- assemble header
    HEADER_0 <= "1001" & x"000" & HEADER_in.timestamp (47 DOWNTO 32);
    HEADER_1 <= '1' & HEADER_in.trigger_word(12 DOWNTO 0) & HEADER_in.LC & HEADER_in.FADCavail
                & HEADER_in.ATWDavail & HEADER_in.ATWDsize & HEADER_in.ATWD_AB & hit_size;
    HEADER_2 <= HEADER_in.timestamp (31 DOWNTO 0);
    HEADER_3 <= HEADER_in.chargestamp;

    ram_data <= HEADER_0 WHEN state = HEADER0 ELSE
                HEADER_1 WHEN state = HEADER1 ELSE
                HEADER_2 WHEN state = HEADER2 ELSE
                HEADER_3;

    ram_addr <= "00" WHEN state = HEADER0 ELSE
                "01" WHEN state = HEADER1 ELSE
                "10" WHEN state = HEADER2 ELSE
                "11";

    hit_size   <= data_bits(13 DOWNTO 3)-4+1;
    compr_size <= data_bits (13 DOWNTO 5);

    ram_header_sel <= '1' WHEN state = HEADER0 OR state = HEADER1 OR state = HEADER2 OR state = HEADER3 ELSE '0';
    buffer2delta   <= '0' WHEN state = WAIT_2LBM_ACK                                                    ELSE '1';

END compression_control_arch;
