-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : dim_pole_flag.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2012-06-29
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module generates the dim-pole-flag
--              The dim-pole-flag is set when when there are more than n
--              discriminator crossings in a set time window.
--              The are 2 dim-pole-flags with different settings
--
--              We write the timestamps of discriminator hits into a buffer.
--              There is a write pointer and a read pointer
--              The read pointer is incremented if the delta t between the
--              current read time and the sytem time is bigger than the time
--              window or when the buffer is full.
--              We have two bufferes for the two "dim pole flags" which share
--              one block ram. Therefore each discriminator crossing is written
--              twice into the block ram. (the two flags could have different
--              time wondows.
-------------------------------------------------------------------------------
-- Copyright (c) -2012
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten 
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;


ENTITY dim_pole_flag IS
    PORT (
        CLK40           : IN  STD_LOGIC;
        RST             : IN  STD_LOGIC;
        -- setup
        disc_select     : IN  STD_LOGIC;  -- 0 = SPE; 1 = MPE
        deadtime        : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
        systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
        dim_pole_n0     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);   -- trigger count
        dim_pole_n1     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
        dim_pole_t0     : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);  -- time window
        dim_pole_t1     : IN  STD_LOGIC_VECTOR (14 DOWNTO 0);
        -- discriminator
        discSPEpulse    : IN  STD_LOGIC;
        discMPEpulse    : IN  STD_LOGIC;
        -- readout status
        triggered_A     : IN  STD_LOGIC;
        triggered_B     : IN  STD_LOGIC;
        -- dim pole flag
        dim_pole_status : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
        -- test connector
        TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END dim_pole_flag;

