----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/26/2025 01:29:10 PM
-- Design Name: 
-- Module Name: mpg - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity mpg is
    Port ( enable : out STD_LOGIC;
        btn : in STD_LOGIC;
        clk : in STD_LOGIC);
end mpg;

architecture Behavioral of mpg is

signal count : STD_LOGIC_VECTOR(31 downto 0):=x"00000000";
signal b1:STD_LOGIC;
signal b2:STD_LOGIC;
signal b3:STD_LOGIC;

begin

process(clk)

begin

if rising_edge(clk) then
 count <= count + 1; 
 end if;
 
end process;


process (clk)
begin 
if rising_edge(clk) then
 if count(15 downto 0) = "1111111111111111" then 
 b1 <= btn;
 end if;
  end if;
  end process;
  
  process (clk)
  begin
  if rising_edge(clk) then
   b2 <=b1;
   b3 <= b2;
   end if;
   end process;
   
   enable <= b2 AND (not b3);
end Behavioral;
