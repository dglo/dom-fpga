-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : header_vector_converter.vhd
-- Author     : joshua sopher
-- Company    : LBNL
-- Created    : 
-- Last update: june 28 2004
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This design is the interface between the compressor and the header vector
--				It converts the header_vector to its std_vector elements. 		 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    	Description
-- May 13 05			Joshua Sopher	32 bit charge stamp is added
-----------------------------------------------------------------------------------------------------------
LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;  -- use to count std_logic_vectors
USE WORK.icecube_data_types.all;
USE WORK.ctrl_data_types.all;

ENTITY type_analyzer_delta IS
	PORT
	(
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


END type_analyzer_delta ;

ARCHITECTURE SYN OF type_analyzer_delta IS

--
BEGIN

ChargeStamp 	<= 	Header_In.chargestamp; 		
TimeStamp 		<= 	Header_In.timestamp; 		
TriggerWord 	<=	Header_In.trigger_word;	-- for monitoring types of data
EventType		<=	Header_In.eventtype;
Atwd_AB			<= 	Header_In.ATWD_AB; 
AtwdAvail		<= 	Header_In.ATWDavail; 		-- if AtwdAvail = 0, and FadcAvail = 0,
FadcAvail		<= 	Header_In.FADCavail;		-- then only the timestamp is avail
AtwdSize		<= 	Header_In.ATWDsize; 
LC				<= 	Header_In.LC;

--Ch0aLoTh		<= 	ComprVar.ATWDa0thres;
--Ch1aLoTh		<=  ComprVar.ATWDa1thres;	
--Ch2aLoTh		<= 	ComprVar.ATWDa2thres;	
--Ch3aLoTh		<= 	ComprVar.ATWDa3thres; 	
--Ch0bLoTh		<= 	ComprVar.ATWDb0thres;	
--Ch1bLoTh		<= 	ComprVar.ATWDb1thres;
--Ch2bLoTh		<= 	ComprVar.ATWDb2thres;
--Ch3bLoTh		<= 	ComprVar.ATWDb3thres;	
--FadcLoTh		<= 	ComprVar.FADCthres;
ComprMode		<= 	ComprVar.Compr_mode;
	
threshold0		<= 	ComprVar.threshold0;	
LastOnly		<= 	ComprVar.LastOnly;	


END SYN;
----
