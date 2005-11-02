
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY adc2fifo IS
    PORT (
        CLK              : IN  STD_LOGIC;
        RST              : IN  STD_LOGIC;
        -- Communications ADC
        COM_AD_D         : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
        COM_AD_OTR       : IN  STD_LOGIC;
        -- fifo
        fifo_data        : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        fifo_rd          : IN  STD_LOGIC;
        fifo_almost_full : OUT STD_LOGIC
        );
END adc2fifo;


ARCHITECTURE adc2fifo_arch OF adc2fifo IS

    COMPONENT commfifo
        PORT
            (
                data        : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
                wrreq       : IN  STD_LOGIC;
                rdreq       : IN  STD_LOGIC;
                clock       : IN  STD_LOGIC;
                q           : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                full        : OUT STD_LOGIC;
                empty       : OUT STD_LOGIC;
                usedw       : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
                almost_full : OUT STD_LOGIC
                );
    END COMPONENT;


    SIGNAL COM_AD_D_int : STD_LOGIC_VECTOR (9 DOWNTO 0);

    SIGNAL fifo_wr_data : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fifo_wr      : STD_LOGIC;
    TYPE   state_type IS (IDLE, sample0, sample1, sample2);
    SIGNAL state        : state_type;
    
BEGIN  -- adc2fifo_arch

    PROCESS (CLK, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN                   -- asynchronous reset (active high)
            fifo_wr_data <= (OTHERS => '0');
            fifo_wr      <= '0';
            state        <= IDLE;
            COM_AD_D_int <= (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            fifo_wr_data (31 DOWNTO 30) <= "00";
--            COM_AD_D_int <= COM_AD_D (11 DOWNTO 2);
            -- for testing
            COM_AD_D_int                <= COM_AD_D_int + 1;
            CASE state IS
                WHEN IDLE =>
                    fifo_wr <= '0';
                    state   <= sample0;
                WHEN sample0 =>
                    fifo_wr_data (9 DOWNTO 0) <= COM_AD_D_int;
                    fifo_wr                   <= '0';
                    state                     <= sample1;
                WHEN sample1 =>
                    fifo_wr_data (19 DOWNTO 10) <= COM_AD_D_int;
                    fifo_wr                     <= '0';
                    state                       <= sample2;
                WHEN sample2 =>
                    fifo_wr_data (29 DOWNTO 20) <= COM_AD_D_int;
                    fifo_wr                     <= '1';
                    state                       <= sample0;
                WHEN OTHERS => NULL;
            END CASE;
        END IF;
    END PROCESS;


    commfifo_int : commfifo
        PORT MAP (
            data        => fifo_wr_data,
            wrreq       => fifo_wr,
            rdreq       => fifo_rd,
            clock       => CLK,
            q           => fifo_data,
            full        => OPEN,
            empty       => OPEN,
            usedw       => OPEN,
            almost_full => fifo_almost_full
            );


END adc2fifo_arch;
