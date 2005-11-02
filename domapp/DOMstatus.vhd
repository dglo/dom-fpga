
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_unsigned.ALL;

LIBRARY WORK;
USE WORK.monitor_data_type.ALL;


ENTITY DOMstatus IS
    PORT (
        CLK20      : IN  STD_LOGIC;
        CLK40      : IN  STD_LOGIC;
        CLK80      : IN  STD_LOGIC;
        RST        : IN  STD_LOGIC;
        -- monitor inputs
        DAQ_status : IN  DAQ_STATUS_STRUCT;
        MultiSPE   : IN  STD_LOGIC;
        OneSPE     : IN  STD_LOGIC;
        -- to the slaveregister
        DOM_status : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
END DOMstatus;

ARCHITECTURE DOMstatus_arch OF DOMstatus IS

    SIGNAL CLK20_5 : STD_LOGIC;
    SIGNAL CLK40_5 : STD_LOGIC;
    SIGNAL CLK80_5 : STD_LOGIC;
    SIGNAL SPE     : STD_LOGIC;
    SIGNAL MPE     : STD_LOGIC;

    SIGNAL AHB_ERROR_latch      : STD_LOGIC;  -- AHB_master bus error
    SIGNAL slavebuserrint_latch : STD_LOGIC;  -- error from bridge
    
BEGIN  -- DOMstatus_arch

    DOM_status(0)            <= DAQ_status.ping_status.busy;
    DOM_status(1)            <= DAQ_status.ping_status.busy_FADC;
    DOM_status(2)            <= DAQ_status.ping_status.buffer_full;
    DOM_status(3)            <= DAQ_status.ping_status.ATWD_acq;
    DOM_status(4)            <= DAQ_status.ping_status.ATWD_dig;
    DOM_status(5)            <= DAQ_status.ping_status.ATWD_read;
    DOM_status(7 DOWNTO 6)   <= (OTHERS => '0');  -- PING
    DOM_status(8)            <= DAQ_status.pong_status.busy;
    DOM_status(9)            <= DAQ_status.pong_status.busy_FADC;
    DOM_status(10)           <= DAQ_status.pong_status.buffer_full;
    DOM_status(11)           <= DAQ_status.pong_status.ATWD_acq;
    DOM_status(12)           <= DAQ_status.pong_status.ATWD_dig;
    DOM_status(13)           <= DAQ_status.pong_status.ATWD_read;
    DOM_status(15 DOWNTO 14) <= (OTHERS => '0');  -- P0NG
    DOM_status(16)           <= DAQ_status.AHB_status.AHB_ERROR;
    DOM_status(17)           <= DAQ_status.AHB_status.slavebuserrint;
    DOM_status(18)           <= AHB_ERROR_latch;
    DOM_status(19)           <= slavebuserrint_latch;
    DOM_status(20)           <= DAQ_status.AHB_status.xfer_eng;
    DOM_status(21)           <= DAQ_status.AHB_status.xfer_compr;
    DOM_status(23 DOWNTO 22) <= (OTHERS => '0');  -- memory interface;
    DOM_status(24)           <= SPE;
    DOM_status(25)           <= MPE;
    DOM_status(28 DOWNTO 26) <= (OTHERS => '0');
    DOM_status(29)           <= CLK20_5;
    DOM_status(30)           <= CLK40_5;
    DOM_status(31)           <= CLK80_5;

    PROCESS (CLK20, RST)
        VARIABLE didvide : STD_LOGIC_VECTOR(1 DOWNTO 0);
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            didvide := "00";
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            CLK20_5 <= didvide(1);
            didvide := didvide + 1;
        END IF;
    END PROCESS;

    PROCESS (CLK40, RST)
        VARIABLE didvide : STD_LOGIC_VECTOR(2 DOWNTO 0);
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            didvide := "000";
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            CLK40_5 <= didvide(2);
            didvide := didvide + 1;
        END IF;
    END PROCESS;

    PROCESS (CLK80, RST)
        VARIABLE didvide : STD_LOGIC_VECTOR(3 DOWNTO 0);
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            didvide := "0000";
        ELSIF CLK80'EVENT AND CLK80 = '1' THEN  -- rising clock edge
            CLK80_5 <= didvide(3);
            didvide := didvide + 1;
        END IF;
    END PROCESS;

    PROCESS (CLK20, RST)
        VARIABLE SPE_sync : STD_LOGIC;
        VARIABLE MPE_sync : STD_LOGIC;
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            SPE_sync := '0';
            MPE_sync := '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            SPE_sync := OneSPE;
            SPE      <= SPE_sync;
            MPE_sync := MultiSPE;
            MPE      <= MPE_sync;
        END IF;
    END PROCESS;

    PROCESS (CLK20, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            AHB_ERROR_latch      <= '0';
            slavebuserrint_latch <= '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF DAQ_status.AHB_status.AHB_ERROR = '1' THEN
                AHB_ERROR_latch <= '1';
            END IF;
            IF DAQ_status.AHB_status.slavebuserrint = '1' THEN
                slavebuserrint_latch <= '1';
            END IF;
        END IF;
    END PROCESS;

END DOMstatus_arch;




