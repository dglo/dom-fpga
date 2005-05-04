
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY LC_TX IS
    PORT (
        CLK40           : IN  STD_LOGIC;
        RST             : IN  STD_LOGIC;
        -- setup
        tx_enable       : IN  STD_LOGIC;
        -- internal LC signals
        n               : IN  STD_LOGIC_VECTOR (1 DOWNTO 0);
        tx              : IN  STD_LOGIC;
        -- LC hardware
        COINCIDENCE_OUT : OUT STD_LOGIC;
        -- test
        TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END LC_TX;


ARCHITECTURE LC_TX_arch OF LC_TX IS

    TYPE   state_type IS (IDLE, BIT0A, BIT0Aw, BIT0B, BIT0Bw, BIT1A, BIT1Aw, BIT1B ,BIT1Bw,wait1,wait2,wait3,wait4);
    SIGNAL state : state_type;
    
BEGIN  -- LC_TX_arch

    transmit : PROCESS (CLK40, RST)
    BEGIN  -- PROCESS tx
        IF RST = '1' THEN               -- asynchronous reset (active high)
            COINCIDENCE_OUT <= 'Z';
            state           <= IDLE;
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            CASE state IS
                WHEN IDLE =>
                    COINCIDENCE_OUT <= 'Z';
                    IF tx = '1' AND tx_enable = '1' THEN
                        state <= BIT0A;
                    END IF;
                WHEN BIT0A =>
                    COINCIDENCE_OUT <= NOT n(0);
                    state           <= BIT0Aw;
				WHEN BIT0Aw =>
                    COINCIDENCE_OUT <= NOT n(0);
                    state           <= BIT0B;

                WHEN BIT0B =>
                    COINCIDENCE_OUT <= n(0);
                    state           <= BIT0Bw;
				WHEN BIT0Bw =>
                    COINCIDENCE_OUT <= n(0);
                    state           <= BIT1A;

                WHEN BIT1A =>
                    COINCIDENCE_OUT <= NOT n(1);
                    state           <= BIT1Aw;
				WHEN BIT1Aw =>
                    COINCIDENCE_OUT <= NOT n(1);
                    state           <= BIT1B;

                WHEN BIT1B =>
                    COINCIDENCE_OUT <= n(1);
                    state           <= BIT1Bw;
				WHEN BIT1Bw =>
                    COINCIDENCE_OUT <= n(1);
                    state           <= wait1;

				WHEN wait1 =>
					COINCIDENCE_OUT <= 'Z';
					state           <= wait2;
				WHEN wait2 =>
					COINCIDENCE_OUT <= 'Z';
					state           <= wait3;
				WHEN wait3 =>
					COINCIDENCE_OUT <= 'Z';
					state           <= wait4;
				WHEN wait4 =>
					COINCIDENCE_OUT <= 'Z';
					state           <= IDLE;
					
                WHEN OTHERS =>
                    COINCIDENCE_OUT <= 'Z';
                    state           <= IDLE;
            END CASE;
        END IF;
    END PROCESS transmit;

END LC_TX_arch;
