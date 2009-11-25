library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use ieee.numeric_std.all;
--use IEEE.STD_LOGIC_ARITH.ALL;

--1. CMP 	<operand1>, <operand2> 		0000
--2. NAND:	<operand1>, <operand2> 		0001
--3. ADD:	<operand1>, <operand2> 		0010
--4. SUB:	<operand1>, <operand2> 		0011
--5. SRA:	<operand1> 						0100
--6. JMP: 	<operand1> 						0101
--7. JRE:	<operand1> 						0110
--8. JNE:	<operand1> 						0111
--9. MOVA:	<operand>                  -- TODO: Add in the next version.
--9. EPERI: <operand> - PID (PERI_ID)	1000
--10. DPERI: <operand> - PID (PERI_ID)	1001
--11. PUSH:  <operand> - address of operand in memory 1010
--12. POP 	 - without operand.			1011

--Также нужно ввести поддержку внешнего счётчика команд так называемый генератор:
--
--Этапы генератора:
--	1. + 	Считать команду и подать Manager для расшифровки её.
--	   +	Записать в регистр команду.
--		
--	2. Далее в зависимости от команды нужно прочитать операнды и записать в дополнительные регистры из памяти данные.
--	   + 	Допустим у нас есть данные.
--	   +	Нужно также сделать проверку на кэширование данных.
--
--
--Распишем циклы команд для работы:
--	Наша ROM память: 
--		ADDRESS_HEX: VALUE_BINARY:
--	      ->0000: JMP,	0000
--		0001: operand,	0011
--		0010: ...
--	     *->0011: CMP
--		0100: operand1
--		0101: operand2
--
--	Результат работы нашей команды:
--		ADDRESS_HEX: VALUE_BINARY:
--		0011: CMP, 	0000
--
--	JMP	<operand>	- адрес на который нужно перепрыгнуть в 
--
--	1. Расшифруем команду JMP -> 011, Запишем в command регистр.
--	2. + Получим из ROM operand и запишем его в регистр операнд1(operand1)
--	   + Получим из ROM operand2.... если есть необходимость.
--	3. Выполним команду и сбросим наш генератор.
--

-- Также у нас есть неявная реализация РОН(регистров общего назначения)
-- ax, bx, dx, cx, flags
-- cmp value1, value2 -> update registry flags(zero, sign)
-- mova value1	-> mov ax, value1

entity Manager is
    Port ( 
			  clk : in std_logic;
           control : in  unsigned (10 downto 0);
           control_out : out unsigned (10 downto 0);
			  data : in unsigned(7 downto 0);
			  address : in unsigned(11 downto 0);
			  address_out : out unsigned (11 downto 0);
			  data_out :  out unsigned (7 downto 0);
			  registry_out : out unsigned (7 downto 0);
			  generator_out : out integer;
			  command_out : out unsigned(3 downto 0);
			  operand_1_out : out unsigned(7 downto 0);
			  operand_2_out : out unsigned(7 downto 0);
			  flags_zero : out std_logic;
			  flags_sign : out std_logic;
			  ip_out : out integer
			 );
end Manager;

