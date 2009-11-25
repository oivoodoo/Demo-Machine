library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ROMMemory is
    Port ( 
			  clk : in  STD_LOGIC;
           address : in  unsigned(11 downto 0);
           data : in  unsigned(7 downto 0);
           data_out : out  unsigned(7 downto 0);
			  read_enabled : in std_logic
			 );
end ROMMemory;

architecture Behavioral of ROMMemory is
	type memory_container is array (0 to 256) of unsigned(7 downto 0);
	shared variable memory : memory_container;
	signal address_registry : unsigned(11 downto 0);
	shared variable is_initialized : boolean := false;
	
	procedure initialize(memory : out memory_container) is
	begin
		memory(0) := "00000000"; -- COMMAND: CMP
		memory(1) := "00000000"; -- OPER1        | CMP OPER1, OPER2 -> OPER1 - OPER2 => update flags
		memory(2) := "00000001"; -- OPER2        |
		memory(3) := "00000001"; -- COMMAND: NAND
		memory(4) := "00000000"; -- OPER1         | NAND OPER1, OPER3 -> not (OPER1 and OPER3)
		memory(5) := "00000010"; -- OPER3         |
		memory(6) := "00000010"; -- COMMAND: ADD
		memory(7) := "00000001"; -- OPER2         | ADD OPER2, OPER3 -> OPER2 + OPER3
		memory(8) := "00000010"; -- OPER3         |
		memory(9) := "00000011"; -- COMMAND: SUB
		memory(10) := "00000011"; -- OPER3        | SUB OPER3, OPER3 -> OPER3 - OPER3 -> update flags
		memory(11) := "00000011"; -- OPER3        |
		memory(12) := "00001010"; -- JZ
		memory(13) := "00000111"; -- OPER7         CMP  OPER1, OPER2
		memory(14) := "00001010"; -- PUSH          NAND OPER1, OPER3 
		memory(15) := "00000001"; -- OPER2         ADD  OPER2, OPER3 
		memory(16) := "00001010"; -- PUSH          SUB  OPER3, OPER3  
		memory(17) := "00000010"; -- OPER3         JZ   OPER7  
		memory(18) := "00001010"; -- PUSH          PUSH OPER2
										  --					 PUSH OPER3
		memory(19) := "00000011"; -- OPER4         PUSH OPER4
		memory(20) := "00001011"; -- POP           POP  OPER6
		memory(21) := "00001111"; -- OPER6         POP  OPER7
		memory(22) := "00001011"; -- POP           CMP  OPER6, OPER7
		memory(23) := "00000111"; -- OPER7         LDA  OPER1
		memory(24) := "00000000"; -- CMP           STA  OPER2
		memory(25) := "00001111"; --               CMP  OPER1, OPER8
		memory(26) := "00000111"; --                                
		memory(27) := "00001100"; -- LDA
		memory(28) := "00000000"; -- OPER1
		memory(29) := "00001101"; -- STA
		memory(30) := "00001111"; -- OPER2
		memory(31) := "00000000"; -- CMP
		memory(32) := "00001100"; -- OPER1
		memory(33) := "00001111"; -- HZ OPER
		memory(34) := "00000000";
		memory(35) := "00000000";
		memory(36) := "00000000";
		memory(37) := "00000000";
	end;
begin
	process(clk)
	begin
		if rising_edge(clk) then
			if is_initialized = false then
				initialize(memory);
				is_initialized := true;
			end if;
			address_registry <= address;
			if read_enabled = '1' then
				data_out <= memory(to_integer(address));
			end if;
		end if;
	end process;
end Behavioral;