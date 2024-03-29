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
-- Last update: June 28 04
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: 
-- atwd and fadc data are saved in an external buffer module, and sent to this module. 
-- Processing is of two types: supression and compression. 
-- For suppression, data is compared to a lower threshold set by the CPU. This threshold is set above the 
-- baseline by a small margin.  
-- Zero supressed data is then compressed, by counting the number of repetitions of the same value data, and
-- encoding the data as: "Data Value, Number of same values".
-- It is followed by "Hoffmann-lite" compression, which is a mixture of Bytes and Bits. Zero values are 
-- represented by a logic 0 bit, non zero values are represented by bytes. An additional bit = logic 1
-- preceeds a non-zero byte.
--
-- The data is processed and sent to the compressor_out.vhd module, where it is written into a temporary RAM. It
-- is read out from the RAM by a Look Back Memory Controller, for storage in the LBM.
-- The LBM is read out under the control of the an external module, in response to a request from the CPU.
-- In addition, uncompressed data and related timing signals are processed and outputted.
--
-------------------------------------------------------------------------------
-- Copyright (c) 2003 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
-- Jan 18 05 				JS		AtwdData/FadcData replaced by atwd_data/fadc_data, in the threshold comparators
--									in the data_suppressor Process. When the data words were changed to 32 bits, the old 
--									method using the 10 bit word had not been updated. 
-- May 12					JS		
--									
-- ******************************************************************************************************************

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;  -- use to count std_logic_vectors
USE WORK.icecube_data_types.all;
---------------
ENTITY compressor_in IS
	PORT(
-- system signals
		reset				: IN	STD_LOGIC;
		clk20			   	: IN	STD_LOGIC;		
		clk40		   		: IN	STD_LOGIC;		
------------------		
-- CPU register signals
  		Ch0aLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch1aLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch2aLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch3aLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
   		Ch0bLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch1bLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch2bLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		Ch3bLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		FadcLoTh			: IN	STD_LOGIC_VECTOR (9 DOWNTO 0); 
  		ComprMode			: IN	STD_LOGIC_VECTOR (1 DOWNTO 0); 
------------------
-- interface signals with the fadc and atwd buffers 
		FadcData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
 		AtwdData			: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 
		BfrDav				: IN	STD_LOGIC;					     

 		AtwdAvail			: IN 	STD_LOGIC;
		FadcAvail			: IN 	STD_LOGIC;
		Atwd_AB 			: IN 	STD_LOGIC;
		AtwdSize			: IN 	STD_LOGIC_VECTOR (1 DOWNTO 0);
		Header				: IN 	HEADER_VECTOR;
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
  		UnCmprFadcData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);  
  		UnCmprAtwdData		: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);  
	  	UnCmprHeader		: OUT	HEADER_VECTOR; 					 

--------------------
--        FadcDataOut		: OUT   STD_LOGIC_VECTOR (9 DOWNTO 0) ;     




------------------       
-- interface signals with the compressor output module
        ComprActive			: OUT   STD_LOGIC ;  
        ComprDoneStrb		: OUT   STD_LOGIC ;    
        ComprDataOut		: OUT   STD_LOGIC_VECTOR (7 DOWNTO 0) ;     
		RingReadEn			: OUT	STD_LOGIC;		  

-----------------
-- test signals 
  		RingData			: OUT	STD_LOGIC_VECTOR (17 DOWNTO 0);  

-- test signals for the input buffer interface
		FadcBfrClk	   		: OUT	STD_LOGIC;		 
		AtwdBfrClk	   		: OUT	STD_LOGIC;		   
  		AtwdChNumber		: OUT	STD_LOGIC_VECTOR (2 DOWNTO 0);  

        RingWriteClk		: OUT   STD_LOGIC   
		);

END compressor_in ;
---------------------------

ARCHITECTURE rtl OF compressor_in IS
	TYPE state_type IS (init, idle, idle0, idle1, save, get, count_end_byte0, count_end_byte, ch_comp_done,  
						process_atwd, end_of_event0, end_of_event1, end_of_event1a, end_of_event2, end_of_event3);    
 	TYPE write_ring_type IS (wr_init, wr_data_idle0, wr_data_idle, wr_data, 
								wr_count_idle, wr_count, wr_last_count);
  	TYPE read_ring_type IS (rd_init, rd_idle, rd_nz, rd_xtra_nz, 
 								rd_zero);
