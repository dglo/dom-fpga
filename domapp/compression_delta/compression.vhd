-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : compressor_top_synch.vhd
-- Author     : joshua sopher
-- Company    : LBNL
-- Created    : 
-- Last update: june 28 2004
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This design is the interface between the compressor and the LBM controller
--				It writes compressed data into RAM, which is read out by LbmRamAddrExt. 		 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    	Description
-- may 15				Joshua Sopher   modified to put a charge stamp in the Header
--										and the two msbytes 0f the timestamp in the header
--										for use by software only. Not transmitted usually.
-----------------------------------------------------------------------------------------------------------
LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;  
USE WORK.icecube_data_types.all;
USE WORK.ctrl_data_types.all;


ENTITY compression IS
GENERIC (
		FADC_WIDTH		: INTEGER := 10
		);
	PORT(
-- system signals
-- reset 
		rst				: IN	STD_LOGIC; 
		clk20			: IN	STD_LOGIC;		
		clk40		 	: IN	STD_LOGIC;		
-----------------
-- CPU register signals
		Compr_ctrl		: IN Compr_struct;	
------------------
-- interface signals with the fadc and atwd buffers 
-- BfrDav
		data_avail_in	: IN	STD_LOGIC;					    
-- BfrReadDone	
		read_done_in   	: OUT	STD_LOGIC;					   
-- Header	
		 Header_in 		: IN 	HEADER_VECTOR;
-- AtwdBfrAddr	
  		ATWD_addr_in	: OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 
-- AtwdData 
 		ATWD_data_in	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
-- FadcBfrAddr	
  		FADC_addr_in	: OUT	STD_LOGIC_VECTOR (6 DOWNTO 0); 
-- FadcData
		Fadc_data_in	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
------------------
-- interface signals with the LBM_WRITE module
-- Ram must be readout before the next buffer read can be done.

-- Handshake signals
-- BfrDavOut 	
		data_avail_out 	: OUT STD_LOGIC  ;
-- LbmReadDone	
		read_done_out	: IN	STD_LOGIC;	
-- RamDavOut 
 		compr_avail_out	: OUT STD_LOGIC  ;		

-- Compression signals 
		compr_size		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
-- LbmRamAddrExt 
		compr_addr		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
-- LBMDataOut	
		compr_data	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
		
-- UnCmprHeader 
  		Header_out		: OUT	HEADER_VECTOR; 
-- AtwdBfrAddrExt	
  		ATWD_addr_out	: IN	STD_LOGIC_VECTOR (7 DOWNTO 0);  
-- UnCmprAtwdData	
  		ATWD_data_out	: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0); 
-- FadcBfrAddrExt 
  		Fadc_addr_out	: IN	STD_LOGIC_VECTOR (6 DOWNTO 0);  
-- UnCmprFadcData	
  		Fadc_data_out	: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);  
-- ComprData,  test connector signals
		TC 				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)  

	);



END compression ;

----*************************************************************
ARCHITECTURE rtl OF compression IS
	SIGNAL  compr_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL  atwd_size		: STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL  l_c				: STD_LOGIC_VECTOR (1 DOWNTO 0); 
  	SIGNAL  compressed_data	: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  charge_stamp	: STD_LOGIC_VECTOR (31 DOWNTO 0); 
	SIGNAL  time_stamp		: STD_LOGIC_VECTOR (47 DOWNTO 0); 
	SIGNAL  trig_word		: STD_LOGIC_VECTOR (15 DOWNTO 0); 
	SIGNAL  atwd_avail 		: STD_LOGIC; 
	SIGNAL  fadc_avail 		: STD_LOGIC; 
	SIGNAL  atwd_a_b 		: STD_LOGIC; 
	SIGNAL  ram_dav 		: STD_LOGIC; 
	SIGNAL  compr_active 	: STD_LOGIC; 
	SIGNAL  ring_read_en 	: STD_LOGIC; 
	SIGNAL  bfr_done_prev 	: STD_LOGIC; 
	SIGNAL  bfr_dav_edge 	: STD_LOGIC; 




	COMPONENT compressor_delta_in
	PORT(
-- system signals
		reset				: IN	STD_LOGIC;
		clk20			   	: IN	STD_LOGIC;		
		clk40		   		: IN	STD_LOGIC;		
------------------
-- interface signals with the fadc and atwd buffers 
		FadcData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); -- 256 FADC words are contained in 128 long words in the FADC bfr. 
 		AtwdData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); -- 128 to 512 ATWD words are contained in 64 to 256 long words in the ATWD bfr.
		BfrDav				: IN	STD_LOGIC;					    -- generated when the buffer is ready to read 

  		ComprMode			: IN	STD_LOGIC_VECTOR (1 DOWNTO 0); -- defines if compr and/or uncompr data is outputted
 		AtwdAvail			: IN 	STD_LOGIC;
		FadcAvail			: IN 	STD_LOGIC;
		Atwd_AB 			: IN 	STD_LOGIC;
		AtwdSize			: IN 	STD_LOGIC_VECTOR (1 DOWNTO 0);
 		Header				: IN 	HEADER_VECTOR;					--!! Uncomment out
