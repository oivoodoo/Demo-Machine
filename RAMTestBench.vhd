LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY RAMTestBench IS
END RAMTestBench;
 
ARCHITECTURE behavior OF RAMTestBench IS 
    COMPONENT RAMMemory
    PORT(
         address : IN  std_logic_vector(11 downto 0);
         data : IN  std_logic_vector(7 downto 0);
         data_out : OUT  std_logic_vector(1 downto 0);
         control : IN  std_logic_vector(39 downto 0);
			write_enabled : IN std_logic;
			read_enabled : IN std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal address : std_logic_vector(11 downto 0) := (others => '0');
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal control : std_logic_vector(39 downto 0) := (others => '0');
	signal write_enabled : std_logic;
	signal read_enabled : std_logic;

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RAMMemory PORT MAP (
          address => address,
          data => data,
          data_out => data_out,
          control => control,
			 read_enabled => read_enabled,
			 write_enabled => write_enabled
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
      wait for clk_period;
		
		wait for clk_period;

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
