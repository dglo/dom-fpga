LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;


ENTITY LC_relais IS
    PORT (
        CLK40     : IN  STD_LOGIC;
        CLK80     : IN  STD_LOGIC;
        RST       : IN  STD_LOGIC;
        -- setup
        lc_length : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- local discriminator
        disc      : IN  STD_LOGIC;
        -- from RX
        n_rx      : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        rx        : IN  STD_LOGIC;
        -- to TX
        n_tx      : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        tx        : OUT STD_LOGIC;
        -- test
        TC        : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_relais;


ARCHITECTURE LC_relais_arch OF LC_relais IS

BEGIN  -- LC_relais_arch

    -- !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    -- PROBLEM if disc while transmit is going on bacause n_tx will change
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)

        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF disc = '1' THEN
                n_tx <= lc_length;
                tx   <= '1';
            ELSIF rx = '1' THEN
                IF n_rx = "00" THEN
                    -- last one; we are done
                    NULL;
                ELSE
                    n_tx <= n_rx - 1;
                    tx   <= '1';
                END IF;
            ELSE
                tx <= '0';
            END IF;
        END IF;
    END PROCESS;

END LC_relais_arch;
