-------------------------------------------------------------------------------
-- timestamp timer
-------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.all;

ENTITY timer IS
    
    PORT (
        CLK     : IN  STD_LOGIC;
        RST     : IN  STD_LOGIC;
        systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
        );

END timer;


ARCHITECTURE timer_arch OF timer IS

BEGIN  -- timer_arch

    PROCESS (CLK, RST)
        VARIABLE systime_cnt : STD_LOGIC_VECTOR (47 DOWNTO 0);
    BEGIN  -- PROCESS clock
        IF RST = '1' THEN
            systime     <= (OTHERS => '0');
            systime_cnt := (OTHERS => '0');
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            systime_cnt := systime_cnt + 1;
            systime     <= systime_cnt;
        END IF;
    END PROCESS;

END timer_arch;
