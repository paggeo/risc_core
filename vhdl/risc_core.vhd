library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- Simple risc_v_core RV32I base integer instruction set
entity risc_v_core_simple is
 port (
  clock : in std_logic;
  reset : in std_logic;
  instruction : in std_logic_vector(XLEN-1 downto 0 );
  pc : out std_logic_vector(XLEN-1 downto 0)
 );
end entity;

architecture rtl of risc_v_core_simple is 

 signal      registers : reg_file:= (others=>(others=>'0'));
 constant    zero : std_logic_vector(XLEN-1 downto 0) :=(others=>'0');
 signal      opcode : opcode_vector := (others=>'0');
 signal      funct3 : funct3_vector := (others=>'0');
 signal      funct7 : funct7_vector := (others=>'0');
 signal      rd     : rd_vector     := (others=>'0');
 signal      rs1    : rs1_vector    := (others=>'0');
 signal      rs2    : rs2_vector    := (others=>'0');

 signal      i_imm           : i_imm_vector          := (others=>'0');
 signal      sb_first_imm    : sb_first_imm_vector   := (others=>'0');
 signal      sb_second_imm   : sb_second_imm_vector  := (others=>'0');
 signal      uj_imm          : uj_imm_vector         := (others=>'0');


 signal i_ram : instruction_ram := (others=>(others=>'0'));
 signal d_ram : data_ram        := (others=>(others=>'0'));

 signal test : std_logic_vector(XLEN-1 downto 0);
 begin 

  registers(0) <= zero;  -- x0 constant zero

  main : process(clock,reset)
  begin 
   if rising_edge(clock) then 
    if reset = '1' then 
     --pc <= std_logic_vector(to_unsigned(x"80000000", XLEN));
     pc <= (others=>'0');
     registers <= (others=> (others=> '0'));
    else 
    -- fetch  
    opcode <= i_ram(to_integer(unsigned(pc)))(opcode_end downto opcode_start);
    funct3 <= i_ram(to_integer(unsigned(pc)))(funct3_end downto funct3_start);
    funct7 <= i_ram(to_integer(unsigned(pc)))(funct7_end downto funct7_start);

    rd  <= i_ram(to_integer(unsigned(pc)))(rd_end downto rd_start);
    rs1 <= i_ram(to_integer(unsigned(pc)))(rs1_end downto rs1_start);
    rs2 <= i_ram(to_integer(unsigned(pc)))(rs2_end downto rs2_start);

    i_imm         <= i_ram(to_integer(unsigned(pc)))(i_imm_end downto i_imm_start);
    sb_first_imm  <= i_ram(to_integer(unsigned(pc)))(sb_first_imm_end downto sb_first_imm_start);
    sb_second_imm <= i_ram(to_integer(unsigned(pc)))(sb_second_imm_end downto sb_second_imm_start);
    uj_imm        <= i_ram(to_integer(unsigned(pc)))(uj_imm_end downto uj_imm_start);

    test <= std_logic_vector'(registers(to_integer(unsigned(rs1)))+std_logic_vector(resize(signed(i_imm),XLEN)));



    -- Decode
    -- First "change pc"  instructions else pc <= pc + 4;
    -- TODO: Check negative jumps
    case opcode is 
    when "1100011" => -- BEQ, BNE, BLT, BGE, BLTU, BGEU
     case funct3 is 
     when "000" => -- BEQ 
     when "001" => -- BNE 
     when "100" => -- BLT
     when "101" => -- BGE
     when "110" => -- BLTU
     when "111" => -- BGEU
     end case;
    when "1101111" => -- JAL
    when "1100111" => -- JALR
    when "0010111" => -- AUIPC
    when "0110111" => -- LUI 
    when "0000011" => -- LB, LH, LW, LBU, LHU
    when "0100011" => -- SB, SH, SW
    when "0010011" => -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
    when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
    when "0001111" => -- FENCE 
    when "1110011" => -- ECALL, EBREAK
    when others => -- Wrong Op
    end case;
   end if;
  end if;
 end process;
end architecture; 
