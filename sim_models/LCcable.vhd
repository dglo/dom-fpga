-------------------------------------------------------------------------------
-- Local coincidence cable for modelsim simulation
-- use cable_delay to set "cable length"
-- thorsten 2005
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY LCcable IS
    GENERIC (
        LONGnSHORT         :     STD_LOGIC := '0'  -- cable length
        );
    PORT (
        COINCIDENCE_OUT_UP : IN  STD_LOGIC;
        COINC_DOWN_A       : OUT STD_LOGIC;
        COINC_DOWN_ABAR    : OUT STD_LOGIC;
        COINC_DOWN_ALATCH  : IN  STD_LOGIC;
        COINC_DOWN_B       : OUT STD_LOGIC;
        COINC_DOWN_BBAR    : OUT STD_LOGIC;
        COINC_DOWN_BLATCH  : IN  STD_LOGIC;

        COINCIDENCE_OUT_DOWN : IN  STD_LOGIC;
        COINC_UP_A           : OUT STD_LOGIC;
        COINC_UP_ABAR        : OUT STD_LOGIC;
        COINC_UP_ALATCH      : IN  STD_LOGIC;
        COINC_UP_B           : OUT STD_LOGIC;
        COINC_UP_BBAR        : OUT STD_LOGIC;
        COINC_UP_BLATCH      : IN  STD_LOGIC
        );
END LCcable;

ARCHITECTURE LCcable_arch OF LCcable IS

    CONSTANT cable_delay : TIME := 270 ns;

    SIGNAL COINCIDENCE_OUT_UP_delay   : STD_LOGIC;
    SIGNAL COINCIDENCE_OUT_DOWN_delay : STD_LOGIC;

BEGIN  -- LCcable_arch

    COINCIDENCE_OUT_UP_delay   <= TRANSPORT COINCIDENCE_OUT_UP   AFTER cable_delay;
    COINCIDENCE_OUT_DOWN_delay <= TRANSPORT COINCIDENCE_OUT_DOWN AFTER cable_delay;

    PROCESS (COINCIDENCE_OUT_UP_delay, COINC_DOWN_ALATCH, COINC_DOWN_BLATCH)
    BEGIN  -- PROCESS
        IF COINCIDENCE_OUT_UP_delay = '1' THEN
            COINC_DOWN_A        <= '1';
            COINC_DOWN_ABAR     <= '0';
        ELSIF COINC_DOWN_ALATCH = '0' THEN
            IF COINCIDENCE_OUT_UP_delay = '1' THEN
                COINC_DOWN_A    <= '1';
                COINC_DOWN_ABAR <= '0';
            ELSE
                COINC_DOWN_A    <= '0';
                COINC_DOWN_ABAR <= '1';
            END IF;
        END IF;

        IF COINCIDENCE_OUT_UP_delay = '0' THEN
            COINC_DOWN_B        <= '1';
            COINC_DOWN_BBAR     <= '0';
        ELSIF COINC_DOWN_ALATCH = '0' THEN
            IF COINCIDENCE_OUT_UP_delay = '0' THEN
                COINC_DOWN_B    <= '1';
                COINC_DOWN_BBAR <= '0';
            ELSE
                COINC_DOWN_B    <= '0';
                COINC_DOWN_BBAR <= '1';
            END IF;
        END IF;
    END PROCESS;

    PROCESS (COINCIDENCE_OUT_DOWN_delay, COINC_UP_ALATCH, COINC_UP_BLATCH)
    BEGIN  -- PROCESS
        IF COINCIDENCE_OUT_DOWN_delay = '1' THEN
            COINC_UP_A        <= '1';
            COINC_UP_ABAR     <= '0';
        ELSIF COINC_UP_ALATCH = '0' THEN
            IF COINCIDENCE_OUT_DOWN_delay = '1' THEN
                COINC_UP_A    <= '1';
                COINC_UP_ABAR <= '0';
            ELSE
                COINC_UP_A    <= '0';
                COINC_UP_ABAR <= '1';
            END IF;
        END IF;

        IF COINCIDENCE_OUT_DOWN_delay = '0' THEN
            COINC_UP_B        <= '1';
            COINC_UP_BBAR     <= '0';
        ELSIF COINC_UP_ALATCH = '0' THEN
            IF COINCIDENCE_OUT_DOWN_delay = '0' THEN
                COINC_UP_B    <= '1';
                COINC_UP_BBAR <= '0';
            ELSE
                COINC_UP_B    <= '0';
                COINC_UP_BBAR <= '1';
            END IF;
        END IF;
    END PROCESS;

END LCcable_arch;
