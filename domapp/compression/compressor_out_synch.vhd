-------------------------------------------------------------------------------
-- Title      : Fadc and Atwd temporary RAM storage for compressed data.
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : compressor_out.vhd
-- Author     : joshua sopher
-- Company    : LBNL
-- Created    : 
-- Last update: june 28 2004
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This design is the interface between the compressor and the LBM controller
--				It receives compressed data from compressor_in.vhd and writes it into a   		 
--				RAM which is 8 bits wide,The compressed data is then read out by a  
--              Lbm data control module, as a 32 bit word, suited for the external SRAM hardware.
--				
-----------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- 
-----------------------------------------------------------------------------------------------------------
LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;  -- use to count std_logic_vectors
--USE WORK.icecube_data_types.all;

ENTITY compressor_out_synch IS
	PORT
	(
		Reset			: IN STD_LOGIC;
		Clk20			: IN STD_LOGIC;
		Clk40			: IN STD_LOGIC;
		ComprActive		: IN STD_LOGIC  ;
		LbmReadDone		: IN STD_LOGIC  ;
		RingReadEn 		: IN STD_LOGIC  ;
		BfrDav  		: IN STD_LOGIC  ;
--		BfrDavEdge		: IN STD_LOGIC  ;
		ComprMode		: IN STD_LOGIC_VECTOR (1 DOWNTO 0)  ;
		LBMRamAddrExt	: IN STD_LOGIC_VECTOR (8 DOWNTO 0); -- address for 32 bit data
		ComprData		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);

--
		Timestamp		: IN STD_LOGIC_VECTOR (47 DOWNTO 0);
		TriggerWord 	: IN STD_LOGIC_VECTOR (15 DOWNTO 0);
--		EventType 		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		Atwd_AB 		: IN STD_LOGIC;
		AtwdAvail		: IN STD_LOGIC;
		FadcAvail		: IN STD_LOGIC;
		AtwdSize		: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
		LC				: IN STD_LOGIC_VECTOR (1 DOWNTO 0);
-- 		Deadtime		: IN STD_LOGIC_VECTOR (15 DOWNTO 0); 
--
		BfrDavOut		: OUT STD_LOGIC  ;		
		RamDavOut 		: OUT STD_LOGIC  ;		 
		ComprSize 		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0); -- compressor size for 32 bit words
		RamAddr 		: OUT STD_LOGIC_VECTOR (10 DOWNTO 0);
		RamWe0 			: OUT STD_LOGIC  ;
		RamDataIn		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);

--		TimestampMsBy	: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
--		TrigWordMsb		: OUT STD_LOGIC_VECTOR (2 DOWNTO 0);

		RamDataOut0		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		RamDataOut1		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		RamDataOut2		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		RamDataOut3		: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
		LBMDataOut		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);


END compressor_out_synch ;

ARCHITECTURE SYN OF compressor_out_synch IS
	TYPE state_type IS (wr_init, wr_idle, wr_unc_cmpr, wr_cmpr_or_hdr, wr_compr,  wait_header_size,
							wr_header_init, wr_header, end_write, rd_ram_init, rd_data, rd_done); 
----
-- ATWD data header data type


	-- ATWD data header data type
