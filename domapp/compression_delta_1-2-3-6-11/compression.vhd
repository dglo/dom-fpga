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

USE WORK.icecube_data_types.ALL; 
USE WORK.ctrl_data_types.ALL; 
USE work.cw_data_types.ALL; 

ENTITY compression IS
    GENERIC (
        FADC_WIDTH : INTEGER := 10
        );
    PORT(
        
        rst             : IN  STD_LOGIC; 
        clk20           : IN  STD_LOGIC; 
        clk40           : IN  STD_LOGIC; 
        
        Compr_ctrl      : IN  Compr_struct; 
        
        data_avail_in   : IN  STD_LOGIC; 
        
        read_done_in    : OUT STD_LOGIC; 
        
        Header_in       : IN  HEADER_VECTOR; 
        
        ATWD_addr_in    : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); 
        
        ATWD_data_in    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        FADC_addr_in    : OUT STD_LOGIC_VECTOR (6 DOWNTO 0); 
        
        Fadc_data_in    : IN  STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        data_avail_out  : OUT STD_LOGIC; 
        
        read_done_out   : IN  STD_LOGIC; 
        
        compr_avail_out : OUT STD_LOGIC; 
        
        compr_size      : OUT STD_LOGIC_VECTOR (8 DOWNTO 0); 
        
        compr_addr      : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); 
        
        compr_data      : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        Header_out      : OUT HEADER_VECTOR; 
        
        ATWD_addr_out   : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); 
        
        ATWD_data_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        Fadc_addr_out   : IN  STD_LOGIC_VECTOR (6 DOWNTO 0); 
        
        Fadc_data_out   : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
        
        TC              : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) 
        
        );
    
END compression; 

