library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity ALU is
    Port ( clk : in  STD_LOGIC;
           data : in  STD_LOGIC_VECTOR (7 downto 0);
           address : in  STD_LOGIC_VECTOR (11 downto 0);
           control : in  STD_LOGIC_VECTOR (39 downto 0);
           data_out : out  STD_LOGIC_VECTOR (7 downto 0));
end ALU;

architecture Behavioral of ALU is

begin


end Behavioral;

