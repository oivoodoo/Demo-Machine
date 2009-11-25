library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Cache is
    Port
		( 
			clk 	 : in std_logic;
			address  : in std_logic_vector(11 downto 0);
			data	 : in std_logic_vector(7 downto 0);
			data_out : out std_logic_vector(7 downto 0);
			control  : in std_logic_vector(39 downto 0)
		);
end Cache;

architecture Behavioral of Cache is
	type cache_line 		is array (0 to 3) of std_logic_vector(17 downto 0);
	type cache_container 	is array (0 to 3) of cache_line;	
	type cache_count_line 	is array (0 to 3) of integer;
	type cache_count_container 	is array (0 to 3) of cache_count_line;
	
	function bit_to_int(value_var : std_logic_vector(1 downto 0)) return integer is
	begin
		if value_var = "00" then
			return 0;
		elsif value_var = "01" then
			return 1;
		elsif value_var = "10" then
			return 2;
		else
			return 3;
		end if;
		return -1;
	end;
	
	function get_tag(address_var : std_logic_vector(11 downto 0)) return std_logic_vector is
	begin
		return address_var(11 downto 2);
	end;

	function get_set(address_var : std_logic_vector(11 downto 0)) return std_logic_vector is
	begin
		return address_var(1 downto 0);
	end;

	function get_cache_tag(cache_var : std_logic_vector(17 downto 0)) return std_logic_vector is
	begin
		return cache_var(9 downto 0);
	end;

	function get_cache_data(cache_var : cache_line; 
		tag_var : std_logic_vector(9 downto 0)) return std_logic_vector is
		variable result : std_logic_vector(7 downto 0) := "00000000";
	begin
		for i in 0 to 3 loop
			if get_cache_tag(cache_var(i)) = tag_var then
				result := cache_var(i)(17 downto 10);
			end if;
		end loop;
		return result;
	end;

	-- Method check cache line for existing data.
	function has_tag(cache_lines_var : cache_line; 
		tag_var : std_logic_vector(9 downto 0)) return Boolean is
	begin
		for i in 0 to 3 loop
			if get_cache_tag(cache_lines_var(i)) = tag_var then
				return true;
			end if;
		end loop;
		return false;
	end;
	
	procedure update_cache_lines(cache : inout cache_container; 
		cache_count : inout cache_count_container;
		max_value_index_var : integer; 
		set_var : std_logic_vector(1 downto 0); 
		tag_var : std_logic_vector(9 downto 0)) is
	begin	
		-- Now we have to add one point to another counters then that was founded.
		for i in 0 to 3 loop
			if i /= max_value_index_var then
				cache_count(bit_to_int(set_var))(i) := cache_count(bit_to_int(set_var))(i) + 1;
			end if;
		end loop;
		-- Set cache line with the newest data.
		cache(bit_to_int(set_var))(max_value_index_var)(17 downto 10) := data;
		-- Set cache line tah with newlest data.
		cache(bit_to_int(set_var))(max_value_index_var)(9 downto 0) := tag_var;
		-- Update line count with zero.
		cache_count(bit_to_int(set_var))(max_value_index_var) := 0;
	end;
	
	function find_max_value_index(
		cache_count : cache_count_container;
		set_var : std_logic_vector(1 downto 0); 
		tag_var : std_logic_vector(9 downto 0)) return integer is
		variable max_value 			: integer;
		variable max_value_index 	: integer := 0;		
	begin
		max_value := cache_count(bit_to_int(set_var))(0);
		max_value_index := 0;
		-- Let's find max value of cache line counter.
		for i in 1 to 3 loop
			if max_value < cache_count(bit_to_int(set_var))(i) then
				max_value_index := i;
				max_value := cache_count(bit_to_int(set_var))(i);
			end if;
		end loop;
		return max_value_index;
	end;
	
	function get_cache_index_by_tag(
		cache : cache_container;
		set_var : std_logic_vector(1 downto 0); 
		tag_var : std_logic_vector(9 downto 0)) return integer is
	begin
		for i in 0 to  3 loop
			if get_cache_tag(cache(bit_to_int(set_var))(i)) = tag_var then
				return i;
			end if;
		end loop;
		return -1;
	end;

	procedure initialize(cache_count : out cache_count_container) is
	begin
		for i in 0 to 3 loop
			for j in 0 to 3 loop
				cache_count(i)(j) := 0;
				-- cache(i)(j) := "ZZZZZZZZZZZZZZZZZZZZ"; 
			end loop;
		end loop;
	end;

	shared variable tag_process_var 	 : std_logic_vector(9 downto 0);
	shared variable set_process_var 	 : std_logic_vector(1 downto 0);
	shared variable cache 				 : cache_container;
	shared variable cache_count		 : cache_count_container;
	shared variable current_data 		 : std_logic_vector(7 downto 0);

	shared variable is_initialized : boolean := false;
	shared variable is_has_tag 		: boolean;
begin
	process (clk)
	begin
		-- TODO: Initialize cache lines with Z.
		if rising_edge(clk) and control(1 downto 0) /= "00" then
			if is_initialized = false then
				is_initialized := true;
				initialize(cache_count);
			end if;
		
			tag_process_var := get_tag(address);
			set_process_var := get_set(address);

			is_has_tag := has_tag(cache(bit_to_int(set_process_var)), tag_process_var);
			if is_has_tag = false then
				update_cache_lines(cache, 
										 cache_count, 
										 find_max_value_index(cache_count, 
																    set_process_var, 
																	 tag_process_var), 
										 set_process_var, 
										 tag_process_var);
			else
				current_data := get_cache_data(cache(bit_to_int(set_process_var)), tag_process_var);
				
				if (current_data /= data) and (control(1 downto 0) = "11") then
					-- If we have situation where data is the newest but address - old.
					-- we should update data in cache line.
					update_cache_lines(cache, 
											 cache_count, 
											 get_cache_index_by_tag(cache, 
																			set_process_var, 
																			tag_process_var), 
											 set_process_var, 
											 tag_process_var);
				end if;
			end if;
			data_out <= get_cache_data(cache(bit_to_int(set_process_var)), tag_process_var);
		end if;
	end process ;
end Behavioral;