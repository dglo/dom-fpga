--- Top Level Compression Module which incorporates the Delta Compressor.
--- written by Dawn Williams, September 2005
--- This module reads in FADC and ATWD data according to the compr_ctrl structure, passing it to
--- the delta compressor module compress_channel. The delta compressor controls the data readout and provides 32-bit compressed data
--- which is written into RAM modules suitable for interface with the look-back memory (LBM).
--- Design of handshake signals is based on Josh Sopher's compression modules for two-stage delta compression and the roadgrader.

LIBRARY ieee;

USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;  

USE WORK.icecube_data_types.all;
USE WORK.ctrl_data_types.all;
use work.cw_data_types.all;

ENTITY compression IS
GENERIC (
		FADC_WIDTH		: INTEGER := 10
		);
	PORT(

		rst			: IN	STD_LOGIC; 
		clk20			: IN	STD_LOGIC;		
		clk40		 	: IN	STD_LOGIC;		

		Compr_ctrl		: IN Compr_struct;	

		data_avail_in	: IN	STD_LOGIC;					    

		read_done_in   	: OUT	STD_LOGIC;					   

		Header_in 		: IN 	HEADER_VECTOR;

  		ATWD_addr_in	: OUT	STD_LOGIC_VECTOR (7 DOWNTO 0); 

 		ATWD_data_in	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 

  		FADC_addr_in	: OUT	STD_LOGIC_VECTOR (6 DOWNTO 0); 

		Fadc_data_in	: IN	STD_LOGIC_VECTOR (31 DOWNTO 0); 

		data_avail_out 	: OUT STD_LOGIC  ;

		read_done_out	: IN	STD_LOGIC;	

 		compr_avail_out	: OUT STD_LOGIC  ;		

		compr_size		: OUT STD_LOGIC_VECTOR (8 DOWNTO 0);

		compr_addr		: IN STD_LOGIC_VECTOR (8 DOWNTO 0);

		compr_data	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

  		Header_out		: OUT	HEADER_VECTOR; 

  		ATWD_addr_out	: IN	STD_LOGIC_VECTOR (7 DOWNTO 0);  

  		ATWD_data_out	: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0); 

  		Fadc_addr_out	: IN	STD_LOGIC_VECTOR (6 DOWNTO 0);  

  		Fadc_data_out	: OUT	STD_LOGIC_VECTOR (31 DOWNTO 0);  

		TC 				: OUT STD_LOGIC_VECTOR (7 DOWNTO 0)  

	);
	
	end compression;

architecture wrapper_behav of compression is

	SIGNAL  charge_stamp	: STD_LOGIC_VECTOR (31 DOWNTO 0); 
	SIGNAL  time_stamp		: STD_LOGIC_VECTOR (47 DOWNTO 0); 
	SIGNAL  trig_word		: STD_LOGIC_VECTOR (15 DOWNTO 0); 
	SIGNAL  atwd_avail 		: STD_LOGIC; 
	SIGNAL  fadc_avail 		: STD_LOGIC; 
	SIGNAL  atwd_a_b 		: STD_LOGIC; 
	SIGNAL  compr_mode		: STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL  atwd_size		: STD_LOGIC_VECTOR (1 DOWNTO 0); 
	SIGNAL  l_c				: STD_LOGIC_VECTOR (1 DOWNTO 0); 
	
	SIGNAL din          : word32;
         SIGNAL  size_in      : unsigned(7 downto 0);

         SIGNAL  start        : std_logic;
         SIGNAL  addr_start_read  : unsigned(7 downto 0);
         SIGNAL  addr_start_write :  unsigned(8 downto 0);
          SIGNAL dout         :  word32;
          SIGNAL addr_read    : unsigned(7 downto 0);
         SIGNAL  addr_write   :  unsigned(8 downto 0);
         SIGNAL  channel_wren         :  std_logic;
         SIGNAL  size_out :unsigned(8 downto 0);
         signal done: std_logic;
         type state_type is (init,start_read,end_fadc_compress,initialize_fadc,compress_fadc,compress_atwd,initialize_atwd,end_compress,write_header0,write_header1,write_header2,write_header3,read_compr_init,read_compr);
         signal compression_state :state_type;
         signal encode_fadc,encode_atwd: std_logic;
         signal compress_reset: std_logic;
         
         SIGNAL  data_sig0,data_sig1,data_sig2,data_sig3			: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  wraddress_sig			: STD_LOGIC_VECTOR (8 DOWNTO 0); 
	SIGNAL  rdaddress_sig			: STD_LOGIC_VECTOR (8 DOWNTO 0); 
	SIGNAL  clock_sig				: STD_LOGIC; 
	SIGNAL  wren_sig			: STD_LOGIC; 
	signal read_done_strb1,read_done_strb2:std_logic;

	SIGNAL  q_sig0					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig1					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig2					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
	SIGNAL  q_sig3					: STD_LOGIC_VECTOR (7 DOWNTO 0); 
         
         signal header_word1,header_word2,header_word3,header_word0: std_logic_vector(31 downto 0);
         signal datacount: std_logic;
         signal datacounter:std_logic;
         signal hit_size : std_logic_vector(10 downto 0);
         signal compr_size_sig : std_logic_vector(8 downto 0);
         SIGNAL  event_end_wait			: STD_LOGIC_VECTOR (2 DOWNTO 0); 
         SIGNAL  lbm_read_done			: STD_LOGIC; 
         
