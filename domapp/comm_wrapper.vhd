-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : comm_wrapper.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-08-03
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Because Kalle changes the comm interface all the time I have
--              this wrapper to compensate his interface changes
-------------------------------------------------------------------------------
-- Copyright (c) 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-08-02  V00-00-00   thorsten
-- 2005-03-09              thorsten  added Kalle's ne comm signals
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE WORK.ctrl_data_types.ALL;

ENTITY comm_wrapper IS
    PORT (
        CLK20            : IN  STD_LOGIC;
        RST              : IN  STD_LOGIC;
        systime          : IN  STD_LOGIC_VECTOR(47 DOWNTO 0);
        -- setup
        COMM_CTRL        : IN  COMM_CTRL_STRUCT;
        COMM_STAT        : OUT COMM_STAT_STRUCT;
        -- hardware
        A_nB             : IN  STD_LOGIC;
        COM_AD_D         : IN  STD_LOGIC_VECTOR(11 DOWNTO 0);
        COM_TX_SLEEP     : OUT STD_LOGIC;
        COM_DB           : OUT STD_LOGIC_VECTOR(13 DOWNTO 0);
        HDV_Rx           : IN  STD_LOGIC;
        HDV_RxENA        : OUT STD_LOGIC;
        HDV_IN           : OUT STD_LOGIC;
        HDV_TxENA        : OUT STD_LOGIC;
        COMM_RESET       : OUT STD_LOGIC;
        -- RX DPM
        dp1_portawe      : OUT STD_LOGIC;
        dp1_portaaddr    : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        dp1_portadatain  : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- TX DPM
        dp0_portaaddr    : OUT STD_LOGIC_VECTOR (12 DOWNTO 0);
        dp0_portadataout : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- TC
        tc               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END comm_wrapper;

ARCHITECTURE arch_comm_wrapper OF comm_wrapper IS

    COMPONENT dcom_ap
        PORT
            (
                tx_pack_rdy     : IN  STD_LOGIC;
                rx_dpr_radr_stb : IN  STD_LOGIC;
                A_nB            : IN  STD_LOGIC;
                id_avail        : IN  STD_LOGIC;
                HVD_Rx          : IN  STD_LOGIC;
                CLK20           : IN  STD_LOGIC;
                RST             : IN  STD_LOGIC;
                reboot_req      : IN  STD_LOGIC;
                COM_AD_D        : IN  STD_LOGIC_VECTOR(9 DOWNTO 0);
                id              : IN  STD_LOGIC_VECTOR(47 DOWNTO 0);
                rx_dpr_radr     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
                systime         : IN  STD_LOGIC_VECTOR(47 DOWNTO 0);
                tx_dataout      : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
                tx_dpr_wadr     : IN  STD_LOGIC_VECTOR(15 DOWNTO 0);
                tx_pack_sent    : OUT STD_LOGIC;
                rx_dpr_aff      : OUT STD_LOGIC;
                rx_pack_rcvd    : OUT STD_LOGIC;
                rx_we           : OUT STD_LOGIC;
                reboot_gnt      : OUT STD_LOGIC;
                com_avail       : OUT STD_LOGIC;
                COMM_RESET      : OUT STD_LOGIC;
                COM_TX_SLEEP    : OUT STD_LOGIC;
                tx_alm_empty    : OUT STD_LOGIC;
                com_reset_rcvd  : OUT STD_LOGIC;
                msg_rd          : OUT STD_LOGIC;
                data_rcvd       : OUT STD_LOGIC;
                data_stb        : OUT STD_LOGIC;
                stf_stb         : OUT STD_LOGIC;
                eof_stb         : OUT STD_LOGIC;
                err_stb         : OUT STD_LOGIC;
                HVD_IN          : OUT STD_LOGIC;
                HVD_RxENA       : OUT STD_LOGIC;
                HVD_TxENA       : OUT STD_LOGIC;
                COM_DB          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                rev             : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                rx_addr         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                rx_datain       : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
                rx_error        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                rx_packets      : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                tc              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
                tx_addr         : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                tx_dpr_radr     : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
                tx_error        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
			com_thr_d		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			dac_max_d		: IN STD_LOGIC_VECTOR(6 DOWNTO 5);
			rec_del_d		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			send_del_d		: IN STD_LOGIC_VECTOR(7 DOWNTO 0);
			clev_min_d		: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			clev_max_d		: IN STD_LOGIC_VECTOR(9 DOWNTO 0);
			clev_wr			: IN STD_LOGIC;
			thr_del_wr		: IN STD_LOGIC
                );
    END COMPONENT;

    -- head: pointer where data gets written to DPM
    -- tail: pointer where data gets read from DPM
    SIGNAL rx_head : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL rx_tail : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL tx_head : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL tx_tail : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL tx_dpm  : STD_LOGIC_VECTOR (15 DOWNTO 0);

	-- kalle high active board low active
	SIGNAL COMM_nRESET : STD_LOGIC;
    
BEGIN

	tx_head	<= COMM_CTRL.tx_head;
	COMM_STAT.tx_tail	<= tx_tail;
	rx_tail	<= COMM_CTRL.rx_tail;
	COMM_STAT.rx_head	<= rx_head;

    inst_dcom_ap : dcom_ap
        PORT MAP
        (
            tx_pack_rdy     => COMM_CTRL.tx_packet_ready,
            rx_dpr_radr_stb => COMM_CTRL.rx_dpr_raddr_stb,
            A_nB            => A_nB,
            id_avail        => COMM_CTRL.id_avail,
            HVD_Rx          => HDV_Rx,
            CLK20           => CLK20,
            RST             => RST,
            reboot_req      => COMM_CTRL.reboot_req,
            COM_AD_D        => COM_AD_D (11 DOWNTO 2),
            id              => COMM_CTRL.id,
            rx_dpr_radr     => rx_tail,
            systime         => systime,
            tx_dataout      => dp0_portadataout,
            tx_dpr_wadr     => tx_head,
            tx_pack_sent    => COMM_STAT.tx_pack_sent,
            rx_dpr_aff      => COMM_STAT.rx_dpr_aff,
            rx_pack_rcvd    => COMM_STAT.rx_pack_rcvd,
            rx_we           => dp1_portawe,
            reboot_gnt      => COMM_STAT.reboot_gnt,
            com_avail       => COMM_STAT.com_avail,
            COMM_RESET      => COMM_nRESET,
            COM_TX_SLEEP    => COM_TX_SLEEP,
            tx_alm_empty    => COMM_STAT.tx_almost_empty,
            com_reset_rcvd  => COMM_STAT.com_reset_rcvd,
            msg_rd          => OPEN,
            data_rcvd       => OPEN,
            data_stb        => OPEN,
            stf_stb         => OPEN,
            eof_stb         => OPEN,
            err_stb         => OPEN,
            HVD_IN          => HDV_IN,
            HVD_RxENA       => HDV_RxENA,
            HVD_TxENA       => HDV_TxENA,
            COM_DB          => COM_DB (13 DOWNTO 6),
            rev             => OPEN,
            rx_addr         => rx_head,
            rx_datain       => dp1_portadatain,
            rx_error        => COMM_STAT.rx_error,
            rx_packets      => COMM_STAT.rx_packets,
            tc              => TC,
            tx_addr         => tx_dpm,
            tx_dpr_radr     => tx_tail,
            tx_error        => COMM_STAT.tx_error,
		com_thr_d		=> x"40",
		dac_max_d		=> "10",
		rec_del_d		=> x"01",
		send_del_d		=> x"01",
		clev_min_d		=> "1100100000",
		clev_max_d		=> "1100101010",
		clev_wr			=> '0', --'1'
		thr_del_wr		=> '0'
        );

    dp1_portaaddr <= rx_head (12 DOWNTO 0);
    dp0_portaaddr <= tx_dpm (12 DOWNTO 0);

	COM_DB (5 DOWNTO 0)	<= (OTHERS=>'Z');
	
	COMM_RESET <= NOT COMM_nRESET;

END;











