library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

--
-- command == '01' -> push
-- command == '10' -> pop
--

entity Stack is
    Port ( clk : in  STD_LOGIC;
           data : in  unsigned (7 downto 0);
           command : in  unsigned(2 downto 0);
           data_out : out  unsigned (7 downto 0));
end Stack;

architecture Behavioral of Stack is
	function ensure_position(last_position : integer) return integer is
	begin
		if last_position > 3 then
			return 0;
		elsif last_position < 0 then
			return 3;
		end if;
		return last_position;
	end;

	type stack_memory_container is array (0 to 3) of unsigned(7 downto 0);
	shared variable stack_memory : stack_memory_container;
	shared variable last_position : integer := 0;
	shared variable last_value : unsigned(7 downto 0);
begin
	-- TODO: Remove cycle stack implementation.
	process(clk)
	begin
		if rising_edge(clk) then
			if command(1 downto 0) = "01" then -- push data
				last_position := ensure_position(last_position - 1);
				stack_memory(last_position) := data;
			elsif command(1 downto 0) = "10" then
				last_value := stack_memory(last_position);
				stack_memory(last_position) := "UUUUUUUU";
				last_position := ensure_position(last_position + 1);
			end if;
		end if;
		if command(2) = '1' then
			data_out <= last_value;
		end if;
	end process;
end Behavioral;

