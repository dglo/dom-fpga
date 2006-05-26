-- -----------------------------------------------------------------------------------------------------------------
--                        FADC and ATWD data Suppression and Compression STATE MACHINE
--                                  	j.sopher   
--                                  
--             
-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : compressor_in.vhd
-- Author     : joshua sopher
-- Company    : LBNL
-- Created    : 
-- Last update: June 7 05
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-- atwd and fadc data are saved in an external buffer module, and sent to this module. 
-- The difference in the counts between two adjacent samples is calculated and used to
-- generate the compressed word. If the difference is between -3 and +3 a small word 
-- is used (sign bit & diff (1..0) & small/big_flag). A big word contains the full   
-- difference in counts (10 bits) plus the sign and flag bits.
-- (sign bit & diff (10..0) & small/big_flag). Compressed data is made up of 
-- big (12 bits) and small words (4 bits). They are written into a temporary buffer 
-- called the ring register. Writing is done on the fly, i.e. uncompressed 
-- data is read at a fixed rate, and compressed data is written as fast as uncompressed data 
-- is read. Data is never over-writen before it is read out. This is done by calculating if 
-- enough bits are written to generate a full read out word, and reading it out immediately.
-- The size of the read out word is 8 bits. It is sent to the compressor_out.vhd module,
-- where it is written into a temporary RAM. It is read out from the RAM by a 
-- Look Back Memory Controller,for storage in the LBM.
-- The LBM is read out under the control of the an external module, in response 
-- to a request from the CPU. In addition, uncompressed data and related timing signals 
-- are processed and outputted.
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--									provided at the same time as the header, when BfrDav is asserted 								  
--------------------------------------------------------------------------------- --------------------------------------------------------------
-- !!!!!!! CHANGE atwd_word_count FROM 15 (USED FOR SIMULATION) TO 254
-- !!!!!!! CHANGE fadc_address FROM 41 (USED FOR SIMULATION) TO 511
-- ******************************************************************************************************************

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_signed.ALL;    
USE ieee.std_logic_arith.ALL;     

USE WORK.icecube_data_types.all;
---------------
ENTITY compressor_delta_in IS
	PORT(
-- system signals
		reset				: IN	STD_LOGIC;
		clk20			   	: IN	STD_LOGIC;		
		clk40		   		: IN	STD_LOGIC;		
------------------
-- interface signals with the fadc and atwd buffers 
		FadcData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
 		AtwdData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
		BfrDav				: IN	STD_LOGIC;					    

  		ComprMode			: IN	STD_LOGIC_VECTOR (1 DOWNTO 0); 
 		AtwdAvail			: IN 	STD_LOGIC;
		FadcAvail			: IN 	STD_LOGIC;
		Atwd_AB 			: IN 	STD_LOGIC;
		AtwdSize			: IN 	STD_LOGIC_VECTOR (1 DOWNTO 0);
 		Header				: IN 	HEADER_VECTOR;					-- uncomment this line before compiling into top entity
--
		BfrReadDone	   		: OUT	STD_LOGIC;					       
  		FadcBfrAddr			: OUT	STD_LOGIC_VECTOR (6 DOWNTO 0);  
  		AtwdBfrAddr			: OUT	STD_LOGIC_VECTOR (7 DOWNTO 0);  

------------------
-- interface signals with Ram to LBM write module
-- used to generate BfrReadDone. Ram must be readout before the next 
-- buffer read can be done.
		LbmReadDone			: IN	STD_LOGIC;	
		RamDav				: IN	STD_LOGIC;					    

  		FadcBfrAddrExt		: IN	STD_LOGIC_VECTOR (6 DOWNTO 0);  
  		AtwdBfrAddrExt		: IN	STD_LOGIC_VECTOR (7 DOWNTO 0);  
   		UnCmprFadcData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0); -- uncomment this line before compiling into top entity
  		UnCmprAtwdData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0); -- uncomment this line before compiling into top entity
  		UnCmprHeader		: OUT	HEADER_VECTOR;   				-- uncomment this line before compiling into top entity 

--------------------
        DataNew 			: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     
        DataOld 			: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     
        DataDelta 			: OUT   STD_LOGIC_VECTOR (10 DOWNTO 0) ;     
        DataDeltaRing		: OUT   STD_LOGIC_VECTOR (11 DOWNTO 0) ;     



------------------       
-- interface signals with the compressor output module
        ComprActive			: OUT   STD_LOGIC ;  
        ComprDoneStrb		: OUT   STD_LOGIC ;    
        ComprDataOut		: OUT   STD_LOGIC_VECTOR (7 DOWNTO 0) ;     
		RingReadEn			: OUT	STD_LOGIC;		  

-----------------
-- test signals 
  		RingData			: OUT	STD_LOGIC_VECTOR (15 DOWNTO 0); 
		Jout				: OUT	INTEGER RANGE 31 DOWNTO 0 ; 
		Iout				: OUT	INTEGER RANGE 31 DOWNTO 0 ; 
		Kout				: OUT	INTEGER RANGE 63 DOWNTO 0 ; 
		Lout				: OUT	INTEGER RANGE 63 DOWNTO 0 ; 

-- test signals for the input buffer interface
		FadcBfrClk	   		: OUT	STD_LOGIC;		 
		AtwdBfrClk	   		: OUT	STD_LOGIC;		   
  		AtwdChNumber		: OUT	STD_LOGIC_VECTOR (2 DOWNTO 0);  

        RingWriteClk		: OUT   STD_LOGIC   
		);

END compressor_delta_in ;
---------------------------

ARCHITECTURE rtl OF compressor_delta_in IS
	TYPE state_type IS (init, idle, idle0, idle1, save, get, wait_end_word0, wait_end_word1, wait_end_word2, 
	 ch_comp_done, process_atwd, end_of_event0, end_of_event1,
	 end_of_event2);    
 	TYPE write_ring_type IS (wr_init, wr_idle, wr_data_idle0, wr_wait, wr_data_idle, wr_data, wr_done, wr_wait_new);
								
  	TYPE read_ring_type IS (rd_init, rd_idle, rd_big, rd_xtra_big, 
 								rd_small);
