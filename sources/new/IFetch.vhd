library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity IFetch is
  Port (CLK: in std_logic;
        RST: in std_logic;
        EN: in std_logic;
        Jump: in std_logic;
        JumpAddress: in std_logic_vector(31 downto 0);
        PCSrc: in std_logic;
        BranchAddress: in std_logic_vector(31 downto 0);
        PC: out std_logic_vector(31 downto 0);
        Instruction: out std_logic_vector(31 downto 0));
end IFetch;

architecture Behavioral of IFetch is
  signal PC_internal : std_logic_vector(31 downto 0) := (others => '0');
  signal Next_PC : std_logic_vector(31 downto 0);
  signal ROM_output : std_logic_vector(31 downto 0);
 
  signal outMUX1: std_logic_vector(31 downto 0) := (others => '0');
  signal outMUX2: std_logic_vector(31 downto 0) := (others => '0');
  signal outADD: std_logic_vector(31 downto 0) := (others => '0');
  signal outPC: std_logic_vector(31 downto 0) := (others => '0');
  signal outROM: std_logic_vector(31 downto 0);

 type rom_type is array (0 to 63) of std_logic_vector(31 downto 0);
  signal ROM : rom_type := (
    B"000000_00000_00000_00001_00000_100000",  -- 0: add $1, $0, $0  -- X"00000020" ; $1 = $0 + $0 (adica $1 = 0)  
    B"100011_00000_00100_0000000000000000",    -- 1: lw $4, 0($0)    -- X"8C040000" ; $4 = Mem[$0 + 0] (încarcã în $4 valoarea de la adresa 0 = lungime array
    B"000000_00000_00000_00010_00000_100000",  -- 2: add $2, $0, $0  -- X"00000020" ; $2 = $0 + $0 (adica $2 = 0 = initializare index array)
    B"001000_00000_00101_1111111111111111",    -- 3: addi $5, $0, -1 -- X"2005FFFF" ; $5 = $0 + (-1) (adica $5 = -1 = default max value)
    B"000100_00001_00100_0000000000001100",    -- 4: beq $1, $4, 12  -- X"1024000C" ; dacã $1 == $4, sari cu 12 instruc?iuni înainte 
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"100011_00010_00011_0000000000000000",    -- 5: lw $3, 0($2)    -- X"8C430000" ; $3 = Mem[$2 + 0] (încarcã în $3 valoarea de la adresa $2 = citeste elem curent din array)
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"001100_00011_00110_0000000000000001",    -- 6: andi $6, $3, 1  -- X"30660001" ; $6 = $3 AND 1 (testare dacã $3 e par/impar)
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000100_00110_00000_0000000000000011",    -- 7: bne $6, $0, 3   -- X"14C00003" ; dacã $6 == 0 (par) sari cu 3 instruc?iuni
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000100_00101_00000_1111111111111110",    -- 8: beq $5, $0, -2  -- X"15A0FFFE" ; dacã $5 == $0, sari cu -2 instruc?iuni pentru a reincerca 
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00011_00101_00110_00000_100010",  -- 9: sub $6, $3, $5  -- X"00653022" ; $6 = $3 - $5 = compara elem curent cu anteriorul
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000101_00110_00000_1111111111111101",    -- 10: bne $6, $0, -3 -- X"14C0FFFD" ; dacã $6 ? 0, sari cu -3 instruc?iuni daca nr e impar
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"000000_00011_00000_00101_00000_100000",  -- 11: add $5, $3, $0 -- X"00602820" ; $5 = $3 + 0 (adica $5 = $3 = actualizarevaloare curenta)
    B"000010_00000000000000000000010010",      -- 12: j 18          -- X"08000008" ; sari la adresa 8 (instruc?iunea 8 = reia verificarea pentru urmatorul element din array)
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"001000_00010_00010_0000000000000100",    -- 13: addi $2, $2, 4 -- X"20420004" ; $2 = $2 + 4 (avanseazã la urmãtorul element în memorie)
    B"001000_00001_00001_0000000000000001",    -- 14: addi $1, $1, 1 -- X"20210001" ; $1 = $1 + 1 (incrementeazã $1)
    B"000010_00000000000000000000000011",      -- 15: j 3          -- X"08000003" ; sari la instruc?iunea 3 (reia bucla principala)
   B"000000_00000_00000_00000_00000_100000",   -- X"0000 0020"; NoOp
    B"101011_00000_00101_0000000000000000",    -- 16: sw $5, 0($0)   -- X"AC050000" ; salveazã $5 în Mem[0] 

    others => X"00000000" 
  );

begin

  -- Next PC logic -- alegem adresa urmatoare in functie de Jump sau Branch
  process(PC_internal, Jump, JumpAddress, PCSrc, BranchAddress)
  begin
    if Jump = '1' then
      Next_PC <= JumpAddress;
    elsif PCSrc = '1' then
      Next_PC <= BranchAddress;
    else
      Next_PC <= PC_internal + 4; -- urmatoarea instructiune (+4 bytes)
    end if;
  end process;

  -- actualizare sincrona PC -- avanseaza la urmatoarea instructiune/branch/jump
  process(CLK)
  begin
    if rising_edge(CLK) then
      if RST = '1' then
        PC_internal <= (others => '0');
      elsif EN = '1' then
        PC_internal <= Next_PC;
      end if;
    end if;
  end process;

  -- Instruction fetch
  ROM_output <= ROM(conv_integer(PC_internal(7 downto 2))); -- doar 32 intrari => adresãm cu PC[6:2]

  PC <= PC_internal;
  Instruction <= ROM_output;

end Behavioral;