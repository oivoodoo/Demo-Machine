LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY MachineA2TestBench IS
END MachineA2TestBench;
 
ARCHITECTURE behavior OF MachineA2TestBench IS 
 
    COMPONENT MachineA2
    PORT(
         clk : IN  std_logic;
         address : IN  std_logic_vector(11 downto 0);
         jumpSuccessed : IN  std_logic;
         astrology_First : OUT  std_logic_vector(1 downto 0);
         astrology_Second : OUT  std_logic_vector(1 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal address : std_logic_vector(11 downto 0) := (others => '0');
   signal jumpSuccessed : std_logic := '0';

 	--Outputs
   signal astrology_First : std_logic_vector(1 downto 0);
   signal astrology_Second : std_logic_vector(1 downto 0);

   -- Clock period definitions
   constant clk_period : time := 1us;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MachineA2 PORT MAP (
          clk => clk,
          address => address,
          jumpSuccessed => jumpSuccessed,
          astrology_First => astrology_First,
          astrology_Second => astrology_Second
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
		jumpSuccessed <= '1';
		address <= "000000000001";
		
      -- hold reset state for 100ms.
      wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000010";
		
		wait for clk_period;
		
		address <= "000000000010";
		
		wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000001";

		wait for clk_period;
		
		address <= "000000000010";
		
		wait for clk_period;
		
		address <= "000000000010";
		
		wait for clk_period;
		
		address <= "000000000011";
		
		wait for clk_period;
		
		address <= "000000000011";

		wait for clk_period;
		
		jumpSuccessed <= '0';
		address <= "000000000001";
		
		wait for clk_period;
		
		address <= "000000000011";
		
		wait for clk_period;
		
		jumpSuccessed <= '1';
		address <= "000000000001";
		
      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
