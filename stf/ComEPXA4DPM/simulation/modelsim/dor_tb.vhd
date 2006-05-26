-- dor testbench
-- contains DOR design and pci_testbench

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
LIBRARY pci_testbench;
USE pci_testbench.pkg_pci_testb.ALL;


ENTITY dor_tb IS
    PORT (
        CLK20   : IN  STD_LOGIC;
        COM_DAC : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        COM_ADC : IN  STD_LOGIC_VECTOR (11 DOWNTO 0)
        );
END dor_tb;


ARCHITECTURE dor_tb_arch OF dor_tb IS

    -- PCI core testbench
    FOR testb_inst : pci_testb USE ENTITY pci_testbench.pci_testb(testbench);

    -- These constants control are used to setup PCI Testbench
    CONSTANT BUS_WIDTH       : INTEGER := 32;  -- PCI bus data path width : 32 or 64
    CONSTANT EXTERNAL_AGENTS : INTEGER := 1;  -- # of user PCI agents connected       

    -- PCI bus signals
    SIGNAL pci_clk, pci_rst, pci_par, pci_par64, pci_m66en : STD_LOGIC;
    SIGNAL pci_inta          : STD_LOGIC;
    SIGNAL pci_perr, pci_serr, pci_pme, pci_clkrun         : STD_LOGIC;
    SIGNAL pci_frame, pci_devsel, pci_trdy, pci_irdy       : STD_LOGIC;
    SIGNAL pci_stop, pci_ack64, pci_req64, pci_lock        : STD_LOGIC;
    SIGNAL pci_cbe                                         : STD_LOGIC_VECTOR (BUS_WIDTH/8-1 DOWNTO 0);
    SIGNAL pci_ad                                          : STD_LOGIC_VECTOR (BUS_WIDTH-1 DOWNTO 0);
    SIGNAL pci_req, pci_gnt, pci_idsel                     : STD_LOGIC_VECTOR (EXTERNAL_AGENTS DOWNTO 1);

    -- PCI bus state (decoded)
    SIGNAL bus_command : pci_command;



    -- DOR design
    COMPONENT DOR
        PORT (
            rst         : IN    STD_LOGIC;
            idsel_pci   : IN    STD_LOGIC;
            lock_pci    : IN    STD_LOGIC;
            gnt_pci     : IN    STD_LOGIC;
            clk_pci     : IN    STD_LOGIC;
            rs4_out0    : IN    STD_LOGIC;
            rs4_out1    : IN    STD_LOGIC;
            rs4_out2    : IN    STD_LOGIC;
            rs4_out3    : IN    STD_LOGIC;
            nplgd_01    : IN    STD_LOGIC;
            nplgd_23    : IN    STD_LOGIC;
            rxd0        : IN    STD_LOGIC;
            cts0        : IN    STD_LOGIC;
            rxd1        : IN    STD_LOGIC;
            rts1        : IN    STD_LOGIC;
            pps         : IN    STD_LOGIC;
            tstrg       : IN    STD_LOGIC;
            rem_nres    : IN    STD_LOGIC;
            fl_nby      : IN    STD_LOGIC;
            mhz20osc    : IN    STD_LOGIC;
            mhz10       : IN    STD_LOGIC;
            mhz10_io    : IN    STD_LOGIC;
            frame_pci   : INOUT STD_LOGIC;
            devsel_pci  : INOUT STD_LOGIC;
            par_pci     : INOUT STD_LOGIC;
            perr_pci    : INOUT STD_LOGIC;
            serr_pci    : INOUT STD_LOGIC;
            req_pci     : INOUT STD_LOGIC;
            m66en_pci   : INOUT STD_LOGIC;
            stop_pci    : INOUT STD_LOGIC;
            irdy_pci    : INOUT STD_LOGIC;
            trdy_pci    : INOUT STD_LOGIC;
            inta_pci    : INOUT STD_LOGIC;
            ad_pci      : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            adc0_d      : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            adc1_d      : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            adc2_d      : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            adc3_d      : IN    STD_LOGIC_VECTOR(11 DOWNTO 0);
            adc_sd      : IN    STD_LOGIC_VECTOR(3 DOWNTO 0);
            cbe_pci     : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dq          : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            fl_adr      : INOUT STD_LOGIC_VECTOR(20 DOWNTO 17);
            fpga_io     : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            dac0_clk    : OUT   STD_LOGIC;
            dac0_slp    : OUT   STD_LOGIC;
            rs4_ren0    : OUT   STD_LOGIC;
            rs4_in0     : OUT   STD_LOGIC;
            rs4_den0    : OUT   STD_LOGIC;
            npon_ch0    : OUT   STD_LOGIC;
            ntx_led_ch0 : OUT   STD_LOGIC;
            nrx_led_ch0 : OUT   STD_LOGIC;
            adc0_clk    : OUT   STD_LOGIC;
            rs4_ren1    : OUT   STD_LOGIC;
            rs4_in1     : OUT   STD_LOGIC;
            rs4_den1    : OUT   STD_LOGIC;
            npon_ch1    : OUT   STD_LOGIC;
            ntx_led_ch1 : OUT   STD_LOGIC;
            nrx_led_ch1 : OUT   STD_LOGIC;
            dac1_clk    : OUT   STD_LOGIC;
            dac1_slp    : OUT   STD_LOGIC;
            adc1_clk    : OUT   STD_LOGIC;
            rs4_ren2    : OUT   STD_LOGIC;
            rs4_in2     : OUT   STD_LOGIC;
            rs4_den2    : OUT   STD_LOGIC;
            npon_ch2    : OUT   STD_LOGIC;
            ntx_led_ch2 : OUT   STD_LOGIC;
            nrx_led_ch2 : OUT   STD_LOGIC;
            dac2_clk    : OUT   STD_LOGIC;
            dac2_slp    : OUT   STD_LOGIC;
            adc2_clk    : OUT   STD_LOGIC;
            rs4_ren3    : OUT   STD_LOGIC;
            rs4_in3     : OUT   STD_LOGIC;
            rs4_den3    : OUT   STD_LOGIC;
            npon_ch3    : OUT   STD_LOGIC;
            ntx_led_ch3 : OUT   STD_LOGIC;
            nrx_led_ch3 : OUT   STD_LOGIC;
            dac3_clk    : OUT   STD_LOGIC;
            dac3_slp    : OUT   STD_LOGIC;
            adc3_clk    : OUT   STD_LOGIC;
            fl_nbyte    : OUT   STD_LOGIC;
            fl_noe      : OUT   STD_LOGIC;
            fl_nwe      : OUT   STD_LOGIC;
            fl_nce      : OUT   STD_LOGIC;
            fl_reset    : OUT   STD_LOGIC;
            fl_prot     : OUT   STD_LOGIC;
            sr_nce0     : OUT   STD_LOGIC;
            sr_noe0     : OUT   STD_LOGIC;
            sr_nbhe0    : OUT   STD_LOGIC;
            sr_nble0    : OUT   STD_LOGIC;
            sr_nce1     : OUT   STD_LOGIC;
            sr_noe1     : OUT   STD_LOGIC;
            sr_nbhe1    : OUT   STD_LOGIC;
            sr_nble1    : OUT   STD_LOGIC;
            sr_nwe0     : OUT   STD_LOGIC;
            sr_nwe1     : OUT   STD_LOGIC;
            fl_nwp      : OUT   STD_LOGIC;
            nreconfig   : OUT   STD_LOGIC;
            fpga_pld    : OUT   STD_LOGIC;
            txd1        : OUT   STD_LOGIC;
            txd0        : OUT   STD_LOGIC;
            rts0        : OUT   STD_LOGIC;
            cts1        : OUT   STD_LOGIC;
            dac_sclk    : OUT   STD_LOGIC;
            dac_din     : OUT   STD_LOGIC;
            dacnsync    : OUT   STD_LOGIC;
            pci_acc     : OUT   STD_LOGIC;
            rj45_out    : OUT   STD_LOGIC;
            adc_sclk    : OUT   STD_LOGIC;
            adc_ncs     : OUT   STD_LOGIC;
            toyo_on     : OUT   STD_LOGIC;
            adr         : OUT   STD_LOGIC_VECTOR(18 DOWNTO 0);
            dac0_db     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            dac1_db     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            dac2_db     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0);
            dac3_db     : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0)
            );
    END COMPONENT;

    SIGNAL GND : std_logic;
    SIGNAL dummy_adc : STD_LOGIC_VECTOR (11 DOWNTO 0);
    SIGNAL dummy : STD_LOGIC_VECTOR (3 DOWNTO 0);

