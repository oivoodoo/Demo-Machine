LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY StackTestBench IS
END StackTestBench;
 
ARCHITECTURE behavior OF StackTestBench IS 
 
    COMPONENT Stack
    PORT(
         clk : IN  std_logic;
         data : IN  std_logic_vector(7 downto 0);
         command : IN  std_logic;
         data_out : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal data : std_logic_vector(7 downto 0) := (others => '0');
   signal command : std_logic := '0';

 	--Outputs
   signal data_out : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Stack PORT MAP (
          clk => clk,
          data => data,
          command => command,
          data_out => data_out
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   stim_proc: process
   begin		
  
		command <= '0';
		data <= "00000001";
		
      wait for clk_period;
		
		command <= '0';
		data <= "00000010";
		
		wait for clk_period;	
		
		command <= '0';
		data <= "00000011";
		
		wait for clk_period;	
		
		command <= '0';
		data <= "00000100";
		
		wait for clk_period;	

		command <= '1';
		data <= "11111111";

		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
		wait for clk_period;	
		
		command <= '1';
		data <= "11111111";
		
      wait for clk_period*10;
		
      wait;
   end process;
END;