architecture Behavioral of Manager is
	type control_container is array(15 downto 0) of unsigned(10 downto 0);
	type commands_container is array(15 downto 0) of control_container;
	-- 000000
	-- ||||||_____ ZERO
	-- |||||______ SIGN
	-- ||||_______ ERROR
	-- |||________ OVERFLOW
	-- ||_________ 
	-- |__________
	shared variable flags : unsigned(5 downto 0) := "000000";
	-- Contains constantly states of commands.
	shared variable commands : commands_container;
	-- Tick/Tack for command steps.
	shared variable generator : integer := 0;
	shared variable int_command : integer := 0;
	-- Store decoded command.
	shared variable command : unsigned(3 downto 0) := "0000";
	-- Store decoded values into operand variables.
	shared variable operand_1 : unsigned(7 downto 0);
	shared variable operand_2 : unsigned(7 downto 0);
	shared variable operand_address1 : unsigned(7 downto 0);
	shared variable operand_address2 : unsigned(7 downto 0);
	
	shared variable saved_registry : unsigned(7 downto 0) := "00000000";
	
	-- Registry block
	shared variable ax : unsigned(7 downto 0) := "00000000";
	shared variable bx : unsigned(7 downto 0) := "00000000";
	shared variable cx : unsigned(7 downto 0) := "00000000";
	shared variable dx : unsigned(7 downto 0) := "00000000";
	
	shared variable address_out_var : unsigned(11 downto 0);
	shared variable data_out_var : unsigned(7 downto 0);	
	
	-- IP steps.
	shared variable ip : integer := 0;
	
	-- Before start to work we have to initialize basic registry and
	-- fixed states of commands.
	shared variable is_initialized : boolean := false;
	
	procedure initialize(commands : out commands_container) is
	begin
		--1. CMP 	<operand1>, <operand2> 		0000
		--2. NAND:	<operand1>, <operand2> 		0001
		--3. ADD:	<operand1>, <operand2> 		0010
		--4. SUB:	<operand1>, <operand2> 		0011
		--5. SRA:	<operand1>, <operand2>		0100
		--6. JMP: 	<operand1> 						0101
		--7. JRE:	<operand1> 						0110
		--8. JNE:	<operand1> 						0111
		--9. EPERI: <operand> - PID (PERI_ID)	1000
		--10. DPERI: <operand> - PID (PERI_ID)	1001
		-- <rom enable to read 0/1> <ram enable memory to write 0/1> <ram enable memory to read 0/1>
		-- CMP - 0000
		commands(0)(0) := "00000000100"; -- enable rom for reading command
		commands(0)(1) := "00000000100"; -- enable rom for reading command
		commands(0)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(0)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(0)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(0)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(0)(6) := "00000000100"; -- enalbe rom for reading address of operand
		commands(0)(7) := "00000000100"; -- enalbe rom for reading address of operand
		commands(0)(8) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(0)(9) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(0)(10) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- NAND - 0001
		commands(1)(0) := "00000000100"; -- enable rom for reading command
		commands(1)(1) := "00000000100"; -- enable rom for reading command
		commands(1)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(1)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(1)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(1)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(1)(6) := "00000000100"; -- enalbe rom for reading address of operand
		commands(1)(7) := "00000000100"; -- enalbe rom for reading address of operand
		commands(1)(8) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(1)(9) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(1)(10) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- ADD - 0010
		commands(2)(0) := "00000000100"; -- enable rom for reading command
		commands(2)(1) := "00000000100"; -- enable rom for reading command
		commands(2)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(2)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(2)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(2)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(2)(6) := "00000000100"; -- enalbe rom for reading address of operand
		commands(2)(7) := "00000000100"; -- enalbe rom for reading address of operand
		commands(2)(8) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(2)(9) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(2)(10) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- SRA - 0011
		commands(3)(0) := "00000000100"; -- enable rom for reading command
		commands(3)(1) := "00000000100"; -- enable rom for reading command
		commands(3)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(3)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(3)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(3)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(3)(6) := "00000000100"; -- enalbe rom for reading address of operand
		commands(3)(7) := "00000000100"; -- enalbe rom for reading address of operand
		commands(3)(8) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(3)(9) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(3)(10) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- SUB - 0100
		commands(4)(0) := "00000000100"; -- enable rom for reading command
		commands(4)(1) := "00000000100"; -- enable rom for reading command
		commands(4)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(4)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(4)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(4)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(4)(6) := "00000000100"; -- enalbe rom for reading address of operand
		commands(4)(7) := "00000000100"; -- enalbe rom for reading address of operand
		commands(4)(8) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(4)(9) := "00000000001"; -- enable ram for reading data by address of operand2 and disable rom
		commands(4)(10) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- JMP - 0101
		commands(5)(0) := "00000000100"; -- enable rom for reading command
		commands(5)(1) := "00000000100"; -- enable rom for reading command
		commands(5)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(5)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(5)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(5)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(5)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(5)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(5)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- JRE - 0110
		commands(6)(0) := "00000000100"; -- enable rom for reading command
		commands(6)(1) := "00000000100"; -- enable rom for reading command
		commands(6)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(6)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(6)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(6)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(6)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(6)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(6)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- JRE - 0111
		commands(7)(0) := "00000000100"; -- enable rom for reading command
		commands(7)(1) := "00000000100"; -- enable rom for reading command
		commands(7)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(7)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(7)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(7)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(7)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(7)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(7)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- EPERI - 1000
		commands(8)(0) := "00000000100"; -- enable rom for reading command
		commands(8)(1) := "00000000100"; -- enable rom for reading command
		commands(8)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(8)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(8)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(8)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(8)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(8)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(8)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		-- DPERI - 1001
		commands(9)(0) := "00000000100"; -- enable rom for reading command
		commands(9)(1) := "00000000100"; -- enable rom for reading command
		commands(9)(2) := "00000000100";	-- enable rom for reading address of operand
		commands(9)(3) := "00000000100";	-- enable rom for reading address of operand
		commands(9)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(9)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(9)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(9)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(9)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		
		-- PUSH 1010
		commands(10)(0) := "00000000100"; -- enable rom for reading command
		commands(10)(1) := "00000000100"; -- enable rom for reading command
		commands(10)(2) := "00000000100"; -- enable rom for reading address of operand
		commands(10)(3) := "00000000100"; -- enable rom for reading address of operand
		commands(10)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(10)(5) := "00000001001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(10)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(10)(7) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		commands(10)(8) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		
		-- POP <operand> - 1011
		commands(11)(0) := "00000000100"; -- enable rom for reading command
		commands(11)(1) := "00000000100"; -- enable rom for reading command
		commands(11)(2) := "00000000100"; -- enable rom for reading address of operand
		commands(11)(3) := "00000010100"; -- enable rom for reading address of operand
		commands(11)(4) := "00000100000"; -- pop -> data_out -> ram with operand_1_address
		commands(11)(5) := "00000100010"; -- 
		commands(11)(6) := "00000100010"; -- 
		
		-- LDA <operand> - 1100
		commands(12)(0) := "00000000100"; -- enable rom for reading command
		commands(12)(1) := "00000000100"; -- enable rom for reading command
		commands(12)(2) := "00000000100"; -- enable rom for reading address of operand
		commands(12)(3) := "00000000100"; -- enable rom for reading address of operand
		commands(12)(4) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(12)(5) := "00000000001"; -- enable ram for reading data by address of operand1 and disable rom
		commands(12)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
		
		-- STA <operand> - 1101 -> save to ax
		commands(13)(0) := "00000000100"; -- enable rom for reading command
		commands(13)(1) := "00000000100"; -- enable rom for reading command
		commands(13)(2) := "00000000100"; -- enable rom for reading address of operand
		commands(13)(3) := "00000000100"; -- enable rom for reading address of operand
		commands(13)(4) := "00001000010"; -- enable ram for reading data by address of operand1 and disable rom
		commands(13)(5) := "00001000010"; -- enable ram for reading data by address of operand1 and disable rom
		commands(13)(6) := "00000000000"; -- nothing to enable - do_operation and save to registry_out
	end;


	-- Function determine result for cmp command.
	function ensure_cmp(value : integer) return integer is
		variable result : integer := 0;
	begin
		if value > 0 then
			result := 1;
		end if;
		if value < 0 then
			result := -1;
		end if;
		return result;
	end;
	
	-- Function fill flags registry after cmp command.
	procedure check_flags(value : integer) is
	begin
		if value = 0 then
			flags(0) := '1';
		else 
			flags(0) := '0';
		end if;
		if value < 0 then
			flags(1) := '1';
		else
			flags(1) := '0';
		end if;
	end;
	
	function convert_to_address(data : unsigned(7 downto 0)) return unsigned is
		variable result : unsigned(11 downto 0) := "000000000000";
	begin
		result(7 downto 0) := data;
		return result;
	end;
	
	function get_command(data : unsigned(7 downto 0)) return unsigned is
	begin
		return data(3 downto 0);
	end;
	
	-- Basic function for ALU implementation.
	procedure do_command(command : in unsigned(3 downto 0); 
								operand1: in unsigned(7 downto 0); 
								operand2: in unsigned(7 downto 0);
								data_out : out unsigned(7 downto 0);
								address_out : out unsigned (11 downto 0)) is
		variable int_command : natural range 0 to 65535;
		variable result : integer;
		variable temp : unsigned(7 downto 0); 
	begin
		int_command := to_integer(command);
		if int_command = 0 then	-- CMP
			result := to_integer(operand1) - to_integer(operand2);
			data_out := to_unsigned(ensure_cmp(result), 8);
			check_flags(result);
		elsif int_command = 1 then -- NAND
			result := to_integer(not (operand1 and operand2));
		elsif int_command = 2 then -- ADD
			result := to_integer(operand1) + to_integer(operand2);
		elsif int_command = 3 then -- SUB 
			result := to_integer(operand1) - to_integer(operand2);
		elsif int_command = 4 then -- SRA:	<operand1>, <operand2>