COMPONENT type_analyzer_delta 
	PORT (
		Header_in		: IN HEADER_VECTOR;
		ComprVar		: IN Compr_struct;	

 		ChargeStamp		: OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
		Timestamp 		: OUT STD_LOGIC_VECTOR (47 DOWNTO 0);
		TriggerWord 		: OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
		EventType 		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		Atwd_AB 		: OUT STD_LOGIC;
		AtwdAvail		: OUT STD_LOGIC;
		FadcAvail		: OUT STD_LOGIC;
		AtwdSize		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
		LC		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);

		ComprMode		: OUT STD_LOGIC_VECTOR (1 DOWNTO 0);		
		Threshold0		: OUT STD_LOGIC;
		LastOnly		: OUT STD_LOGIC
	);
	END COMPONENT;

component compress_channel
	 port ( din          : in word32;
           size_in      : in unsigned(7 downto 0);
           clock        : in std_logic;
           reset        : in std_logic;
           start        : in std_logic;
           addr_start_read  : in unsigned(7 downto 0);
           dout         : out word32;
           addr_read    : out unsigned(7 downto 0);
           wren         : out std_logic;
           size_out     : out unsigned(8 downto 0);
           errors       : out std_logic_vector(7 downto 0);
           done         : out std_logic		
           );
end component   ;        

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

begin

type_analyzer_delta0 : type_analyzer_delta PORT MAP
	(
		Header_in		=>  Header_in,
		ComprVar		=>  Compr_ctrl,

		ChargeStamp		=>  charge_stamp,
		TimeStamp 		=>  time_stamp,
		TriggerWord 		=>  trig_word,
		Atwd_AB 		=>  atwd_a_b,
		AtwdAvail		=>  atwd_avail,
		FadcAvail		=>  fadc_avail,
		AtwdSize		=>  atwd_size,
		LC		=>  l_c,

		ComprMode		=>  compr_mode

	);
	
compress_channel0: compress_channel port map
	( din          => din,
           size_in      => size_in,
           clock        => clk20,
           reset        => compress_reset,
           start       => start,
           addr_start_read  => addr_start_read,

           dout         => dout,
           addr_read    => addr_read,

           wren         => channel_wren,
           size_out     => size_out,
		done => done
           );	
    
    compr_ram0 : compr_ram PORT MAP(
		data	 	 => data_sig0,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig,
		clock	 	=> clk40,
		q	 		=> q_sig0
	);

compr_ram1 : compr_ram PORT MAP(
		data	 	 => data_sig1,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig,
		clock	 	=> clk40,
		q	 		=> q_sig1
	);

compr_ram2 : compr_ram PORT MAP(
		data	 	 => data_sig2,
		wraddress	 => wraddress_sig,
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig,
		clock	 	=> clk40,
		q	 		=> q_sig2
	);

