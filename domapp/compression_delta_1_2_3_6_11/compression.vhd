-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : compression.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-04-07
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module does the data compression on the ADC data
--
--              This implementation of the delta compression is based on the
--              works of Dawn Williams, Joshua Sopher and Nobuyoshi Kitamura
--
--              This link describes the compression algorithm:
--              http://docushare.icecube.wisc.edu/docushare/dsweb/Get/
--                 Document-20568/delta_123611_format_and_processes.pdf
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-03-    V01-01-00   thorsten  
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

USE WORK.icecube_data_types.ALL;
USE WORK.ctrl_data_types.ALL;

ENTITY compression IS
    GENERIC (
        FADC_WIDTH : INTEGER := 10
        );
    PORT (
        CLK20           : IN  STD_LOGIC;
        CLK40           : IN  STD_LOGIC;
        RST             : IN  STD_LOGIC;
        -- enable
        COMPR_ctrl      : IN  COMPR_STRUCT;
        -- data input from data buffer
        data_avail_in   : IN  STD_LOGIC;
        read_done_in    : OUT STD_LOGIC;
        HEADER_in       : IN  HEADER_VECTOR;
        ATWD_addr_in    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        ATWD_data_in    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        FADC_addr_in    : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
        FADC_data_in    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- data output
        data_avail_out  : OUT STD_LOGIC;
        read_done_out   : IN  STD_LOGIC;
        compr_avail_out : OUT STD_LOGIC;
        compr_size      : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        compr_addr      : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
        compr_data      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        HEADER_out      : OUT HEADER_VECTOR;
        ATWD_addr_out   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        ATWD_data_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        FADC_addr_out   : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
        FADC_data_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- test connector
        TC              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END compression;


ARCHITECTURE arch_compression OF compression IS

    COMPONENT compression_control
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
    END COMPONENT;

    COMPONENT delta_calc
        PORT (
            CLK         : IN  STD_LOGIC;
            RST         : IN  STD_LOGIC;
            -- control
            next_wf     : IN  STD_LOGIC;
            FADC_nATWD  : IN  STD_LOGIC;
            ATWD_CH     : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
            wf_done     : OUT STD_LOGIC;
            -- to delta encoder
            delta_avail : OUT STD_LOGIC;
            delta       : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            next_delta  : IN  STD_LOGIC;
            -- raw data buffer interface
            atwd_addr   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
            atwd_data   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
            fadc_addr   : OUT STD_LOGIC_VECTOR (6 DOWNTO 0);
            fadc_data   : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
            TC          : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT delta_encoder
        PORT (
            CLK            : IN  STD_LOGIC;
            RST            : IN  STD_LOGIC;
            -- control
            next_wf        : IN  STD_LOGIC;
            encodeing      : OUT STD_LOGIC;
            -- deltas in
            delta_in       : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
            next_delta_in  : OUT STD_LOGIC;
            delta_avail    : IN  STD_LOGIC;
            -- encoded deltas out
            delta_out      : OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
            bits_per_delta : OUT INTEGER RANGE 1 TO 11;
            next_delta_out : OUT STD_LOGIC;
            -- test connector
            TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT delta2word
        PORT (
            CLK              : IN  STD_LOGIC;
            RST              : IN  STD_LOGIC;
            -- control
            next_hit         : IN  STD_LOGIC;
            data_bits        : OUT STD_LOGIC_VECTOR (18 DOWNTO 0);
            write_last_short : IN  STD_LOGIC;
            -- input data
            delta_valid      : IN  STD_LOGIC;
            delta            : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
            bits_per_delta   : IN  INTEGER RANGE 1 TO 11;
            -- output data (compression memory)
            ram_data         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            ram_addr         : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
            ram0_we          : OUT STD_LOGIC;
            ram1_we          : OUT STD_LOGIC;
            -- test connector
            TC               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT compr_ram
        PORT (
            data      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
            wraddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
            rdaddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0);
            wren      : IN  STD_LOGIC;
            clock     : IN  STD_LOGIC;
            q         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL next_delta_out : STD_LOGIC;
    SIGNAL delta_out      : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL bits_per_delta : INTEGER RANGE 1 TO 11;

    SIGNAL FADC_nATWD       : STD_LOGIC;
    SIGNAL ATWD_CH          : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL next_wf          : STD_LOGIC;
    SIGNAL next_hit         : STD_LOGIC;
    --SIGNAL wf_done_calc     : STD_LOGIC;
    SIGNAL wf_done          : STD_LOGIC;
    SIGNAL delta_busy       : STD_LOGIC;
    SIGNAL write_last_short : STD_LOGIC;

    SIGNAL data_bits : STD_LOGIC_VECTOR (18 DOWNTO 0);


    SIGNAL ram_header_sel : STD_LOGIC;
    SIGNAL buffer2delta   : STD_LOGIC;

    -- delta_calc 2 delta_encoder
    SIGNAL delta_avail     : STD_LOGIC;
    SIGNAL next_delta_in   : STD_LOGIC;
    SIGNAL delta_in        : STD_LOGIC_VECTOR (10 DOWNTO 0);
    SIGNAL ATWD_addr_compr : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL FADC_addr_compr : STD_LOGIC_VECTOR (6 DOWNTO 0);

    -- data from compr control
    SIGNAL header_addr  : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL header_data  : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL header_we    : STD_LOGIC;
    -- data from delta
    SIGNAL delta_data   : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL delta_addr   : STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL delta_we_LSB : STD_LOGIC;
    SIGNAL delta_we_MSB : STD_LOGIC;
    -- compr RAM
    SIGNAL ram_addr     : STD_LOGIC_VECTOR (8 DOWNTO 0);
    SIGNAL ram_data     : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL we_LSB       : STD_LOGIC;
    SIGNAL we_MSB       : STD_LOGIC;

BEGIN

    compression_control_inst : compression_control
        PORT MAP (
            CLK              => CLK40,
            RST              => RST,
            -- enable
            COMPR_ctrl       => COMPR_ctrl,
            -- compr control interface
            FADC_nATWD       => FADC_nATWD,
            ATWD_CH          => ATWD_CH,
            next_hit         => next_hit,
            next_wf          => next_wf,
            wf_done          => wf_done,
            delta_busy       => delta_busy,
            write_last_short => write_last_short,
            buffer2delta     => buffer2delta ,
            data_bits        => data_bits,
            -- raw data BUFFER
            data_avail_in    => data_avail_in,
            read_done_in     => read_done_in,
            HEADER_in        => HEADER_in,
            -- 2LBM interface
            data_avail_out   => data_avail_out,
            read_done_out    => read_done_out,
            compr_avail_out  => compr_avail_out,
            compr_size       => compr_size,
            -- compr data buffer
            ram_header_sel   => ram_header_sel,
            ram_data         => header_data,
            ram_addr         => header_addr,
            -- test connector
            TC               => OPEN
            );

    delta_calc_inst : delta_calc
        PORT MAP (
            CLK         => CLK40,
            RST         => RST,
            -- control
            next_wf     => next_wf,
            FADC_nATWD  => FADC_nATWD,
            ATWD_CH     => ATWD_CH,
            wf_done     => wf_done,
            -- to delta encoder
            delta_avail => delta_avail,
            delta       => delta_in,
            next_delta  => next_delta_in,
            -- raw data buffer interface
            atwd_addr   => ATWD_addr_compr,
            atwd_data   => ATWD_data_in,
            fadc_addr   => FADC_addr_compr,
            fadc_data   => FADC_data_in,
            TC          => OPEN
            );

    delta_encoder_inst : delta_encoder
        PORT MAP (
            CLK            => CLK40,
            RST            => RST,
            -- control
            next_wf        => next_wf,
            encodeing      => delta_busy,
            -- deltas in
            delta_in       => delta_in,
            next_delta_in  => next_delta_in,
            delta_avail    => delta_avail,
            -- encoded deltas out
            delta_out      => delta_out,
            bits_per_delta => bits_per_delta,
            next_delta_out => next_delta_out,
            -- test connector
            TC             => OPEN
            );

    delta2word_inst : delta2word
        PORT MAP (
            CLK              => CLK40,
            RST              => RST,
            -- control
            next_hit         => next_hit,
            data_bits        => data_bits,
            write_last_short => write_last_short,
            -- input data
            delta_valid      => next_delta_out,
            delta            => delta_out,
            bits_per_delta   => bits_per_delta,
            -- output data (compression memory)
            ram_data         => delta_data,
            ram_addr         => delta_addr,
            ram0_we          => delta_we_LSB,
            ram1_we          => delta_we_MSB,
            -- test connector
            TC               => OPEN
            );


    -- input MUX
    -- present raw data the output after compression is done (in case we want
    -- to read raw and compressed)
    HEADER_out    <= HEADER_in;
    ATWD_addr_in  <= ATWD_addr_out WHEN buffer2delta = '0' ELSE ATWD_addr_compr;
    ATWD_data_out <= ATWD_data_in;
    FADC_addr_in  <= FADC_addr_out WHEN buffer2delta = '0' ELSE FADC_addr_compr;
    FADC_data_out <= FADC_data_in;

    -- select ram data
    -- header data comes from compression control and waveform data comes from
    -- delta2word
    header_we <= '1';
    ram_addr  <= delta_addr              WHEN ram_header_sel = '0' ELSE "0000000" & header_addr;
    ram_data  <= delta_data & delta_data WHEN ram_header_sel = '0' ELSE header_data;
    we_LSB    <= delta_we_LSB            WHEN ram_header_sel = '0' ELSE header_we;
    we_MSB    <= delta_we_MSB            WHEN ram_header_sel = '0' ELSE header_we;


    -- buffer ram
    -- I use the 1 byte wide bufferes because Joshua used them and so I know
    -- they are configures correctly
    compr_ram_0 : compr_ram
        PORT MAP (
            data      => ram_data(7 DOWNTO 0),
            wraddress => ram_addr,
            rdaddress => compr_addr,
            wren      => we_LSB,
            clock     => CLK40,
            q         => compr_data(7 DOWNTO 0)
            );
    compr_ram_1 : compr_ram
        PORT MAP (
            data      => ram_data(15 DOWNTO 8),
            wraddress => ram_addr,
            rdaddress => compr_addr,
            wren      => we_LSB,
            clock     => CLK40,
            q         => compr_data(15 DOWNTO 8)
            );
    compr_ram_2 : compr_ram
        PORT MAP (
            data      => ram_data(23 DOWNTO 16),
            wraddress => ram_addr,
            rdaddress => compr_addr,
            wren      => we_MSB,
            clock     => CLK40,
            q         => compr_data(23 DOWNTO 16)
            );
    compr_ram_3 : compr_ram
        PORT MAP (
            data      => ram_data(31 DOWNTO 24),
            wraddress => ram_addr,
            rdaddress => compr_addr,
            wren      => we_MSB,
            clock     => CLK40,
            q         => compr_data(31 DOWNTO 24)
            );


    -- for debugging !!!!!!!!
--    debugging : PROCESS (CLK40, RST)
--        VARIABLE wf_cnt : INTEGER;
--        VARIABLE ht_cnt : INTEGER;
--    BEGIN  -- PROCESS debugging
--        IF RST = '1' THEN               -- asynchronous reset (active high)
--            wf_cnt := 0;
--            ht_cnt := 0;
--        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
--            IF delta_avail = '1' AND next_delta_in = '1' THEN
--                wf_cnt := wf_cnt + 1;
--                ht_cnt := ht_cnt + 1;
--            END IF;
--            IF next_hit = '1' THEN
--                ht_cnt := 0;
--            END IF;
--            IF next_wf = '1' THEN
--                wf_cnt := 0;
--            END IF;
--        END IF;
--    END PROCESS debugging;

END;









