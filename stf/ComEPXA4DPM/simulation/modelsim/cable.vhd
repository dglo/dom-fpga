LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_signed.ALL;

ENTITY cable IS

    PORT (
        DOR_DAC : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        DOR_ADC : OUT STD_LOGIC_VECTOR (11 DOWNTO 0);
        DOM_DAC : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
        DOM_ADC : OUT STD_LOGIC_VECTOR (9 DOWNTO 0)
        );

END cable;

ARCHITECTURE cable_inst OF cable IS

    SIGNAL doradc : INTEGER;
    SIGNAL dordac : INTEGER;
    SIGNAL domadc : INTEGER;
    SIGNAL domdac : INTEGER;

    SIGNAL test : STD_LOGIC_VECTOR (9 DOWNTO 0);

BEGIN  -- cable_inst

    dordac  <= CONV_INTEGER(DOR_DAC XOR "10000000");
    DOR_ADC <= (CONV_STD_LOGIC_VECTOR( doradc, 12) XOR X"800");
    domdac  <= CONV_INTEGER(DOM_DAC XOR "10000000");
    DOM_ADC <= (CONV_STD_LOGIC_VECTOR(domadc, 10) XOR "1000000000");
 test <= CONV_STD_LOGIC_VECTOR(domadc, 10);

--    doradc <= dordac*2 + domdac*2;
--    domadc <= domdac*2 + dordac*2;
    doradc <= TRANSPORT (domdac*2) AFTER 2500 ns;
    domadc <= TRANSPORT (dordac*2) AFTER 2500 ns;

END cable_inst;