--	TYPE HEADER_VECTOR IS
--		RECORD
--			timestamp		: STD_LOGIC_VECTOR (47 DOWNTO 0);
--			trigger_word	: STD_LOGIC_VECTOR (15 DOWNTO 0); -- monitoring type 
--			eventtype		: STD_LOGIC_VECTOR (1 DOWNTO 0);  -- time stamp, fadc only, fadc and atwd 
--			ATWD_AB			: STD_LOGIC;
--			ATWDavail		: STD_LOGIC;
--			FADCavail		: STD_LOGIC;
--			ATWDsize		: STD_LOGIC_VECTOR (1 DOWNTO 0);
--			LC				: STD_LOGIC_VECTOR (1 DOWNTO 0);
--			deadtime		: STD_LOGIC_VECTOR (15 DOWNTO 0);
--		END RECORD;
	
	
----
	SIGNAL 	comprn_bfr_state		: state_type;

	SIGNAL 	sub_wire0				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL 	out_bfr0				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL 	out_bfr1				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL 	out_bfr2				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL 	out_bfr3				: STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL  ram_data_hdr			: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  ram_data_hdr_dly		: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  ram_data_in				: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  ram_data_in0			: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  ram_we_data				: STD_LOGIC; 
	SIGNAL  hdr_cmpr_bit			: STD_LOGIC; 

	SIGNAL  ram_address				: STD_LOGIC_VECTOR (10 DOWNTO 0); 
	SIGNAL  ram_address_compr		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
	SIGNAL  ram_address_header		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
	SIGNAL  hit_size_in_header		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
	SIGNAL  compr_size				: STD_LOGIC_VECTOR (8 DOWNTO 0);  --hit_size_in_header/4 or hit_size_in_header/4 + 1
	SIGNAL  lbm_data_out			: STD_LOGIC_VECTOR (31 DOWNTO 0); 

	SIGNAL  data_sig				: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  wraddress_sig			: STD_LOGIC_VECTOR (8 DOWNTO 0); 
	SIGNAL  rdaddress_sig			: STD_LOGIC_VECTOR (8 DOWNTO 0); 
	SIGNAL  clock_sig				: STD_LOGIC; 
	SIGNAL  wren_sig0				: STD_LOGIC; 
	SIGNAL  wren_sig1				: STD_LOGIC; 
	SIGNAL  wren_sig2				: STD_LOGIC; 
	SIGNAL  wren_sig3				: STD_LOGIC; 
	SIGNAL  q_sig0					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig1					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig2					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig3					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
 

 
	SIGNAL  ram_hdr_busy			: STD_LOGIC; 
	SIGNAL  bfr_dav_out				: STD_LOGIC; 
	SIGNAL  lbm_read_done			: STD_LOGIC; 
 
	SIGNAL  ram_we0					: STD_LOGIC; 
	SIGNAL  ram_we1					: STD_LOGIC; 
	SIGNAL  ram_we2					: STD_LOGIC; 
	SIGNAL  ram_we3					: STD_LOGIC; 
	SIGNAL  ram_addr_clk			: STD_LOGIC; 
	SIGNAL  ram_clk					: STD_LOGIC; 
	SIGNAL  header_write			: STD_LOGIC; 
	SIGNAL 	header_compr			: STD_LOGIC_VECTOR (63 DOWNTO 0);
	SIGNAL  ram_header_we			: STD_LOGIC; 
	SIGNAL  ram_write_done			: STD_LOGIC; 

	SIGNAL  event_end_wait			: STD_LOGIC_VECTOR (2 DOWNTO 0); 




	COMPONENT compr_ram
	PORT (
			wren		: IN STD_LOGIC ;
			clock		: IN STD_LOGIC ;
			q			: OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
			data		: IN STD_LOGIC_VECTOR (7 DOWNTO 0);
			rdaddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0);
			wraddress	: IN STD_LOGIC_VECTOR (8 DOWNTO 0)
	);
	END COMPONENT;
-----

BEGIN
---------
-- 4 rams to store data
compr_ram0 : compr_ram PORT MAP(
		data	 	 => data_sig,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig0,
		clock	 	=> clock_sig,
		q	 		=> q_sig0
	);

compr_ram1 : compr_ram PORT MAP(
		data	 	 => data_sig,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig1,
		clock	 	=> clock_sig,
		q	 		=> q_sig1
	);

compr_ram2 : compr_ram PORT MAP(
		data	 	 => data_sig,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig2,
		clock	 	=> clock_sig,
		q	 		=> q_sig2
	);

compr_ram3 : compr_ram PORT MAP(
		data	 	 => data_sig,
		wraddress	 => wraddress_sig, 
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig3,
		clock	 	=> clock_sig,
		q	 		=> q_sig3
	);

	data_sig 		<= ram_data_in;
	wraddress_sig	<= ram_address(10 DOWNTO 2); 
	rdaddress_sig	<= LBMRamAddrExt;				 
	clock_sig 		<= clk40;
	wren_sig0 		<= ram_we0 ;
	wren_sig1 		<= ram_we1 ;
	wren_sig2 		<= ram_we2 ;
	wren_sig3 		<= ram_we3 ;
	RamDataOut0		<= q_sig0;
	RamDataOut1		<= q_sig1;
	RamDataOut2		<= q_sig2;
	RamDataOut3		<= q_sig3;

--	header_compr <= HeaderIn;

