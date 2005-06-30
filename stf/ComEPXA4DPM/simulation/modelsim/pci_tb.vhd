------------------------------------------------------------------------------------
--
-- pci_tb.vhd	
--
-- This design is a PCI simulation environment skeleton generated
-- by PCI Testbench Wizard (c) PLD Application 1998-2001 
--
------------------------------------------------------------------------------------

library ieee,pci_testbench;
use ieee.std_logic_1164.all;
use pci_testbench.pkg_pci_testb.all;

entity pci_tb is
	-- Top level simulation environment has no ports
end pci_tb;

------------------------------------------------------------------------------------

architecture structural of pci_tb is
	for testb_inst : pci_testb use entity pci_testbench.pci_testb(testbench);

	-- Declare user components here
	-- ...
	
	-- These constants control are used to setup PCI Testbench
	constant BUS_WIDTH			: integer:=32;		-- PCI bus data path width : 32 or 64
	constant EXTERNAL_AGENTS	: integer:=1;		-- # of user PCI agents connected	
	
	-- PCI bus signals
	signal pci_clk,pci_rst,pci_par,pci_par64,pci_m66en	: std_logic;
	signal pci_inta,pci_intb,pci_intc,pci_intd			: std_logic;
	signal pci_perr,pci_serr,pci_pme,pci_clkrun			: std_logic;
	signal pci_frame,pci_devsel,pci_trdy,pci_irdy		: std_logic;
	signal pci_stop,pci_ack64,pci_req64,pci_lock		: std_logic;
	signal pci_cbe										: std_logic_vector (BUS_WIDTH/8-1 downto 0);
	signal pci_ad										: std_logic_vector (BUS_WIDTH-1 downto 0);
	signal pci_req,pci_gnt,pci_idsel					: std_logic_vector (EXTERNAL_AGENTS downto 1);		
	
	-- PCI bus state (decoded)
	signal bus_command								: pci_command;
	
	-- Declare user signals here
	-- ...
	    		
begin
	
	---------------------------------------------------------
	-- PCI Testbench instance
	--
	-- Note that optional signals must be left unconnected
	-- if you do not use them in your design (64-bit control,
	-- interrupts,PME#,CLRUN#,...)
	--
	---------------------------------------------------------

	testb_inst : pci_testb
	generic map
		(
		BUS_WIDTH		=> BUS_WIDTH,
		BUS_FREQUENCY	=> 33,
		EXTERNAL_AGENTS	=> EXTERNAL_AGENTS,
		BAR0_SIZE		=> 8,
		BAR1_SIZE		=> 8,
		BAR2_SIZE		=> 8,
		BAR3_SIZE		=> 8,
		BAR4_SIZE		=> 8,
		BAR5_SIZE		=> 8,
		RAW_DATA_FORMAT	=> 0,
		EMULATE_PULLUP	=> 1
		)
	port map
		(
		pci_clk			=> pci_clk,
		pci_rst			=> pci_rst,
   		pci_cbe			=> pci_cbe,
		pci_ad			=> pci_ad,
		pci_par			=> pci_par,
		pci_frame		=> pci_frame,
		pci_devsel		=> pci_devsel,
		pci_trdy		=> pci_trdy,
		pci_irdy		=> pci_irdy,
		pci_stop		=> pci_stop,
		pci_ack64		=> pci_ack64,
		pci_req64		=> pci_req64,
		pci_par64		=> pci_par64,
		pci_inta		=> pci_inta,
		pci_intb		=> pci_intb,
		pci_intc		=> pci_intc,
		pci_intd		=> pci_intd,
		pci_perr		=> pci_perr,
		pci_serr		=> pci_serr,
		pci_pme			=> pci_pme,
		pci_clkrun		=> pci_clkrun,
		pci_lock		=> pci_lock,
		pci_m66en		=> pci_m66en,
		pci_req			=> pci_req,
		pci_gnt			=> pci_gnt,
		pci_idsel		=> pci_idsel,
		bus_command		=> bus_command
		);

	---------------------------------------------------------
	-- User PCI agent (connected as device #1 on PCI bus)
	--
	---------------------------------------------------------

	-- REQ# is not necessary for a target device and must be tied, grant can be left unconnected
	pci_req(1) <='1';
	
	-- Replace sample instantiation below with your PCI design
	-- ...
		
--	user_design_inst : my_pci_design
--    port map
--    	(
--		clk		   		=> pci_clk,
--		rst				=> pci_rst,
--		ad_pci			=> pci_ad,
--		cbe_pci			=> pci_cbe,
--		idsel_pci		=> pci_idsel(1),
--		frame_pci		=> pci_frame,
--		irdy_pci		=> pci_irdy,	
--		trdy_pci		=> pci_trdy,
--		devsel_pci		=> pci_devsel,
--		stop_pci		=> pci_stop,
--		par_pci			=> pci_par,
--		perr_pci		=> pci_perr,
--		serr_pci		=> pci_serr,
--		inta_pci		=> pci_inta,
--		lock_pci		=> pci_lock,
--		m66en_pci		=> pci_m66en,
--		
--		-- Add other backend signals here
--		-- ...
--		);
		
end structural;

------------------------------------------------------------------------------------

-- Some simulators require a configuration declaration
configuration cfg_testbench of pci_tb IS
	for structural
	end for;
end;

-- Following lines contain Testbench Wizard parameters, do not edit !
-- PARAM: VERSION 0x0514
-- PARAM: BUSWIDTH 32
-- PARAM: AGENT 0
-- PARAM: LANGUAGE 0
-- PARAM: PULLUP 1

