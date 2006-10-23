-- VHDL replacement for Kalle's DC_MRAP.DIA

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

ENTITY DC_MRAP IS
    PORT (
        CLK            : IN  STD_LOGIC;
        stf_stb        : IN  STD_LOGIC;
        crc_zero       : IN  STD_LOGIC;
        ctrl_msg       : IN  STD_LOGIC;
        data_msg       : IN  STD_LOGIC;
        data_stb       : IN  STD_LOGIC;
        eof_stb        : IN  STD_LOGIC;
        RESET          : IN  STD_LOGIC;
        byte_ena0a     : OUT STD_LOGIC;
        byte_ena0b     : OUT STD_LOGIC;
        byte_ena1      : OUT STD_LOGIC;
        byte_ena2      : OUT STD_LOGIC;
        byte_ena3      : OUT STD_LOGIC;
        cmd_ena        : OUT STD_LOGIC;
        crc_init       : OUT STD_LOGIC;
        ctrl_error     : OUT STD_LOGIC;
        ctrl_rcvd      : OUT STD_LOGIC;
        data_error     : OUT STD_LOGIC;
        data_rcvd      : OUT STD_LOGIC;
        first_wadr_ena : OUT STD_LOGIC;
        first_wadr_rld : OUT STD_LOGIC;
        msg_type_ena   : OUT STD_LOGIC;
        rx_we          : OUT STD_LOGIC
        );
END DC_MRAP;

ARCHITECTURE DC_MRAP_ARCH OF DC_MRAP IS

    TYPE   STATE_TYPE IS (STF_WAIT, LEN0, MTYPE_LEN1, PTYPE_SEQ0, DCMD_SEQ1, EOF_WAIT, CTRL_OK, CTRL_ERR, BYTE0, DPR_DAT_WR, BYTE1, BYTE2, BYTE3, DATA_OK, DATA_ERR, DEAD_END, PROTOCOL_ERROR);
    SIGNAL state : STATE_TYPE;
    
BEGIN  -- DC_MRAP_ARCH

    FSM : PROCESS (CLK, RESET)
    BEGIN  -- PROCESS FSM
        IF RESET = '1' THEN                 -- asynchronous reset (active high)
            -- byte_ena0a     <= '1';
            -- byte_ena0b     <= '0';
            -- byte_ena1      <= '0';
            -- byte_ena2      <= '0';
            -- byte_ena3      <= '0';
            cmd_ena        <= '0';
            crc_init       <= '1';
            ctrl_error     <= '0';
            ctrl_rcvd      <= '0';
            data_error     <= '0';
            data_rcvd      <= '0';
            first_wadr_ena <= '0';
            first_wadr_rld <= '0';
            msg_type_ena   <= '0';
            rx_we          <= '0';
            state          <= DEAD_END;
        ELSIF CLK'EVENT AND CLK = '1' THEN  -- rising clock edge
            CASE state IS
                WHEN STF_WAIT =>
--                    byte_ena0a     <= '1';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '1';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= LEN0;
                WHEN LEN0 =>
--                    byte_ena0a     <= '1';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= MTYPE_LEN1;
                    END IF;
                WHEN MTYPE_LEN1 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '1';
--                    byte_ena1      <= '1';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '1';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= PTYPE_SEQ0;
                    END IF;
                WHEN PTYPE_SEQ0 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '1';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= DCMD_SEQ1;
                    END IF;
                WHEN DCMD_SEQ1 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '1';
                    cmd_ena        <= '1';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '1';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' AND ctrl_msg = '0' AND data_msg = '0' THEN
                        state <= DEAD_END;
                    ELSIF data_stb = '1' AND data_msg = '1' THEN
                        state <= BYTE0;
                    ELSIF data_stb = '1' AND ctrl_msg = '1' THEN
                        state <= EOF_WAIT;
                    END IF;
                WHEN EOF_WAIT =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF eof_stb = '1' AND crc_zero = '0' THEN
                        state <= CTRL_ERR;
                    ELSIF eof_stb = '1' AND crc_zero = '1' THEN
                        state <= CTRL_OK;
                    END IF;
                WHEN CTRL_OK =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '1';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= DEAD_END;
                WHEN CTRL_ERR =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '1';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= DEAD_END;
                WHEN BYTE0 =>
--                    byte_ena0a     <= '1';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF eof_stb = '1' AND crc_zero = '0' THEN
                        state <= DATA_ERR;
                    ELSIF data_stb = '1' THEN
                        state <= DPR_DAT_WR;
                    ELSIF eof_stb = '1' AND crc_zero = '1' THEN
                        state <= DATA_OK;
                    END IF;
                WHEN DPR_DAT_WR =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '1';

                    state <= BYTE1;
                WHEN BYTE1 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '1';
--                    byte_ena1      <= '1';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= BYTE2;
                    END IF;
                WHEN BYTE2 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '1';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= BYTE3;
                    END IF;
                WHEN BYTE3 =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '1';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF data_stb = '1' THEN
                        state <= BYTE0;
                    END IF;
                WHEN DATA_OK =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '1';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= DEAD_END;
                WHEN DATA_ERR =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '1';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '1';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= DEAD_END;

                WHEN DEAD_END =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '0';
                    ctrl_rcvd      <= '0';
                    data_error     <= '0';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '0';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    IF stf_stb = '1' THEN
                        state <= STF_WAIT;
                    END IF;
                WHEN PROTOCOL_ERROR =>
--                    byte_ena0a     <= '0';
--                    byte_ena0b     <= '0';
--                    byte_ena1      <= '0';
--                    byte_ena2      <= '0';
--                    byte_ena3      <= '0';
                    cmd_ena        <= '0';
                    crc_init       <= '0';
                    ctrl_error     <= '1';
                    ctrl_rcvd      <= '0';
                    data_error     <= '1';
                    data_rcvd      <= '0';
                    first_wadr_ena <= '0';
                    first_wadr_rld <= '1';
                    msg_type_ena   <= '0';
                    rx_we          <= '0';

                    state <= STF_WAIT;
                WHEN OTHERS => NULL;
            END CASE;

            IF stf_stb = '1' THEN
                IF state = DEAD_END THEN
                    state <= STF_WAIT;
                ELSE
                    state <= PROTOCOL_ERROR;
                END IF;
            END IF;
        END IF;
    END PROCESS FSM;

    -- moved asynchronous to match the timing of the existing schematics
    byte_ena0a <= '1' WHEN data_stb = '1' AND (state = LEN0 OR state = BYTE0)       ELSE '0';
    byte_ena0b <= '1' WHEN data_stb = '1' AND (state = MTYPE_LEN1 OR state = BYTE1) ELSE '0';
    byte_ena1  <= '1' WHEN data_stb = '1' AND (state = MTYPE_LEN1 OR state = BYTE1) ELSE '0';
    byte_ena2  <= '1' WHEN data_stb = '1' AND (state = PTYPE_SEQ0 OR state = BYTE2) ELSE '0';
    byte_ena3  <= '1' WHEN data_stb = '1' AND (state = DCMD_SEQ1 OR state = BYTE3)  ELSE '0';

END DC_MRAP_ARCH;