ARCHITECTURE dim_pole_flag_arch OF dim_pole_flag IS

    COMPONENT dim_pole_buffer
        PORT (
            data      : IN  STD_LOGIC_VECTOR (15 DOWNTO 0);
            wraddress : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
            rdaddress : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
            wren      : IN  STD_LOGIC := '1';
            clock     : IN  STD_LOGIC;
            q         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL deadtime_cnt : UNSIGNED (6 DOWNTO 0);
    SIGNAL disc         : STD_LOGIC;

    TYPE   state_wr_type IS (IDLE, CLR_START, CLR_MEM, WR_FLAG0, WR_FLAG1);
    SIGNAL state_wr : state_wr_type;
    TYPE   state_rd_type IS (RESET, RD_FLAG0, RD_FLAG1);
    SIGNAL state_rd : state_rd_type;

    -- menory addrsss signals
    SIGNAL wren    : STD_LOGIC;
    SIGNAL wr_addr : STD_LOGIC_VECTOR (6 DOWNTO 0);
    SIGNAL rd_addr : STD_LOGIC_VECTOR (6 DOWNTO 0);

    -- cricular buffer pointers
    SIGNAL wr_ptr  : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- next entry to write
    SIGNAL wr_ptr_d  : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- next entry to write
    SIGNAL wr_ptr_del  : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- next entry to write
    SIGNAL rd_ptr0 : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- last valid entry
    SIGNAL rd_ptr1 : STD_LOGIC_VECTOR (6 DOWNTO 0);  -- last valid entry
    -- buffer is empty when wr_ptr = rd_ptr0/1

    SIGNAL dim_pole_cnt0 : STD_LOGIC_VECTOR (6 DOWNTO 0);
    SIGNAL dim_pole_cnt1 : STD_LOGIC_VECTOR (6 DOWNTO 0);
    SIGNAL delta_t       : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL drop0_last    : STD_LOGIC;
    SIGNAL drop1_last    : STD_LOGIC;

    SIGNAL triggered_A_old : STD_LOGIC;
    SIGNAL triggered_B_old : STD_LOGIC;

    SIGNAL dim_pole_found : STD_LOGIC_VECTOR (1 DOWNTO 0);

    SIGNAL dim_pole_flag : STD_LOGIC_VECTOR (1 DOWNTO 0);

    -- memory data
    SIGNAL wr_data : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL wr_zero : STD_LOGIC;
    SIGNAL rd_data : STD_LOGIC_VECTOR (15 DOWNTO 0);
    
BEGIN  -- dim_pole_flag_arch


    -- select discriminator and apply artificial dead time
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            deadtime_cnt <= (OTHERS => '0');
            disc         <= '0';
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF deadtime_cnt > 0 THEN
                deadtime_cnt <= deadtime_cnt - 1;
                disc         <= '0';
            ELSIF (disc_select = '0' AND discSPEpulse = '1') OR
                (disc_select = '1' AND discMPEpulse = '1') THEN
                deadtime_cnt <= UNSIGNED (deadtime);
                disc         <= '1';
            ELSE
                deadtime_cnt <= (OTHERS => '0');
                disc         <= '0';
            END IF;
        END IF;
    END PROCESS;

    -- write timstamps to BUFFER
    -- write twice for the two flags
    -- clear buffer at startup
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            wren     <= '0';
            wr_zero  <= '1';
            wr_addr  <= (OTHERS => '0');
            wr_ptr   <= (OTHERS => '0');
            state_wr <= CLR_START;
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            CASE state_wr IS
                WHEN IDLE =>
                    wren    <= '0';
                    wr_zero <= '1';
                    IF disc = '1' THEN
                        state_wr <= WR_FLAG0;
                    END IF;
                WHEN CLR_START =>
                    wren     <= '1';
                    wr_zero  <= '1';
                    wr_addr  <= (OTHERS => '0');
                    state_wr <= CLR_MEM;
                WHEN CLR_MEM =>
                    wren    <= '1';
                    wr_zero <= '1';
                    wr_addr <= STD_LOGIC_VECTOR(UNSIGNED(wr_addr) + 1);
                    IF wr_addr = "1111111" THEN
                        state_wr <= IDLE;
                    ELSE
                        state_wr <= CLR_MEM;
                    END IF;
                WHEN WR_FLAG0 =>
                    wren                <= '1';
                    wr_zero             <= '0';
                    wr_addr(0)          <= '0';
                    wr_addr(6 DOWNTO 1) <= wr_ptr (5 DOWNTO 0);
                    state_wr            <= WR_FLAG1;
                WHEN WR_FLAG1 =>
                    wren                <= '1';
                    wr_zero             <= '0';
                    wr_addr(0)          <= '1';
                    wr_addr(6 DOWNTO 1) <= wr_ptr (5 DOWNTO 0);
                    wr_ptr              <= STD_LOGIC_VECTOR(UNSIGNED(wr_ptr) + 1);  -- we just added 1
                    state_wr            <= IDLE;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

    -- read BUFFER
    -- read alternating for the two flags
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            rd_addr    <= (OTHERS => '0');
            rd_ptr0    <= (OTHERS => '0');
            rd_ptr1    <= (OTHERS => '0');
            drop0_last <= '0';
            drop1_last <= '0';
            state_rd   <= RESET;
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            CASE state_rd IS
                WHEN RESET =>
                    rd_addr    <= (OTHERS => '0');
                    rd_ptr0    <= (OTHERS => '0');
                    rd_ptr1    <= (OTHERS => '0');
                    drop0_last <= '0';
                    drop1_last <= '0';
                    IF state_wr = CLR_MEM THEN
                        state_rd <= RESET;
                    ELSE
                        state_rd <= RD_FLAG0;
                    END IF;
                WHEN RD_FLAG0 =>
                    rd_addr(0)          <= '0';
                    rd_addr(6 DOWNTO 1) <= rd_ptr0 (5 DOWNTO 0);
                    drop0_last          <= '0';
                    IF UNSIGNED(dim_pole_cnt0) >= 64 OR
                        (UNSIGNED(delta_t) > UNSIGNED('0' & dim_pole_t0) AND UNSIGNED(dim_pole_cnt0) >= 1 AND drop0_last = '0') THEN
                        rd_ptr0    <= STD_LOGIC_VECTOR(UNSIGNED(rd_ptr0) + 1);
                        drop0_last <= '1';
                    END IF;
                    IF state_wr = CLR_MEM THEN
                        state_rd <= RESET;
                    ELSE
                        state_rd <= RD_FLAG1;
                    END IF;
                WHEN RD_FLAG1 =>
                    rd_addr(0)          <= '1';
                    rd_addr(6 DOWNTO 1) <= rd_ptr1 (5 DOWNTO 0);
                    drop1_last          <= '0';
                    IF UNSIGNED(dim_pole_cnt1) >= 64 OR
                        (UNSIGNED(delta_t) > UNSIGNED('0' & dim_pole_t1) AND UNSIGNED(dim_pole_cnt1) >= 1 AND drop1_last = '0') THEN
                        rd_ptr1    <= STD_LOGIC_VECTOR(UNSIGNED(rd_ptr1) + 1);
                        drop1_last <= '1';
                    END IF;
                    IF state_wr = CLR_MEM THEN
                        state_rd <= RESET;
                    ELSE
                        state_rd <= RD_FLAG0;
                    END IF;
                WHEN OTHERS =>
                    NULL;
            END CASE;
        END IF;
    END PROCESS;

    dim_pole_cnt0 <= STD_LOGIC_VECTOR(UNSIGNED(wr_ptr_del) - UNSIGNED(rd_ptr0));
    dim_pole_cnt1 <= STD_LOGIC_VECTOR(UNSIGNED(wr_ptr_del) - UNSIGNED(rd_ptr1));

    -- pipeline the delta_t computation to match the state machine checking
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN
            delta_t <= (OTHERS => '0');
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            delta_t <= STD_LOGIC_VECTOR(UNSIGNED(systime(15 DOWNTO 0)) - UNSIGNED(rd_data));
            -- deley write pointer to align readout statemachine memory latency
			wr_ptr_del <= wr_ptr_d;
			wr_ptr_d <= wr_ptr;
        END IF;
    END PROCESS;


    -- check size
    dim_pole_found(0) <= '1' WHEN UNSIGNED(dim_pole_cnt0) >= UNSIGNED('0'&dim_pole_n0) ELSE '0';
    dim_pole_found(1) <= '1' WHEN UNSIGNED(dim_pole_cnt1) >= UNSIGNED('0'&dim_pole_n1) ELSE '0';

    -- set/reset dim pole flags
    PROCESS (CLK40, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            triggered_A_old <= '0';
            triggered_B_old <= '0';
            dim_pole_flag   <= "00";
        ELSIF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            IF (triggered_A = '1' AND triggered_A_old = '0') OR
                (triggered_B = '1' AND triggered_B_old = '0') THEN
                -- risign edge of triggered (start of acquisition)
                dim_pole_flag <= dim_pole_found;
            ELSE
                dim_pole_flag <= dim_pole_flag OR dim_pole_found;
            END IF;
            triggered_A_old <= triggered_A;
            triggered_B_old <= triggered_B;
        END IF;
    END PROCESS;
    dim_pole_status <= dim_pole_flag;


    -- time buffer
    wr_data <= (OTHERS => '0') WHEN wr_zero = '1' ELSE systime (15 DOWNTO 0);
    dim_pole_buffer_inst : dim_pole_buffer
        PORT MAP (
            data      => wr_data,
            wraddress => wr_addr,
            rdaddress => rd_addr,
            wren      => wren,
            clock     => CLK40,
            q         => rd_data
            );

END dim_pole_flag_arch;
