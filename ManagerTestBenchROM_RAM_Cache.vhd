
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ManagerTestBench_ROM_RAM_Cache IS
END ManagerTestBench_ROM_RAM_Cache;
 
ARCHITECTURE behavior OF ManagerTestBench_ROM_RAM_Cache IS 
 
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
	 
	 COMPONENT ROMMemory
    PORT(
         clk : IN  std_logic;
         address : IN  unsigned(11 downto 0);
         data : IN  unsigned(7 downto 0);
         data_out : OUT  unsigned(7 downto 0);
			read_enabled : in std_logic
        );
    END COMPONENT;
    
	 COMPONENT RAMMemory
    PORT(
         address : IN  unsigned(11 downto 0);
         data : IN  unsigned(7 downto 0);
         data_out : OUT  unsigned(7 downto 0);
			write_enabled : in std_logic;
			read_enabled : IN std_logic
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
	signal write_enabled : std_logic;
	signal read_enabled : std_logic;
	
   -- Clock period definitions
   constant clk_period : time := 50 ns;

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   ManagerInstance: Manager PORT MAP (
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
		  
	 RAMInstance: RAMMemory PORT MAP (
		address => address, 
		data => data, 
		data_out => data_out, 
		write_enabled => control_out(0), 
		read_enabled => control_out(1));
		  
	 ROMInstance: ROMMemory PORT MAP (
		clk => clk, 
		address => address, 
		data => data, 
		data_out => data_out, 
		read_enabled => control_out(2));

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
      wait for clk_period*10;

      wait;
   end process;

END;
