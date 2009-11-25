library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity RAMMemory is
    Port 
		( 
			  clk : IN std_logic;
           address : in  unsigned(11 downto 0);
           data : in  unsigned(7 downto 0);
           data_out : out  unsigned(7 downto 0);
			  write_enabled : in std_logic;
			  read_enabled : in std_logic
		 );
end RAMMemory;

architecture Behavioral of RAMMemory is
	type memory_container is array (0 to 256) of unsigned(7 downto 0);
	shared variable memory : memory_container;
	signal address_registry : unsigned(11 downto 0);
	shared variable is_initialized : boolean := false;
	
	procedure initialize(memory : out memory_container) is
	begin
		memory(0) := "11111111"; -- OPER1
		memory(1) := "11111110"; -- OPER2
		memory(2) := "11111100"; -- OPER3
		memory(3) := "11111000"; -- OPER4
		memory(4) := "11110000"; -- OPER5
		memory(5) := "00000101"; -- OPER6
		memory(6) := "00000000"; -- OPER7
		memory(7) := "00001110"; -- OPER8
		memory(8) := "00000000";
		memory(9) := "00000000";
		memory(10) := "00000000";
		memory(11) := "00000000";
		memory(12) := "00000000";
		memory(13) := "00000000";
		memory(14) := "00000000";
		memory(15) := "00000000";
		memory(16) := "00000000";
		memory(17) := "00000000";
		memory(18) := "00000000";
		memory(19) := "00000000";
		memory(20) := "00000000";
		memory(21) := "00000000";
		memory(22) := "00000000";
		memory(23) := "00000000";
		memory(24) := "00000000";
		memory(25) := "00000000";
		memory(26) := "00000000";
		memory(27) := "00000000";
		memory(28) := "00000000";
		memory(29) := "00000000";
		memory(30) := "00000000";
		memory(31) := "00000000";
		memory(32) := "00000000";
		memory(33) := "00000000";
		memory(34) := "00000000";
		memory(35) := "00000000";
		memory(36) := "00000000";
		memory(37) := "00000000";
	end;
begin
	process(clk)
	begin
--		if rising_edge(clk) then
			if is_initialized = false then
				initialize(memory);
				is_initialized := true;
			end if;
			if write_enabled = '1' then
				memory(to_integer(address)) := data;
			end if;
			if read_enabled = '1' then
				data_out <= memory(to_integer(address));
			end if;
			address_registry <= address;
--		end if;
	end process;
end Behavioral;