--
		BfrReadDone	   		: OUT	STD_LOGIC;					       
  		FadcBfrAddr			: OUT	STD_LOGIC_VECTOR (6 DOWNTO 0);  -- 7 changed to 6
  		AtwdBfrAddr			: OUT	STD_LOGIC_VECTOR (7 DOWNTO 0);  -- 8 changed to 7

------------------
-- interface signals with Ram to LBM write module
-- used to generate BfrReadDone. Ram must be readout before the next 
-- buffer read can be done.
		LbmReadDone			: IN	STD_LOGIC;	
		RamDav				: IN	STD_LOGIC;					    

  		FadcBfrAddrExt		: IN	STD_LOGIC_VECTOR (6 DOWNTO 0);  
  		AtwdBfrAddrExt		: IN	STD_LOGIC_VECTOR (7 DOWNTO 0);  
  		UnCmprFadcData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0); -- uncomment this line before compiling into top entity
  		UnCmprAtwdData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);  -- uncomment this line before compiling into top entity
  		UnCmprHeader		: OUT	HEADER_VECTOR;   				--!! Uncomment out 

------------------       
-- interface signals with the compressor output module
        ComprActive			: OUT   STD_LOGIC ;  
        ComprDoneStrb		: OUT   STD_LOGIC ;    
        ComprDataOut		: OUT   STD_LOGIC_VECTOR (7 DOWNTO 0) ;     
		RingReadEn			: OUT	STD_LOGIC;		  

--------------------
-- test signals
--      FadcDataOut		: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     
        DataNew 			: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     
        DataOld 			: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     
        DataDelta 			: OUT   STD_LOGIC_VECTOR (10 DOWNTO 0) ;     
        DataDeltaRing		: OUT   STD_LOGIC_VECTOR (11 DOWNTO 0) ;     
-----------------
-- test signals 
  		RingData			: OUT	STD_LOGIC_VECTOR (15 DOWNTO 0); 
		Jout				: OUT	INTEGER RANGE 15 DOWNTO 0 ; 
		Iout				: OUT	INTEGER RANGE 17 DOWNTO 0 ; 
		Kout				: OUT	INTEGER RANGE 32 DOWNTO 0 ; 
		Lout				: OUT	INTEGER RANGE 32 DOWNTO 0 ; 
--		Mout				: OUT	INTEGER RANGE 42 DOWNTO 0 ; 
--		Yout				: OUT	INTEGER RANGE 16 DOWNTO 0 ; 
--		Zout				: OUT	INTEGER RANGE 16 DOWNTO 0 ; 
--		Pout				: OUT	INTEGER RANGE 40 DOWNTO 0 ; 

-- test signals for the input buffer interface
		FadcBfrClk	   		: OUT	STD_LOGIC;		 
		AtwdBfrClk	   		: OUT	STD_LOGIC;		   
  		AtwdChNumber		: OUT	STD_LOGIC_VECTOR (2 DOWNTO 0);  

        RingWriteClk		: OUT   STD_LOGIC   
		);

	END COMPONENT;

	COMPONENT compressor_delta_out
	PORT (
		Reset			: IN STD_LOGIC;
		Clk20			: IN STD_LOGIC;
		Clk40			: IN STD_LOGIC;
--

		ComprActive		: IN STD_LOGIC  ; 	
		LbmReadDone		: IN STD_LOGIC  ;	
		RingReadEn 		: IN STD_LOGIC  ; 	
		BfrDav 			: IN STD_LOGIC  ; 	
		ComprMode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0) ; 
		LbmRamAddrExt	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);	 
		ComprData 		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
--
		ChargeStamp		: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
		Timestamp		: IN STD_LOGIC_VECTOR (47 DOWNTO 0); 
		TriggerWord		: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
--		EventType 		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Atwd_AB 		: IN STD_LOGIC;						 
		AtwdAvail		: IN STD_LOGIC;						 
		FadcAvail		: IN STD_LOGIC;						 
		AtwdSize		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);  
		LC				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);	 
