-------------------------------------------------------------------------------
-- Title      : Fadc and Atwd temporary RAM storage for compressed data.
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : charge_stamp_generator.vhd
-- Author     : joshua sopher
-- Company    : LBNL
-- Created    : 
-- Last update: april 17 2005
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: The peak, pre-peak, and post-peak data is also extracted. These 
--                              three samples can establish the charge and timing of the fadc pulse. 
--                               
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author               Description
-- May 5 2005                   joshua sopher        
--                                                                       
--                                                                       
-----------------------------------------------------------------------------------------------------------
LIBRARY ieee;

USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;   

ENTITY charge_stamp_generator IS
        PORT
        (
                Clk40                   : IN STD_LOGIC;                  
                Rst                             : IN STD_LOGIC;                  
--              systime         : IN  STD_LOGIC_VECTOR (47 DOWNTO 0);
--FADC
                Busy_Fadc               : IN STD_LOGIC;                                          
                Fadc_D                  : IN STD_LOGIC_VECTOR (9 DOWNTO 0);  
--      FADC_NCO        : IN  STD_LOGIC;
        FADC_addr       : IN  STD_LOGIC_VECTOR (7 DOWNTO 0);
-- charge
        ChargeStamp     : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);

                PkRange                 : OUT STD_LOGIC;        
                PkSampleNumber  : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);    
                FadcPrePeak             : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);    
                FadcPeak                : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);    
                FadcPostPeak    : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);            
------                  
-- test connector
        TC              : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );


END charge_stamp_generator;

ARCHITECTURE rtl OF charge_stamp_generator IS
        TYPE state_type IS (idle, process_data_fadc); 
        
----
        SIGNAL  charge_stamp_generator_state    : state_type;

-------

        SIGNAL  peak_range                              : STD_LOGIC; 
        SIGNAL  post_peak_flag                  : STD_LOGIC; 
        SIGNAL  fadc_data                               : STD_LOGIC_VECTOR (9 DOWNTO 0); 
        
        SIGNAL  fadc_prev                               : STD_LOGIC_VECTOR (9 DOWNTO 0);  
        SIGNAL  fadc_peak0                              : STD_LOGIC_VECTOR (9 DOWNTO 0); 
        SIGNAL  fadc_prepeak0                   : STD_LOGIC_VECTOR (9 DOWNTO 0); 
        SIGNAL  fadc_postpeak0                  : STD_LOGIC_VECTOR (9 DOWNTO 0); 
        SIGNAL  fadc_peak                               : STD_LOGIC_VECTOR (8 DOWNTO 0); 
        SIGNAL  fadc_prepeak                    : STD_LOGIC_VECTOR (8 DOWNTO 0); 
        SIGNAL  fadc_postpeak                   : STD_LOGIC_VECTOR (8 DOWNTO 0); 
        SIGNAL  peak_sample_number              : STD_LOGIC_VECTOR (4 DOWNTO 0); 

-------------------------------------------------------------------------------------------
BEGIN

peak_extractor:    PROCESS (clk40, rst)

      BEGIN
                IF (rst = '1') THEN
                        charge_stamp_generator_state <= idle;
                                fadc_prev                       <= "0000000000";
                                fadc_peak0                      <= "0000000000";
                                fadc_prepeak0           <= "0000000000";
                                fadc_postpeak0          <= "0000000000";
                                fadc_peak                       <= "000000000";
                                fadc_prepeak            <= "000000000";
                                fadc_postpeak           <= "000000000";
                                peak_sample_number  <= "00000";
                                peak_range              <= '0';
                                post_peak_flag          <= '0';
                                
                ELSIF (clk40'EVENT) AND (clk40 = '1') THEN   

                  CASE charge_stamp_generator_state IS
                
                WHEN idle =>                    
                                IF      (Busy_Fadc= '1') THEN                    
                                        fadc_prev               <=  Fadc_D;
                                        fadc_peak0              <= "0000000000";
                                        fadc_prepeak0   <= "0000000000";
                                        fadc_postpeak0  <= "0000000000";
                                        fadc_peak               <= "000000000";
                                        fadc_prepeak    <= "000000000";
                                        fadc_postpeak   <= "000000000";
                                        peak_sample_number <= "00000";
                                        peak_range      <= '0';
                                        post_peak_flag  <= '0';
                                        charge_stamp_generator_state <=  process_data_fadc;     
                                ELSE                                                                       
                                        charge_stamp_generator_state <=  idle;          
                                END IF;
                WHEN process_data_fadc =>
                          IF (FADC_addr = 17) THEN                                      
                                IF (fadc_peak0(9) = '1') THEN                   
                                        peak_range      <= '1';
                                        fadc_peak               <= fadc_peak0(9 DOWNTO 1);
                                        fadc_postpeak   <= fadc_postpeak0(9 DOWNTO 1);   
                                        fadc_prepeak    <= fadc_prepeak0(9 DOWNTO 1);                                   
                                ELSE
                                        peak_range      <= '0';
                                        fadc_peak               <= fadc_peak0(8 DOWNTO 0);
                                        fadc_postpeak   <= fadc_postpeak0(8 DOWNTO 0);   
                                        fadc_prepeak    <= fadc_prepeak0(8 DOWNTO 0);                                           
                                END IF;
                          END IF;

                                                fadc_prev               <= Fadc_D;      
                IF (FADC_addr <= 16) THEN                                       
                                IF (FADC_addr < 16) THEN
                                        IF (Fadc_D > fadc_peak0) THEN   
                                                fadc_peak0              <= Fadc_D ;     
                                                fadc_postpeak0  <= fadc_postpeak0;
                                                fadc_prepeak0   <= fadc_prev;     
                                                post_peak_flag  <= '1';
                                                peak_sample_number      <= FADC_addr(4 DOWNTO 0);
                                        ELSE                                                     
                                                fadc_peak0              <= fadc_peak0 ;
                                                fadc_prepeak0   <= fadc_prepeak0;
                                                IF (post_peak_flag = '1') THEN           
                                                 fadc_postpeak0         <= Fadc_D ;         
                                                 post_peak_flag         <= '0';                 
                                                END IF;                  
                                        END IF; 
                                ELSIF (FADC_addr = 16) THEN
                                        post_peak_flag  <= '0';
                                        fadc_peak0              <= fadc_peak0 ;
                                        fadc_prepeak0   <= fadc_prepeak0;        
                                                IF (post_peak_flag = '1') THEN
                                                 fadc_postpeak0         <= Fadc_D ;           
                                                END IF;                  
                                END IF;
                        END IF;
                                
                IF (Busy_Fadc = '0') THEN
                        charge_stamp_generator_state <=  idle;          
                ELSE                                                                     
                        charge_stamp_generator_state <=  process_data_fadc;     
                END IF;
                                
                END CASE;
                END IF;
        END PROCESS peak_extractor;

----
PkSampleNumber <= peak_sample_number(3 DOWNTO 0);
PkRange          <= peak_range;
FadcPrePeak  <= fadc_prepeak;
FadcPeak         <= fadc_peak;
FadcPostPeak <= fadc_postpeak;
ChargeStamp  <= peak_range & peak_sample_number(3 DOWNTO 0) & fadc_prepeak & fadc_peak & fadc_postpeak;
-- TC(3 DOWNTO 0) <= sample_number;;
-----
END rtl;