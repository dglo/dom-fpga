-- 05/15/2011 fixed IceTop charge stamp scanning enable

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;

ENTITY icetop_get_atwd_chan IS
    PORT (
        CLK            : IN  STD_LOGIC;
        RST            : IN  STD_LOGIC;
        -- mode
        icetop_mode_en : IN  STD_LOGIC;
        icetop_scan    : IN  STD_LOGIC;
        icetop_channel : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- ATWD status
        abort          : IN  STD_LOGIC;
        overflow       : IN  STD_LOGIC;
        get_chan       : OUT STD_LOGIC;
        channel        : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test connector
        TC             : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END icetop_get_atwd_chan;

ARCHITECTURE icetop_get_atwd_chan_arch OF icetop_get_atwd_chan IS

    SIGNAL channel_old  : STD_LOGIC_VECTOR (1 DOWNTO 0);
    SIGNAL overflow_int : STD_LOGIC;

BEGIN  -- icetop_get_atwd_chan_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            get_chan    <= '0';
            channel_old <= "00";
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            IF abort = '1' AND icetop_mode_en = '1' THEN
                IF icetop_scan = '1' THEN
                    IF (channel <= icetop_channel AND overflow_int = '1') OR channel = "00" THEN
                        get_chan <= '1';
                    ELSE
                        get_chan <= '0';
                    END IF;
                ELSE
                    IF channel = icetop_channel THEN
                        get_chan <= '1';
                    ELSE
                        get_chan <= '0';
                    END IF;
                END IF;
            ELSE
                get_chan <= '0';
            END IF;
            channel_old <= channel;
            IF channel /= channel_old THEN
                overflow_int <= overflow;
            END IF;
        END IF;
    END PROCESS;

END icetop_get_atwd_chan_arch;
