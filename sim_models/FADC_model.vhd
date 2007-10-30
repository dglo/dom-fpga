LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;


ENTITY FADC_model IS
    GENERIC (
        width : INTEGER := 10);
    PORT (
        CLK : IN  STD_LOGIC;
        D   : OUT STD_LOGIC_VECTOR (9 DOWNTO 0));
END FADC_model;


ARCHITECTURE FADC_arch OF FADC_model IS

    SIGNAL data : STD_LOGIC_VECTOR (9 DOWNTO 0) := (OTHERS => '0');
    SIGNAL Udef : STD_LOGIC                     := '0';
    SIGNAL def  : STD_LOGIC                     := '0';
    
BEGIN  -- FADC_arch

    xyz : PROCESS (CLK)
    BEGIN  -- PROCESS xyz
        IF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            data <= data+1 AFTER 5 ns;
            Udef <= '1'    AFTER 2 ns;
            def  <= '1'    AFTER 6 ns;
            --        D <= (OTHERS=>'U') AFTER 2 ns;
            --        D <= data AFTER 4 ns;
        ELSIF CLK'EVENT AND CLK = '0' THEN
            Udef <= '0';
            def  <= '0';
        END IF;
    END PROCESS xyz;

    D <= (OTHERS => 'U') WHEN Udef = '1' AND def = '0' ELSE data;

END FADC_arch;










