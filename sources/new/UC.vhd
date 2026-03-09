library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity UC is
  Port ( Instr: in std_logic_vector(5 downto 0);
         RegDst: out std_logic;
         ExtOp: out std_logic;
         ALUSrc: out std_logic;
         Branch: out std_logic;
         Jump: out std_logic;
         ALUOp: out std_logic_vector(1 downto 0);
         MemWrite: out std_logic;
         MemtoReg : out std_logic;
         RegWrite : out std_logic
         );
end UC;

architecture Behavioral of UC is

begin
process(Instr)
begin
--default values for signals
    RegDst <= '0';
    ExtOp <= '0';
    ALUSrc <= '0';
    Branch <= '0';
    Jump <= '0';
    ALUOp <= "00";
    MemWrite <= '0';
    MemtoReg <= '0';
    RegWrite <= '0';

case Instr is
        when "000000" => -- add, sub    (sll, srl, logical AND, logical OR, XOR, sra)
            RegWrite <= '1';
            ALUOp <= "10";  -- R-TYPE
        when "001000" => -- addi
            RegDst <= '0';
			ExtOp <= '1';
			ALUSrc <= '1';
			RegWrite <= '1';
			ALUOp <= "00"; 
        when "100011" => --lw
            RegDst <= '0';
            ExtOp <= '1';
            ALUSrc <= '1';
            MemtoReg<= '1';
            RegWrite <= '1';
            ALUOp <= "00";
        when "101011" => --sw
            ExtOp <= '1';
            ALUSrc <= '1';
            MemWrite <= '1';
            ALUOp <= "00";
        when "000100" => --beq
            ExtOp <= '1';
            Branch <= '1';
            ALUOp <= "01";--subtract to compare
        when "000101" => -- bne
            ExtOp <= '1';
            Branch <= '1';
            ALUOp <= "01"; 
        when "001100" => --andi
            RegDst <= '0';
            ALUSrc <= '1';
            RegWrite <= '1';
            ALUOp <= "11";
        when "000010" =>-- jump 
            Jump <='1';
        when others => 
    end case;

end process;
end Behavioral;
