library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity MEM is
    Port ( MemWrite: in std_logic;
           ALUResIN : in std_logic_vector(31 downto 0);
           RD2 : in std_logic_vector(31 downto 0);
           CLK : in std_logic;
           EN : in std_logic;
           MemData : out std_logic_vector(31 downto 0);
           ALUResOUT: out std_logic_vector(31 downto 0));
end MEM;

architecture Behavioral of MEM is

type memory_array is array (0 to 63) of std_logic_vector(31 downto 0);
signal MEM : memory_array := (
  0 => B"00000000000000000000000000001000", -- X"00000008" = 8 (A_length)
  1 => B"00000000000000000000000000000100", -- X"00000004" = 4 (A[0])
  2 => B"00000000000000000000000000000011", -- X"00000003" = 3
  3 => B"00000000000000000000000000000010", -- X"00000002" = 2
  4 => B"00000000000000000000000000000101", -- X"00000005" = 5
  5 => B"00000000000000000000000000000110", -- X"00000006" = 6
  6 => B"00000000000000000000000000000111", -- X"00000007" = 7
  7 => B"00000000000000000000000000001000", -- X"00000008" = 8
  8 => B"00000000000000000000000000001001", -- X"00000009" = 9 (A[7])
  others => B"00000000000000000000000000000000"
);


begin
process(clk)
begin 
    if rising_edge(clk) then
        if en='1' and MemWrite='1' then 
            MEM(conv_integer(ALUResIN(7 downto 2))) <= RD2;
        end if ;
    end if;
end process;

-- citirea asincrona
MemData <= MEM(conv_integer(ALUResIN(7 downto 2)));
ALUResOUT <= AluResIN;
end Behavioral;