-------------------------------------------
    PROCESS (clk20, reset)

      BEGIN
		IF (reset = '1') THEN
			comprn_bfr_state <= wr_init;
		ELSIF (clk20'EVENT) AND (clk20 = '1') THEN   

		  CASE comprn_bfr_state IS
		
-- initialize ram_address_compr and ram data
     		WHEN wr_init =>
				header_write <= '0';
				ram_write_done <= '0';
				bfr_dav_out		<= '0';	
				ram_address_header <= "00000000000" ; 	
				ram_data_hdr	<= "00000000"; 
				comprn_bfr_state <=  wr_idle;  	

    		WHEN wr_idle =>			
				ram_data_hdr	<= "00000000"; 
				IF (BfrDav = '1') THEN				
					comprn_bfr_state <=  wr_unc_cmpr;  	
				ELSE									 
					comprn_bfr_state <=  wr_idle;  	
				END IF;

    		WHEN wr_unc_cmpr =>			
					IF (ComprMode = "00") THEN
						comprn_bfr_state <=  rd_data;
					ELSE  	
						comprn_bfr_state <=  wr_cmpr_or_hdr;	
					END IF;  	

    		WHEN wr_cmpr_or_hdr =>
				ram_data_hdr	<= "00000000"; 
				  	IF (FadcAvail = '1') OR (AtwdAvail = '1') THEN
						IF (ComprActive = '1') THEN			
							comprn_bfr_state <=  wr_compr; 
						ELSE  	
							comprn_bfr_state <=  wr_cmpr_or_hdr;  	
				  		END IF;
				  	ELSE									
							comprn_bfr_state <=  wait_header_size; 
				 	END IF;
 	
-- write compressed data in ram
     		WHEN  wr_compr =>
				IF (ComprActive = '0') THEN
					comprn_bfr_state <=  wr_header_init; 
				ELSE  	
					comprn_bfr_state <=  wr_compr ;  	
				END IF;

     		WHEN  wait_header_size =>
					comprn_bfr_state <=  wr_header_init; 

-- initialize ram_address_header and ram data
     		WHEN wr_header_init =>
				ram_hdr_busy	<= '1'; 
				header_write	<= '1'; 
				ram_data_hdr		<= header_compr(63 DOWNTO 56); 
				ram_address_header <= "00000000000" ; 		
				comprn_bfr_state <=  wr_header ; 
 	
    		WHEN  wr_header =>
					header_write <= '1';
					ram_address_header <= ram_address_header + 1 ; 		
				IF (ram_address_header = "00000000101") THEN
						ram_data_hdr		<= header_compr(15 DOWNTO 8); 
				ELSIF (ram_address_header = "00000000100") THEN
						ram_data_hdr		<= header_compr(23 DOWNTO 16); 
				ELSIF (ram_address_header = "00000000011") THEN
						ram_data_hdr		<= header_compr(31 DOWNTO 24); 
 				ELSIF (ram_address_header = "00000000010") THEN
						ram_data_hdr		<= header_compr(39 DOWNTO 32); 
 				ELSIF (ram_address_header = "00000000001") THEN
						ram_data_hdr		<= header_compr(47 DOWNTO 40); 
 				ELSIF (ram_address_header = "00000000000") THEN
  						ram_data_hdr		<= header_compr(55 DOWNTO 48); 
				ELSE
 						ram_data_hdr		<= header_compr(7 DOWNTO 0); 
				END IF;

				IF (ram_address_header = "00000000111") THEN
					header_write <= '0';  
					comprn_bfr_state <=  end_write;  
				ELSE
					comprn_bfr_state <=  wr_header;  
 				END IF;

   			WHEN  end_write =>
				ram_hdr_busy	<= '0'; 
				header_write <= '0';
				comprn_bfr_state <=  rd_ram_init ;  	

    		WHEN  rd_ram_init =>
				header_write 	<= '0';
				ram_write_done 	<= '1';
				bfr_dav_out		<= '1';				
				comprn_bfr_state <=  rd_data ;  	

    		WHEN  rd_data =>
				ram_write_done 	<= '1';			-- for compr data
				bfr_dav_out		<= '1';			-- for uncompr data	
			IF (lbm_read_done = '1') THEN				 
				comprn_bfr_state <=  rd_done ;  	 
				ram_write_done 	<= '0';
				bfr_dav_out		<= '0';				
			ELSE
				comprn_bfr_state <=  rd_data ;  	
			END IF;			
	
    		WHEN  rd_done =>
			IF (event_end_wait = "011") THEN				 
				ram_write_done 	<= '0';
				bfr_dav_out		<= '0';				
				comprn_bfr_state <=  wr_init ;  	
			ELSE
				comprn_bfr_state <=  rd_done ;  	
			END IF;			
		END CASE;
		END IF;
	END PROCESS  ;

----------------------------------------------------------
-- create the header for compression, using only the required sets of raw header data. 
-- if changes are made to the header package elsewhere, they will not be recognized
-- and must be changed here.

header_gen: PROCESS (comprn_bfr_state, clk20, reset)
  BEGIN 
	IF (reset = '1') THEN
			header_compr <= x"0000000000000000";
	ELSIF (clk20 = '0') AND (clk20'EVENT) THEN
		IF (comprn_bfr_state = wr_init) THEN 		 
			header_compr <= header_compr(63 DOWNTO 1) & '0';	  
		ELSIF (comprn_bfr_state = wr_compr) 
				OR (comprn_bfr_state = wait_header_size) THEN

 			header_compr <= Timestamp(31 DOWNTO 0) & 			
							TriggerWord(12 DOWNTO 0) & 			
							LC & 
							ATWD_AB & 
							AtwdSize & 
							AtwdAvail & 		
							FadcAvail &			
							hit_size_in_header & '1';		
   		END IF;
	END IF;
 END PROCESS header_gen;

----------------------------------------------------------
-- LbmReadDone is one clk40 cycle wide. 
-- stretch it 3 clk20 cycles. 

lbm_pulse_stretcher:PROCESS(clk40, comprn_bfr_state, reset)
BEGIN
	IF (reset = '1') THEN
		lbm_read_done <= '0';
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
		IF (comprn_bfr_state <= wr_init) THEN  
				lbm_read_done <= '0';   -- reset after latching LbmReadDone
		ELSIF (LbmReadDone = '1') THEN 
				lbm_read_done <= '1'; -- latch LbmReadDone
		END IF;
	END IF;
END PROCESS lbm_pulse_stretcher;	

-----
-- give BfrDav (data_avail_in) time to go to logic 0, 

wait_counter: PROCESS(clk20, comprn_bfr_state, reset)
BEGIN 
	IF (reset = '1') THEN
 		event_end_wait <= "000";
	ELSIF (clk20 = '0') AND (clk20'EVENT) THEN
		IF (comprn_bfr_state = rd_done) THEN   -- count during rd_done only
 			event_end_wait <= event_end_wait + 1;
		ELSE
 			event_end_wait <= "000";

		END IF;
	END IF;
		
END PROCESS wait_counter;

-------------------------------------------------
--
-- ram_we_del: PROCESS(clk40, comprn_bfr_state, reset)
--  		BEGIN
--	IF (reset = '1') THEN
--		ram_we_data <= '0';
--	ELSIF (clk40 = '0' ) AND (clk40'EVENT) THEN 
--				IF (comprn_bfr_state = wr_init) THEN 
--					ram_we_data <= '0';
--				ELSIF (comprn_bfr_state = wr_compr) THEN
--					ram_we_data <= RingReadEn;
--				ELSE 
--					ram_we_data <= '0';
--				END IF;
--	END IF;
-- END PROCESS ram_we_del;

------
-- select the source of the ram address
-- hit size will = last ram_address_count when ComprActive = '0'
   
ram_wr_address_gen: PROCESS (comprn_bfr_state, clk40, reset)
 BEGIN 
	IF (reset = '1') THEN
			ram_address <= "00000000000";	   
			hit_size_in_header 	<= "00000000000";    
			compr_size 	<= "000000000";    
	ELSIF (clk40 = '0') AND (clk40'EVENT) THEN  
	  IF (comprn_bfr_state = wr_init) OR 		 
		(comprn_bfr_state = wr_idle) OR
		(comprn_bfr_state = wr_cmpr_or_hdr) THEN
			ram_address <= "00000000111";	   
			hit_size_in_header 	<= "00000001000";    
			compr_size 	<= "000000010";    
 	  ELSIF (comprn_bfr_state = wr_compr) THEN
			IF (RingReadEn = '1') THEN
				ram_address <= ram_address + 1;
				hit_size_in_header 	<= hit_size_in_header + 1;
			ELSE
				ram_address <= ram_address;
				hit_size_in_header 	<= hit_size_in_header; 
			  IF (hit_size_in_header(1 DOWNTO 0) = "00") THEN -- hit size = multiple of 4
				  compr_size <= hit_size_in_header(10 DOWNTO 2);
			  ELSE 
				  compr_size <= hit_size_in_header(10 DOWNTO 2) + '1'; -- hit size /= multiple of 4 
			  END IF;								
			END IF;
 	  ELSIF (header_write	= '1') THEN    
 		ram_address <= ram_address_header;  
	  ELSE			
		ram_address <= ram_address ;			
   	  END IF;
	END IF;
 END PROCESS ram_wr_address_gen;

--------------
-- set up ram_we for four ram blocks

 ram_we_gen: PROCESS(clk40, comprn_bfr_state, reset)

  		BEGIN
		IF (reset = '1') THEN
 	  					ram_we0	<= '0'; 
 	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
		ELSIF (clk40 = '0' ) AND (clk40'EVENT) THEN 
				IF (comprn_bfr_state = wr_init) THEN  -- synch reset
 	  					ram_we0	<= '0'; 
 	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
	 			ELSIF (header_write = '1') THEN  --
		    		IF (ram_address(1 DOWNTO 0) = "11") THEN --- demux ram_header_clk0
 	  			 		ram_we3 	<= ram_header_we; 
	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we0	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "10") THEN
  	  			 		ram_we2 	<= ram_header_we; 
	  					ram_we1	<= '0'; 
 	  					ram_we0	<= '0'; 
 	  					ram_we3	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "01") THEN
 	  			 		ram_we1 	<= ram_header_we; 
 	  					ram_we0	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "00") THEN
 	  			 		ram_we0 	<= ram_header_we; 
 	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
					END IF;
				ELSE
					IF (ram_address(1 DOWNTO 0) = "11") THEN
 	  			 		ram_we0 	<= RingReadEn ; 
 	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "00") THEN
 	  			 		ram_we1 	<= RingReadEn ; 
 	  					ram_we0	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we3	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "01") THEN
 	  			 		ram_we2 	<= RingReadEn ; 
 	  					ram_we1	<= '0'; 
 	  					ram_we0	<= '0'; 
 	  					ram_we3	<= '0'; 
					ELSIF (ram_address(1 DOWNTO 0) = "10") THEN
  	  			 		ram_we3 	<= RingReadEn ; 
	  					ram_we1	<= '0'; 
 	  					ram_we2	<= '0'; 
 	  					ram_we0	<= '0'; 
					END IF;
			  END IF;
		END IF;
 END PROCESS ram_we_gen;

------------------------------------
   header_synch: PROCESS(Clk40, comprn_bfr_state, reset )

		BEGIN
 		IF (reset = '1') THEN
			ram_data_hdr_dly <= "00000000"; 	
		ELSIF (Clk40= '0') AND (Clk40'EVENT) THEN 
				IF (comprn_bfr_state = wr_header_init) THEN --synch reset
					ram_data_hdr_dly <= "00000000"; 	
				ELSE	
					ram_data_hdr_dly <= ram_data_hdr; 
				END IF;
 		END IF;
END PROCESS header_synch;

---------------------------------------		

-- select source of the ram data in  
  PROCESS (header_write, ram_data_in0, ram_data_hdr_dly, ComprData)
 BEGIN
 	IF	(header_write	= '1') THEN ram_data_in0 <= ram_data_hdr_dly ;    
    ELSE ram_data_in0 	<= ComprData;	 
    END IF;
 END PROCESS;
--
-- clock ram_data_in0 into a register
ram_data_synch: PROCESS(Clk40, comprn_bfr_state, reset )

		BEGIN
 		IF (reset = '1') THEN
				ram_data_in <= "00000000"; 	
 		ELSIF (Clk40= '0') AND (Clk40'EVENT) THEN 
				IF (comprn_bfr_state = wr_header_init) THEN  
					ram_data_in <= "00000000"; 	
				ELSE	
					ram_data_in <= ram_data_in0; 
				END IF;
 		END IF;
END PROCESS ram_data_synch;



----------------------------------------
-- generate the header ram_header_we

 
  header_clk_gen0: PROCESS(Clk40, comprn_bfr_state, reset )

		BEGIN
 		IF (reset = '1') THEN
				  ram_header_we	<= '0'; 		
 		ELSIF (Clk40= '0') AND (Clk40'EVENT) THEN 
			  IF (comprn_bfr_state = wr_init)
				OR (comprn_bfr_state = wr_header_init) 
				OR (comprn_bfr_state = end_write)  THEN	
					    ram_header_we	<= '0'; 		
			  ELSIF (comprn_bfr_state = wr_header) THEN
					ram_header_we	<= NOT ram_header_we; 	
			  ELSE
					ram_header_we	<= '0'; 	
			  END IF;
		END IF;
 	END PROCESS header_clk_gen0;

------
LBMDataOut <= q_sig0 & q_sig1 & q_sig2 & q_sig3;

---- ram_data_out
RamWe0 <= ram_we0;
RamDataIn <= ram_data_in;
RamAddr  <= ram_address;
ComprSize  <= compr_size;  
 
-- deassert BfrDavOut and RamDavOut one clk40 
-- cycle after LbmReadDone
BfrDavOut <= bfr_dav_out AND (NOT lbm_read_done); 
RamDavOut <= ram_write_done AND (NOT lbm_read_done);
 
----------------------------------------------------------

END SYN;



