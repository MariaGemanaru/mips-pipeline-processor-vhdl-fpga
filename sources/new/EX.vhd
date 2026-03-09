library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity EX is
  Port (   ALUSrc : in STD_LOGIC;
           RD1 : in STD_LOGIC_VECTOR (31 downto 0);
           RD2 : in STD_LOGIC_VECTOR (31 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR (31 downto 0);
           func : in STD_LOGIC_VECTOR (5 downto 0);
           sa : in STD_LOGIC_VECTOR (4 downto 0);
           PC4 : in STD_LOGIC_VECTOR (31 downto 0);
           ALURes : out STD_LOGIC_VECTOR (31 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR (31 downto 0);
           Zero : out STD_LOGIC;
           ALUOp : in STD_LOGIC_VECTOR (1 downto 0));
end EX;

architecture Behavioral of EX is

-- semnal de control pentru ALU generat de ALUControl
signal ALUCtrl : std_logic_vector(1 downto 0) := "00";

-- ALUIn2 este rezultatul MUX-ului ALUSrc: RD2 sau Ext_Imm
signal ALUIn2 : STD_LOGIC_VECTOR (31 downto 0);

-- rezultat temporar al ALU
signal ALUResSig : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

begin

-- procesul de la ALUControl: determinã operatia ALU pe baza ALUOp si func
process(ALUOp, func)
begin 
    case ALUOp is
        when "10" => -- tip R
            if func = "100000" then -- add
                ALUCtrl <= "00";
            elsif func = "100010" then -- sub
                ALUCtrl <= "01";
            elsif func = "100100" then -- and
                ALUCtrl <= "10";
            else
                ALUCtrl <= "XX"; -- opera?ie nefolositã
            end if;
        when "00" => -- pentru beq, bne, addi
            ALUCtrl <= "00"; -- add
        when "01" => -- pentru beq, bne
            ALUCtrl <= "01"; -- sub
        when "11" => -- pentru andi
            ALUCtrl <= "10"; -- and
        when others =>
            ALUCtrl <= "XX";
    end case;
end process;

-- mux ALUSrc: alege între RD2 si Ext_Imm
ALUIn2 <= RD2 when ALUSrc = '0' else Ext_Imm;

-- branch PC: adresa de salt (PC + offset << 2)
BranchAddress <= PC4 + (Ext_Imm(29 downto 0) & "00");

-- zero pentru branch: activat dacã rezultatul ALU este 0
Zero <= '1' when ALUResSig = X"00000000" else '0';

-- procesul de la ALU: executã operatia pe baza ALUCtrl
process(RD1, ALUIn2, ALUCtrl)
begin
    case ALUCtrl is
        when "00" => -- add
            ALUResSig <= RD1 + ALUIn2;
        when "01" => -- sub
            ALUResSig <= RD1 - ALUIn2;
        when "10" => -- and
            ALUResSig <= RD1 and ALUIn2;
        when others =>
            ALUResSig <= (others => '0');
    end case;
end process;

-- rezultatul final al ALU
ALURes <= ALUResSig;

end Behavioral;

