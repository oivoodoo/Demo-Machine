LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY MUXDataTestBench IS
END MUXDataTestBench;
 
ARCHITECTURE behavior OF MUXDataTestBench IS 
 
    COMPONENT MUXData
    PORT(
         clk : IN  std_logic;
         data_rom : IN  std_logic_vector(7 downto 0);
         data_ram : IN  std_logic_vector(7 downto 0);
         data_stack : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(7 downto 0);
         control : IN  std_logic_vector(10 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data_rom : std_logic_vector(7 downto 0) := (others => '0');
   signal data_ram : std_logic_vector(7 downto 0) := (others => '0');
   signal data_stack : std_logic_vector(7 downto 0) := (others => '0');
   signal control : std_logic_vector(10 downto 0) := (others => '0');

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MUXData PORT MAP (
          clk => clk,
          data_rom => data_rom,
          data_ram => data_ram,
          data_stack => data_stack,
          data_out => data_out,
          control => control
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
