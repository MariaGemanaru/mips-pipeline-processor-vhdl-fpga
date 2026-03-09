library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity ID is
  Port (RegWrite:in std_logic;
        Instr: in std_logic_vector(25 downto 0);
        RegDst: in std_logic;
        CLK: in std_logic;
        en: in std_logic;
        ExtOp: in std_logic;
        RD1: out std_logic_vector(31 downto 0);
        RD2: out std_logic_vector(31 downto 0);
        WD: in std_logic_vector(31 downto 0);
        Ext_Imm: out std_logic_vector(31 downto 0);
        func: out std_logic_vector(5 downto 0);
        sa: out std_logic_vector(4 downto 0));
end ID;

architecture Behavioral of ID is

type reg_array is array(0 to 31) of std_logic_vector(31 downto 0);
signal reg_file : reg_array := (others => x"00000000");

-- Semnale interne
signal wa : std_logic_vector(4 downto 0);
signal ID_EX_RD1_int, ID_EX_RD2_int : std_logic_vector(31 downto 0);
signal ID_EX_ExtImm_int : std_logic_vector(31 downto 0);
signal ID_EX_func_int : std_logic_vector(5 downto 0);
signal ID_EX_sa_int : std_logic_vector(4 downto 0);

begin

-- Selectarea registrului de destinatie (rt vs rd)
process(Instr, RegDst)
begin
    if RegDst = '1' then
        wa <= Instr(20 downto 16); -- rt
    else
        wa <= Instr(15 downto 11); -- rd
    end if;
end process;

-- Scriere în registru (RF) pe falling_edge (pentru a permite citire imediata)
process(CLK)
begin
    if falling_edge(CLK) then
        if en = '1' and RegWrite = '1' then
            reg_file(conv_integer(wa)) <= WD;
        end if;
    end if;
end process;

-- Pipeline ID/EX - capturã sincrona pe rising_edge
process(CLK)
begin
    if rising_edge(CLK) then
        if en = '1' then
            ID_EX_RD1_int <= reg_file(conv_integer(Instr(25 downto 21)));
            ID_EX_RD2_int <= reg_file(conv_integer(Instr(20 downto 16)));

            ID_EX_ExtImm_int(15 downto 0) <= Instr(15 downto 0);
            if ExtOp = '1' then
                ID_EX_ExtImm_int(31 downto 16) <= (others => Instr(15));
            else
                ID_EX_ExtImm_int(31 downto 16) <= (others => '0');
            end if;

            ID_EX_func_int <= Instr(5 downto 0);
            ID_EX_sa_int <= Instr(10 downto 6);
        end if;
    end if;
end process;

-- Iesiri din ID/EX catre etapa EX
RD1 <= ID_EX_RD1_int;
RD2 <= ID_EX_RD2_int;
Ext_Imm <= ID_EX_ExtImm_int;
func <= ID_EX_func_int;
sa <= ID_EX_sa_int;

end Behavioral;