--			temp := operand1 sra to_integer(operand2)
--			result := to_integer(temp);
		elsif int_command = 5 then -- JMP: 	<operand1>
			address_out := convert_to_address(operand1);
			ip := to_integer(operand1);
		elsif int_command = 6 then -- JRE:	<operand1>
			if flags(0) = '1' then
				-- Минус 1 так как у нас в главном обработчике всегда идёт нарощение ip.
				-- поэтому учиваем, что ip увеличится => уменьшаем на 1.
				ip := to_integer(operand1);
			end if;
		elsif int_command = 7 then -- JNE:	<operand1>
			if not (flags(0) = '1') then
				-- Минус 1 так как у нас в главном обработчике всегда идёт нарощение ip.
				-- поэтому учиваем, что ip увеличится => уменьшаем на 1.
				ip := to_integer(operand1) - 1;
			end if;
		elsif int_command = 8 then -- EPERI: <operand>
			-- TODO: Add peri enable statement.
		elsif int_command = 9 then -- DPERI: <operand>
			-- TODO: Add peri disable statement.
		elsif int_command = 12 then
			ax := operand1;
		end if;
		-- All commands without CMP command and connecting with address bus.
		if int_command /= 0 and int_command <= 4 then
			data_out := to_unsigned(result, 8);
			check_flags(result);
		end if;
		saved_registry := to_unsigned(result, 8);
	end;
