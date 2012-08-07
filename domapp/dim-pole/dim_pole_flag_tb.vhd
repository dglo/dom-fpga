LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY dim_pole_flag_tb IS

END dim_pole_flag_tb;



ARCHITECTURE dim_pole_flag_tb_arch OF dim_pole_flag_tb IS

    COMPONENT dim_pole_flag
        PORT (
            CLK40           : IN  STD_LOGIC;
            RST             : IN  STD_LOGIC;
            -- setup
            disc_select     : IN  STD_LOGIC;  -- 0 = SPE; 1 = MPE
            deadtime        : IN  STD_LOGIC_VECTOR (6 DOWNTO 0);
            systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
            dim_pole_n0     : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);  -- trigger count
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
    END COMPONENT;

    SIGNAL CLK40   : STD_LOGIC                      := '0';
    SIGNAL RST     : STD_LOGIC                      := '1';
    SIGNAL systime : STD_LOGIC_VECTOR (47 DOWNTO 0) := (OTHERS => '0');

    SIGNAL discSPEpulse : STD_LOGIC;
    SIGNAL discMPEpulse : STD_LOGIC;
    SIGNAL disc_srg     : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";

    
BEGIN  -- dim_pole_flag_tb_arch

    CLK40 <= NOT CLK40 AFTER 12.5 ns;
    RST   <= '0'       AFTER 251 ns;

    PROCESS (CLK40)
    BEGIN  -- PROCESS
        IF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            systime <= STD_LOGIC_VECTOR(UNSIGNED(systime) + 1);
        END IF;
    END PROCESS;

    PROCESS (CLK40)
    BEGIN  -- PROCESS
        IF CLK40'EVENT AND CLK40 = '1' THEN  -- rising clock edge
            disc_srg (3 DOWNTO 0) <= disc_srg (2 DOWNTO 0) & systime (5);
        END IF;
    END PROCESS;
    discSPEpulse <= '1' WHEN disc_srg (3 DOWNTO 2) = "01" ELSE '0';
    discMPEpulse <= '1' WHEN disc_srg (3 DOWNTO 2) = "10" ELSE '0';

    dim_pole_flag_inst : dim_pole_flag
        PORT MAP (
            CLK40           => CLK40,
            RST             => RST,
            -- setup
            disc_select     => '0',
            deadtime        => "1000000",
            systime         => systime,
            dim_pole_n0     => "001100",
            dim_pole_n1     => "010001",
            dim_pole_t0     => "001"&x"800",
            dim_pole_t1     => "000"&x"800",
            -- discriminator
            discSPEpulse    => discSPEpulse,
            discMPEpulse    => discMPEpulse,
            -- readout status
            triggered_A     => '0',
            triggered_B     => '0',
            -- dim pole flag
            dim_pole_status => OPEN,
            -- test connector
            TC              => OPEN
            );


END dim_pole_flag_tb_arch;