ARCHITECTURE wrapper_behav OF compression IS
    
    SIGNAL charge_stamp                                           : STD_LOGIC_VECTOR (31 DOWNTO 0); 
    SIGNAL time_stamp                                             : STD_LOGIC_VECTOR (47 DOWNTO 0); 
    SIGNAL trig_word                                              : STD_LOGIC_VECTOR (15 DOWNTO 0); 
    SIGNAL atwd_avail                                             : STD_LOGIC; 
    SIGNAL fadc_avail                                             : STD_LOGIC; 
    SIGNAL atwd_a_b                                               : STD_LOGIC; 
    SIGNAL compr_mode                                             : STD_LOGIC_VECTOR (1 DOWNTO 0); 
    SIGNAL atwd_size                                              : STD_LOGIC_VECTOR (1 DOWNTO 0); 
    SIGNAL l_c                                                    : STD_LOGIC_VECTOR (1 DOWNTO 0); 
    
    SIGNAL din                                                    : word32; 
    SIGNAL size_in                                                : UNSIGNED(7 DOWNTO 0); 
    
    SIGNAL start                                                  : STD_LOGIC; 
    SIGNAL addr_start_read                                        : UNSIGNED(7 DOWNTO 0); 
    SIGNAL addr_start_write                                       : UNSIGNED(8 DOWNTO 0); 
    SIGNAL dout                                                   : word32; 
    SIGNAL addr_read                                              : UNSIGNED(7 DOWNTO 0); 
    SIGNAL addr_write                                             : UNSIGNED(8 DOWNTO 0); 
    SIGNAL channel_wren                                           : STD_LOGIC; 
    SIGNAL size_out                                               : UNSIGNED(8 DOWNTO 0); 
    SIGNAL done                                                   : STD_LOGIC; 
    TYPE   state_type IS (init, start_read, end_fadc_compress, initialize_fadc, start_fadc, compress_fadc, compress_atwd, start_atwd, initialize_atwd, end_compress, write_header0, write_header1, write_header2, write_header3, read_compr_init, read_compr); 
    SIGNAL compression_state                                      : state_type; 
    SIGNAL encode_fadc, encode_atwd                               : STD_LOGIC; 
    SIGNAL compress_reset                                         : STD_LOGIC; 
    
    SIGNAL data_sig0, data_sig1, data_sig2, data_sig3             : STD_LOGIC_VECTOR (7 DOWNTO 0); 
    SIGNAL wraddress_sig                                          : STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL rdaddress_sig                                          : STD_LOGIC_VECTOR (8 DOWNTO 0); 
    SIGNAL clock_sig                                              : STD_LOGIC; 
    SIGNAL wren_sig                                               : STD_LOGIC; 
    SIGNAL read_done_strb1, read_done_strb2                       : STD_LOGIC; 
    
    SIGNAL q_sig0                                                 : STD_LOGIC_VECTOR (7 DOWNTO 0); 
    SIGNAL q_sig1                                                 : STD_LOGIC_VECTOR (7 DOWNTO 0); 
    SIGNAL q_sig2                                                 : STD_LOGIC_VECTOR (7 DOWNTO 0); 
    SIGNAL q_sig3                                                 : STD_LOGIC_VECTOR (7 DOWNTO 0); 
    
    SIGNAL header_word1, header_word2, header_word3, header_word0 : STD_LOGIC_VECTOR(31 DOWNTO 0); 
    SIGNAL datacount                                              : STD_LOGIC; 
    SIGNAL datacounter                                            : STD_LOGIC; 
    SIGNAL hit_size                                               : STD_LOGIC_VECTOR(10 DOWNTO 0); 
    SIGNAL compr_size_sig                                         : STD_LOGIC_VECTOR(8 DOWNTO 0); 
    SIGNAL event_end_wait                                         : STD_LOGIC_VECTOR (2 DOWNTO 0); 
    SIGNAL lbm_read_done                                          : STD_LOGIC; 
    
    COMPONENT type_analyzer_delta 
        PORT (
            Header_in   : IN  HEADER_VECTOR; 
            ComprVar    : IN  Compr_struct; 
            
            ChargeStamp : OUT STD_LOGIC_VECTOR (31 DOWNTO 0); 
            Timestamp   : OUT STD_LOGIC_VECTOR (47 DOWNTO 0); 
            TriggerWord : OUT STD_LOGIC_VECTOR (15 DOWNTO 0); 
            EventType   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); 
            Atwd_AB     : OUT STD_LOGIC; 
            AtwdAvail   : OUT STD_LOGIC; 
            FadcAvail   : OUT STD_LOGIC; 
            AtwdSize    : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); 
            LC          : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); 
            
            ComprMode   : OUT STD_LOGIC_VECTOR (1 DOWNTO 0); 
            Threshold0  : OUT STD_LOGIC; 
            LastOnly    : OUT STD_LOGIC
            );
    END COMPONENT; 
    
    COMPONENT compress_channel
        PORT (din             : IN  word32; 
              size_in         : IN  UNSIGNED(7 DOWNTO 0); 
              clock           : IN  STD_LOGIC; 
              reset           : IN  STD_LOGIC; 
              op_reset        : IN  STD_LOGIC; 
              start           : IN  STD_LOGIC; 
              addr_start_read : IN  UNSIGNED(7 DOWNTO 0); 
              dout            : OUT word32; 
              addr_read       : OUT UNSIGNED(7 DOWNTO 0); 
              wren            : OUT STD_LOGIC; 
              size_out        : OUT UNSIGNED(8 DOWNTO 0); 
              errors          : OUT STD_LOGIC_VECTOR(7 DOWNTO 0); 
              done            : OUT STD_LOGIC 
              );
    END COMPONENT; 
    
    COMPONENT compr_ram
        PORT (
            wren      : IN  STD_LOGIC; 
            clock     : IN  STD_LOGIC; 
            q         : OUT STD_LOGIC_VECTOR (7 DOWNTO 0); 
            data      : IN  STD_LOGIC_VECTOR (7 DOWNTO 0); 
            rdaddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0); 
            wraddress : IN  STD_LOGIC_VECTOR (8 DOWNTO 0)
            );
    END COMPONENT; 
    