compr_ram3 : compr_ram PORT MAP(
		data	 	 => data_sig3,
		wraddress	 => wraddress_sig, 
		rdaddress	 => rdaddress_sig,
		wren	 	=> wren_sig,
		clock	 	=> clk40,
		q	 		=> q_sig3
	);
           
 process(rst,clk20,lbm_read_done,data_avail_in,compr_mode,done,atwd_size,atwd_avail)
 	begin
 
 	if rst='1' then
 		compression_state <=init;
 		compress_reset <='1';
 		start <='0';
 		read_done_strb1 <='0';
 		size_in <="00000000";
 		encode_fadc <='0';
 		encode_atwd<='0';
 		compr_avail_out<='0';
 		data_avail_out<='0';
 		
 	elsif clk20'event and clk20='1' then
 		case compression_state is
 			when init =>
 
 				compress_reset <='0';
 				read_done_strb1 <='0';
 				start <='0';
 				if data_avail_in='1' then
 					compression_state <= start_read;
 				else
 					compression_state <= init;
 				end if;
 			when start_read =>
 			
 				if compr_mode = "00" or fadc_avail='0' then
 					compression_state <= read_compr_init;
 				else
 					compression_state <= initialize_fadc;
 				end if;
 			
 			when initialize_fadc =>

 				addr_start_read <= "00000000";
 				size_in <= "10000000";
 				encode_fadc <='1';
 				FADC_addr_in<=	conv_std_logic_vector(addr_read,7);
 				if done='0' then
 					compression_state <=compress_fadc;
 					
 				else
 					compression_state <=end_compress;
 				end if;
 				
 				
 			when compress_fadc =>
 				start <='1';

 				FADC_addr_in<=	conv_std_logic_vector(addr_read,7);
 				if done='0' then
 					compression_state <=compress_fadc;
 				else
 					compression_state <=end_fadc_compress;
 					start<='0';
 				end if;
 			when end_fadc_compress =>
 				encode_fadc<='0';
 				compress_reset <='1';
 				if atwd_avail='0' then
 
 					compression_state <=end_compress;
 				else
 					compression_state <= initialize_atwd;
 				end if;
 			
 			when initialize_atwd =>
 				compress_reset <='0';
 				addr_start_read <= "00000000";
 				if atwd_size="00" then
 					size_in<="01000000";
 				elsif atwd_size="01" then
 					size_in<="10000000";
 				elsif atwd_size="10" then
 					size_in<="11000000";
 				end if;

 				encode_atwd <='1';
 				ATWD_addr_in<=	conv_std_logic_vector(addr_read,8);
 
 				compression_state <=compress_atwd;
 	
 				
 				
 			when compress_atwd =>
 				start <='1';

 				ATWD_addr_in<=	conv_std_logic_vector(addr_read,8);
 				
 				if done='0' then
 					compression_state <=compress_atwd;
 				else
 					compression_state <=end_compress;
 
 				end if;	
 				
 			when end_compress =>
 				start<='0';
 				encode_atwd<='0';
 				encode_fadc <='0';
 				if compr_mode="01" then
 					read_done_strb1<='1';
 				end if;
 
 				compression_state <=write_header0;
 			when write_header0 =>
 				compr_size <=compr_size_sig;
 				compression_state <=write_header1;
 			when write_header1 =>
 				compression_state <=write_header2;
 			when write_header2 =>
 				compression_state <=write_header3;
 			when write_header3 =>
 				
 				compression_state <=read_compr_init;
 			when read_compr_init =>
 				compr_avail_out <='1';
 				data_avail_out <='1';

 				
 				compression_state <=read_compr;
 			when read_compr =>
 				if lbm_read_done='1' then
 					compr_avail_out <='0';
 					data_avail_out <='0';
 					compression_state <=init;
 					
 				elsif lbm_read_done='0' then
 					compression_state <=read_compr;
 				end if;
 				if compr_mode="00" then 
 					ATWD_addr_in<=ATWD_addr_out;
 					FADC_addr_in<=Fadc_addr_out;
 					read_done_strb1<=read_done_out;
 				elsif compr_mode="10" then
 					ATWD_addr_in<=ATWD_addr_out;
 					FADC_addr_in<=Fadc_addr_out;
 					read_done_strb1<=read_done_out;
 				end if;
 				
 			end case;
 		end if;
 	end process;
 	
 process(rst,clk20,channel_wren)
 begin
 	if rst='1' then
 		datacount <='0';
 	elsif clk20'event and clk20='1' then
 		datacount <=channel_wren;
 	end if;
 end process;
 
 datacounter<=channel_wren and not datacount;
  process(rst,clk40,read_done_strb1)
 begin
 	if rst='1' then
 		read_done_strb2 <='0';
 	elsif clk40'event and clk40='1' then
 		read_done_strb2 <=read_done_strb1;
 	end if;
 end process;		
 	
read_done_in<=read_done_strb1 and not read_done_strb2;
 process(clk20,channel_wren,rst,compression_state)