----------------

	SIGNAL supr_compr_state		: 	state_type;
	SIGNAL write_ring_state		: 	write_ring_type;
 	SIGNAL read_ring_state		: 	read_ring_type;

	SIGNAL st_mach_init			: 	STD_LOGIC;
	SIGNAL ring_init			: 	STD_LOGIC;

  	SIGNAL   th_lo0a				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
  	SIGNAL   th_lo1a				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
  	SIGNAL   th_lo2a				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
	SIGNAL   th_lo3a				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
  	SIGNAL   th_lo0b				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
  	SIGNAL   th_lo1b				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
  	SIGNAL   th_lo2b				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
	SIGNAL   th_lo3b				: STD_LOGIC_VECTOR (9 DOWNTO 0) ; 
	SIGNAL   th_fadc				: STD_LOGIC_VECTOR (9 DOWNTO 0) ;  
	SIGNAL   compr_mode				: STD_LOGIC_VECTOR (1 DOWNTO 0) ;  
	SIGNAL   atwd_bfr_size	 		: STD_LOGIC_VECTOR (2 DOWNTO 0) ;

	SIGNAL   lbm_read_done			: STD_LOGIC; 
	SIGNAL   event_end_wait			: STD_LOGIC_VECTOR (2 DOWNTO 0) ; 
	
	SIGNAL   ch0_start			 	: STD_LOGIC; 
	SIGNAL   ch1_start			 	: STD_LOGIC; 
	SIGNAL   ch2_start			 	: STD_LOGIC; 
	SIGNAL   ch3_start			 	: STD_LOGIC; 

	SIGNAL   data_exceeds_zero	 	: STD_LOGIC;
	SIGNAL   count_exceeds_zero  	: STD_ULOGIC;  

	SIGNAL   cmp_data_t0_t1		 	: STD_LOGIC;
	SIGNAL   old_equals_new_data	: STD_LOGIC;
	
	SIGNAL   compr_active			: STD_LOGIC;
  	SIGNAL   compr_done_strb 		: STD_LOGIC; 
  	SIGNAL   compr_done_strb_clk40	: STD_LOGIC; 
  	SIGNAL   bfr_rd_done_compr 		: STD_LOGIC; 
  	SIGNAL   compr_done 			: STD_LOGIC; 
	SIGNAL   ring_write_clk 		: STD_LOGIC; 
	SIGNAL   ring_write_clk1		: STD_LOGIC; 
	SIGNAL   ring_write_en			: STD_LOGIC; 
	SIGNAL   ring_write_en_dly		: STD_LOGIC; 
	SIGNAL   ring_write_en_dly1		: STD_LOGIC; 
   	SIGNAL   ring_rd_en				: STD_LOGIC; 
   	SIGNAL   ring_rd_en_dly			: STD_LOGIC; 
   	SIGNAL   ring_rd_en_dly1		: STD_LOGIC; 
   	SIGNAL   ram_wr_en				: STD_LOGIC; 
 	SIGNAL   init_k 				: STD_LOGIC;  


   	SIGNAL   read_idle_en			: STD_LOGIC; 
   	SIGNAL   read_position_flag 	: STD_LOGIC; 
  	SIGNAL	 nz_rd_done				: STD_LOGIC; 

 	SIGNAL   data_supr0			 	: STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL   data_t0			 	: STD_LOGIC_VECTOR (9 DOWNTO 0);

  	SIGNAL   same_value_count		: STD_LOGIC_VECTOR (9 DOWNTO 0); 
 	SIGNAL   same_value_count1		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
	SIGNAL   flagged_rl_data		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
  	SIGNAL   flagged_rl_count		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
 	SIGNAL   flagged_rl_compr		: STD_LOGIC_VECTOR (10 DOWNTO 0); 
 	SIGNAL   flagged_rl_compr_dly	: STD_LOGIC_VECTOR (10 DOWNTO 0); 

	SIGNAL   ring_data	 			: STD_LOGIC_VECTOR (17 DOWNTO 0);
	SIGNAL   ring_data_dly 			: STD_LOGIC_VECTOR (17 DOWNTO 0);
	SIGNAL   ring_data_dly1			: STD_LOGIC_VECTOR (17 DOWNTO 0);
	SIGNAL   h_compr_data	 		: STD_LOGIC_VECTOR (7 DOWNTO 0);

  	SIGNAL   i_dly1 				: INTEGER RANGE 31 DOWNTO 0 ;
  	SIGNAL   i_dly 					: INTEGER RANGE 31 DOWNTO 0 ;	
 	SIGNAL   j_dly					: INTEGER RANGE 31 DOWNTO 0 ;	
  	SIGNAL   i 						: INTEGER RANGE 31 DOWNTO 0 ;	
 	SIGNAL   j						: INTEGER RANGE 31 DOWNTO 0 ;	
  	SIGNAL   k 						: INTEGER RANGE 63 DOWNTO 0 ;	
 	SIGNAL   l 						: INTEGER RANGE 63 DOWNTO 0 ;		
 	SIGNAL   m 						: INTEGER RANGE 63 DOWNTO 0 ;		
   	SIGNAL   y 						: INTEGER RANGE 31 DOWNTO 0 ;	
   	SIGNAL   z 						: INTEGER RANGE 31 DOWNTO 0 ;	
  	SIGNAL   p 						: INTEGER RANGE 63 DOWNTO 0 ;	

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



BEGIN