begin
	MainProcess: process(clk)
	begin
		if rising_edge(clk) then
			if is_initialized = false then
				initialize(commands);
				is_initialized := true;
				generator := 0;
			else
				-- split programming phase to 2 partial templates:
				-- one: command with one operand
				-- second: command with two operands
				if generator = 0 then -- read first command from rom
					-- We send command to read data from rom memory for reading command.
					control_out <= commands(to_integer(command))(generator);
					address_out <= to_unsigned(ip, 12);
				elsif generator = 2 then
					command := get_command(data);
					address_out <= to_unsigned(ip + 1, 12);
					ip := ip + 1;
				else
					-- We are found command with two operands.
					if (to_integer(command) >= 0 and to_integer(command) < 4) then
						-- There we have to check cache for catching.
						if generator = 4 then
							address_out <= convert_to_address(data);
						elsif generator = 6 then
							address_out_var := to_unsigned(ip + 1, 12);
							address_out <= address_out_var;
							ip := ip + 1;
							operand_1 := data;
							operand_1_out <= operand_1;
						elsif generator = 8 then
							address_out <= convert_to_address(data);
						elsif generator = 10 then
							operand_2 := data;
							operand_2_out <= operand_2;
							address_out_var := address;
							data_out_var := data;
							do_command(command, operand_1, operand_2, data_out_var, address_out_var);
							address_out <= to_unsigned(ip + 1, 12);
							data_out <= data_out_var;
							ip := ip + 1;
						elsif generator = 12 then
--							address_out <= to_unsigned(ip + 1, 12);
--							ip := ip + 1;
						end if;
					end if;
					-- We are found command with one operand.
					if to_integer(command) >= 4 then
						if generator = 4 then 
							address_out <= convert_to_address(data);
							-- it's only for pop command
							if to_integer(command) = 11 then -- pop
								operand_1 := data;
							end if;
							if to_integer(command) = 13 then -- STA
								data_out <= ax;
							end if;
						elsif generator = 6 then
							if to_integer(command) = 11 then
								address_out <= convert_to_address(operand_1);
							else
								address_out <= to_unsigned(ip + 1, 12);
							end if;
							operand_1 := data;
							if to_integer(command) /= 11 and -- pop
								to_integer(command) /= 10 and -- push
								to_integer(command) /= 13 then -- STA
								address_out_var := address;
								data_out_var := data;
								do_command(command, operand_1, operand_2, data_out_var, address_out_var);
								address_out <= address_out_var;
								data_out <= data_out_var;
								operand_1_out <= operand_1;
							end if;
							if to_integer(command) = 13 then
								address_out <= to_unsigned(ip + 1, 12);
							end if;
							if to_integer(command) = 12 then
								address_out <= to_unsigned(ip + 1, 12);
							end if;
							ip := ip + 1;
						end if;
					end if;
				end if;
				if generator >= 2 then
					control_out <= commands(to_integer(command))(generator); 
				end if;
				-- Clear command counter(generator).
				if (to_integer(command) >= 0 and to_integer(command) < 4 and generator = 12) or 
					(to_integer(command) >= 4 and generator = 6) then
					generator := 0;
					operand_1 := "UUUUUUUU";
					operand_2 := "UUUUUUUU";
				else
					generator := generator + 1;
				end if;
				command_out <= command;
				operand_1_out <= operand_1;
				operand_2_out <= operand_2;
				flags_zero <= flags(0);
				flags_sign <= flags(1);
				ip_out <= ip;
			end if;
			generator_out <= generator;
		end if;
		registry_out <= saved_registry;
	end process;
end Behavioral;
