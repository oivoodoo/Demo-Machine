
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ManagerTestBench_ROM_RAM_Manager IS
END ManagerTestBench_ROM_RAM_Manager;
 
ARCHITECTURE behavior OF ManagerTestBench_ROM_RAM_Manager IS 
 
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
			clk : IN std_logic;
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
   signal control_out : unsigned(10 downto 0) := (others => '0');
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
	signal data_var : unsigned(7 downto 0);
	signal data_temp : unsigned(7 downto 0);
	signal data_rom : unsigned(7 downto 0);
	signal data_ram : unsigned(7 downto 0);
	signal address_rom : unsigned(11 downto 0);
	signal address_ram : unsigned(11 downto 0);
	
   -- Clock period definitions
   constant clk_period : time := 50 ns;

BEGIN
 
--	-- Instantiate the Unit Under Test (UUT)
	ManagerInstance: Manager PORT MAP (
          clk => clk,
          control => control,
          control_out => control_out,
          data => data_out,
          address => address,
          address_out => address_out,
          data_out => data_var,
          registry_out => registry_out,
			 generator_out => generator_out,
			 command_out => command_out,
			 operand_1_out => operand_1_out,
			 operand_2_out => operand_2_out,
			 flags_zero => flags_zero,
			 flags_sign => flags_sign,
			 ip_out => ip_out
        );
		  
--	data_temp <= data_var;
	
	RAMInstance: RAMMemory PORT MAP (
		clk => clk,
		address => address_ram, 
		data => data, 
		data_out => data_ram,
		write_enabled => control_out(1), 
		read_enabled => control_out(0)
	);
		  
	ROMInstance: ROMMemory PORT MAP (
		clk => clk, 
		address => address_rom, 
		data => data, 
		data_out => data_rom, 
		read_enabled => control_out(2)
	);

	control_condition : process(clk)
	begin
		if control_out(2) = '1' then --rom is enabled
			data_out <= data_rom;
			address_rom <= address_out;
		elsif control_out(0) = '1' then
			data_out <= data_ram;
			address_ram <= address_out;
		end if;
	end process;
	
   -- Clock process definitions
   clk_process : process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
--		control_out <= "00000000001";
--		address_out <= "000000000001";
--		
--		wait for clk_period;
--		
--		control_out <= "00000000100";
--		address_out <= "000000000001";
--			
--		wait for clk_period;
--		
--		control_out <= "00000000001";
--		address_out <= "000000000010";
--		
--		wait for clk_period;
--		
--		control_out <= "00000000100";
--		address_out <= "000000000010";
--		
      wait for clk_period*10;

      wait;
   end process;

END;
