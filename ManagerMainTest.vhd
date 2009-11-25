--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:26:02 05/03/2009
-- Design Name:   
-- Module Name:   C:/MainProject/Vitalik pack/Machine/ManagerMainTest.vhd
-- Project Name:  Machine
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Manager
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ManagerMainTest IS
END ManagerMainTest;
 
ARCHITECTURE behavior OF ManagerMainTest IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Manager
    PORT(
         clk : IN  std_logic;
         control : IN  std_logic_vector(10 downto 0);
         control_out : OUT  std_logic_vector(10 downto 0);
         data : IN  std_logic_vector(7 downto 0);
         address : IN  std_logic_vector(11 downto 0);
         address_out : OUT  std_logic_vector(11 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         registry_out : OUT  std_logic_vector(7 downto 0);
         generator_out : OUT  std_logic;
         command_out : OUT  std_logic_vector(3 downto 0);
         operand_1_out : OUT  std_logic_vector(7 downto 0);
         operand_2_out : OUT  std_logic_vector(7 downto 0);
         flags_zero : OUT  std_logic;
         flags_sign : OUT  std_logic;
         ip_out : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal control : std_logic_vector(10 downto 0) := (others => '0');
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal address : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal control_out : std_logic_vector(10 downto 0);
   signal address_out : std_logic_vector(11 downto 0);
   signal data_out : std_logic_vector(7 downto 0);
   signal registry_out : std_logic_vector(7 downto 0);
   signal generator_out : std_logic;
   signal command_out : std_logic_vector(3 downto 0);
   signal operand_1_out : std_logic_vector(7 downto 0);
   signal operand_2_out : std_logic_vector(7 downto 0);
   signal flags_zero : std_logic;
   signal flags_sign : std_logic;
   signal ip_out : std_logic;

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Manager PORT MAP (
          clk => clk,
          control => control,
          control_out => control_out,
          data => data,
          address => address,
          address_out => address_out,
          data_out => data_out,
          registry_out => registry_out,
          generator_out => generator_out,
          command_out => command_out,
          operand_1_out => operand_1_out,
          operand_2_out => operand_2_out,
          flags_zero => flags_zero,
          flags_sign => flags_sign,
          ip_out => ip_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100ms.
      wait for 100ms;	

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
