-------------------------------------------------------------------------------
-- Title      : COMMUNICATION
-- Project    : IceCube DOM main board/ DOR Card
-------------------------------------------------------------------------------
-- File       : crc32.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2004/04/05
-- Platform   : Altera Excalibur/Altera APEX
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: this module calculates the CRC32
-------------------------------------------------------------------------------
-- Copyright (c) 2004 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2004-04-05  V01-01-00   thorsten  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;


ENTITY crc32 IS
    PORT (
        CLK     : IN  STD_LOGIC;
        RST     : IN  STD_LOGIC;
        init    : IN  STD_LOGIC;
        data_en : IN  STD_LOGIC;
        data_in : IN  STD_LOGIC;
        crc     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
        );
END crc32;


ARCHITECTURE crc32_arch OF crc32 IS

    CONSTANT CRC_polynom : STD_LOGIC_VECTOR (32 DOWNTO 0) := "100000100110000010001110110110111";
    SIGNAL   SRG         : STD_LOGIC_VECTOR (31 DOWNTO 0) := X"00000000";

BEGIN  -- crc32_arch

    CRC_SRG : PROCESS (CLK, RST)
    BEGIN  -- process CRC_SRG
        IF RST = '1' THEN               -- asynchronous reset (active high)

        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            IF init = '1' THEN
                SRG            <= (OTHERS => '1');
            ELSE
                IF data_en = '1' THEN
                    -- do CRC shift
                    SRG(0)     <= (SRG(31) AND CRC_polynom(0)) XOR data_in;
                    FOR i IN 1 TO 31 LOOP
                        SRG(i) <= (SRG(31) AND CRC_polynom(i)) XOR SRG(i-1);  -- xor data_in;
                    END LOOP;  -- i
                END IF;
            END IF;
        END IF;
    END PROCESS CRC_SRG;

    CRC <= SRG;

END crc32_arch;
