library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity test_env is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (7 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end test_env;

architecture Behavioral of test_env is

component MPG is
    Port ( enable : out STD_LOGIC;
           btn : in STD_LOGIC;
           clk : in STD_LOGIC);
end component;

component IFetch is
  Port (Jump: in std_logic;
        JumpAddress: in std_logic_vector(31 downto 0);
        PCSrc: in std_logic;
        BranchAddress: in std_logic_vector(31 downto 0);
        EN: in std_logic;
        RST: in std_logic;
        CLK: in std_logic;
        PC: out std_logic_vector(31 downto 0);
        Instruction: out std_logic_vector(31 downto 0));
end component;

component ID is
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
end component;

component EX is
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
end component;

component MEM is
    Port ( MemWrite: in std_logic;
           ALUResIN : in std_logic_vector(31 downto 0);
           RD2 : in std_logic_vector(31 downto 0);
           CLK : in std_logic;
           EN : in std_logic;
           MemData : out std_logic_vector(31 downto 0);
           ALUResOUT: out std_logic_vector(31 downto 0));
end component;

component UC is
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
end component;

component SSD is
    Port ( clk : in STD_LOGIC;
           digits : in STD_LOGIC_VECTOR(31 downto 0);
           an : out STD_LOGIC_VECTOR(7 downto 0);
           cat : out STD_LOGIC_VECTOR(6 downto 0));
end component;

-- Semnale generale
signal EN : std_logic;
signal Jump : std_logic;
signal JumpAddress: std_logic_vector(31 downto 0) := (others =>'0');
signal PCSrc : std_logic;
signal BranchAddress : std_logic_vector(31 downto 0) := (others =>'0');
signal Instruction : std_logic_vector(31 downto 0):=(others =>'0');
signal PC : std_logic_vector(31 downto 0) := (others => '0');

-- Semnale ID
signal RegWrite: std_logic;
signal RegDst: std_logic;
signal ExtOp: std_logic;
signal RD1 : std_logic_vector(31 downto 0):= (others =>'0');
signal RD2: std_logic_vector(31 downto 0):= (others =>'0');
signal WD : std_logic_vector(31 downto 0):= (others =>'0');
signal Ext_Imm: std_logic_vector(31 downto 0):= (others =>'0');
signal func: std_logic_vector(5 downto 0):= (others =>'0');
signal sa: std_logic_vector(4 downto 0 ):= (others =>'0');

-- Semnale EX
signal ALUSrc: std_logic;
signal ALURes : std_logic_vector(31 downto 0):=(others => '0');
signal Zero : std_logic;
signal ALUOp:  std_logic_vector(1 downto 0);

-- Semnale MEM
signal MemWrite: std_logic;
signal MemData: std_logic_vector(31 downto 0):= (others =>'0');
signal ALUResOUT: std_logic_vector(31 downto 0):= (others =>'0');

-- Semnale UC
signal Branch : std_logic;
signal MemtoReg : std_logic;

signal DIGITS : std_logic_vector(31 downto 0);

-- Registre pipeline IF/ID
signal IF_ID_Instruction : std_logic_vector(31 downto 0) := (others => '0');
signal IF_ID_PC : std_logic_vector(31 downto 0) := (others => '0');

-- Registre pipeline ID/EX
signal ID_EX_RD1 : std_logic_vector(31 downto 0) := (others => '0');
signal ID_EX_RD2 : std_logic_vector(31 downto 0) := (others => '0');
signal ID_EX_Ext_Imm : std_logic_vector(31 downto 0) := (others => '0');
signal ID_EX_func : std_logic_vector(5 downto 0) := (others => '0');
signal ID_EX_sa : std_logic_vector(4 downto 0) := (others => '0');
signal ID_EX_ALUOp : std_logic_vector(1 downto 0) := (others => '0');
signal ID_EX_ALUSrc : std_logic := '0';
signal ID_EX_RegWrite : std_logic := '0';
signal ID_EX_RegDst : std_logic := '0';
signal ID_EX_Branch : std_logic := '0';
signal ID_EX_MemWrite : std_logic := '0';
signal ID_EX_MemtoReg : std_logic := '0';

-- Registre pipeline EX/MEM
signal EX_MEM_BranchAddress : std_logic_vector(31 downto 0) := (others => '0');
signal EX_MEM_Zero : std_logic := '0';
signal EX_MEM_ALURes : std_logic_vector(31 downto 0) := (others => '0');
signal EX_MEM_RD2 : std_logic_vector(31 downto 0) := (others => '0');
signal EX_MEM_Branch : std_logic := '0';
signal EX_MEM_MemWrite : std_logic := '0';
signal EX_MEM_MemtoReg : std_logic := '0';
signal EX_MEM_RegWrite : std_logic := '0';

-- Registre pipeline MEM/WB
signal MEM_WB_MemData : std_logic_vector(31 downto 0) := (others => '0');
signal MEM_WB_ALURes : std_logic_vector(31 downto 0) := (others => '0');
signal MEM_WB_MemtoReg : std_logic := '0';
signal MEM_WB_RegWrite : std_logic := '0';

begin

-- Calcul JumpAddress conform schemei
JumpAddress <= PC(31 downto 28) & Instruction(25 downto 0) & "00";

-- Control pentru branch
PCSrc <= EX_MEM_Zero and EX_MEM_Branch;

-- Instaiere componente
Componenta1_MPG: MPG port map(EN , btn(0), clk);
Componenta2_IFetch: IFetch port map(Jump, JumpAddress, PCSrc, EX_MEM_BranchAddress, EN, btn(1), clk, PC, Instruction);
Componenta3_ID : ID port map(MEM_WB_RegWrite, IF_ID_Instruction(25 downto 0), RegDst, clk, EN, ExtOp, RD1, RD2, WD, Ext_Imm, func, sa);
Componenta4_EX: EX port map(ID_EX_ALUSrc, ID_EX_RD1, ID_EX_RD2, ID_EX_Ext_Imm, ID_EX_func, ID_EX_sa, IF_ID_PC, ALURes, BranchAddress, Zero, ID_EX_ALUOp);
Componenta5_MEM: MEM port map(EX_MEM_MemWrite, EX_MEM_ALURes, EX_MEM_RD2, clk, EN, MEM_WB_MemData, MEM_WB_ALURes);
Componenta6_UC : UC port map(IF_ID_Instruction(31 downto 26), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);

-- Multiplexor scriere bancã registre
WD <= MEM_WB_MemData when MEM_WB_MemtoReg = '1' else MEM_WB_ALURes;

-- Proces sincron pentru registre pipeline
process(clk)
begin
    if rising_edge(clk) then
        if EN = '1' then
            -- IF/ID registre
            IF_ID_Instruction <= Instruction;
            IF_ID_PC <= PC;

            -- ID/EX registre
            ID_EX_RD1 <= RD1;
            ID_EX_RD2 <= RD2;
            ID_EX_Ext_Imm <= Ext_Imm;
            ID_EX_func <= func;
            ID_EX_sa <= sa;
            ID_EX_ALUOp <= ALUOp;
            ID_EX_ALUSrc <= ALUSrc;
            ID_EX_RegWrite <= RegWrite;
            ID_EX_RegDst <= RegDst;
            ID_EX_Branch <= Branch;
            ID_EX_MemWrite <= MemWrite;
            ID_EX_MemtoReg <= MemtoReg;

            -- EX/MEM registre
            EX_MEM_BranchAddress <= BranchAddress;
            EX_MEM_Zero <= Zero;
            EX_MEM_ALURes <= ALURes;
            EX_MEM_RD2 <= ID_EX_RD2;
            EX_MEM_Branch <= ID_EX_Branch;
            EX_MEM_MemWrite <= ID_EX_MemWrite;
            EX_MEM_MemtoReg <= ID_EX_MemtoReg;
            EX_MEM_RegWrite <= ID_EX_RegWrite;

            -- MEM/WB registre
            MEM_WB_MemData <= MEM_WB_MemData;
            MEM_WB_ALURes <= MEM_WB_ALURes;
            MEM_WB_MemtoReg <= EX_MEM_MemtoReg;
            MEM_WB_RegWrite <= EX_MEM_RegWrite;
        end if;
    end if;
end process;

-- Selectare semnale pentru afisaj în functie de switch
process(sw(7 downto 5))
begin
    case sw(7 downto 5) is
        when "000" => DIGITS <= IF_ID_Instruction;
        when "001" => DIGITS <= IF_ID_PC;
        when "010" => DIGITS <= ID_EX_RD1;
        when "011" => DIGITS <= ID_EX_RD2;
        when "100" => DIGITS <= ID_EX_Ext_Imm;
        when "101" => DIGITS <= ALURes;
        when "110" => DIGITS <= MEM_WB_MemData;
        when others => DIGITS <= WD;
    end case;
end process;

-- Instantiere SSD pentru afisaj
Componenta7_SSD: SSD port map(clk, DIGITS, an, cat);

-- Indicator LED pentru semnalele principale de control
led(9 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;

end Behavioral;