---------------------------------------------------
   PROCESS (clk20, reset)

      BEGIN
		IF (reset = '1') THEN
			supr_compr_state <= init;
			st_mach_init 	<=	'1';
			ring_init 	<=	'1';
		ELSIF (clk20'EVENT) AND (clk20 = '1') THEN

		  CASE supr_compr_state IS

--
    		WHEN init  =>  	
			compr_mode 		<= ComprMode;				 	
			atwd_start 		<= '0';
			fadc_done 		<= '0';								
			compr_done_strb	<= '0';				
			compr_done 		<= '0';				
            data_t0 		<= data_supr0 ;  		
			do_last_count 	<= '0';		
									
			IF (BfrDav = '1') THEN
				st_mach_init 	<=	'0';
				ring_init 	<=	'0';
				supr_compr_state <= idle;
			ELSE
				supr_compr_state <= init;			
			END IF;							

			WHEN idle  =>
				st_mach_init 	<=	'0';
				ring_init 	<=	'0';
 				IF (compr_mode = "00") OR (FadcAvail = '0') THEN   	
					fadc_done <= '1';							
					supr_compr_state <= end_of_event3;			  
				ELSE											
					supr_compr_state <= idle0;  						
            	END IF;		


			WHEN idle0  =>			
				do_last_count <= '1';								
             	data_t0 	<= data_supr0 ;  	 
				supr_compr_state <= idle1;

			WHEN idle1  =>									 
				do_last_count <= '1';								
                data_t0 		<= data_supr0 ; 
								 
			IF (fadc_bfr_en = '1') AND (fadc_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSIF (atwd_bfr_en= '1') AND (atwd_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSE
				supr_compr_state <= idle1 ;
            END IF;


    		WHEN save =>  			
				do_last_count <= '0';					 			
            	data_t0 <= data_supr0 ; 		
 				supr_compr_state <= get;

    		WHEN get =>  	
		   	
			IF (fadc_bfr_en = '1') AND (fadc_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSIF (atwd_bfr_en= '1') AND (atwd_bfr_clk = '1') THEN
				supr_compr_state <= save ;
			ELSE
				supr_compr_state 	<= count_end_byte0;	
          END IF;
	
   			WHEN count_end_byte0 => 							  			
				supr_compr_state <= count_end_byte ;	

   			WHEN count_end_byte => 							  			
				do_last_count <= '1';					 		
				supr_compr_state <= ch_comp_done ;	

-- 
 
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
 					   	supr_compr_state <= idle0 ;   

      		WHEN end_of_event0 => 							   			
  					   	supr_compr_state <= end_of_event1; 					
      		WHEN end_of_event1 => 							   			
   					   	supr_compr_state <= end_of_event1a; 
      		WHEN end_of_event1a => 							  			
   					   	supr_compr_state <= end_of_event2; 	
       		WHEN end_of_event2 => 							  			
   					   	supr_compr_state <= end_of_event3; 					
       		WHEN end_of_event3 => 
  					IF (compr_done = '0') THEN		-- 			
						compr_done_strb <= '1';				
 				 		compr_done 		<= '1';				
					ELSIF (compr_done = '1') THEN					
 						compr_done_strb <= '0';				
 					END IF;
-- 
					IF (event_end_wait = "011") THEN 		
    				  supr_compr_state <= init; 			
					  st_mach_init 	<=	'1';
					ELSE
    				  supr_compr_state <= end_of_event3; 	
					END IF;
		END CASE;
		END IF;
	END PROCESS  ;


----------------------------------------------------------

 		  	th_lo0a 	<= Ch0aLoTh ; 	 
			th_lo1a 	<= Ch1aLoTh ; 	 
			th_lo2a 	<= Ch2aLoTh ; 	 
			th_lo3a 	<= Ch3aLoTh ; 	 
		  	th_lo0b 	<= Ch0bLoTh ; 	 
			th_lo1b 	<= Ch1bLoTh ; 	 
			th_lo2b 	<= Ch2bLoTh ; 	 
			th_lo3b 	<= Ch3bLoTh ; 	 
			th_fadc 	<= FadcLoTh ;

----------------------------------

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

wait_counter: PROCESS(clk20, supr_compr_state, reset)
BEGIN 
	IF (reset = '1') THEN
 		event_end_wait <= "000";
	ELSIF (clk20 = '1') AND (clk20'EVENT) THEN
			IF (lbm_read_done = '1') THEN
 				event_end_wait <= event_end_wait + 1;
			ELSE
 				event_end_wait <= "000";
			END IF;
	END IF;
END PROCESS wait_counter;

---------------------------------------	
--  

fifo_wr_req_gen: PROCESS(clk20, supr_compr_state, reset )

  		BEGIN
 			IF (reset = '1') THEN
 	  			compr_active	<= '0'; 
			ELSIF (clk20= '1' ) AND (clk20'EVENT) THEN 
				IF (supr_compr_state = end_of_event3)
					OR (supr_compr_state = init) THEN 
 	  			 compr_active	<= '0'; 
				ELSE
 	  			 compr_active	<= '1'; 
				END IF;
			END IF;
  	END PROCESS fifo_wr_req_gen;

------------------------------------------------------------

same_d_counter: PROCESS (clk20, supr_compr_state, reset )
 
BEGIN
 		IF (reset = '1') THEN
  			same_value_count1 <= "11111111111" ;
		ELSIF (clk20 = '1') AND (clk20'EVENT) THEN 
  			IF (supr_compr_state = get) AND (cmp_data_t0_t1= '1') THEN 
	 	  			  same_value_count1 <= same_value_count1 + 1 ;	
  			ELSIF (supr_compr_state = get) AND (atwd_bfr_en = '0') THEN
	 	  			  same_value_count1 <= same_value_count1 + 1 ;	 
 			ELSIF (cmp_data_t0_t1= '0') AND (supr_compr_state = save)  THEN    
	  				same_value_count1 <= "11111111111" ;  
			ELSIF (write_ring_state = wr_last_count) 
					OR (supr_compr_state = idle1) THEN 		--reset count Dec 3 04
	  				same_value_count1 <= "11111111111" ;  
			END IF;		 						 					
		END IF;
 END PROCESS same_d_counter;
----------------------------------------------------------
  same_d_counter1: PROCESS(clk20 , supr_compr_state, reset )

		BEGIN
 		IF (reset = '1') THEN
  			same_value_count  <= "1111111111" ;
 		ELSIF (clk20 = '1') AND (clk20'EVENT) THEN  
			IF (supr_compr_state = init) THEN 
			  	same_value_count <= "1111111111" ;
			ELSE
				same_value_count <= same_value_count1(9 DOWNTO 0) ;
			END IF;
		END IF;
 	END PROCESS same_d_counter1;

---------------------------------------

 old_new_comparator: PROCESS(clk40, supr_compr_state, reset )

 	 BEGIN
  		IF (reset = '1') THEN
 			cmp_data_t0_t1	<= '0' ;          
 	 	ELSIF ((clk40= '0') AND (clk40'EVENT)) THEN	
			IF (data_supr0 = data_t0) THEN 
 				cmp_data_t0_t1	<= '1' ;          
			ELSIF (supr_compr_state = init) THEN 
 				cmp_data_t0_t1	<= '0' ;   
			ELSE        
 				cmp_data_t0_t1	<= '0' ;    
 		 	END IF;
 		END IF;
   	END PROCESS old_new_comparator;

----------------------------------------------------------
  
 old_new_synch: PROCESS(clk20, supr_compr_state, reset)
			
		BEGIN
  		  IF (reset = '1') THEN
	  			old_equals_new_data	<= '0' ; 
	 	  ELSIF ((clk20 = '1') AND (clk20'EVENT)) THEN  
		   	 IF (supr_compr_state = init) 
			   OR (supr_compr_state = end_of_event0 ) THEN   
	  			old_equals_new_data	<= '0' ; 
			 ELSIF (do_last_count = '1') THEN				 			
	  			old_equals_new_data	<= '0' ;           
			 ELSE
		  		old_equals_new_data	<= cmp_data_t0_t1 ;       
			 END IF;
		  END IF;
 	END PROCESS old_new_synch;

----------------------------
 
data_suppressor: PROCESS(clk20, supr_compr_state, reset)

 	 BEGIN
  		IF (reset = '1') THEN
 			data_supr0	<= "0000000000" ;
 	 	ELSIF ((clk20  = '0') AND (clk20'EVENT)) THEN
			IF (supr_compr_state = save) THEN
				IF (atwd_bfr_en = '1') AND (fadc_bfr_en = '0') THEN
					IF 	  (atwd_ch_count = "011") THEN 
						IF ((Atwd_AB = '0') AND (atwd_data > th_lo3a)) 
							OR ((Atwd_AB = '1') AND (atwd_data > th_lo3b))
							OR (atwd_address(7 DOWNTO 2) > "111011") THEN   
   							data_supr0	<= atwd_data ;					   
						ELSE 
		 					data_supr0	<= "0000000000" ; 
						END IF;
					ELSIF (atwd_ch_count = "010") THEN
						IF ((Atwd_AB = '0') AND (atwd_data > th_lo2a)) 
							OR ((Atwd_AB = '1') AND (atwd_data > th_lo2b))   
							OR (atwd_address(7 DOWNTO 2) > "111011") THEN   
   							data_supr0	<= atwd_data ; 
						ELSE 
		 					data_supr0	<= "0000000000" ; 
						END IF;
					ELSIF (atwd_ch_count = "001") THEN
						IF ((Atwd_AB = '0') AND (atwd_data > th_lo1a)) 
							OR ((Atwd_AB = '1') AND (atwd_data > th_lo1b))   
							OR (atwd_address(7 DOWNTO 2) > "111011") THEN    
   							data_supr0	<= atwd_data ; 
						ELSE 
		 					data_supr0	<= "0000000000" ; 
						END IF;
					ELSIF (atwd_ch_count = "000") THEN
						IF ((Atwd_AB = '0') AND (atwd_data > th_lo0a)) 
							OR ((Atwd_AB = '1') AND (atwd_data > th_lo0b))   
 							OR (atwd_address(7 DOWNTO 2) > "111011") THEN  
  							data_supr0	<= atwd_data ; 
						ELSE 
		 					data_supr0	<= "0000000000" ; 
						END IF;
					ELSE
		 					data_supr0	<= "0000000000" ; 
					END IF;
 				ELSIF (atwd_bfr_en = '0') AND (fadc_bfr_en = '1') THEN
					IF (fadc_data > th_fadc) 
						OR (fadc_address(8 DOWNTO 2) < "0000100") THEN           
 						data_supr0	<= fadc_data ; 
					ELSE		
 						data_supr0	<= "0000000000" ; 
					END IF;
				END IF;
 			ELSIF (supr_compr_state = init) THEN 

 				data_supr0	<= "0000000000" ;
			ELSE 
  				data_supr0	<= data_supr0; 
			END IF;
		END IF;
   	END PROCESS data_suppressor;

------------------------------------------------
   data_comparator: PROCESS(clk40, write_ring_state, reset )

 	 BEGIN
   		IF (reset = '1') THEN
 			data_exceeds_zero	 	<= '0' ;          
 	 	ELSIF ((clk40 = '1') AND (clk40'EVENT)) THEN
			IF (supr_compr_state = init) THEN 
 				data_exceeds_zero	 	<= '0' ;
			ELSIF (data_t0 > "0000000000") THEN 
 				data_exceeds_zero	 	<= '1' ;          
            ELSE
 				data_exceeds_zero	 	<= '0' ;          
 		 	END IF;
 		END IF;
   	END PROCESS data_comparator;

--------------------------------------------------
   count_comparator: PROCESS(clk40,supr_compr_state, reset)

 	 BEGIN
   		IF (reset = '1') THEN
 			count_exceeds_zero <= '0' ;          
 	 	ELSIF ((clk40 = '1') AND (clk40'EVENT)) THEN
			IF (supr_compr_state = init) THEN 
 				count_exceeds_zero <= '0' ;          
			ELSIF (same_value_count > 0) THEN 
	 			count_exceeds_zero <= '1' ;          
			ELSE          
 				count_exceeds_zero <= '0' ;          
 		 	END IF;
 		END IF;
   	END PROCESS count_comparator;

--------------------------------------------
-- ONLY USED FOR TESTING PURPOSES

	flagged_rl_data   <= data_exceeds_zero & data_t0 ; 
  	flagged_rl_count  <= count_exceeds_zero & same_value_count ; 

------------------------------------------------------------------------

--					WRITE RING REGISTER					--
  

   PROCESS (clk40, supr_compr_state, reset)

    BEGIN
	IF (reset = '1') THEN
				j 	<= 0 ;       
	  			k	<= 0 ;	   	 
				p 	<= 0 ;        
				y 	<= 0 ;
				z 	<= 0 ;      
				init_k <= '0';	 
	  			flagged_rl_compr  	<= "00000000000";           
				ring_write_en <= '0';   
				ring_write_clk <= '0';
				read_idle_en <= '0'; 	-- 
 				write_ring_state <= wr_init;	
	ELSIF (clk40'EVENT) AND (clk40 = '0') THEN
					p <= k;
		IF (st_mach_init = '1') THEN			
--		IF (supr_compr_state = init) THEN 
				j 	<= 0 ;       
	  			k	<= 0 ;	   	 
 				p 	<= 0 ;       
				y 	<= 0 ;	
				z 	<= 0 ;       
				init_k <= '0';	 
	  			flagged_rl_compr  	<= "00000000000";           
				ring_write_clk <= '0';
				read_idle_en <= '0'; 	-- 
 				write_ring_state <= wr_init;
		ELSE
	  CASE write_ring_state IS
    		WHEN wr_init =>  			
 	  			flagged_rl_compr  	<= data_t0 & data_exceeds_zero;           
				ring_write_clk <= '0';
 				ring_write_en <= '0';   
					init_k <= '1';	 
 				IF (data_exceeds_zero = '0') THEN
					j <= 17;  					 
					k <= 11;
					y <= 17;	
					z <= 17;
				ELSE
					j <= 7 ;
					k <= 11;
					y <= 7 ;	
					z <= 7 ;
				END IF;

 				IF (supr_compr_state = get) THEN		 
   						write_ring_state <= wr_data_idle0;  
	  					flagged_rl_compr  	<= data_t0 & data_exceeds_zero;          
				ELSE
						write_ring_state <= wr_init;
				END IF;

   		WHEN wr_data_idle0 =>  						 
				y <= z;
				read_idle_en <= '1'; 		
				ring_write_en <= '0';   
				IF  (supr_compr_state = save)
					AND (old_equals_new_data = '1') THEN   
 						write_ring_state <= wr_data_idle;  
				ELSE
						write_ring_state <= wr_data_idle0;
				END IF;

 

    		WHEN wr_data_idle =>  			
 				y <= z;			
				read_idle_en 	<= '0'; 	 
				init_k 		<= '0';	 
  				ring_write_clk 	<= '0';								 
 				ring_write_en <= '1';   
 				flagged_rl_compr  	<= data_t0 & data_exceeds_zero; 
				IF (flagged_rl_compr(0) = '1') THEN
 
					IF j  > 6	THEN
						j <= j - 7;
					ELSE
						j <= j + 11;
					END IF;
 
					IF (init_k = '1') THEN		
						k <= 22;    
					ELSIF j  > 6	THEN
						k <= j + 4;
					ELSE
						k <= j + 22;
					END IF; 
 
					IF z  > 6	THEN
						z <= z - 7;
					ELSE
						z <= z + 11;
					END IF;

	  			ELSE
 
					IF j > 16	THEN
						j <= j - 17;
					ELSE
						j <= j + 1;
					END IF;

					IF (init_k = '1') THEN		 
						k <= 11;   
					ELSE 
						k <= k + 1;			 
					END IF;
  						z <= z + 1 ;		 
				END IF;

    				write_ring_state <= wr_data;  

     		WHEN wr_data  =>
				y <= z;			
			  	ring_write_clk <= '1';
				ring_write_en <= '0';   
				
					IF (old_equals_new_data = '0') THEN
   						write_ring_state <= wr_count_idle;  
  					ELSE 
    					write_ring_state <= wr_data;  
  					END IF;

    		WHEN wr_count_idle =>  			
					y <= z;			
 					ring_write_clk <= '0';				 
 					ring_write_en <= '1';   
					flagged_rl_compr 	<= same_value_count & count_exceeds_zero; 
				IF (flagged_rl_compr(0) = '1') THEN
 
					IF j  > 6	THEN
						j <= j - 7;
					ELSE
						j <= j + 11;
					END IF;
 
					IF j  > 6	THEN
						k <= j + 4;
					ELSE
						k <= j + 22;
					END IF;

					IF z  > 6	THEN
						z <= z - 7;
					ELSE
						z <= z + 11;
					END IF;

	  			ELSE
 					IF j > 16	THEN
						j <= j - 17;
					ELSE
						j <= j + 1;
					END IF;

 						k <= k + 1;				 
  						z <= z + 1 ;			 

				END IF;
  				write_ring_state <= wr_count;

			WHEN wr_count =>  			
					y <= z;
					ring_write_clk <= '1';
					ring_write_en <= '0';   
				IF (supr_compr_state = idle1) 	THEN 		 
					write_ring_state <= wr_last_count;  

				ELSIF (old_equals_new_data = '1') THEN
					write_ring_state <= wr_data_idle; 
				ELSE 
					write_ring_state <= wr_count ;  
				END IF;

			WHEN wr_last_count => 
					ring_write_clk <= '0';
					ring_write_en <= '0';   
					read_idle_en <= '1'; 		 
					write_ring_state <= wr_data_idle0 ; 
				IF (flagged_rl_compr(0) = '1') THEN		
					y 	<= z ;
				ELSE
					y 	<= z + 1;
				END IF;


		END CASE;
	  END IF;
	 END IF;
	END PROCESS  ;

-----------------------------
    ring_write_clk_delayer: PROCESS(clk40, reset)

 	 BEGIN
 		 IF (reset = '1') THEN
 			ring_write_clk1 <= '0' ;          		
 		ELSIF ((clk40= '1') AND (clk40'EVENT)) THEN 
 			ring_write_clk1 <= ring_write_clk ;           
 		END IF;
   	END PROCESS ring_write_clk_delayer;

-------------------------------------------------------------------------------

--					READ RING REGISTER					--


   PROCESS (clk40, supr_compr_state, reset)

      BEGIN
 		IF (reset = '1') THEN 
			read_position_flag 	<= '0'; 	 
			nz_rd_done			<= '0'; 	
							i	<= 0 ;     	
	 	 		  			l	<= 0 ;	     	
 	 		  				m	<= 0 ;	  	   	
	  		  	ring_rd_en 	<= '0'; 	 
			read_ring_state <= rd_init;
			
 		ELSIF (clk40'EVENT) AND (clk40 = '0') THEN 	 
			IF (st_mach_init = '1') THEN			
--			IF (supr_compr_state = init) THEN 
			 	read_position_flag 	<= '0'; 	 
			 	nz_rd_done			<= '0'; 	
							i	<= 0 ;     	
	 	 		  			l	<= 0 ;	     	
 	 		  				m	<= 0 ;	  	   	
	  		  	ring_rd_en 	<= '0'; 	 
			 	read_ring_state <= rd_init;
			ELSE					
		  CASE read_ring_state IS
		
    		WHEN rd_init =>  			
				i	<= 0;       		  
 	 		  	l	<= 8  ;
 	 	 		m	<= 16 ;
	  		  	ring_rd_en 	<= '0'; 	 
 				IF (fadc_bfr_en= '1') AND (fadc_bfr_clk = '1') THEN		
 					read_ring_state <= rd_idle ;  
				ELSE  
 					read_ring_state <= rd_init ;
 				END IF;											

    		WHEN rd_idle =>
	  		  	ring_rd_en 	<= '0'; 	 
 				IF (read_idle_en  = '1') THEN 			 
    					read_ring_state <= rd_idle;  	 		
				ELSIF (flagged_rl_compr(0)= '1') THEN  
    					read_ring_state <= rd_nz;  
    	  		ELSIF (flagged_rl_compr(0)= '0') THEN	
  					read_ring_state <= rd_zero;
				END IF;		
								 
------------------------------------
   		WHEN rd_nz =>
   			IF (l <= p) AND (ring_write_clk1 = '1') THEN  
	  		  read_position_flag 	<= NOT read_position_flag; 
	  		  			ring_rd_en 	<= '1'; 	 
					nz_rd_done		<= '1';
 				IF i > 9 THEN
					i 	<= i - 10;				
				ELSE
	 		  		i	<= i + 8 ;				 
				END IF;	
   	 		  		l	<= l + 8  ;	 
 			ELSE
				nz_rd_done	<= '0'; 
	  		  	ring_rd_en 	<= '0'; 	 
			END IF;		

 			IF (ring_write_clk1 = '1') THEN
  				read_ring_state <= rd_xtra_nz ;		
			ELSE
  				read_ring_state <= rd_nz ;			
			END IF;

------------------------------------------
 

    	WHEN rd_xtra_nz =>  	 
		  IF (ring_write_clk1 = '0') 
				OR (supr_compr_state = end_of_event2)  THEN
				nz_rd_done	<= '0'; 
			 IF (m <= p )  
					OR (supr_compr_state = end_of_event2)  THEN		
   		  		read_position_flag 	<= NOT read_position_flag  ;
	  		  			ring_rd_en 	<= '1'; 	 
				IF i > 9 THEN
					i 	<= i - 10;				
				ELSE
	 		  		i	<= i + 8 ;				 
				END IF;	

 				IF (p > 17) AND ( l > 9) THEN	
 					l 	<= l - 10;
 				ELSE 
  	 		  		l	<= l + 8 ;
 				END IF;

 				IF (p > 17)  AND ( l > 9) THEN	
						m <= l - 2; 
 				ELSE 
  	 		  			m <= l + 16  ;
 				END IF;		
 
			 ELSIF (nz_rd_done	<= '1') THEN 
	  		  		ring_rd_en 	<= '0'; 	 
 				IF (p > 17) AND ( l > 17) THEN	
					l <= l - 18;
				ELSE
					l <= l ;	
				END IF;
  				IF (p > 17) AND ( l > 17) THEN	
  					m 	<= l - 10;
 				ELSE 
  	 		  		m	<= l + 8  ;
 				END IF;
 			 ELSE
	  		  		ring_rd_en 	<= '0'; 	 
					i <= i;
 				IF (p > 17) AND ( l > 17) THEN	
					l <= l - 18;
					m <= m - 18;
				ELSE
					l <= l;
					m <= m;
				END IF;
			END IF;
		ELSE
	  	ring_rd_en 	<= '0'; 	 
		END IF;
 		  IF (supr_compr_state = end_of_event2) THEN 
  				read_ring_state <= rd_init ;	 
		  ELSIF (ring_write_clk1 = '0') THEN
 				IF (read_idle_en  = '1') THEN 			 
    				read_ring_state <= rd_idle;  	 		
				ELSIF (flagged_rl_compr(0) = '1') THEN  
  					read_ring_state <= rd_nz ; 
 				ELSIF (flagged_rl_compr(0)= '0') THEN  
  					read_ring_state <= rd_idle ;
				END IF;
		  ELSE 
  					read_ring_state <= rd_xtra_nz ;
 		  END IF;	
---------------------------------------															
     	WHEN rd_zero =>
		  IF (ring_write_clk1 = '0') 
	    	 OR (supr_compr_state = end_of_event1a) THEN  
  				IF (l = z ) OR (l = y)      														   
 					OR (supr_compr_state = end_of_event1a)   
				THEN				 
	  		  		read_position_flag 	<= NOT read_position_flag  ;
	  		  			ring_rd_en 	<= '1'; 	 
 					IF i > 9 THEN
						i 	<= i - 10;				
					ELSE
	 		  			i	<= i + 8 ;				 
					END IF;		
				
  	 		  			l	<= l + 8 ;
   	 		  			m 	<= l + 16  ;
				ELSE
	  		  			ring_rd_en 	<= '0'; 	 
				END IF;
		  		IF (supr_compr_state = end_of_event1a) THEN 
  					read_ring_state <= rd_init ;	 
				ELSIF (read_idle_en  = '1') THEN 			  
    					read_ring_state <= rd_idle;  	 		
				ELSIF (flagged_rl_compr(0)= '0') THEN  
 						read_ring_state <= rd_idle ;  
				ELSE
    					read_ring_state <= rd_nz; 		 		
				END IF;
		ELSE
 						read_ring_state <= rd_zero ;  
		END IF;

		END CASE;
		END IF;
   	 END IF;
	END PROCESS  ;
 	

----------------------------------------------------------

   ring_write_en_del: PROCESS(clk40, reset)

 	 BEGIN
 	 	IF (reset = '1') THEN
 			ring_write_en_dly <= '0' ;         
 	   	ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN -- '1'
         	ring_write_en_dly <= ring_write_en ;           
 		END IF;
   	END PROCESS ring_write_en_del;
----
PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			ring_write_en_dly1 <= '0' ;          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN 
 			IF (st_mach_init = '1') THEN			
  			ring_write_en_dly1 <= '0' ;          
			ELSE
  			ring_write_en_dly1 <= ring_write_en_dly ;          
			END IF; 	
		END IF; 	
END PROCESS ;
---
PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			j_dly <= 0 ;          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN 
 			IF (st_mach_init = '1') THEN			
  			j_dly <= 0 ;          
			ELSE
  			j_dly <= j;          
			END IF; 	
		END IF; 	
END PROCESS ;


PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			flagged_rl_compr_dly <= "00000000000";          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN 
 			IF (st_mach_init = '1') THEN			
  			flagged_rl_compr_dly <= "00000000000";          
			ELSE
  			flagged_rl_compr_dly <= flagged_rl_compr; 
			END IF; 	
		END IF; 	
END PROCESS ;


-----------------------------
 wr_ring_reg: PROCESS(reset, clk40)

			BEGIN
				IF (reset = '1') THEN
		  			ring_data	<= "000000000000000000";          
 				ELSIF ((clk40= '0') AND (clk40'EVENT)) THEN --'0'
 				  IF (ring_write_en_dly1 = '1') THEN 
					IF (ring_init = '1') THEN			
		  			ring_data	<= "000000000000000000";          
					ELSIF (j_dly = 0) THEN
			  		ring_data <=  ring_data(17 DOWNTO 11) & (flagged_rl_compr_dly);   
					ELSIF (j_dly = 1) THEN
			  		ring_data <= ring_data(17 DOWNTO 12) & flagged_rl_compr_dly & ring_data(0);  
					ELSIF (j_dly = 2) THEN
			  		ring_data <= ring_data(17 DOWNTO 13) & flagged_rl_compr_dly & ring_data(1 DOWNTO 0);  
					ELSIF (j_dly = 3) THEN
			  		ring_data <= ring_data(17 DOWNTO 14) & flagged_rl_compr_dly & ring_data(2 DOWNTO 0);  
					ELSIF (j_dly = 4) THEN
			  		ring_data <= ring_data(17 DOWNTO 15) & flagged_rl_compr_dly & ring_data(3 DOWNTO 0);  
					ELSIF (j_dly = 5) THEN
			  		ring_data <=  ring_data(17 DOWNTO 16) & flagged_rl_compr_dly & ring_data(4 DOWNTO 0); 
					ELSIF (j_dly = 6) THEN
			  		ring_data <=  ring_data(17) & flagged_rl_compr_dly & ring_data(5 DOWNTO 0); 
					ELSIF (j_dly = 7) THEN
			  		ring_data <= flagged_rl_compr_dly & ring_data(6 DOWNTO 0); 
					ELSIF (j_dly = 8) THEN
			  		ring_data  <= flagged_rl_compr_dly(9 DOWNTO 0) & ring_data(7 DOWNTO 1) & flagged_rl_compr_dly(10); 
					ELSIF (j_dly = 9) THEN
			  		ring_data  <= flagged_rl_compr_dly(8 DOWNTO 0) & ring_data(8 DOWNTO 2) & flagged_rl_compr_dly(10 DOWNTO 9); 
					ELSIF (j_dly = 10) THEN
			  		ring_data <= flagged_rl_compr_dly(7 DOWNTO 0) & ring_data(9 DOWNTO 3) & flagged_rl_compr_dly(10 DOWNTO 8);  
					ELSIF (j_dly = 11) THEN
			  		ring_data  <= flagged_rl_compr_dly(6 DOWNTO 0) & ring_data(10 DOWNTO 4) & flagged_rl_compr_dly(10 DOWNTO 7);
					ELSIF (j_dly = 12) THEN
			  		ring_data  <= flagged_rl_compr_dly(5 DOWNTO 0) & ring_data(11 DOWNTO 5) & flagged_rl_compr_dly(10 DOWNTO 6);  
					ELSIF (j_dly = 13) THEN
			  		ring_data <= flagged_rl_compr_dly(4 DOWNTO 0) & ring_data(12 DOWNTO 6) & flagged_rl_compr_dly(10 DOWNTO 5);  
					ELSIF (j_dly = 14) THEN
			  		ring_data  <= flagged_rl_compr_dly(3 DOWNTO 0) & ring_data(13 DOWNTO 7) & flagged_rl_compr_dly(10 DOWNTO 4);
					ELSIF (j_dly = 15) THEN
			  		ring_data  <= flagged_rl_compr_dly(2 DOWNTO 0) & ring_data(14 DOWNTO 8) & flagged_rl_compr_dly(10 DOWNTO 3);  
					ELSIF (j_dly = 16) THEN
			  		ring_data <= flagged_rl_compr_dly(1 DOWNTO 0 ) & ring_data(15 DOWNTO 9) & flagged_rl_compr_dly(10 DOWNTO 2);  
					ELSIF (j_dly = 17) THEN
			  		ring_data <= flagged_rl_compr_dly(0) & ring_data(16 DOWNTO 10) & flagged_rl_compr_dly(10 DOWNTO 1);  
					ELSE
			  		ring_data <= ring_data;
					END IF;
			   END IF;
 			END IF;
 	END PROCESS wr_ring_reg;

--------------------------------------------

PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			i_dly <= 0 ;          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN 
 			IF (st_mach_init = '1') THEN			
  			i_dly <= 0 ;          
			ELSE
  			i_dly <= i;          
			END IF; 	
		END IF; 	
END PROCESS ;

----
PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			ring_rd_en_dly <= '0' ;          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN 
 			IF (st_mach_init = '1') THEN			
  			ring_rd_en_dly <= '0' ;          
			ELSE
  			ring_rd_en_dly <= ring_rd_en ;          
			END IF; 	
		END IF; 	
END PROCESS ;

----
PROCESS (clk40, supr_compr_state, reset )
BEGIN
		IF (reset = '1') THEN
  			ram_wr_en <= '0' ;          
 		ELSIF ((clk40 = '0') AND (clk40'EVENT)) THEN  
 			IF (st_mach_init = '1') THEN			
  			ram_wr_en <= '0' ;          
			ELSE
  			ram_wr_en <= ring_rd_en_dly ;          
			END IF; 	
		END IF; 	
END PROCESS ;

---------  

    rd_ring_reg: PROCESS(clk40 , supr_compr_state, reset )

 		BEGIN
 			IF (reset = '1') THEN
	 			h_compr_data	<= "00000000";          
 	  	ELSIF ((clk40 = '0') AND (clk40 'EVENT)) THEN 
 			IF (ring_init = '1') THEN			
	 			h_compr_data	<= "00000000";          
	  		 	ELSIF (ring_rd_en_dly  = '1') THEN    
	 			IF (i_dly = 0) THEN
		  		h_compr_data <= ring_data(17 DOWNTO 10);  
	   			ELSIF (i_dly = 1)  THEN
		  		h_compr_data <= ring_data(0) & ring_data(17 DOWNTO 11);  
				ELSIF (	i_dly = 2) THEN
		  		h_compr_data <= ring_data(1 DOWNTO 0) & ring_data(17 DOWNTO 12); 
				ELSIF (i_dly = 3) THEN
		  		h_compr_data <= ring_data(2 DOWNTO 0) & ring_data(17 DOWNTO 13);  
				ELSIF (i_dly = 4) THEN
		  		h_compr_data <= ring_data(3 DOWNTO 0) & ring_data(17 DOWNTO 14); 
				ELSIF (i_dly = 5)  THEN
		  		h_compr_data <= ring_data(4 DOWNTO 0) & ring_data(17 DOWNTO 15);
				ELSIF (i_dly = 6)  THEN
		  		h_compr_data <= ring_data(5 DOWNTO 0) & ring_data(17 DOWNTO 16); 
				ELSIF (i_dly = 7)  THEN
		  		h_compr_data <= ring_data(6 DOWNTO 0) & ring_data(17); 
	  			ELSIF (i_dly = 8)  THEN
		  		h_compr_data <=  ring_data(7 DOWNTO 0);  
				ELSIF (i_dly = 9)  THEN
		  		h_compr_data <= ring_data(8 DOWNTO 1);  
				ELSIF (i_dly = 10)  THEN
		  		h_compr_data <= ring_data(9 DOWNTO 2);  
				ELSIF (i_dly = 11)  THEN
		  		h_compr_data <= ring_data(10 DOWNTO 3);  
				ELSIF (i_dly = 12)  THEN
		  		h_compr_data <=  ring_data(11 DOWNTO 4);  
				ELSIF (i_dly = 13)  THEN
		  		h_compr_data <=  ring_data(12 DOWNTO 5);
				ELSIF (i_dly = 14)  THEN
		  		h_compr_data <= ring_data(13 DOWNTO 6); 
				ELSIF (i_dly = 15)  THEN
		  		h_compr_data <= ring_data(14 DOWNTO 7); 
				ELSIF (i_dly = 16)  THEN
		  		h_compr_data <= ring_data(15 DOWNTO 8); 
				ELSIF (i_dly = 17)  THEN
		  		h_compr_data <= ring_data(16 DOWNTO 9); 
			  	ELSE
		  		h_compr_data <= h_compr_data; 
	 			END IF;
	 
		   END IF;
 	END IF;
 	END PROCESS rd_ring_reg;


----------------------------------------------------------

 fadc_clk_gen: PROCESS(clk20, supr_compr_state, reset )

		BEGIN
		IF (reset = '1') THEN
			fadc_bfr_clk <= '0' ;
 			fadc_bfr_en <= '0';
			fadc_address <= "1111111111" ;	   
		ELSIF (clk20 = '0') AND (clk20'EVENT) THEN 
			IF (supr_compr_state = init)  
  				OR (supr_compr_state = idle ) 
  				OR (supr_compr_state = idle0 ) 
  				OR (supr_compr_state = end_of_event3 ) THEN
					fadc_bfr_clk <= '0' ;
 					fadc_bfr_en <= '0';
					fadc_address <= "1111111111" ;	 
			ELSIF 	(fadc_done = '1') OR  						
--					(fadc_address = 41) THEN    
			 		(fadc_address = 511) THEN   
					fadc_bfr_clk <= '0' ;   
 					fadc_bfr_en <= '0';
					fadc_address <= fadc_address;  
			ELSE
					fadc_bfr_clk <= NOT fadc_bfr_clk  ;
 					fadc_bfr_en <= '1';
					fadc_address <= fadc_address + 1 ;  
			
			END IF;
		END IF;
 	END PROCESS fadc_clk_gen;
--------------------------------------------------

 fadc_data <= FadcData(9 DOWNTO 0) WHEN (fadc_address(1) = '0')  ELSE
			  FadcData(25 DOWNTO 16) WHEN (fadc_address(1) = '1')  ELSE
			  fadc_data;

 -- FadcDataOut <= fadc_data ;
--------------------------------------------------------

 atwd_clk_gen: PROCESS(clk20, supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN
			atwd_bfr_clk <= '0' ;
 			atwd_bfr_en <= '0';		
			atwd_address <= "1111111111" ;   
		ELSIF (clk20 = '0') AND (clk20'EVENT) THEN 
			IF (supr_compr_state = init)  			 
  				OR (supr_compr_state = end_of_event3 ) THEN
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

atwd_word_counter: PROCESS(clk20 , supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN 
				atwd_word_count <= "000000000" ;	 
				atwd_ch_done <= '0';					
 		ELSIF (clk20 = '0') AND (clk20'EVENT) THEN 
			IF (supr_compr_state = init) 			
			OR (supr_compr_state = idle  )    
			OR (supr_compr_state = idle0 ) THEN  
				atwd_word_count <= "000000000" ;
				atwd_ch_done <= '0';		
			ELSIF  (atwd_bfr_en = '1') THEN
				IF (atwd_done = '1')  	
--					OR (atwd_word_count = 30) THEN	 
					OR (atwd_word_count = 254) THEN	 
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


atwd_ch_count_delayer : PROCESS (reset, clk20)
 BEGIN
 	IF (reset = '1') THEN
     	atwd_ch_done_dly <= '0';
  	ELSIF (clk20 = '0') AND (clk20'EVENT) THEN
			atwd_ch_done_dly <= atwd_ch_done;
	END IF;
 END PROCESS atwd_ch_count_delayer;

atwd_ch_count_en <= atwd_ch_done AND NOT atwd_ch_done_dly;

-----------------------------------------------------------

 atwd_bfr_size <= ('0' & AtwdSize) + 1;


----------

 atwd_ch_counter: PROCESS (clk20, supr_compr_state, reset)
	BEGIN
		IF (reset = '1') THEN
			atwd_ch_count <= "000" ;
			atwd_done <= '0';				-- all channels are read out
	  	ELSIF (clk20 = '1') AND (clk20'EVENT) THEN
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
 compr_done_shortner : PROCESS (clk40, reset)
  BEGIN
		IF (reset = '1') THEN
			compr_done_strb_clk40 <= '0' ;
	  	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			compr_done_strb_clk40 <= compr_done_strb ;
		END IF;	
  END PROCESS compr_done_shortner;

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
UnCmprAtwdData		<= AtwdData; 
UnCmprFadcData		<= FadcData; 
UnCmprHeader		<= Header;

-- compr and test
RingWriteClk		<= ring_write_clk;
ComprDataOut		<= h_compr_data;
RingData			<= ring_data;

-- to output buffer
ComprActive	 		<= compr_active;   
ComprDoneStrb		<= compr_done_strb; 
RingReadEn			<= ram_wr_en ;

------------------------
----------------------------------

END rtl ;