----------------

	SIGNAL supr_compr_state		: 	state_type;
	SIGNAL write_ring_state		: 	write_ring_type;
 	SIGNAL read_ring_state		: 	read_ring_type;

	SIGNAL ring_init			: 	STD_LOGIC;

	SIGNAL   compr_mode				: STD_LOGIC_VECTOR (1 DOWNTO 0) ;  
	SIGNAL   atwd_bfr_size	 		: STD_LOGIC_VECTOR (2 DOWNTO 0) ;

	SIGNAL   lbm_read_done			: STD_LOGIC; 
	SIGNAL   event_end_wait			: STD_LOGIC_VECTOR (2 DOWNTO 0) ; 
	
	SIGNAL   big_small_flag	 		: STD_LOGIC;	
	SIGNAL   compr_active			: STD_LOGIC;
  	SIGNAL   compr_done_strb 		: STD_LOGIC; 
  	SIGNAL   compr_done_strb_clk40	: STD_LOGIC; 
  	SIGNAL   bfr_rd_done_compr 		: STD_LOGIC; 
  	SIGNAL   compr_done 			: STD_LOGIC; 
	SIGNAL   ring_write_clk 		: STD_LOGIC; 
	SIGNAL   ring_write_en			: STD_LOGIC; 
	SIGNAL   ring_write_en_dly		: STD_LOGIC; 
	SIGNAL   ring_write_en_dly1		: STD_LOGIC; 
	SIGNAL   wr_done_flag	 		: STD_LOGIC; 
   	SIGNAL   ring_rd_en				: STD_LOGIC; 
   	SIGNAL   ring_rd_en_dly			: STD_LOGIC; 
   	SIGNAL   ram_wr_en				: STD_LOGIC; 
 	SIGNAL   init_wr_pointers 		: STD_LOGIC;  
	SIGNAL   write_wait_new_count	: STD_LOGIC_VECTOR (3 DOWNTO 0); 

   	SIGNAL   read_idle_en			: STD_LOGIC; 
   	SIGNAL   read_idle_en_count		: STD_LOGIC_VECTOR (3 DOWNTO 0); 
  	SIGNAL	 nz_rd_done				: STD_LOGIC; 

 	SIGNAL   data_new			 	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL   data_old			 	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL   data_delta			 	: STD_LOGIC_VECTOR (10 DOWNTO 0);
--	SIGNAL   data_delta_dly		 	: STD_LOGIC_VECTOR (10 DOWNTO 0);
	SIGNAL   delta_to_write			: STD_LOGIC_VECTOR (10 DOWNTO 0);
	SIGNAL   data_delta_ring	 	: STD_LOGIC_VECTOR (11 DOWNTO 0);
	SIGNAL   data_delta_ring_dly 	: STD_LOGIC_VECTOR (11 DOWNTO 0);
	
	SIGNAL   ring_data	 			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL   ring_data_dly 			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL   ring_data_dly1			: STD_LOGIC_VECTOR (15 DOWNTO 0);
	SIGNAL   h_compr_data	 		: STD_LOGIC_VECTOR (7 DOWNTO 0);

  	SIGNAL   i_dly 					: INTEGER RANGE 31 DOWNTO 0 ;	
 	SIGNAL   j_dly					: INTEGER RANGE 31 DOWNTO 0 ;	
  	SIGNAL   i 						: INTEGER RANGE 31 DOWNTO 0 ;	
 	SIGNAL   j						: INTEGER RANGE 31 DOWNTO 0 ;	
  	SIGNAL   k 						: INTEGER RANGE 63 DOWNTO 0 ;
 	SIGNAL   l 						: INTEGER RANGE 63 DOWNTO 0 ;	

------
--interface signals
	SIGNAL   atwd_start		 	: STD_LOGIC;
	SIGNAL   atwd_ch_done		: STD_LOGIC;
	SIGNAL   atwd_ch_done_dly	: STD_LOGIC;
	SIGNAL   atwd_ch_count_en	: STD_LOGIC;
	SIGNAL   atwd_done		 	: STD_LOGIC;
	SIGNAL   fadc_done		 	: STD_LOGIC;
	SIGNAL   atwd_bfr_clk 		: STD_LOGIC;
	SIGNAL   fadc_bfr_clk 		: STD_LOGIC;
	SIGNAL   atwd_counter_clk 	: STD_LOGIC;
	SIGNAL   fadc_counter_clk 	: STD_LOGIC;
	SIGNAL   atwd_bfr_en		: STD_LOGIC;
	SIGNAL   fadc_bfr_en		: STD_LOGIC;

	SIGNAL 	fadc_data			: STD_LOGIC_VECTOR (9 DOWNTO 0);  
	SIGNAL 	atwd_data			: STD_LOGIC_VECTOR (9 DOWNTO 0);  
	SIGNAL 	atwd_word_count		: STD_LOGIC_VECTOR (8 DOWNTO 0);  
	SIGNAL 	fadc_address		: STD_LOGIC_VECTOR (9 DOWNTO 0);  
	SIGNAL 	atwd_address		: STD_LOGIC_VECTOR (9 DOWNTO 0);  
	SIGNAL 	atwd_ch_count		: STD_LOGIC_VECTOR (2 DOWNTO 0);
	SIGNAL 	ch_count			: STD_LOGIC_VECTOR (1 DOWNTO 0);
 
	SIGNAL 	do_last_count		: STD_LOGIC;
	SIGNAL 	start_writing		: STD_LOGIC;



BEGIN

