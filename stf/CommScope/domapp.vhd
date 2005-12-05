-------------------------------------------------------------------------------
-- Title      : CommScope
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : domapp.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2005-12-02
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This is a tool to debug quad 2. It monitors the wire pair
-------------------------------------------------------------------------------
-- Copyright (c) 2003 2004
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 2003-10-23  V01-01-00   thorsten
-- 2004-07-28              thorsten  added communications code  
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.std_logic_arith.ALL;
USE IEEE.std_logic_unsigned.ALL;


ENTITY domapp IS
    PORT (
        -- stripe IO
        CLK_REF           : IN    STD_LOGIC;
        nPOR              : IN    STD_LOGIC;
        nRESET            : INOUT STD_LOGIC;
        -- UART
        UARTRXD           : IN    STD_LOGIC;
        UARTDSRN          : IN    STD_LOGIC;
        UARTCTSN          : IN    STD_LOGIC;
        UARTRIN           : INOUT STD_LOGIC;
        UARTDCDN          : INOUT STD_LOGIC;
        UARTTXD           : OUT   STD_LOGIC;
        UARTRTSN          : OUT   STD_LOGIC;
        UARTDTRN          : OUT   STD_LOGIC;
        -- EBI
        INTEXTPIN         : IN    STD_LOGIC;
        EBIACK            : IN    STD_LOGIC;
        EBIDQ             : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        EBICLK            : OUT   STD_LOGIC;
        EBIWEN            : OUT   STD_LOGIC;
        EBIOEN            : OUT   STD_LOGIC;
        EBIADDR           : OUT   STD_LOGIC_VECTOR(24 DOWNTO 0);
        EBIBE             : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        EBICSN            : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
        -- SDRAM
        SDRAMDQ           : INOUT STD_LOGIC_VECTOR (31 DOWNTO 0);
        SDRAMDQS          : INOUT STD_LOGIC_VECTOR (3 DOWNTO 0);
        SDRAMCLK          : OUT   STD_LOGIC;
        SDRAMCLKN         : OUT   STD_LOGIC;
        SDRAMCLKE         : OUT   STD_LOGIC;
        SDRAMWEN          : OUT   STD_LOGIC;
        SDRAMCASN         : OUT   STD_LOGIC;
        SDRAMRASN         : OUT   STD_LOGIC;
        SDRAMADDR         : OUT   STD_LOGIC_VECTOR (14 DOWNTO 0);
        SDRAMCSN          : OUT   STD_LOGIC_VECTOR (1 DOWNTO 0);
        SDRAMDQM          : OUT   STD_LOGIC_VECTOR (3 DOWNTO 0);
        -- general FPGA IO
        CLK1p             : IN    STD_LOGIC;
        CLK2p             : IN    STD_LOGIC;
        CLK3p             : IN    STD_LOGIC;
        CLK4p             : IN    STD_LOGIC;
        CLKLK_OUT2p       : OUT   STD_LOGIC;  -- 40MHz outpout for FADC
        -- setup information
        A_nB              : IN    STD_LOGIC;
        COMM_RESET        : OUT   STD_LOGIC;  -- board reset initiated by the communication
        FPGA_LOADED       : OUT   STD_LOGIC;  -- pulled low when FPGA is configured
        -- Communications DAC
        COM_TX_SLEEP      : OUT   STD_LOGIC;
        COM_DB            : OUT   STD_LOGIC_VECTOR (13 DOWNTO 0);
        -- Communications ADC
        COM_AD_D          : IN    STD_LOGIC_VECTOR (11 DOWNTO 0);
        COM_AD_OTR        : IN    STD_LOGIC;
        -- ATWD 0
        ATWD0_D           : IN    STD_LOGIC_VECTOR (9 DOWNTO 0);
        ATWDTrigger_0     : OUT   STD_LOGIC;
        TriggerComplete_0 : IN    STD_LOGIC;
        OutputEnable_0    : OUT   STD_LOGIC;
        CounterClock_0    : OUT   STD_LOGIC;
        ShiftClock_0      : OUT   STD_LOGIC;
        RampSet_0         : OUT   STD_LOGIC;
        ChannelSelect_0   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        ReadWrite_0       : OUT   STD_LOGIC;
        AnalogReset_0     : OUT   STD_LOGIC;
        DigitalReset_0    : OUT   STD_LOGIC;
        DigitalSet_0      : OUT   STD_LOGIC;
        ATWD0VDD_SUP      : OUT   STD_LOGIC;
        -- ATWD 1
        ATWD1_D           : IN    STD_LOGIC_VECTOR (9 DOWNTO 0);
        ATWDTrigger_1     : OUT   STD_LOGIC;
        TriggerComplete_1 : IN    STD_LOGIC;
        OutputEnable_1    : OUT   STD_LOGIC;
        CounterClock_1    : OUT   STD_LOGIC;
        ShiftClock_1      : OUT   STD_LOGIC;
        RampSet_1         : OUT   STD_LOGIC;
        ChannelSelect_1   : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
        ReadWrite_1       : OUT   STD_LOGIC;
        AnalogReset_1     : OUT   STD_LOGIC;
        DigitalReset_1    : OUT   STD_LOGIC;
        DigitalSet_1      : OUT   STD_LOGIC;
        ATWD1VDD_SUP      : OUT   STD_LOGIC;
        -- PLD to FPGA EBI like interface (not fully defined yet)
        PLD_FPGA          : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
        PLD_FPGA_nOE      : IN    STD_LOGIC;
        PLD_FPGA_nWE      : IN    STD_LOGIC;
        PLD_FPGA_BUSY     : OUT   STD_LOGIC;
        -- Test connector (JP13) No defined use for it yet!
        FPGA_D            : OUT   STD_LOGIC_VECTOR (7 DOWNTO 0);
        FPGA_DA           : OUT   STD_LOGIC;
        FPGA_CE           : OUT   STD_LOGIC;
        FPGA_RW           : OUT   STD_LOGIC;
        -- Test connector (JP19)        THERE IS NO 11   11 is CLK1n
        PGM               : OUT   STD_LOGIC_VECTOR (15 DOWNTO 0)
        );
