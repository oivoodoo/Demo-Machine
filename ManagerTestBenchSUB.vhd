LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ManagerTestBenchSUB IS
END ManagerTestBenchSUB;
 
ARCHITECTURE behavior OF ManagerTestBenchSUB IS 
 
    COMPONENT Manager
    PORT(
         clk : IN  std_logic;
         control : IN  unsigned(10 downto 0);
         control_out : OUT  unsigned(10 downto 0);
         data : IN  unsigned(7 downto 0);
			data_out : OUT  unsigned(7 downto 0);
         address : IN  unsigned(11 downto 0);
         address_out : OUT  unsigned(11 downto 0);
         registry_out : OUT  unsigned(7 downto 0);
			generator_out : out integer;
		   command_out : out unsigned(3 downto 0);
			operand_1_out : out unsigned(7 downto 0);
		   operand_2_out : out unsigned(7 downto 0);
			flags_zero : out std_logic;
			flags_sign : out std_logic;
			ip_out : out integer
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal control : unsigned(10 downto 0) := (others => '0');
   signal data : unsigned(7 downto 0) := (others => '0');
   signal address : unsigned(11 downto 0) := (others => '0');

 	--Outputs
   signal control_out : unsigned(10 downto 0);
   signal address_out : unsigned(11 downto 0);
   signal data_out : unsigned(7 downto 0);
   signal registry_out : unsigned(7 downto 0);
	signal generator_out : integer;
	signal command_out : unsigned(3 downto 0);
	signal operand_1_out : unsigned(7 downto 0);
	signal operand_2_out : unsigned(7 downto 0);
	signal flags_zero : std_logic;
	signal flags_sign : std_logic;
	signal ip_out : integer;
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
	   -- SUB
      data <= "00000011"; -- COMMAND
		address <= "000000000000";
		
      wait for clk_period;
		
		data <= "00000011"; -- COMMAND
		address <= "000000000000";
		
		wait for clk_period;
		
		data <= "00000001";
		address <= "011111111111";
		
		wait for clk_period;
		
		data <= "00000001";
		address <= "011111111111";
		
		wait for clk_period;
		
		data <= "00000010";
		address <= "000000000010";

		wait for clk_period;

		data <= "00000010";
		address <= "000000000010";
		
		wait for clk_period;

		data <= "00000010";
		address <= "000000000010";

      wait for clk_period*10;

      -- insert stimulus here 

      wait;
   end process;

END;