---------------------------------------------------
   PROCESS (clk40, reset)

      BEGIN
		IF (reset = '1') THEN
			atwd_start 		<= '0';
			fadc_done 		<= '0';								
			compr_done_strb	<= '0';				
			compr_done 		<= '0';				
			compr_mode 		<= "00";				 	
            data_old 		<= "0000000000" ;  		
            data_new 		<= "0000000000" ;  		

			big_small_flag 	<= '0';		
			do_last_count 	<= '0';		
			start_writing 	<= '0';
			
			supr_compr_state <= init;
		ELSIF (clk40'EVENT) AND (clk40 = '1') THEN

		  CASE supr_compr_state IS

-- don't compress if compression mode constant = compr off
-- or daq mode constant = header only
    		WHEN init  =>  	
			atwd_start 		<= '0';
			fadc_done 		<= '0';								
			compr_done_strb	<= '0';				
			compr_done 		<= '0';				
			compr_mode 		<= ComprMode;				 	
            data_old 		<= "0000000000" ;  		
            data_new 		<= "0000000000" ;  		
			big_small_flag 	<= '0';		
			do_last_count 	<= '0';		
			start_writing 	<= '0';
			
			IF (BfrDav = '1') THEN
				supr_compr_state <= idle;
			ELSE
				supr_compr_state <= init;			
			END IF;							

			WHEN idle  =>
 				IF (compr_mode = "00") OR (FadcAvail = '0') THEN   	
					fadc_done <= '1';							
					supr_compr_state <= end_of_event2;			  
				ELSE											
					supr_compr_state <= idle0;  						
            	END IF;		


			WHEN idle0  =>			
				do_last_count 	<= '1';								
				start_writing 	<= '0';
             	data_old 		<= data_new ;  	 
				supr_compr_state <= idle1;

			WHEN idle1  =>									 
				do_last_count <= '1';								
                data_old 		<= data_new ; 
			IF (fadc_bfr_en = '1') AND (fadc_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSIF (atwd_bfr_en= '1') AND (atwd_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSE
				supr_compr_state <= idle1 ;
            END IF;

    		WHEN save =>  			
				do_last_count <= '0';					 			
           		data_old <= data_new ;
				IF (atwd_bfr_en = '1') AND (fadc_bfr_en = '0') THEN
   							data_new	<= atwd_data ;
 				ELSIF (atwd_bfr_en = '0') AND (fadc_bfr_en = '1') THEN
 						data_new	<= fadc_data ; 
				ELSE
						data_new <= data_new;
				END IF;
 				IF (data_delta(10) = '0')					
					AND (data_delta > "00000000011") THEN
 						big_small_flag	 	<= '1' ;           
            	ELSIF (data_delta(10) = '1')
 					AND (data_delta < "11111111101") THEN  
						big_small_flag	 	<= '1' ; 
				ELSE 
						big_small_flag	 	<= '0' ; 				         
 		 		END IF;	
		
 				supr_compr_state <= get;

    		WHEN get =>  	
 				start_writing 	<= '1';
		   	
			IF (fadc_bfr_en = '1') AND (fadc_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSIF (atwd_bfr_en= '1') AND (atwd_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSE
				supr_compr_state 	<= wait_end_word0;	
            END IF;
	
   			WHEN wait_end_word0 => 							  			
				IF (data_delta(10) = '0')					 
					AND (data_delta > "00000000011") THEN
 						big_small_flag	 	<= '1' ;           
            	ELSIF (data_delta(10) = '1')
 					AND (data_delta < "11111111101") THEN   
						big_small_flag	 	<= '1' ; 
				ELSE 
						big_small_flag	 	<= '0' ; 				         
 		 		END IF;										 
				supr_compr_state <= wait_end_word1 ;	

   			WHEN wait_end_word1 => 							  			
				do_last_count <= '1';					 		
				start_writing 	<= '0';
				supr_compr_state <= wait_end_word2 ;	

   			WHEN wait_end_word2 => 							  			
				do_last_count <= '1';					 														
				IF (data_delta(10) = '0')					 
					AND (data_delta > "00000000011") THEN
 						big_small_flag	 	<= '1' ;           
            	ELSIF (data_delta(10) = '1')
 					AND (data_delta < "11111111101") THEN   
						big_small_flag	 	<= '1' ; 
				ELSE 
						big_small_flag	 	<= '0' ; 				         
 		 		END IF;	
				supr_compr_state <= ch_comp_done ;	
				
-- fadc is compressed first, 
 
     		WHEN ch_comp_done => 							  			
					do_last_count <= '1';					 			
					fadc_done 	  <= '1';
				IF (AtwdAvail = '0') THEN 				 
   					supr_compr_state <= end_of_event0;	
				ELSIF (AtwdAvail = '1') THEN 
					IF (atwd_start = '1') AND (atwd_done = '1') THEN 
    					supr_compr_state <= end_of_event0;		  
					ELSE
						supr_compr_state <= process_atwd;						
	            	END IF;	
	            END IF;	
								 
    		WHEN process_atwd => 							 			
						do_last_count <= '1';				
						atwd_start <= '1';					
                		data_new 		<= "0000000000"; 
                		data_old 		<= "0000000000"; 
 					   	supr_compr_state <= idle0 ;   

      		WHEN end_of_event0 => 							   			
  					   	supr_compr_state <= end_of_event1; 					
      		WHEN end_of_event1 => 							   			
   					   	supr_compr_state <= end_of_event2; 					
       		WHEN end_of_event2 => 
--  					wr_rd_init 		<=	'1';
 					IF (compr_done = '0') THEN		-- 			
						compr_done_strb <= '1';				
 				 		compr_done 		<= '1';				
					ELSIF (compr_done = '1') THEN					
 						compr_done_strb <= '0';				
 					END IF;
-- event_end_wait starts counting when LBM READ DONE (LbmReadDone) is asserted.
-- wait for the LBM module to read out compressed data
					IF (event_end_wait = "011") THEN 		
    				  supr_compr_state <= init; 			
					ELSE
    				  supr_compr_state <= end_of_event2; 	
					END IF;
		END CASE;
		END IF;
	END PROCESS  ;

-----------------
-- delta generator
				data_delta <= ('0' & data_new) - ('0' & data_old);  	

----------------------------------
-- LbmReadDone is one clk40 cycle wide. only occurs during end_of_event2
-- stretch it 3 clk20 cycles. 

lbm_pulse_stretcher:PROCESS(clk40, supr_compr_state, reset)
BEGIN
	IF (reset = '1') THEN
		lbm_read_done <= '0';
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
		IF (supr_compr_state <= init) THEN  
				lbm_read_done <= '0';    
		ELSIF (LbmReadDone = '1') THEN 
				lbm_read_done <= '1';  
		END IF;
	END IF;
END PROCESS lbm_pulse_stretcher;	
--------------
-- give BfrDav (data_avail_in) time to go to logic 0, 
-- lbm_read_done will only be asserted during end_of_event2

wait_counter: PROCESS(clk40, supr_compr_state, reset)
BEGIN 
	IF (reset = '1') THEN
 		event_end_wait <= "000";
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			IF (lbm_read_done = '1') THEN
 				event_end_wait <= event_end_wait + 1;
			ELSE
 				event_end_wait <= "000";
			END IF;
	END IF;
END PROCESS wait_counter;

---------------------------------------
     
initializer :PROCESS(clk40, reset)
BEGIN
	IF (reset = '1') THEN
			ring_init 		<= '0';
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
		IF (supr_compr_state <= init) THEN 
			ring_init 		<= '0';		
		ELSIF (supr_compr_state <= idle) THEN 
			ring_init 		<= '1';
		ELSE
			ring_init 		<= '0';		
		END IF;
	END IF;
END PROCESS initializer;	

-------------------------------------------------- 

fifo_wr_req_gen: PROCESS(clk40, supr_compr_state, reset )

  		BEGIN
 			IF (reset = '1') THEN
 	  			compr_active	<= '0'; 
			ELSIF (clk40= '1' ) AND (clk40'EVENT) THEN 
				IF (supr_compr_state = end_of_event2)
					OR (supr_compr_state = init) THEN 
 	  			 compr_active	<= '0'; 
				ELSE
 	  			 compr_active	<= '1'; 
				END IF;
			END IF;
  	END PROCESS fifo_wr_req_gen;

-------------------
-- delay by one clock cycle to synch delta-data and big_small_flag
-- for negative small words the sign flag in data_delta is automatically 
-- in delta_to_write(2). 

data_delta_delayer: PROCESS(clk40, supr_compr_state, reset)
	
  	 BEGIN
	  	IF (reset = '1') THEN
  			 delta_to_write	<= "00000000000" ;
	 	ELSIF ((clk40  = '1') AND (clk40'EVENT)) THEN
  			IF (supr_compr_state = init) THEN 
	 			delta_to_write	<= "00000000000" ;
			ELSIF (supr_compr_state = save) 
					OR (supr_compr_state = wait_end_word0) 
					OR (supr_compr_state = wait_end_word2) 
					THEN
	 			delta_to_write	<= data_delta ;
		    END IF;
		END IF;
   	END PROCESS data_delta_delayer;
				
------------------------------------------------------------------------

--					WRITE RING REGISTER					--

   PROCESS (clk40, supr_compr_state, reset)

    BEGIN
	IF (reset = '1') THEN
				j 	<= 0 ;     
	  			k	<= 0 ;	   	 
				init_wr_pointers <= '0';	 
	  			data_delta_ring <= "000000000000";           
				ring_write_en 	<= '0';   
				ring_write_clk 	<= '0';
				wr_done_flag	<= '0'; 
 				write_ring_state <= wr_init;	
	ELSIF (clk40'EVENT) AND (clk40 = '1') THEN
	  CASE write_ring_state IS
    		WHEN wr_init =>  			
 	  			data_delta_ring  	<= delta_to_write & big_small_flag;           
				ring_write_clk <= '0';
 				ring_write_en <= '0';   
				wr_done_flag	<= '0'; 
				init_wr_pointers <= '1';	 
					j <= 0;  					 
					k <= 0;  

 				IF (supr_compr_state = idle1)  THEN
   						write_ring_state <= wr_idle;  
	  					data_delta_ring  	<= delta_to_write & big_small_flag;          
				ELSE
						write_ring_state <= wr_init;
				END IF;

   		WHEN wr_idle  => 
				wr_done_flag	<= '0';
	  			data_delta_ring  	<= delta_to_write & big_small_flag;  
					j <= 0;  					 
					k <= 0; 	--!!!
   				write_ring_state <= wr_wait;

   		WHEN wr_wait  => 
				wr_done_flag	<= '1';
 					write_ring_state <= wr_data_idle0;
					 						 
   		WHEN wr_data_idle0 =>  						 
				wr_done_flag	<= '0';
				ring_write_en <= '0';   
				IF  ((supr_compr_state = save) 		 
					AND (start_writing = '1'))		 --!!!!
 					OR (supr_compr_state = wait_end_word0) 
 					OR (supr_compr_state = wait_end_word2) THEN
 						write_ring_state <= wr_data_idle;  
				ELSE
						write_ring_state <= wr_data_idle0;
				END IF;

 

    		WHEN wr_data_idle =>  			
 				ring_write_clk 	 <= '0';								 
 				ring_write_en    <= '1';   
 				data_delta_ring  	<= delta_to_write & big_small_flag; 
				IF (big_small_flag = '1') THEN
   					init_wr_pointers <= '0';	 
					IF (init_wr_pointers = '1') THEN 
						j <= 12;    		
					ELSIF j  > 3	THEN
						j <= j - 4;
					ELSE
						j <= j + 12;
					END IF;
 					IF (init_wr_pointers = '1') THEN 
						k <= 12;    
					ELSIF j  > 3	THEN
						k <= j + 12;
					ELSE
						k <= 12;  						 
					END IF; 
	  			ELSE
 					IF k > 4 THEN
  					 init_wr_pointers <= '0';	
					END IF; 
					IF (init_wr_pointers = '1') THEN  	 
						j <= j + 4;    				 
					ELSIF j > 11	THEN
						j <= j - 12;
					ELSE
						j <= j + 4;
					END IF;

 					IF (init_wr_pointers = '1') THEN  	 
						k <= k + 4;   				   
					ELSIF j > 7	THEN
						k <= j + 4;					
					ELSE
						k <= j + 20;
					END IF;
				END IF;

    				write_ring_state <= wr_data;  

     		WHEN wr_data  =>
			  	ring_write_clk <= '1';
				ring_write_en <= '0';   
				
				IF (start_writing = '1') THEN
 					wr_done_flag	<= '0'; 
					write_ring_state <= wr_data_idle;  
  				ELSE
    				write_ring_state <= wr_done; 
					wr_done_flag	<= '1'; 
  				END IF;

     		WHEN wr_done  =>
    			write_ring_state <= wr_wait_new; 
				wr_done_flag	<= '1';
     		WHEN wr_wait_new  =>
				wr_done_flag	<= '1';
				IF  (supr_compr_state = end_of_event0) THEN		 
   						write_ring_state <= wr_init;
				ELSIF (write_wait_new_count = "0100") THEN					
   						write_ring_state <= wr_wait;
				ELSE  
   						write_ring_state <= wr_wait_new;
				END IF;
		END CASE;
	 END IF;
	END PROCESS  ;

-----

write_wait_counter: PROCESS(clk40, reset)

 	 BEGIN
 		 IF (reset = '1') THEN
 			write_wait_new_count <= "0000" ;          		
 		ELSIF ((clk40= '1') AND (clk40'EVENT)) THEN 
			IF (write_ring_state = wr_init) THEN
 				write_wait_new_count <= "0000" ;          	
			ELSIF (write_ring_state = wr_wait_new) 
			 	OR (write_ring_state = wr_done)
			THEN
 				write_wait_new_count <= write_wait_new_count + 1 ; 
			ELSE
 				write_wait_new_count <= "0000" ;          	
			END IF;
 		END IF;
   	END PROCESS write_wait_counter;

----------------
  read_idle_en_delayer0: PROCESS(clk40, reset)

 	 BEGIN
 		 IF (reset = '1') THEN
 			read_idle_en_count <= "0000" ;          		
 		ELSIF ((clk40= '1') AND (clk40'EVENT)) THEN 
			IF (write_ring_state = wr_init) 
			 OR (write_ring_state = wr_idle)  THEN
 				read_idle_en_count <= "0000" ;          	
			ELSIF (read_idle_en_count = "0011") THEN
 				read_idle_en_count <= read_idle_en_count ;          	
			ELSE
 				read_idle_en_count <= read_idle_en_count + 1 ; 
			END IF;
 		END IF;
   	END PROCESS read_idle_en_delayer0;

---------
 read_starter: PROCESS(clk40, reset)

  	 BEGIN
 		IF (reset = '1') THEN
			read_idle_en <= '0';		
 		ELSIF ((clk40= '1') AND (clk40'EVENT)) THEN 
		  IF (write_ring_state = wr_init) THEN
			read_idle_en <= '0';		 	
		  ELSIF (read_idle_en_count < "0010") 
				OR (wr_done_flag = '1') THEN
			     read_idle_en <= '1';		-- start read idle	
		  ELSE
			read_idle_en <= '0';		 
		  END IF;
		END IF;		
   	END PROCESS read_starter;

-------------------------------------------------------------------------------

--					READ RING REGISTER					--


   PROCESS (clk40, supr_compr_state, reset)

      BEGIN
 		IF (reset = '1') THEN 
					nz_rd_done	<= '0'; 	
							i	<= 0 ;     	
	 	 		  			l	<= 0 ;	     	
	  		  	ring_rd_en 	<= '0'; 	 
			read_ring_state <= rd_init;
			
 		ELSIF (clk40'EVENT) AND (clk40 = '1') THEN 	
		  CASE read_ring_state IS		
    		WHEN rd_init =>  			
				i	<= 0;        		  
 	 		  	l	<= 8  ;		 
	  		  	ring_rd_en 	<= '0'; 	 
   				IF  (start_writing = '0') THEN
  					read_ring_state <= rd_init ;  
 				ELSE  
  					read_ring_state <= rd_idle ;
 				END IF;											

    		WHEN rd_idle =>
	  		  	ring_rd_en 	<= '0'; 	
				IF (big_small_flag = '1') THEN  
   					read_ring_state <= rd_big;        
     	  		ELSIF (big_small_flag = '0') THEN	
  					read_ring_state <= rd_small;
				END IF;		
								 
------------------------------------
   		WHEN rd_big =>
   			IF (i < k) THEN  
   				IF (read_idle_en  = '1') THEN 			 
	  				ring_rd_en 	<= '0'; 	 
				ELSE	
		  			ring_rd_en 	<= '1'; 
				END IF;
					nz_rd_done		<= '1';
 				IF i = 8 THEN
					i 	<= 0;	
					l   <= 24;			
				ELSE
	 		  		i	<= 8 ;				 
					l 	<= 16;								
				END IF;	
 			ELSE
				nz_rd_done	<= '0'; 
	  		  	ring_rd_en 	<= '0'; 	 
			END IF;		
 				read_ring_state <= rd_xtra_big ;		

------------------------------------------
    	WHEN rd_xtra_big =>  	 
 		  IF (ring_write_clk = '1')
 			OR (supr_compr_state = end_of_event1) THEN 
				nz_rd_done	<= '0'; 
			 IF (l <= k ) THEN	
  				IF (read_idle_en  = '1') THEN 			 
	  				ring_rd_en 	<= '0'; 	 
				ELSE	
  		  		ring_rd_en 	<= '1'; 
				END IF;
					 	 
 				IF i = 8 THEN
					i 	<= 0;	
					l   <= 24;			
				ELSE
	 		  		i	<= 8 ;				 
					l 	<= 16;								
				END IF;		 
			 ELSIF (nz_rd_done	<= '1') THEN 
	  		  		ring_rd_en 	<= '0'; 	 
 			 ELSE
	  		  		ring_rd_en 	<= '0'; 	 
					i <= i;
					l  <= l;			
			END IF;
		ELSE
	  				ring_rd_en 	<= '0'; 	 
		END IF;
		
 		  IF (supr_compr_state = end_of_event1) THEN 
  				read_ring_state <= rd_init ;	 
		  ELSIF (ring_write_clk = '1') THEN
 				IF (read_idle_en  = '1') THEN 			 
    				read_ring_state <= rd_idle;  	 		
				ELSIF (big_small_flag = '1') THEN  
  					read_ring_state <= rd_big ; 
 				ELSIF (big_small_flag = '0') THEN  
  					read_ring_state <= rd_idle ;
				END IF;
		  ELSE 
 					read_ring_state <= rd_xtra_big ;
 		  END IF;	
-----------------------------------------															
      	WHEN rd_small =>
		  IF (ring_write_clk = '1') 
 	    	 OR (supr_compr_state = end_of_event2) THEN 
 			IF (l = k )  THEN
   				  IF (read_idle_en  = '1') THEN 			 
	  				ring_rd_en 	<= '0'; 	 
				  ELSE	
  		  			ring_rd_en 	<= '1'; 
				  END IF;
								 
 				  IF i = 8 THEN
					i 	<= 0;	
					l   <= 24;			
				  ELSE
	 		  		i	<= 8 ;				 
					l 	<= 16;								
				  END IF;		 			
		  	  ELSE
	  		  		ring_rd_en 	<= '0'; 	 
			  END IF;
		  	   IF (supr_compr_state = end_of_event2) THEN 
  					read_ring_state <= rd_init ;	 	
			   ELSIF (read_idle_en  = '1') THEN 			  
    				read_ring_state <= rd_idle;  	 		
			   ELSIF (big_small_flag = '0') THEN  
 						read_ring_state <= rd_idle ;  
			   ELSE
    					read_ring_state <= rd_big; 		 		
			   END IF;
		   ELSE
						read_ring_state <= rd_small ;  
		  END IF;
		END CASE;
   	 END IF;
	END PROCESS  ;
 
-----------------------------
-- write to ring register
 wr_ring_reg: PROCESS(reset, clk40, ring_init)

BEGIN
		IF (reset = '1') THEN
		  	ring_data	<= "0000000000000000";          
 		ELSIF ((clk40= '1') AND (clk40'EVENT)) THEN  
			IF (ring_init = '1') THEN			
		  		ring_data	<= "0000000000000000";
 			ELSIF (ring_write_en = '1') THEN
 			  IF (data_delta_ring(0) = '1') THEN
				IF (j = 0) THEN
		  		ring_data <= data_delta_ring & ring_data(3 DOWNTO 0);  
				ELSIF (j = 4) THEN
		  		ring_data  <= data_delta_ring(7 DOWNTO 0) & ring_data(7 DOWNTO 4) & data_delta_ring(11 DOWNTO 8); 
				ELSIF (j = 8) THEN
		  		ring_data  <= data_delta_ring(3 DOWNTO 0) & ring_data(11 DOWNTO 8) & data_delta_ring(11 DOWNTO 4);  
				ELSIF (j = 12) THEN
		  		ring_data <=  ring_data(15 DOWNTO 12) & (data_delta_ring); 
				ELSE
				ring_data <=  ring_data;  
  				END IF;
 			  ELSE
 				IF (j = 0) THEN
				  	ring_data  <= data_delta_ring(3 DOWNTO 0) & ring_data(11 DOWNTO 0);  
				ELSIF (j = 4) THEN
			  		ring_data <=  ring_data(15 DOWNTO 4) & data_delta_ring(3 DOWNTO 0);   
 				ELSIF (j = 8) THEN
			  		ring_data <= ring_data(15 DOWNTO 8) & data_delta_ring(3 DOWNTO 0) & ring_data(3 DOWNTO 0);  
 				ELSIF (j = 12) THEN
			  		ring_data  <= ring_data(15 DOWNTO 12) & data_delta_ring(3 DOWNTO 0) & ring_data(7 DOWNTO 0); 
				ELSE
			  		ring_data <= ring_data;
 			    END IF;
 			  END IF;
 			END IF;
		END IF;
 END PROCESS wr_ring_reg;

--------------------------------------------
PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			ring_data_dly <= "0000000000000000";          
 		ELSIF (clk40 = '0') AND (clk40'EVENT) THEN 
 			IF (ring_init = '1') THEN			
  			ring_data_dly <= "0000000000000000";          
			ELSE
  			ring_data_dly <= ring_data; 
			END IF; 	
		END IF; 	
 END PROCESS ;

-- generate enable to write compr_data into the ram in compressor_delta_out
PROCESS (clk40, supr_compr_state, reset )
BEGIN
			IF (reset = '1') THEN
   			ram_wr_en <= '0' ;          
  		ELSIF (clk40 = '0') AND (clk40'EVENT) THEN 
  			IF (ring_init = '1') THEN			
   			ram_wr_en <= '0' ;          
				ELSE
   			ram_wr_en <= ring_rd_en ;          
				END IF; 	
			END IF; 	
END PROCESS ;
----

    rd_ring_reg: PROCESS(clk40 , ring_init, reset )

 		BEGIN
 			IF (reset = '1') THEN
	 			h_compr_data	<= "00000000";          
 	  	ELSIF ((clk40 = '1') AND (clk40 'EVENT)) THEN 
 			IF (ring_init = '1') THEN			
	 			h_compr_data	<= "00000000";          
	  		 	ELSIF (ring_rd_en  = '1') THEN    
	 			IF (i = 0) THEN
		  		h_compr_data <= ring_data_dly(15 DOWNTO 8);  
	   			ELSIF (i = 1)  THEN
		  		h_compr_data <= ring_data_dly(0) & ring_data_dly(15 DOWNTO 9);  
				ELSIF (	i = 2) THEN
		  		h_compr_data <= ring_data_dly(1 DOWNTO 0) & ring_data_dly(15 DOWNTO 10); 
				ELSIF (i = 3) THEN
		  		h_compr_data <= ring_data_dly(2 DOWNTO 0) & ring_data_dly(15 DOWNTO 11);  
				ELSIF (i = 4) THEN
		  		h_compr_data <= ring_data_dly(3 DOWNTO 0) & ring_data_dly(15 DOWNTO 12); 
				ELSIF (i = 5)  THEN
		  		h_compr_data <= ring_data_dly(4 DOWNTO 0) & ring_data_dly(15 DOWNTO 13);
				ELSIF (i = 6)  THEN
		  		h_compr_data <= ring_data_dly(5 DOWNTO 0) & ring_data_dly(15 DOWNTO 14); 
				ELSIF (i = 7)  THEN
		  		h_compr_data <= ring_data_dly(6 DOWNTO 0) & ring_data_dly(15); 
	  			ELSIF (i = 8)  THEN
		  		h_compr_data <=  ring_data_dly(7 DOWNTO 0);  
				ELSIF (i = 9)  THEN
		  		h_compr_data <= ring_data_dly(8 DOWNTO 1);  
				ELSIF (i = 10)  THEN
		  		h_compr_data <= ring_data_dly(9 DOWNTO 2);  
				ELSIF (i = 11)  THEN
		  		h_compr_data <= ring_data_dly(10 DOWNTO 3);  
				ELSIF (i = 12)  THEN
		  		h_compr_data <=  ring_data_dly(11 DOWNTO 4);  
				ELSIF (i = 13)  THEN
		  		h_compr_data <=  ring_data_dly(12 DOWNTO 5);
				ELSIF (i = 14)  THEN
		  		h_compr_data <= ring_data_dly(13 DOWNTO 6); 
				ELSIF (i = 15)  THEN
		  		h_compr_data <= ring_data_dly(14 DOWNTO 7); 
	 			END IF;
	 
		   END IF;
 	END IF;
 	END PROCESS rd_ring_reg;


----------------------------------------------------------

-- THE BUFFER INTERFACE IS DESIGNED BELOW 

----------------------------------------------------------

 fadc_clk_gen: PROCESS(clk40, supr_compr_state, reset )

		BEGIN
		IF (reset = '1') THEN
			fadc_bfr_clk <= '0' ;
 			fadc_bfr_en <= '0';
			fadc_address <= "1111111111" ;	 -- no of bits allow for a count of 511 
		ELSIF (clk40 = '1') AND (clk40'EVENT) THEN 
			IF (supr_compr_state = init)  
  				OR (supr_compr_state = idle ) 
  				OR (supr_compr_state = idle0 ) 
  				OR (supr_compr_state = end_of_event2 ) THEN
					fadc_bfr_clk <= '0' ;
 					fadc_bfr_en <= '0';
					fadc_address <= "1111111111" ;	 
			ELSIF 	(fadc_done = '1') OR  						
--					(fadc_address = 41) THEN   --- 40 is for testing only, CHANGE to 511
			 		(fadc_address = 511) THEN  -- 511 will generate 128 FadcBfrAddresses
					fadc_bfr_clk <= '0' ;   
 					fadc_bfr_en <= '0';
					fadc_address <= fadc_address;  
			ELSE
					fadc_bfr_clk <= NOT fadc_bfr_clk  ;
 					fadc_bfr_en <= '1';
					fadc_address <= fadc_address + 1 ; -- counts from 0
			
			END IF;
		END IF;
 	END PROCESS fadc_clk_gen;

--------------------------------------------------
-- multiplex the two fadc data words contained in FadcData
-- Fadc_ data(n) = D[9..0], fadc_data(n+1) = D[25..16]

 fadc_data <= FadcData(9 DOWNTO 0) WHEN (fadc_address(1) = '0')  ELSE
			  FadcData(25 DOWNTO 16) WHEN (fadc_address(1) = '1')  ELSE
			  fadc_data;

--------------------------------------------------------
 atwd_clk_gen: PROCESS(clk40, supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN
			atwd_bfr_clk <= '0' ;
 			atwd_bfr_en <= '0';		
			atwd_address <= "1111111111" ;   
		ELSIF (clk40 = '1') AND (clk40'EVENT) THEN 
			IF (supr_compr_state = init)  			-- reset atwd_address
  				OR (supr_compr_state = end_of_event2 ) THEN
					atwd_bfr_clk <= '0' ;
  					atwd_bfr_en <= '0';
					atwd_address <= "1111111111" ;   
			ELSIF (supr_compr_state = idle ) 	 	
  				OR (supr_compr_state = idle0 )  THEN   
					atwd_bfr_clk <= '0' ;
  					atwd_bfr_en <= '0';
					atwd_address <= atwd_address ;   
 			ELSIF ((atwd_start = '1') AND (atwd_ch_done = '0')) THEN
					atwd_bfr_clk <= NOT atwd_bfr_clk;  
 					atwd_bfr_en <= '1';
					atwd_address <= atwd_address + 1 ;   
			ELSE
					atwd_bfr_clk <= '0' ;
 					atwd_bfr_en <= '0';
					atwd_address <= atwd_address ;   
			END IF;
		END IF;
 	END PROCESS atwd_clk_gen;

-----------------------------------------------------------

atwd_word_counter: PROCESS(clk40 , supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN 
				atwd_word_count <= "000000000" ;	-- sic
				atwd_ch_done <= '0';				 	
 		ELSIF (clk40 = '1') AND (clk40'EVENT) THEN 
			IF (supr_compr_state = init) 			
			OR (supr_compr_state = idle  )    
			OR (supr_compr_state = idle0 ) THEN  
				atwd_word_count <= "000000000" ;
				atwd_ch_done <= '0';		
			ELSIF  (atwd_bfr_en = '1') THEN
				IF (atwd_done = '1')  	
--					OR (atwd_word_count = 30) THEN	-- 30 is for testing only, CHANGE to 254
					OR (atwd_word_count = 254) THEN	-- 254 will generate 256 atwd_addresses
					atwd_word_count <= atwd_word_count;
					atwd_ch_done <= '1';
			 	ELSE
					atwd_word_count <= atwd_word_count + 1 ;
 					atwd_ch_done <= '0' ;
				END IF;
			ELSE   
				atwd_word_count 	<= atwd_word_count;
				atwd_ch_done 		<= atwd_ch_done;
			END IF;
		END IF;
 	END PROCESS atwd_word_counter;

--------------------------------------------------

 atwd_data <= AtwdData(9 DOWNTO 0) WHEN (atwd_word_count(1) = '0')  ELSE
			  AtwdData(25 DOWNTO 16) WHEN (atwd_word_count(1) = '1')  ELSE
			  atwd_data;

-----

-- delay atwd_ch_done to enable atwd_ch_count 

atwd_ch_count_delayer : PROCESS (reset, clk40)
 BEGIN
 	IF (reset = '1') THEN
     	atwd_ch_done_dly <= '0';
  	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			atwd_ch_done_dly <= atwd_ch_done;
	END IF;
 END PROCESS atwd_ch_count_delayer;

atwd_ch_count_en <= atwd_ch_done AND NOT atwd_ch_done_dly;

-----------------------------------------------------------

 atwd_bfr_size <= ('0' & AtwdSize) + 1;


----------
-- generate atwd_done, when all channels are done, 
-- as defined by AtwdMode and AtwdSize.

 atwd_ch_counter: PROCESS (clk40, supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN
			atwd_ch_count <= "000" ;
			atwd_done <= '0';				-- all channels are read out
	  	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			IF  (supr_compr_state = init) THEN		
					atwd_ch_count <= "000" ;
					atwd_done <= '0';		
			ELSIF (atwd_ch_count = atwd_bfr_size ) AND 
					(atwd_start = '1')	THEN	
					atwd_ch_count <= atwd_ch_count;
					atwd_done <= '1';
			ELSIF (atwd_ch_count_en = '1') THEN
					atwd_ch_count <= atwd_ch_count + 1 ;
					atwd_done <= '0';
			END IF;
		END IF;
 END PROCESS atwd_ch_counter;

----------------------
-- generate clk40 signals
 compr_done_shortner : PROCESS (clk40, reset)
  BEGIN
		IF (reset = '1') THEN
			compr_done_strb_clk40 <= '0' ;
	  	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			compr_done_strb_clk40 <= compr_done_strb ;
		END IF;	
  END PROCESS compr_done_shortner;

-- create clk40 wide pulse
 bfr_rd_done_compr <= compr_done_strb AND (NOT compr_done_strb_clk40);

------

 address_selector: PROCESS (reset, compr_mode,  atwd_address, fadc_address, bfr_rd_done_compr, 
		AtwdBfrAddrExt, FadcBfrAddrExt, LbmReadDone, RamDav)
BEGIN
  	IF (reset = '1') THEN
 		AtwdBfrAddr <= "00000000";
 		FadcBfrAddr <= "0000000";
		BfrReadDone <= '0';	
	ELSIF (compr_mode = "01") THEN 			   
 		   AtwdBfrAddr <= atwd_address(9 DOWNTO 2);
 		   FadcBfrAddr <= fadc_address(8 DOWNTO 2); 
		   BfrReadDone <= bfr_rd_done_compr;
	ELSIF (compr_mode = "10") THEN 		 
 		   	IF (RamDav = '0') THEN
 	 		  AtwdBfrAddr <= atwd_address(9 DOWNTO 2);
 	 		  FadcBfrAddr <= fadc_address(8 DOWNTO 2); 
			  BfrReadDone <= LbmReadDone;	 	  
		   	ELSE
 			  AtwdBfrAddr <= AtwdBfrAddrExt; 
 			  FadcBfrAddr <= FadcBfrAddrExt; 
			  BfrReadDone <= LbmReadDone;	 	  
 		   END IF;							  
	ELSE 
 		  AtwdBfrAddr <= AtwdBfrAddrExt; 	 
 		  FadcBfrAddr <= FadcBfrAddrExt; 
		  BfrReadDone <= LbmReadDone;	 
  END IF;
END PROCESS address_selector;

-------------------------------------
-- to input buffer
FadcBfrClk	 		<= fadc_bfr_clk;
AtwdBfrClk	 		<= atwd_bfr_clk;
AtwdChNumber 		<= atwd_ch_count;

-- uncmpr 
UnCmprAtwdData		<= AtwdData; -- changed to fit into I/O pins, replace to compile into top entity 
UnCmprFadcData		<= FadcData; -- changed to fit into I/O pins, replace to compile into top entity
UnCmprHeader		<= Header;	 --!! Uncomment out

-- compr and test
RingWriteClk		<= ring_write_clk;
ComprDataOut		<= h_compr_data;
RingData			<= ring_data;

-- to output buffer
ComprActive	 		<= compr_active;   -- used for compressor_out_synch module
ComprDoneStrb		<= compr_done_strb; 
RingReadEn			<= ram_wr_en ; 

---
--testing
DataNew 			<= data_new ;
DataOld 			<= data_old ;
Datadelta 			<= data_delta ;
DataDeltaRing		<= data_delta_ring;
Iout 				<= i ;
Jout				<= j ;
Kout				<= k ;
Lout				<= l ;

------------------------
----------------------------------

END rtl ;


--
--
--
--
--
--
--
--