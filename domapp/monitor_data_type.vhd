-------------------------------------------------------------------------------
-- Title      : DOMAPP
-- Project    : IceCube DOM main board
-------------------------------------------------------------------------------
-- File       : monitor_data_type.vhd
-- Author     : thorsten
-- Company    : LBNL
-- Created    : 
-- Last update: 2007-03-22
-- Platform   : Altera Excalibur
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: This is a package to define data types use to collect
--              monitoring data
-------------------------------------------------------------------------------
-- Copyright (c) 2005
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version     Author    Description
--             V01-01-00   thorsten
-- 2007-03-22              thorsten  added ATWD dead flag
-------------------------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;

PACKAGE monitor_data_type IS

    TYPE AHB_STATUS_STRUCT IS
        RECORD
            AHB_ERROR      : STD_LOGIC;
            slavebuserrint : STD_LOGIC;
            xfer_eng       : STD_LOGIC;
            xfer_compr     : STD_LOGIC;
        END RECORD;

    TYPE PP_STRUCT IS
        RECORD
            busy        : STD_LOGIC;
            busy_FADC   : STD_LOGIC;
            buffer_full : STD_LOGIC;
            ATWD_acq    : STD_LOGIC;
            ATWD_dig    : STD_LOGIC;
            ATWD_read   : STD_LOGIC;
        END RECORD;
    
    TYPE DAQ_STATUS_STRUCT IS
        RECORD
            PING_status : PP_STRUCT;
            PONG_status : PP_STRUCT;
            AHB_status  : AHB_STATUS_STRUCT;
        END RECORD;

    TYPE DEAD_STATUS_STRUCT IS
        RECORD
            dead_A    : STD_LOGIC;
            dead_B    : STD_LOGIC;
            dead_both : STD_LOGIC;
        END RECORD;
END monitor_data_type;
