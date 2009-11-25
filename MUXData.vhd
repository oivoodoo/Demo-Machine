library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;


entity MUXData is
    Port ( clk : in  STD_LOGIC;
           data_rom : in unsigned(7 downto 0);
           data_ram : in unsigned(7 downto 0);
           data_stack : in unsigned(7 downto 0);
			  data_manager : in unsigned(7 downto 0);
           data_out : out unsigned(7 downto 0);
           control : in unsigned (10 downto 0));
end MUXData;

architecture Behavioral of MUXData is

begin
	process(clk)
	begin
		if control(2) = '1' then --rom enabled
			data_out <= data_rom;
		end if;
		if control(0) = '1' then -- ram enabled
			data_out <= data_ram;
		end if;
		if control(6) = '1' then
			data_out <= data_manager;
		end if;
		if rising_edge(clk) then
			if control(5) = '1' then
				data_out <= data_stack;
			end if;
		end if;
	end process;
end Behavioral;
