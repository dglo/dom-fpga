-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : dcom_ap.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004-08-03
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Empty entity (interface) of Kalle's communications formware for
--              simulation purposes (modelsim)
-------------------------------------------------------------------------------
-- Copyright (c) 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-08-03  V00-00-00   thorsten
-------------------------------------------------------------------------------


LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;

ENTITY dcom_ap IS
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
            tx_error        : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
            );
END dcom_ap;

ARCHITECTURE bdf_type OF dcom_ap IS

BEGIN

    tx_error   <= x"FFFF";
    rx_error   <= x"FFFF";
    rx_packets <= x"FFFF";
    reboot_gnt <= reboot_req;
    COM_DB     <= (OTHERS => 'Z');

    
END;
