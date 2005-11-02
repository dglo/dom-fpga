LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

LIBRARY work;
USE WORK.ctrl_data_types.all;

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
        dp0_portadataout : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        -- TC
        tc               : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
END comm_wrapper;

ARCHITECTURE arch_comm_wrapper OF comm_wrapper IS

BEGIN

END;