END domapp;


ARCHITECTURE arch_domapp OF domapp IS

    COMPONENT ROC
        PORT (
            CLK : IN  STD_LOGIC;
            RST : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT pll2x
        PORT (
            inclock : IN  STD_LOGIC;
            locked  : OUT STD_LOGIC;
            clock0  : OUT STD_LOGIC;
            clock1  : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT pll4x
        PORT (
            inclock : IN  STD_LOGIC;
            locked  : OUT STD_LOGIC;
            clock1  : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT systimer IS
        PORT (
            CLK     : IN  STD_LOGIC;
            RST     : IN  STD_LOGIC;
            systime : OUT STD_LOGIC_VECTOR (47 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT stripe
        PORT (
            clk_ref          : IN    STD_LOGIC;
            npor             : IN    STD_LOGIC;
            nreset           : INOUT STD_LOGIC;
            uartrxd          : IN    STD_LOGIC;
            uartdsrn         : IN    STD_LOGIC;
            uartctsn         : IN    STD_LOGIC;
            uartrin          : INOUT STD_LOGIC;
            uartdcdn         : INOUT STD_LOGIC;
            uarttxd          : OUT   STD_LOGIC;
            uartrtsn         : OUT   STD_LOGIC;
            uartdtrn         : OUT   STD_LOGIC;
            intextpin        : IN    STD_LOGIC;
            ebiack           : IN    STD_LOGIC;
            ebidq            : INOUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            ebiclk           : OUT   STD_LOGIC;
            ebiwen           : OUT   STD_LOGIC;
            ebioen           : OUT   STD_LOGIC;
            ebiaddr          : OUT   STD_LOGIC_VECTOR(24 DOWNTO 0);
            ebibe            : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            ebicsn           : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            sdramdq          : INOUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            sdramdqs         : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            sdramclk         : OUT   STD_LOGIC;
            sdramclkn        : OUT   STD_LOGIC;
            sdramclke        : OUT   STD_LOGIC;
            sdramwen         : OUT   STD_LOGIC;
            sdramcasn        : OUT   STD_LOGIC;
            sdramrasn        : OUT   STD_LOGIC;
            sdramaddr        : OUT   STD_LOGIC_VECTOR(14 DOWNTO 0);
            sdramcsn         : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            sdramdqm         : OUT   STD_LOGIC_VECTOR(3 DOWNTO 0);
            slavehclk        : IN    STD_LOGIC;
            slavehwrite      : IN    STD_LOGIC;
            slavehreadyi     : IN    STD_LOGIC;
            slavehselreg     : IN    STD_LOGIC;
            slavehsel        : IN    STD_LOGIC;
            slavehmastlock   : IN    STD_LOGIC;
            slavehaddr       : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            slavehtrans      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehsize       : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehburst      : IN    STD_LOGIC_VECTOR(2 DOWNTO 0);
            slavehwdata      : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            slavehreadyo     : OUT   STD_LOGIC;
            slavebuserrint   : OUT   STD_LOGIC;
            slavehresp       : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehrdata      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            masterhclk       : IN    STD_LOGIC;
            masterhready     : IN    STD_LOGIC;
            masterhgrant     : IN    STD_LOGIC;
            masterhrdata     : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            masterhresp      : IN    STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhwrite     : OUT   STD_LOGIC;
            masterhlock      : OUT   STD_LOGIC;
            masterhbusreq    : OUT   STD_LOGIC;
            masterhaddr      : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            masterhburst     : OUT   STD_LOGIC_VECTOR(2 DOWNTO 0);
            masterhsize      : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhtrans     : OUT   STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhwdata     : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            intpld           : IN    STD_LOGIC_VECTOR(5 DOWNTO 0);
            dp0_2_portaclk   : IN    STD_LOGIC;
            dp0_portawe      : IN    STD_LOGIC;
            dp0_portaaddr    : IN    STD_LOGIC_VECTOR(12 DOWNTO 0);
            dp0_portadatain  : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            dp0_portadataout : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            dp1_3_portaclk   : IN    STD_LOGIC;
            dp1_portawe      : IN    STD_LOGIC;
            dp1_portaaddr    : IN    STD_LOGIC_VECTOR(12 DOWNTO 0);
            dp1_portadatain  : IN    STD_LOGIC_VECTOR(31 DOWNTO 0);
            dp1_portadataout : OUT   STD_LOGIC_VECTOR(31 DOWNTO 0);
            gpi              : IN    STD_LOGIC_VECTOR(7 DOWNTO 0);
            gpo              : OUT   STD_LOGIC_VECTOR(7 DOWNTO 0)
            );
    END COMPONENT;

    COMPONENT ahb_slave
        PORT (
            CLK           : IN  STD_LOGIC;
            RST           : IN  STD_LOGIC;
            -- connections to the stripe
            masterhclk    : OUT STD_LOGIC;
            masterhready  : OUT STD_LOGIC;
            masterhgrant  : OUT STD_LOGIC;
            masterhrdata  : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            masterhresp   : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhwrite  : IN  STD_LOGIC;
            masterhlock   : IN  STD_LOGIC;
            masterhbusreq : IN  STD_LOGIC;
            masterhaddr   : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            masterhburst  : IN  STD_LOGIC_VECTOR(2 DOWNTO 0);
            masterhsize   : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhtrans  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            masterhwdata  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- local bus signals
            reg_write     : OUT STD_LOGIC;
            reg_address   : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            reg_wdata     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            reg_rdata     : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            reg_enable    : OUT STD_LOGIC;
            reg_wait_sig  : IN  STD_LOGIC
            );
    END COMPONENT;


    COMPONENT ahb_master
        PORT (
            CLK            : IN  STD_LOGIC;
            RST            : IN  STD_LOGIC;
            -- connections to the stripe
            slavehclk      : OUT STD_LOGIC;
            slavehwrite    : OUT STD_LOGIC;
            slavehreadyi   : OUT STD_LOGIC;
            slavehselreg   : OUT STD_LOGIC;
            slavehsel      : OUT STD_LOGIC;
            slavehmastlock : OUT STD_LOGIC;
            slavehaddr     : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            slavehtrans    : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehsize     : OUT STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehburst    : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            slavehwdata    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            slavehreadyo   : IN  STD_LOGIC;
            slavebuserrint : IN  STD_LOGIC;
            slavehresp     : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            slavehrdata    : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            -- local bus signals
            start_trans    : IN  STD_LOGIC;
            abort_trans    : IN  STD_LOGIC;
            address        : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            ahb_address    : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            wdata          : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wait_sig       : OUT STD_LOGIC;
            ready          : OUT STD_LOGIC;
            trans_length   : IN  INTEGER;
            bus_error      : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT mem_interface
        PORT (
            CLK20        : IN  STD_LOGIC;
            RST          : IN  STD_LOGIC;
            -- enable
            LBM_ptr      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            -- cdata interface A (ping)
            avail1k      : IN  STD_LOGIC;
            fifo_re      : OUT STD_LOGIC;
            fifo_data    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0);
            -- ahb_master interface
            start_trans  : OUT STD_LOGIC;
            abort_trans  : OUT STD_LOGIC;
            address      : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            ahb_address  : IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
            wdata        : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
            wait_sig     : IN  STD_LOGIC;
            ready        : IN  STD_LOGIC;
            trans_length : OUT INTEGER;
            bus_error    : IN  STD_LOGIC;
            -- test connector
            TC           : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;




    COMPONENT adc2fifo
        PORT (
            CLK              : IN  STD_LOGIC;
            RST              : IN  STD_LOGIC;
            -- launch
            launch           : IN  STD_LOGIC;
            -- Communications ADC
            COM_AD_D         : IN  STD_LOGIC_VECTOR (11 DOWNTO 0);
            COM_AD_OTR       : IN  STD_LOGIC;
            -- fifo
            fifo_data        : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
            fifo_rd          : IN  STD_LOGIC;
            fifo_almost_full : OUT STD_LOGIC
            );
    END COMPONENT;

    COMPONENT tx_wave
        PORT (
            data      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
            wraddress : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
            rdaddress : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
            wren      : IN  STD_LOGIC;
            clock     : IN  STD_LOGIC;
            q         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
            );
    END COMPONENT;



    -- gerneal siganls
    SIGNAL low  : STD_LOGIC;
    SIGNAL high : STD_LOGIC;

    SIGNAL CLK20   : STD_LOGIC;
    SIGNAL CLK40   : STD_LOGIC;
    SIGNAL CLK80   : STD_LOGIC;
    SIGNAL RST     : STD_LOGIC;
    SIGNAL systime : STD_LOGIC_VECTOR (47 DOWNTO 0);

    SIGNAL TC : STD_LOGIC_VECTOR (7 DOWNTO 0);

    -- PLD to STRIPE bridge
    SIGNAL slavehclk      : STD_LOGIC;
    SIGNAL slavehwrite    : STD_LOGIC;
    SIGNAL slavehreadyi   : STD_LOGIC;
    SIGNAL slavehselreg   : STD_LOGIC;
    SIGNAL slavehsel      : STD_LOGIC;
    SIGNAL slavehmastlock : STD_LOGIC;
    SIGNAL slavehaddr     : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL slavehtrans    : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL slavehsize     : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL slavehburst    : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL slavehwdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL slavehreadyo   : STD_LOGIC;
    SIGNAL slavebuserrint : STD_LOGIC;
    SIGNAL slavehresp     : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL slavehrdata    : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- STRIPE to PLD bridge
    SIGNAL masterhclk    : STD_LOGIC;
    SIGNAL masterhready  : STD_LOGIC;
    SIGNAL masterhgrant  : STD_LOGIC;
    SIGNAL masterhrdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL masterhresp   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL masterhwrite  : STD_LOGIC;
    SIGNAL masterhlock   : STD_LOGIC;
    SIGNAL masterhbusreq : STD_LOGIC;
    SIGNAL masterhaddr   : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL masterhburst  : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL masterhsize   : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL masterhtrans  : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL masterhwdata  : STD_LOGIC_VECTOR(31 DOWNTO 0);

    -- interrupts
    SIGNAL intpld : STD_LOGIC_VECTOR(5 DOWNTO 0);
    -- GP stripe IO
    SIGNAL gpi    : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL gpo    : STD_LOGIC_VECTOR(7 DOWNTO 0);


    -- local bus signals for the AHB master interface
    SIGNAL start_trans  : STD_LOGIC;
    SIGNAL abort_trans  : STD_LOGIC;
    SIGNAL address      : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL ahb_address  : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wdata        : STD_LOGIC_VECTOR(31 DOWNTO 0);
    SIGNAL wait_sig     : STD_LOGIC;
    SIGNAL ready        : STD_LOGIC;
    SIGNAL trans_length : INTEGER;
    SIGNAL bus_error    : STD_LOGIC;

    -- fifo interface
    SIGNAL CLK20n           : STD_LOGIC;
    SIGNAL fifo_data        : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL fifo_rd          : STD_LOGIC;
    SIGNAL fifo_almost_full : STD_LOGIC;

    SIGNAL adc_launch : STD_LOGIC;
    SIGNAL dac_launch : STD_LOGIC;

    SIGNAL tx_buff_we   : STD_LOGIC;
    SIGNAL tx_buff_addr : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tx_buff_data : STD_LOGIC_VECTOR (7 DOWNTO 0);

    SIGNAL tx_addr : STD_LOGIC_VECTOR (7 DOWNTO 0);
    SIGNAL tx_data : STD_LOGIC_VECTOR (7 DOWNTO 0);

    SIGNAL reg_wdata   : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL reg_address : STD_LOGIC_VECTOR (31 DOWNTO 0);
    SIGNAL reg_enable  : STD_LOGIC;
    SIGNAL reg_write   : STD_LOGIC;
    
BEGIN
    -- general
    low  <= '0';
    high <= '1';

    -- STRIPE to PLD bridge
    masterhclk <= CLK20;


    inst_ROC : ROC
        PORT MAP (
            CLK => CLK20,
            RST => RST
            );

    inst_pll2x : pll2x
        PORT MAP (
            inclock => CLK2p,
            locked  => OPEN,
            clock0  => CLK20,
            clock1  => CLK40
            );

    CLKLK_OUT2p <= CLK40;

    inst_pll4x : pll4x
        PORT MAP (
            inclock => CLK1p,
            locked  => OPEN,
            clock1  => CLK80
            );

    inst_systimer : systimer
        PORT MAP (
            CLK     => CLK40,
            RST     => RST,
            systime => systime
            );

    stripe_inst : stripe
        PORT MAP (
            clk_ref          => CLK_REF,
            npor             => nPOR,
            nreset           => nRESET,
            uartrxd          => UARTRXD,
            uartdsrn         => UARTDSRN,
            uartctsn         => UARTCTSN,
            uartrin          => UARTRIN,
            uartdcdn         => UARTDCDN,
            uarttxd          => UARTTXD,
            uartrtsn         => UARTRTSN,
            uartdtrn         => UARTDTRN,
            intextpin        => INTEXTPIN,
            ebiack           => EBIACK,
            ebidq            => EBIDQ,
            ebiclk           => EBICLK,
            ebiwen           => EBIWEN,
            ebioen           => EBIOEN,
            ebiaddr          => EBIADDR,
            ebibe            => EBIBE,
            ebicsn           => EBICSN,
            sdramdq          => SDRAMDQ,
            sdramdqs         => SDRAMDQS,
            sdramclk         => SDRAMCLK,
            sdramclkn        => SDRAMCLKN,
            sdramclke        => SDRAMCLKE,
            sdramwen         => SDRAMWEN,
            sdramcasn        => SDRAMCASN,
            sdramrasn        => SDRAMRASN,
            sdramaddr        => SDRAMADDR,
            sdramcsn         => SDRAMCSN,
            sdramdqm         => SDRAMDQM,
            slavehclk        => slavehclk,
            slavehwrite      => slavehwrite,
            slavehreadyi     => slavehreadyi,
            slavehselreg     => slavehselreg,
            slavehsel        => slavehsel,
            slavehmastlock   => slavehmastlock,
            slavehaddr       => slavehaddr,
            slavehtrans      => slavehtrans,
            slavehsize       => slavehsize,
            slavehburst      => slavehburst,
            slavehwdata      => slavehwdata,
            slavehreadyo     => slavehreadyo,
            slavebuserrint   => slavebuserrint,
            slavehresp       => slavehresp,
            slavehrdata      => slavehrdata,
            masterhclk       => masterhclk,
            masterhready     => masterhready,
            masterhgrant     => masterhgrant,
            masterhrdata     => masterhrdata,
            masterhresp      => masterhresp,
            masterhwrite     => masterhwrite,
            masterhlock      => masterhlock,
            masterhbusreq    => masterhbusreq,
            masterhaddr      => masterhaddr,
            masterhburst     => masterhburst,
            masterhsize      => masterhsize,
            masterhtrans     => masterhtrans,
            masterhwdata     => masterhwdata,
            intpld           => (OTHERS => '0'),
            dp0_2_portaclk   => CLK20,
            dp0_portawe      => '0',
            dp0_portaaddr    => (OTHERS => '0'),
            dp0_portadatain  => (OTHERS => '0'),
            dp0_portadataout => OPEN,
            dp1_3_portaclk   => clk20,
            dp1_portawe      => '0',
            dp1_portaaddr    => (OTHERS => '0'),
            dp1_portadatain  => (OTHERS => '0'),
            dp1_portadataout => OPEN,
            gpi              => (OTHERS => '0'),
            gpo              => OPEN
            );

    -- stripe interface
    inst_ahb_slave : ahb_slave
        PORT MAP (
            CLK           => CLK20,
            RST           => RST,
            -- connections to the stripe
            masterhclk    => masterhclk,
            masterhready  => masterhready,
            masterhgrant  => masterhgrant,
            masterhrdata  => masterhrdata,
            masterhresp   => masterhresp,
            masterhwrite  => masterhwrite,
            masterhlock   => masterhlock,
            masterhbusreq => masterhbusreq,
            masterhaddr   => masterhaddr,
            masterhburst  => masterhburst,
            masterhsize   => masterhsize,
            masterhtrans  => masterhtrans,
            masterhwdata  => masterhwdata,
            -- local bus signals
            reg_write     => reg_write,
            reg_address   => reg_address,
            reg_wdata     => reg_wdata,
            reg_rdata     => (OTHERS => '1'),
            reg_enable    => reg_enable,
            reg_wait_sig  => '1'
            );

    slavereg : PROCESS (CLK20, RST)
    BEGIN  -- PROCESS slavereg
        IF RST = '1' THEN               -- asynchronous reset (active high)
            adc_launch <= '0';
            dac_launch <= '0';
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            tx_buff_we <= '0';

            IF reg_enable = '1' THEN
                IF reg_address(10) = '0' THEN  -- registers
                    IF reg_write = '1' THEN
                        IF reg_address (9 DOWNTO 2) = "00000000" THEN
                            IF reg_wdata(0) = '1' THEN
                                adc_launch <= '1';
                            END IF;
                            IF reg_wdata(1) = '1' THEN
                                dac_launch <= '1';
                            END IF;
                        END IF;
                    END IF;
                ELSE
                    IF reg_write = '1' THEN
                        -- write to tx BUFFER
                        tx_buff_data <= reg_wdata (7 DOWNTO 0);
                        tx_buff_addr <= reg_address (9 DOWNTO 2);
                        tx_buff_we   <= '1';
                    END IF;
                END IF;
            END IF;
        END IF;
    END PROCESS slavereg;

    PROCESS (CLK20, RST)
    BEGIN  -- PROCESS
        IF RST = '1' THEN               -- asynchronous reset (active high)
            tx_addr <= "00000000";
        ELSIF CLK20'EVENT AND CLK20 = '1' THEN  -- rising clock edge
            IF dac_launch = '1' THEN
                IF tx_addr = "11111111" THEN
                    NULL;
                ELSE
                    tx_addr <= tx_addr + 1;
                END IF;
            END IF;
            COM_DB(13 DOWNTO 6) <= tx_data;
        END IF;
    END PROCESS;
    COM_TX_SLEEP <= '0';

    mem_interface_nst : mem_interface
        PORT MAP (
            CLK20        => CLK20,
            RST          => RST,
            -- enable
            LBM_ptr      => OPEN,
            -- cdata interface A (ping)
            avail1k      => fifo_almost_full,
            fifo_re      => fifo_rd,
            fifo_data    => fifo_data,
            -- ahb_master interface
            start_trans  => start_trans,
            abort_trans  => abort_trans,
            address      => address,
            ahb_address  => ahb_address,
            wdata        => wdata,
            wait_sig     => wait_sig,
            ready        => ready,
            trans_length => trans_length,
            bus_error    => bus_error,
            -- test connector
            TC           => OPEN
            );

    
    CLK20n <= NOT CLK20;
    inst_ahb_master : ahb_master
        PORT MAP (
            CLK            => CLK20n,
            RST            => RST,
            -- connections to the stripe
            slavehclk      => slavehclk,
            slavehwrite    => slavehwrite,
            slavehreadyi   => slavehreadyi,
            slavehselreg   => slavehselreg,
            slavehsel      => slavehsel,
            slavehmastlock => slavehmastlock,
            slavehaddr     => slavehaddr,
            slavehtrans    => slavehtrans,
            slavehsize     => slavehsize,
            slavehburst    => slavehburst,
            slavehwdata    => slavehwdata,
            slavehreadyo   => slavehreadyo,
            slavebuserrint => slavebuserrint,
            slavehresp     => slavehresp,
            slavehrdata    => slavehrdata,
            -- local bus signals
            start_trans    => start_trans,
            abort_trans    => abort_trans,
            address        => address,
            ahb_address    => ahb_address,
            wdata          => wdata,
            wait_sig       => wait_sig,
            ready          => ready,
            trans_length   => trans_length,
            bus_error      => bus_error
            );



    adc2fifo_inst : adc2fifo
        PORT MAP (
            CLK              => CLK20,
            RST              => RST,
            -- launch
            launch           => adc_launch,
            -- Communications ADC
            COM_AD_D         => COM_AD_D,
            COM_AD_OTR       => COM_AD_OTR,
            -- fifo
            fifo_data        => fifo_data,
            fifo_rd          => fifo_rd,
            fifo_almost_full => fifo_almost_full
            );
    -- adc_launch <= '1' WHEN gpo = x"a5" ELSE '0';

    tx_wave_inst : tx_wave
        PORT MAP (
            data      => tx_buff_data,
            wraddress => tx_buff_addr,
            rdaddress => tx_addr,
            wren      => tx_buff_we,
            clock     => CLK20,
            q         => tx_data
            );



    --COM_DB <= (OTHERS => 'Z');

    -- FPGA loaded output to be read by the CPU through the CPLD
    FPGA_LOADED <= '0';
    COMM_RESET  <= '1';

    -- unused pins
    -- PLD to FPGA EBI like interface (not fully defined yet)
    PLD_FPGA          <= (OTHERS => 'Z');
    PLD_FPGA_BUSY     <= 'Z';
    -- Test connector (JP13) No defined use for it yet!
    FPGA_D            <= (OTHERS => 'Z');
    FPGA_DA           <= 'Z';
    FPGA_CE           <= 'Z';
    FPGA_RW           <= 'Z';
    -- Test connector (JP19)
    PGM(13 DOWNTO 0)  <= (OTHERS => 'Z');
    PGM(15 DOWNTO 14) <= "01";


END arch_domapp;
