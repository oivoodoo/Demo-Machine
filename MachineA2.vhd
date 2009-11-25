library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity MachineA2 is
    Port ( 
			  clk 		 : in  STD_LOGIC;
           address 	 : in  STD_LOGIC_VECTOR (11 downto 0);
			  jumpSuccessed : in STD_LOGIC;
			  -- показатель найденного предсказани€
			  astrology_First		: out STD_LOGIC_VECTOR(1 downto 0);
			  astrology_Second	: out STD_LOGIC_VECTOR(1 downto 0)
         );
end MachineA2;

architecture Behavioral of MachineA2 is
	type PHT_ARRAY_TYPE is array(7 downto 0) of std_logic_vector(1 downto 0);
	
	function toIndex(fromValue: STD_LOGIC_VECTOR(2 downto 0)) return integer is
		variable result : integer := -1;
	begin
		if (fromValue = "000") then
			result := 0;
		elsif (fromValue = "001") then
			result := 1;
		elsif (fromValue = "010") then
			result := 2;
		elsif (fromValue = "011") then
			result := 3;
		elsif (fromValue = "100") then
			result := 4;
		elsif (fromValue = "101") then
			result := 5;
		elsif (fromValue = "110") then
			result := 6;
		elsif (fromValue = "111") then
			result := 7;
		end if;
		return result;
	end;

	function machineAction(machineValue : STD_LOGIC_VECTOR(1 downto 0); hit : STD_LOGIC) return STD_LOGIC_VECTOR is
		variable result : std_logic_vector(1 downto 0) := "00";
	begin
		if (machineValue = "00" and hit = '0') then
			result := "00";
		elsif (machineValue = "00" and hit = '1') then
			result := "01";
		elsif (machineValue = "01" and hit = '0') then
			result := "10";
		elsif (machineValue = "01" and hit = '1') then
			result := "11";
		elsif (machineValue = "10" and hit = '0') then
			result := "00";
		elsif (machineValue = "10" and hit = '1') then
			result := "01";
		elsif (machineValue = "11" and hit = '0') then
			result := "10";
		elsif (machineValue = "11" and hit = '1') then
			result := "11";
		end if;
		return result;
	end;
	
	procedure initialize(PHT_Table : out PHT_ARRAY_TYPE; GHR_Vector : out STD_LOGIC_VECTOR(2 downto 0)) is
	begin
		for i in 0 to 7 loop
			PHT_Table(i) := "00";
		end loop;
		GHR_Vector := "000";
	end;
begin
	process(clk)
		variable PHT_Table 	: PHT_ARRAY_TYPE;
		variable GHR_Vector	: STD_LOGIC_VECTOR(2 downto 0);
		variable is_initialized : boolean := false;
		variable switch: boolean := false;
		variable PHT_Value : STD_LOGIC_VECTOR(1 downto 0);
		variable programmCounter_Part : STD_LOGIC_VECTOR(2 downto 0);
		variable xorResult : STD_LOGIC_VECTOR(2 downto 0);
	begin
		if (rising_edge(clk)) then
			if is_initialized = false then
				initialize(PHT_Table, GHR_Vector);
				is_initialized := true;
			end if;
			if (switch = false) then
				-- ѕытаемс€ предсказать выполнитс€ ли команда до начала выполнени€ операции.
				programmCounter_Part := address(2 downto 0);
				--  сорим 3 бита адреса команды и 3 бита Global History Table.
				-- xorResult <= xorValue(GHR_Vector, programmCounter);
				xorResult(0) := GHR_Vector(0) xor programmCounter_Part(0);
				xorResult(1) := GHR_Vector(1) xor programmCounter_Part(1);
				xorResult(2) := GHR_Vector(2) xor programmCounter_Part(2);
				
				PHT_Value := PHT_Table(toIndex(xorResult));
				-- ¬ыводим результат нашего следующего предсказани€ по текущему адресу команды до выполени€ команды.
				astrology_First <= PHT_Value;
				astrology_Second <= "ZZ";
			else
				-- ѕосле выполнени€ операции, нужно обновить значение в Global History Table.
				-- ѕодаЄм значение на автомат и получаем новое значение дл€ предсказани€.
				PHT_Value := machineAction(PHT_Value, jumpSuccessed);
				-- ќбновл€ем значение в табличке.
				PHT_Table(toIndex(xorResult)) := PHT_Value;
				-- —двигаем влево GHR и добавл€ем jumpSuccessed.
				GHR_Vector(2) := GHR_Vector(1);
				GHR_Vector(1) := GHR_Vector(0);
				GHR_Vector(0) := jumpSuccessed;
				-- ¬ыводим результат нашего следующего предсказани€ по текущему адресу команды после выполнени€ команды.
				astrology_First <= "ZZ";
				astrology_Second <= PHT_Value;
			end if;
			switch := not switch;
		end if;
	end process;
end Behavioral;