begin
	if rst='1' then
		

		wraddress_sig<="000000011";
		hit_size <="00000001100";
		compr_size_sig <="000000011";
	elsif clk20'event and clk20='1' then
		if compression_state=compress_fadc then
			if datacounter='1' then

					wraddress_sig	<=wraddress_sig+1;
					data_sig0<=dout(7 downto 0);
					data_sig1<=dout(15 downto 8);
					data_sig2 <=dout(23 downto 16);
					data_sig3 <=dout(31 downto 24);
					hit_size<=hit_size+"00000000100";
					compr_size_sig <=compr_size_sig+"000000001";
					wren_sig<='1';

			elsif datacounter='0' then

				wren_sig<='0';
				hit_size<=hit_size;
				
			
			end if;
		elsif compression_state=compress_atwd then

				if datacounter='1' then
					wraddress_sig	<=wraddress_sig+1;
					data_sig0<=dout(7 downto 0);
					data_sig1<=dout(15 downto 8);
					data_sig2 <=dout(23 downto 16);
					data_sig3 <=dout(31 downto 24);
					hit_size<=hit_size+"00000000100";
					compr_size_sig <=compr_size_sig+"000000001";
					wren_sig<='1';

				elsif datacounter='0' then

					wren_sig<='0';
					hit_size<=hit_size;
				end if;
			

		elsif compression_state=end_fadc_compress then

				if datacounter='1' then
					wraddress_sig	<=wraddress_sig+1;
					data_sig0<=dout(7 downto 0);
					data_sig1<=dout(15 downto 8);
					data_sig2 <=dout(23 downto 16);
					data_sig3 <=dout(31 downto 24);
					hit_size<=hit_size+"00000000100";
					compr_size_sig <=compr_size_sig+"000000001";
					wren_sig<='1';

				elsif datacounter='0' then

					wren_sig<='0';
					hit_size<=hit_size;
				end if;

		elsif compression_state = write_header0 then
			wraddress_sig <= "000000000";
			wren_sig<='1';
			data_sig0 <=header_word0(7 downto 0);
			data_sig1 <=header_word0(15 downto 8);
			data_sig2 <=header_word0(23 downto 16);
			data_sig3 <=header_word0(31 downto 24);
		elsif compression_state = write_header1 then
			wren_sig <='1';
			wraddress_sig <= "000000001";
			data_sig0 <=header_word1(7 downto 0);
			data_sig1 <=header_word1(15 downto 8);
			data_sig2 <=header_word1(23 downto 16);
			data_sig3 <=header_word1(31 downto 24);
		elsif compression_state = write_header2 then
			wren_sig <='1';
			wraddress_sig <= "000000010";
			data_sig0 <=header_word2(7 downto 0);
			data_sig1 <=header_word2(15 downto 8);
			data_sig2 <=header_word2(23 downto 16);
			data_sig3 <=header_word2(31 downto 24);
		elsif compression_state = write_header3 then	
			wren_sig <='1';
			wraddress_sig <= "000000011";
			data_sig0 <=header_word3(7 downto 0);
			data_sig1 <=header_word3(15 downto 8);
			data_sig2 <=header_word3(23 downto 16);
			data_sig3 <=header_word3(31 downto 24);
		end if;
		
	end if;
end process;	

lbm_pulse_stretcher:PROCESS(clk40, compression_state, rst)
BEGIN
	IF (rst = '1') THEN
		lbm_read_done <= '0';
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
		IF (compression_state <= init) THEN  
				lbm_read_done <= '0';    
		ELSIF (read_done_out = '1') THEN 
				lbm_read_done <= '1';
		elsif event_end_wait="001" then  
			lbm_read_done<='0';
		END IF;
	END IF;
END PROCESS lbm_pulse_stretcher;	
--------------

wait_counter: PROCESS(clk40, rst)
BEGIN 
	IF (rst = '1') THEN
 		event_end_wait <= "000";
	ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
			IF (lbm_read_done = '1') THEN
 				event_end_wait <= event_end_wait + 1;
			ELSE
 				event_end_wait <= "000";
			END IF;
	END IF;
END PROCESS wait_counter;

compr_data <= q_sig3 & q_sig2 & q_sig1 & q_sig0;
rdaddress_sig	<= compr_addr;	
din <= Fadc_data_in when encode_fadc='1' else Atwd_data_in when encode_atwd='1' else (others=>'0');	
ATWD_data_out		<= ATWD_data_in; 
Fadc_data_out<=Fadc_data_in;
Header_out		<= Header_in;	
header_word0 <= '1'&"001"&"000000000000"&time_stamp(47 downto 32);
header_word1 <= '1' & trig_word(12 downto 0) & l_c & fadc_avail & atwd_avail & atwd_size & atwd_a_b & hit_size;
header_word2 <= time_stamp(31 downto 0);
header_word3 <= charge_stamp(31 downto 0);
END wrapper_behav ;