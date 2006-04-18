-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : delta2word.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2006-03-21
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This module packs the delta encoded samples into 32 bit words
--              The longest delta word is 11 bits. The 32 bit word is split
--              into 16 bit words. This ensure only one overflow can happen at
--              one time and it reduces the size of the barrel shifter
--
-- Input Timing:
--                   ___     ___
-- CLK          |___|   |___|
--                   _______
-- delta_valid  ____|       |______
--              ____ _______ ______
-- bits_p_delta ____X valid X______
--              ____ _______ ______
-- delta        ____X valid X______
-------------------------------------------------------------------------------
-- Copyright (c) 2006 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2006-       V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_unsigned.ALL;
USE IEEE.std_logic_arith.ALL;

ENTITY delta2word IS
    PORT (
        CLK              : IN  STD_LOGIC;
        RST              : IN  STD_LOGIC;
        -- control
        next_hit         : IN  STD_LOGIC;
        data_bits        : OUT STD_LOGIC_VECTOR (18 DOWNTO 0);
        write_last_short : IN  STD_LOGIC;
        -- input data
        delta_valid      : IN  STD_LOGIC;
        delta            : IN  STD_LOGIC_VECTOR (10 DOWNTO 0);
        bits_per_delta   : IN  INTEGER RANGE 1 TO 11;
        -- output data (compression memory)
        ram_data         : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        ram_addr         : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
        ram0_we          : OUT STD_LOGIC;
        ram1_we          : OUT STD_LOGIC;
        -- test connector
        TC               : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
END delta2word;

ARCHITECTURE delta2word_arch OF delta2word IS

    COMPONENT barrel_shift
        PORT (
            distance : IN  STD_LOGIC_VECTOR (3 DOWNTO 0);
            data     : IN  STD_LOGIC_VECTOR (25 DOWNTO 0);
            result   : OUT STD_LOGIC_VECTOR (25 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL fill_cnt         : STD_LOGIC_VECTOR (18 DOWNTO 0);
    SIGNAL data             : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL barrel_data      : STD_LOGIC_VECTOR (25 DOWNTO 0);
    SIGNAL barrel_data_in   : STD_LOGIC_VECTOR (25 DOWNTO 0) := (OTHERS => '0');
    SIGNAL last_barrel_data : STD_LOGIC_VECTOR (9 DOWNTO 0);
    
BEGIN  -- delta2word_arch

    -- update
    PROCESS (CLK, RST)
        VARIABLE barrel_tmp   : STD_LOGIC_VECTOR (15 DOWNTO 0);
        VARIABLE fill_cnt_old : STD_LOGIC;
        VARIABLE overflow     : STD_LOGIC;
        VARIABLE fill_cnt_var : STD_LOGIC_VECTOR (18 DOWNTO 0);
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            data       <= (OTHERS => '0');
            barrel_tmp := (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            IF next_hit = '1' THEN
                fill_cnt         <= CONV_STD_LOGIC_VECTOR(128, 19);  -- init to include header
                fill_cnt_var     := CONV_STD_LOGIC_VECTOR(128, 19);  -- init to include header
                fill_cnt_old     := '0';
                data             <= (OTHERS => '0');
                last_barrel_data <= (OTHERS => '0');
                overflow         := '0';
                ram0_we          <= '0';
                ram1_we          <= '0';
            ELSIF delta_valid = '1' THEN
                fill_cnt_var     := fill_cnt_var + bits_per_delta;
                barrel_tmp       := barrel_data (15 DOWNTO 0) OR "000000"&last_barrel_data;
                last_barrel_data <= barrel_data (25 DOWNTO 16);
                IF overflow = '0' THEN
                    data <= data OR barrel_tmp;
                ELSE
                    data <= barrel_tmp;
                END IF;
                overflow     := fill_cnt_var(4) XOR fill_cnt_old;
                fill_cnt_old := fill_cnt_var(4);
                IF overflow = '1' THEN
                    IF fill_cnt(4) = '0' THEN
                        ram0_we <= '1';
                        ram1_we <= '0';
                    ELSE
                        ram0_we <= '0';
                        ram1_we <= '1';
                    END IF;
                ELSE
                    ram0_we <= '0';
                    ram1_we <= '0';
                END IF;
            ELSIF write_last_short = '1' THEN
                IF overflow = '0' THEN
                    data <= data OR "000000"&last_barrel_data;
                ELSE
                    data <= "000000"&last_barrel_data;
                END IF;
                IF fill_cnt_var(3 DOWNTO 0) = "0000" THEN
                    NULL;
                    -- we just filled the short
                ELSE
                    IF fill_cnt_var(4) = '0' THEN
                        ram0_we <= '1';
                        ram1_we <= '0';
                    ELSE
                        ram0_we <= '0';
                        ram1_we <= '1';
                    END IF;
                END IF;
            ELSE
                ram0_we <= '0';
                ram1_we <= '0';
            END IF;
            fill_cnt <= fill_cnt_var;
            ram_addr <= fill_cnt (13 DOWNTO 5);
        END IF;
    END PROCESS;

    -- better way to compute:
    -- WARNING fix hit size, because Joshua defined hitsize without first long
    -- word and starting from 1
--    hit_size <= fill_cnt(13 DOWNTO 3)-3 WHEN fill_cnt(2 DOWNTO 0)="000" ELSE fill_cnt(13 DOWNTO3)+1-3; -- in bytes
--    compr_size <= fill_cnt(13 DOWNTO 5) WHEN fill_cnt(4 DOWNTO 0)="00000" ELSE fill_cnt(13 DOWNTO 5)+1;

    ram_data <= data;

    -- REPLACED by Megafunction because of Quartus
    -- barel shift
--    fill <= conv_integer(fill_cnt(3 DOWNTO 0));
--    PROCESS (delta, fill)
--    BEGIN  -- PROCESS
--        barrel_data                       <= (OTHERS => '0');
--        barrel_data (fill+10 DOWNTO fill) <= delta;
--    END PROCESS;

    -- replaced by megafunction because quartus can not translate it
    barrel_data_in(10 DOWNTO 0) <= delta;
    barrel_shift_inst : barrel_shift
        PORT MAP (
            distance => fill_cnt(3 DOWNTO 0),
            data     => barrel_data_in,  --"000000000000000"&delta,
            result   => barrel_data
            );

    data_bits <= fill_cnt-1;            -- -1 because fill_cnt points to the
                                        -- next free bit

END delta2word_arch;









