--------------------------------------------------------------------------------
-- Copyright (c) 1995-2003 Xilinx, Inc.
-- All Right Reserved.
--------------------------------------------------------------------------------
--   ____  ____ 
--  /   /\/   / 
-- /___/  \  /    Vendor: Xilinx 
-- \   \   \/     Version : 10.1
--  \   \         Application : ISE
--  /   /         Filename : CacheWave.vhw
-- /___/   /\     Timestamp : Mon Apr 20 14:22:23 2009
-- \   \  /  \ 
--  \___\/\___\ 
--
--Command: 
--Design Name: CacheWave
--Device: Xilinx
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE STD.TEXTIO.ALL;

ENTITY CacheWave IS
END CacheWave;

ARCHITECTURE testbench_arch OF CacheWave IS
    FILE RESULTS: TEXT OPEN WRITE_MODE IS "results.txt";

    COMPONENT Cache
        PORT (
            clk : In std_logic;
            address : In std_logic_vector (11 DownTo 0);
            data : In std_logic_vector (7 DownTo 0);
            data_out : Out std_logic_vector (7 DownTo 0);
            control : In std_logic_vector (39 DownTo 0)
        );
    END COMPONENT;

    SIGNAL clk : std_logic := '0';
    SIGNAL address : std_logic_vector (11 DownTo 0) := "000000000000";
    SIGNAL data : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL data_out : std_logic_vector (7 DownTo 0) := "00000000";
    SIGNAL control : std_logic_vector (39 DownTo 0) := "0000000000000000000000000000000000000000";

    constant PERIOD : time := 200 ns;
    constant DUTY_CYCLE : real := 0.5;
    constant OFFSET : time := 100 ns;

    BEGIN
        UUT : Cache
        PORT MAP (
            clk => clk,
            address => address,
            data => data,
            data_out => data_out,
            control => control
        );

        PROCESS    -- clock process for clk
        BEGIN
            WAIT for OFFSET;
            CLOCK_LOOP : LOOP
                clk <= '0';
                WAIT FOR (PERIOD - (PERIOD * DUTY_CYCLE));
                clk <= '1';
                WAIT FOR (PERIOD * DUTY_CYCLE);
            END LOOP CLOCK_LOOP;
        END PROCESS;

        PROCESS
            BEGIN
                WAIT FOR 1200 ns;

            END PROCESS;

    END testbench_arch;