BEGIN  -- dor_tb_arch


    ---------------------------------------------------------
    -- PCI Testbench instance
    --
    -- Note that optional signals must be left unconnected
    -- if you do not use them in your design (64-bit control,
    -- interrupts,PME#,CLRUN#,...)
    --
    ---------------------------------------------------------

    testb_inst : pci_testb
        GENERIC MAP
        (
            BUS_WIDTH       => BUS_WIDTH,
            BUS_FREQUENCY   => 33,
            EXTERNAL_AGENTS => EXTERNAL_AGENTS,
            BAR0_SIZE       => 8,
            BAR1_SIZE       => 8,
            BAR2_SIZE       => 8,
            BAR3_SIZE       => 8,
            BAR4_SIZE       => 8,
            BAR5_SIZE       => 8,
            RAW_DATA_FORMAT => 0,
            EMULATE_PULLUP  => 1
            )
        PORT MAP
        (
            pci_clk         => pci_clk,
            pci_rst         => pci_rst,
            pci_cbe         => pci_cbe,
            pci_ad          => pci_ad,
            pci_par         => pci_par,
            pci_frame       => pci_frame,
            pci_devsel      => pci_devsel,
            pci_trdy        => pci_trdy,
            pci_irdy        => pci_irdy,
            pci_stop        => pci_stop,
            pci_inta        => pci_inta,
            pci_perr        => pci_perr,
            pci_serr        => pci_serr,
            pci_lock        => pci_lock,
            pci_m66en       => pci_m66en,
            pci_req         => pci_req,
            pci_gnt         => pci_gnt,
            pci_idsel       => pci_idsel,
            bus_command     => bus_command
            );

    ---------------------------------------------------------
    -- User PCI agent (connected as device #1 on PCI bus)
    --
    ---------------------------------------------------------

    -- REQ# is not necessary for a target device and must be tied, grant can be left unconnected
    -- pci_req(1) <= '1';


GND <= '0';
    dummy_adc <= (OTHERS=>'0');
    dummy <= (OTHERS=>'0');

 --   pci_inta <= '1';

  --  pci_cbe <= "H0H0";

    -- DOR
    DOR_inst : DOR
        PORT MAP (
            rst         => pci_rst,
            idsel_pci   => pci_idsel(1),
            lock_pci    => pci_lock,
            gnt_pci     => pci_gnt(1),
            clk_pci     => pci_clk,
            rs4_out0    => GND,
            rs4_out1    => GND,
            rs4_out2    => GND,
            rs4_out3    => GND,
            nplgd_01    => GND,
            nplgd_23    => GND,
            rxd0        => GND,
            cts0        => GND,
            rxd1        => GND,
            rts1        => GND,
            pps         => GND,
            tstrg       => GND,
            rem_nres    => GND,
            fl_nby      => GND,
            mhz20osc    => CLK20,
            mhz10       => CLK20,
            mhz10_io    => CLK20,
            frame_pci   => pci_frame,
            devsel_pci  => pci_devsel,
            par_pci     => pci_par,
            perr_pci    => pci_perr,
            serr_pci    => pci_serr,
            req_pci     => pci_req(1),
            m66en_pci   => pci_m66en,
            stop_pci    => pci_stop,
            irdy_pci    => pci_irdy,
            trdy_pci    => pci_trdy,
            inta_pci    => pci_inta,
            ad_pci      => pci_ad,
            adc0_d      => COM_ADC,
            adc1_d      => dummy_adc,
            adc2_d      => dummy_adc,
            adc3_d      => dummy_adc,
            adc_sd      => dummy,
            cbe_pci     => pci_cbe,
            dq          => OPEN,
            fl_adr      => OPEN,
            fpga_io     => OPEN,
            dac0_clk    => OPEN,
            dac0_slp    => OPEN,
            rs4_ren0    => OPEN,
            rs4_in0     => OPEN,
            rs4_den0    => OPEN,
            npon_ch0    => OPEN,
            ntx_led_ch0 => OPEN,
            nrx_led_ch0 => OPEN,
            adc0_clk    => OPEN,
            rs4_ren1    => OPEN,
            rs4_in1     => OPEN,
            rs4_den1    => OPEN,
            npon_ch1    => OPEN,
            ntx_led_ch1 => OPEN,
            nrx_led_ch1 => OPEN,
            dac1_clk    => OPEN,
            dac1_slp    => OPEN,
            adc1_clk    => OPEN,
            rs4_ren2    => OPEN,
            rs4_in2     => OPEN,
            rs4_den2    => OPEN,
            npon_ch2    => OPEN,
            ntx_led_ch2 => OPEN,
            nrx_led_ch2 => OPEN,
            dac2_clk    => OPEN,
            dac2_slp    => OPEN,
            adc2_clk    => OPEN,
            rs4_ren3    => OPEN,
            rs4_in3     => OPEN,
            rs4_den3    => OPEN,
            npon_ch3    => OPEN,
            ntx_led_ch3 => OPEN,
            nrx_led_ch3 => OPEN,
            dac3_clk    => OPEN,
            dac3_slp    => OPEN,
            adc3_clk    => OPEN,
            fl_nbyte    => OPEN,
            fl_noe      => OPEN,
            fl_nwe      => OPEN,
            fl_nce      => OPEN,
            fl_reset    => OPEN,
            fl_prot     => OPEN,
            sr_nce0     => OPEN,
            sr_noe0     => OPEN,
            sr_nbhe0    => OPEN,
            sr_nble0    => OPEN,
            sr_nce1     => OPEN,
            sr_noe1     => OPEN,
            sr_nbhe1    => OPEN,
            sr_nble1    => OPEN,
            sr_nwe0     => OPEN,
            sr_nwe1     => OPEN,
            fl_nwp      => OPEN,
            nreconfig   => OPEN,
            fpga_pld    => OPEN,
            txd1        => OPEN,
            txd0        => OPEN,
            rts0        => OPEN,
            cts1        => OPEN,
            dac_sclk    => OPEN,
            dac_din     => OPEN,
            dacnsync    => OPEN,
            pci_acc     => OPEN,
            rj45_out    => OPEN,
            adc_sclk    => OPEN,
            adc_ncs     => OPEN,
            toyo_on     => OPEN,
            adr         => OPEN,
            dac0_db     => COM_DAC,
            dac1_db     => OPEN,
            dac2_db     => OPEN,
            dac3_db     => OPEN
            );




END dor_tb_arch;