BEGIN
    
    type_analyzer_delta0 : type_analyzer_delta PORT MAP
        (
            Header_in   => Header_in, 
            ComprVar    => Compr_ctrl, 
            
            ChargeStamp => charge_stamp, 
            TimeStamp   => time_stamp, 
            TriggerWord => trig_word, 
            Atwd_AB     => atwd_a_b, 
            AtwdAvail   => atwd_avail, 
            FadcAvail   => fadc_avail, 
            AtwdSize    => atwd_size, 
            LC          => l_c, 
            
            ComprMode   => compr_mode
            
            );
    
    compress_channel0 : compress_channel PORT MAP
        (din             => din, 
         size_in         => size_in, 
         clock           => clk20, 
         reset           => rst, 
         op_reset        => compress_reset, 
         start           => start, 
         addr_start_read => addr_start_read, 
         
         dout            => dout, 
         addr_read       => addr_read, 
         
         wren            => channel_wren, 
         size_out        => size_out, 
         done            => done
         );    
    
    compr_ram0 : compr_ram PORT MAP(
        data      => data_sig0, 
        wraddress => wraddress_sig, 
        rdaddress => rdaddress_sig, 
        wren      => wren_sig, 
        clock     => clk40, 
        q         => q_sig0
        );
    
    compr_ram1 : compr_ram PORT MAP(
        data      => data_sig1, 
        wraddress => wraddress_sig, 
        rdaddress => rdaddress_sig, 
        wren      => wren_sig, 
        clock     => clk40, 
        q         => q_sig1
        );
    
    compr_ram2 : compr_ram PORT MAP(
        data      => data_sig2, 
        wraddress => wraddress_sig, 
        rdaddress => rdaddress_sig, 
        wren      => wren_sig, 
        clock     => clk40, 
        q         => q_sig2
        );
    
    compr_ram3 : compr_ram PORT MAP(
        data      => data_sig3, 
        wraddress => wraddress_sig, 
        rdaddress => rdaddress_sig, 
        wren      => wren_sig, 
        clock     => clk40, 
        q         => q_sig3
        );
    
    PROCESS(rst, clk20, lbm_read_done, data_avail_in, compr_mode, done, atwd_size, atwd_avail)
    BEGIN
        
        IF rst = '1' THEN
            compression_state <= init; 
            compress_reset    <= '1'; 
            start             <= '0'; 
            read_done_strb1   <= '0'; 
            size_in           <= "00000000"; 
            encode_fadc       <= '0'; 
            encode_atwd       <= '0'; 
            --compr_avail_out<='0';
            --data_avail_out<='0';
            
        ELSIF clk20'EVENT AND clk20 = '1' THEN
            CASE compression_state IS
                WHEN init => 
                    
                    compress_reset  <= '0'; 
                    read_done_strb1 <= '0'; 
                    start           <= '0'; 
                    IF data_avail_in = '1' THEN
                        compression_state <= start_read; 
                    ELSE
                        compression_state <= init; 
                    END IF; 
                WHEN start_read => 
                    
                    IF compr_mode = "00" OR fadc_avail = '0' THEN
                        compression_state <= end_compress; 
                    ELSE
                        compression_state <= initialize_fadc; 
                    END IF; 
                    
                WHEN initialize_fadc => 
                    
                    addr_start_read <= "00000000"; 
                    size_in         <= "10000000"; 
                    encode_fadc     <= '1'; 
                    start           <= '1'; 
                    FADC_addr_in    <= conv_std_logic_vector(addr_read, 7); 
                    IF done = '0' THEN
                        compression_state <= start_fadc; 
                        
                    ELSE
                        compression_state <= end_compress; 
                    END IF; 
                    
                WHEN start_fadc => 
                    
                    
                    start        <= '1'; 
                    FADC_addr_in <= conv_std_logic_vector(addr_read, 7); 
                    IF done = '0' THEN
                        compression_state <= compress_fadc; 
                        
                    ELSE
                        compression_state <= end_compress; 
                    END IF; 
                    
                WHEN compress_fadc => 
                    --start <='1';
                    start        <= '0'; 
                    FADC_addr_in <= conv_std_logic_vector(addr_read, 7); 
                    IF done = '0' THEN
                        compression_state <= compress_fadc; 
                    ELSE
                        compression_state <= end_fadc_compress; 
                        start             <= '0'; 
                    END IF; 
                WHEN end_fadc_compress => 
                    encode_fadc    <= '0'; 
                    compress_reset <= '1'; 
                    IF atwd_avail = '0' THEN
                        
                        compression_state <= end_compress; 
                    ELSE
                        compression_state <= initialize_atwd; 
                    END IF; 
                    
                WHEN initialize_atwd => 
                    start           <= '1'; 
                    compress_reset  <= '0'; 
                    addr_start_read <= "00000000"; 
                    IF atwd_size = "00" THEN
                        size_in <= "01000000"; 
                    ELSIF atwd_size = "01" THEN
                        size_in <= "10000000"; 
                    ELSIF atwd_size = "10" THEN
                        size_in <= "11000000"; 
                    END IF; 
                    
                    encode_atwd       <= '1'; 
                    ATWD_addr_in      <= conv_std_logic_vector(addr_read, 8); 
                    
                    compression_state <= start_atwd; 
                    
                WHEN start_atwd => 
                    start        <= '1'; 
                    
                    ATWD_addr_in <= conv_std_logic_vector(addr_read, 8); 
                    
                    IF done = '0' THEN
                        compression_state <= compress_atwd; 
                    ELSE
                        compression_state <= end_compress; 
                        
                    END IF; 
                    
                WHEN compress_atwd => 
                    --start <='1';
                    start        <= '0'; 
                    ATWD_addr_in <= conv_std_logic_vector(addr_read, 8); 
                    
                    IF done = '0' THEN
                        compression_state <= compress_atwd; 
                    ELSE
                        compression_state <= end_compress; 
                        
                    END IF; 
                    
                WHEN end_compress => 
                    start       <= '0'; 
                    encode_atwd <= '0'; 
                    encode_fadc <= '0'; 
                    IF compr_mode = "01" THEN
                        read_done_strb1 <= '1'; 
                    END IF; 
                    
                    compression_state <= write_header0; 
                WHEN write_header0 => 
                    compr_size        <= compr_size_sig; 
                    compression_state <= write_header1; 
                WHEN write_header1 => 
                    compression_state <= write_header2; 
                WHEN write_header2 => 
                    compression_state <= write_header3; 
                WHEN write_header3 => 
                    
                    compression_state <= read_compr_init; 
                WHEN read_compr_init => 
                    --compr_avail_out <='1';
                    --data_avail_out <='1';
                    
                    
                    compression_state <= read_compr; 
                WHEN read_compr => 
                    IF lbm_read_done = '1' THEN
                                        --compr_avail_out <='0';
                                        --data_avail_out <='0';
                        compression_state <= init; 
                        compress_reset    <= '1';
                    ELSIF lbm_read_done = '0' THEN
                        compression_state <= read_compr; 
                    END IF; 
                    IF compr_mode = "00" THEN 
                        ATWD_addr_in    <= ATWD_addr_out; 
                        FADC_addr_in    <= Fadc_addr_out; 
                        read_done_strb1 <= read_done_out; 
                    ELSIF compr_mode = "10" THEN
                        ATWD_addr_in    <= ATWD_addr_out; 
                        FADC_addr_in    <= Fadc_addr_out; 
                        read_done_strb1 <= read_done_out; 
                    END IF; 
                    
            END CASE; 
        END IF; 
    END PROCESS; 
    
    PROCESS(rst, clk20, channel_wren)
    BEGIN
        IF rst = '1' THEN
            datacount <= '0'; 
        ELSIF clk20'EVENT AND clk20 = '1' THEN
            datacount <= channel_wren; 
        END IF; 
    END PROCESS; 
    
    datacounter <= channel_wren AND NOT datacount; 
    PROCESS(rst, clk40, read_done_strb1)
    BEGIN
        IF rst = '1' THEN
            read_done_strb2 <= '0'; 
        ELSIF clk40'EVENT AND clk40 = '1' THEN
            read_done_strb2 <= read_done_strb1; 
        END IF; 
    END PROCESS; 
    
    read_done_in <= read_done_strb1 AND NOT read_done_strb2; 
    PROCESS(clk20, channel_wren, rst, compression_state)
        
        
    BEGIN
        IF rst = '1' THEN
            
            
            wraddress_sig  <= "000000011"; 
            hit_size       <= "00000001100"; 
            compr_size_sig <= "000000011"; 
        ELSIF clk20'EVENT AND clk20 = '1' THEN
            IF compression_state = init THEN
                wraddress_sig  <= "000000011"; 
                hit_size       <= "00000001100"; 
                compr_size_sig <= "000000011"; 
            ELSIF compression_state = compress_fadc THEN
                IF datacounter = '1' THEN
                    
                    wraddress_sig  <= wraddress_sig+1; 
                    data_sig0      <= dout(7 DOWNTO 0); 
                    data_sig1      <= dout(15 DOWNTO 8); 
                    data_sig2      <= dout(23 DOWNTO 16); 
                    data_sig3      <= dout(31 DOWNTO 24); 
                    hit_size       <= hit_size+"00000000100"; 
                    compr_size_sig <= compr_size_sig+"000000001"; 
                    wren_sig       <= '1'; 
                    
                ELSIF datacounter = '0' THEN
                    
                    wren_sig <= '0'; 
                    hit_size <= hit_size; 
                    
                    
                END IF; 
            ELSIF compression_state = compress_atwd THEN
                
                IF datacounter = '1' THEN
                    wraddress_sig  <= wraddress_sig+1; 
                    data_sig0      <= dout(7 DOWNTO 0); 
                    data_sig1      <= dout(15 DOWNTO 8); 
                    data_sig2      <= dout(23 DOWNTO 16); 
                    data_sig3      <= dout(31 DOWNTO 24); 
                    hit_size       <= hit_size+"00000000100"; 
                    compr_size_sig <= compr_size_sig+"000000001"; 
                    wren_sig       <= '1'; 
                    
                ELSIF datacounter = '0' THEN
                    
                    wren_sig <= '0'; 
                    hit_size <= hit_size; 
                END IF; 
                
                
            ELSIF compression_state = end_fadc_compress THEN
                
                IF datacounter = '1' THEN
                    wraddress_sig  <= wraddress_sig+1; 
                    data_sig0      <= dout(7 DOWNTO 0); 
                    data_sig1      <= dout(15 DOWNTO 8); 
                    data_sig2      <= dout(23 DOWNTO 16); 
                    data_sig3      <= dout(31 DOWNTO 24); 
                    hit_size       <= hit_size+"00000000100"; 
                    compr_size_sig <= compr_size_sig+"000000001"; 
                    wren_sig       <= '1'; 
                    
                ELSIF datacounter = '0' THEN
                    
                    wren_sig <= '0'; 
                    hit_size <= hit_size; 
                END IF; 
                
            ELSIF compression_state = write_header0 THEN
                wraddress_sig <= "000000000"; 
                wren_sig      <= '1'; 
                data_sig0     <= header_word0(7 DOWNTO 0); 
                data_sig1     <= header_word0(15 DOWNTO 8); 
                data_sig2     <= header_word0(23 DOWNTO 16); 
                data_sig3     <= header_word0(31 DOWNTO 24); 
            ELSIF compression_state = write_header1 THEN
                wren_sig      <= '1'; 
                wraddress_sig <= "000000001"; 
                data_sig0     <= header_word1(7 DOWNTO 0); 
                data_sig1     <= header_word1(15 DOWNTO 8); 
                data_sig2     <= header_word1(23 DOWNTO 16); 
                data_sig3     <= header_word1(31 DOWNTO 24); 
            ELSIF compression_state = write_header2 THEN
                wren_sig      <= '1'; 
                wraddress_sig <= "000000010"; 
                data_sig0     <= header_word2(7 DOWNTO 0); 
                data_sig1     <= header_word2(15 DOWNTO 8); 
                data_sig2     <= header_word2(23 DOWNTO 16); 
                data_sig3     <= header_word2(31 DOWNTO 24); 
            ELSIF compression_state = write_header3 THEN 
                wren_sig      <= '1'; 
                wraddress_sig <= "000000011"; 
                data_sig0     <= header_word3(7 DOWNTO 0); 
                data_sig1     <= header_word3(15 DOWNTO 8); 
                data_sig2     <= header_word3(23 DOWNTO 16); 
                data_sig3     <= header_word3(31 DOWNTO 24); 
            END IF; 
            
        END IF; 
    END PROCESS; 
    
    lbm_pulse_stretcher : PROCESS(clk40, compression_state, rst)
    BEGIN
        IF (rst = '1') THEN
            lbm_read_done <= '0'; 
        ELSIF (clk40 = '1') AND (clk40'EVENT) THEN
            IF (compression_state = init) THEN 
                lbm_read_done <= '0'; 
            ELSIF (read_done_out = '1') THEN 
                lbm_read_done <= '1'; 
            ELSIF event_end_wait = "001" THEN 
                lbm_read_done <= '0'; 
            END IF; 
        END IF; 
    END PROCESS lbm_pulse_stretcher; 
--------------
    
    wait_counter : PROCESS(clk40, rst)
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
    
    
    PROCESS(clk40, rst, compression_state)
    BEGIN
        IF (rst = '1') THEN
            compr_avail_out <= '0'; 
            data_avail_out  <= '0'; 
        ELSIF clk40'EVENT AND clk40 = '1' THEN
            IF compression_state = init THEN
                compr_avail_out <= '0'; 
                data_avail_out  <= '0'; 
            ELSIF compression_state = read_compr_init THEN
                
                compr_avail_out <= '1'; 
                data_avail_out  <= '1'; 
            ELSE
                IF read_done_out = '1' THEN
                    compr_avail_out <= '0'; 
                    data_avail_out  <= '0'; 
                END IF; 
            END IF; 
        END IF; 
    END PROCESS; 
    
    compr_data    <= q_sig3 & q_sig2 & q_sig1 & q_sig0; 
    rdaddress_sig <= compr_addr; 
    din           <= Fadc_data_in WHEN encode_fadc = '1' ELSE Atwd_data_in WHEN encode_atwd = '1' ELSE (OTHERS => '0'); 
    ATWD_data_out <= ATWD_data_in; 
    Fadc_data_out <= Fadc_data_in; 
    Header_out    <= Header_in; 
    header_word0  <= '1'&"001"&"000000000000"&time_stamp(47 DOWNTO 32); 
    header_word1  <= '1' & trig_word(12 DOWNTO 0) & l_c & fadc_avail & atwd_avail & atwd_size & atwd_a_b & hit_size; 
    header_word2  <= time_stamp(31 DOWNTO 0); 
    header_word3  <= charge_stamp(31 DOWNTO 0); 
END wrapper_behav;