-- 		Deadtime		: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
--
		BfrDavOut	 	: OUT STD_LOGIC  ;			
		RamDavOut 		: OUT STD_LOGIC  ;			 
		ComprSize 		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
		RamAddr 		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		RamWe0 			: OUT STD_LOGIC  ;
		RamDataIn		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

		LBMDataOut		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0) 
	);
	END COMPONENT;

	COMPONENT type_analyzer_delta 
	PORT (
		Header_in		: IN HEADER_VECTOR;
		ComprVar		: IN Compr_struct;	

 		ChargeStamp		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
		Timestamp 		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
		TriggerWord 	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		EventType 		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		Atwd_AB 		: OUT STD_LOGIC;
		AtwdAvail		: OUT STD_LOGIC;
		FadcAvail		: OUT STD_LOGIC;
		AtwdSize		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		LC				: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

		ComprMode		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		
		Threshold0		: OUT STD_LOGIC;
		LastOnly		: OUT STD_LOGIC
	);
	END COMPONENT;

--------------------
BEGIN

compressor_delta_in0 : compressor_delta_in PORT MAP
(
-- system signals	
		reset		=> 	rst,
		clk20		=>	clk20,
		clk40		=>  clk40, 	
------------------
-- interface signals with external data buffer
		FadcData	=>	Fadc_data_in,	
 		AtwdData	=>	ATWD_data_in,	
		BfrDav		=>	data_avail_in,
				
		ComprMode	=>	compr_mode,	
 		AtwdAvail	=>	atwd_avail,	
		FadcAvail	=>	fadc_avail,	
		Atwd_AB 	=>	atwd_A_B, 	
		AtwdSize	=>	atwd_size,
		Header		=>	Header_In,		
--
		BfrReadDone	=>  read_done_in, 	
  		FadcBfrAddr	=>	FADC_addr_in,
  		AtwdBfrAddr	=>	ATWD_addr_in,

------------------
-- interface signals with external lbm controller
		LbmReadDone		=> read_done_out,	
		RamDav			=> ram_dav,	
			
  		FadcBfrAddrExt	=> Fadc_addr_out,	
  		AtwdBfrAddrExt	=> ATWD_addr_out,	
  		UnCmprFadcData	=> Fadc_data_out,
  		UnCmprAtwdData	=> ATWD_data_out,	
  		UnCmprHeader	=> Header_out,	

------------------      
-- interface signals with compressor_out_synch
        ComprActive		=> compr_active,		
--      ComprDoneStrb	=> ComprDoneStrb,  -- not used
        ComprDataOut	=> compressed_data,	 
		RingReadEn		=> ring_read_en 		
);

compressor_delta_out0 : compressor_delta_out PORT MAP
(
		Reset			=> 	rst,
		Clk20			=>	clk20,	
		Clk40			=>	Clk40, 
--
		ComprActive		=>	compr_active, 
		LbmReadDone		=>	read_done_out, 	
		RingReadEn		=>	ring_read_en, 
 		BfrDav 			=>	data_avail_in, 	
 		ComprMode		=>	compr_mode, 	
		LbmRamAddrExt	=>	compr_addr, 	
		ComprData 		=>  compressed_data, 
--
		ChargeStamp		=> charge_stamp,
		TimeStamp		=> time_stamp,
		TriggerWord 	=> trig_word,
--		EventType 		
		Atwd_AB 		=> 	atwd_a_b,
		AtwdAvail		=> 	atwd_avail,
		FadcAvail		=> 	fadc_avail,
		AtwdSize		=> 	atwd_size,
		LC				=>	l_c,
-- 		Deadtime		
--
		BfrDavOut 		=>  data_avail_out,
		RamDavOut 		=> 	ram_dav,
		ComprSize 		=>  compr_size,
		LBMDataOut		=>  compr_data
	);

type_analyzer_delta0 : type_analyzer_delta PORT MAP
	(
		Header_in		=>  Header_in,
		ComprVar		=>  Compr_ctrl,

		ChargeStamp		=>  charge_stamp,
		TimeStamp 		=>  time_stamp,
		TriggerWord 	=>  trig_word,
--		EventType 		=>  EventType,
		Atwd_AB 		=>  atwd_a_b,
		AtwdAvail		=>  atwd_avail,
		FadcAvail		=>  fadc_avail,
		AtwdSize		=>  atwd_size,
		LC				=>  l_c,

		ComprMode		=>  compr_mode
--		Threshold0		=>  Threshold0,
--		LastOnly		=>  LastOnly,
--   	Header  		=>  Header
	);

compr_avail_out <= ram_dav;
TC <= compressed_data;

END  rtl;


