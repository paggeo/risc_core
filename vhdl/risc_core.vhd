library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- Simple risc_v_core RV32I base integer instruction set
entity risc_v_core is
 port (
  clock : in std_logic;
  reset : in std_logic;
  instruction : in std_logic_vector(XLEN-1 downto 0 );
  pc_out : out std_logic_vector(XLEN-1 downto 0)
 );
end entity;

architecture rtl of risc_v_core is 

 -- Registers in the processor
 signal      registers : reg_file:= (others=>(others=>'0'));
 constant    zero : std_logic_vector(XLEN-1 downto 0) :=(others=>'0');
 signal pc   : std_logic_vector(XLEN-1 downto 0);

 -- Pipeline registers
 signal      opcode : opcode_vector := (others=>'0');
 signal      funct3 : funct3_vector := (others=>'0');
 signal      funct7 : funct7_vector := (others=>'0');
 signal      rd     : rd_vector     := (others=>'0');
 signal      rs1    : rs1_vector    := (others=>'0');
 signal      rs2    : rs2_vector    := (others=>'0');

 -- integer helper
 signal ird  : integer := 0;
 signal irs1 : integer := 0;
 signal irs2 : integer := 0;

 signal      i_imm           : i_imm_vector          := (others=>'0');
 signal      sb_first_imm    : sb_first_imm_vector   := (others=>'0');
 signal      sb_second_imm   : sb_second_imm_vector  := (others=>'0');
 signal      uj_imm          : uj_imm_vector         := (others=>'0');


 signal i_ram : instruction_ram := (others=>(others=>'0'));
 signal d_ram : data_ram        := data_ram_fillup;

 signal test : std_logic_vector(XLEN-1 downto 0);

 begin 

  registers(0) <= zero;  -- x0 constant zero
  pc_out <= pc;
  main : process(clock,reset)
  begin 
   if rising_edge(clock) then 
    if reset = '1' then 
     --pc <= std_logic_vector(to_unsigned(x"80000000", XLEN));
     pc <= (others=>'0');
     registers <= (others=> (others=> '0'));
     registers(6) <= (others=>'1');
    else 
    -- fetch  
    opcode <= instruction(opcode_end downto opcode_start);
    funct3 <= instruction(funct3_end downto funct3_start);
    funct7 <= instruction(funct7_end downto funct7_start);

    rd  <= instruction(rd_end downto rd_start);
    rs1 <= instruction(rs1_end downto rs1_start);
    rs2 <= instruction(rs2_end downto rs2_start);

    ird  <= to_integer(unsigned(instruction(rd_end downto rd_start)));
    irs1 <= to_integer(unsigned(instruction(rs1_end downto rs1_start)));
    irs2 <= to_integer(unsigned(instruction(rs2_end downto rs2_start)));

    i_imm         <= instruction(i_imm_end downto i_imm_start);
    sb_first_imm  <= instruction(sb_first_imm_end downto sb_first_imm_start);
    sb_second_imm <= instruction(sb_second_imm_end downto sb_second_imm_start);
    uj_imm        <= instruction(uj_imm_end downto uj_imm_start);
    
    --opcode <= i_ram(to_integer(unsigned(pc)))(opcode_end downto opcode_start);
    --funct3 <= i_ram(to_integer(unsigned(pc)))(funct3_end downto funct3_start);
    --funct7 <= i_ram(to_integer(unsigned(pc)))(funct7_end downto funct7_start);

    --rd  <= i_ram(to_integer(unsigned(pc)))(rd_end downto rd_start);
    --rs1 <= i_ram(to_integer(unsigned(pc)))(rs1_end downto rs1_start);
    --rs2 <= i_ram(to_integer(unsigned(pc)))(rs2_end downto rs2_start);

    --i_imm         <= i_ram(to_integer(unsigned(pc)))(i_imm_end downto i_imm_start);
    --sb_first_imm  <= i_ram(to_integer(unsigned(pc)))(sb_first_imm_end downto sb_first_imm_start);
    --sb_second_imm <= i_ram(to_integer(unsigned(pc)))(sb_second_imm_end downto sb_second_imm_start);
    --uj_imm        <= i_ram(to_integer(unsigned(pc)))(uj_imm_end downto uj_imm_start);

    --test <= std_logic_vector'(registers(irs1))+std_logic_vector(resize(signed(i_imm),XLEN)));



    -- Decode
    case opcode is 
    when "1100011" => -- BEQ, BNE, BLT, BGE, BLTU, BGEU
      case funct3 is 
        when "000" => -- BEQ 
          if(registers(irs1) = registers(irs2)) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when "001" => -- BNE 
          if(registers(irs1) /= registers(irs2)) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when "100" => -- BLT
          if(signed(registers(irs1)) < signed(registers(irs2))) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when "101" => -- BGE
          if(signed(registers(irs1)) >= signed(registers(irs2))) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when "110" => -- BLTU
          if(unsigned(registers(irs1)) < unsigned(registers(irs2))) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when "111" => -- BGEU
          if(unsigned(registers(irs1)) >= unsigned(registers(irs2))) then
             pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(0) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-1 downto 1) & '0')),XLEN));
          else 
             pc <= pc +4;
          end if;
       when others => -- Wrong Op
     end case;

    -- TODO: Test jumps (seems correct) 
    when "1101111" => -- JAL
      pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(uj_imm(19) & uj_imm(7 downto 0) & uj_imm(8) & uj_imm(18 downto 9) & '0')),XLEN));
      if ird /= 0 then 
        registers(ird) <= pc + 4 + std_logic_vector(resize(signed(std_logic_vector'(uj_imm(19) & uj_imm(7 downto 0) & uj_imm(8) & uj_imm(18 downto 9) & '0')),XLEN));
      end if;
    when "1100111" => -- JALR
      pc <= signed(irs1)  + std_logic_vector(resize(signed(std_logic_vector'(i_imm)),XLEN));
      if ird /= 0 then 
        registers(ird) <= signed(irs1) + 4 + std_logic_vector(resize(signed(std_logic_vector'(i_imm)),XLEN));
      end if;

    -- test that seems correct
    when "0010111" => -- AUIPC
      registers(ird) <=pc  + std_logic_vector'(uj_imm & "000000000000");
      pc <= pc +4;

    when "0110111" => -- LUI 
      registers(ird) <= std_logic_vector'(uj_imm & "000000000000");
      pc <= pc +4;

    when "0000011" => -- LB, LH, LW, LBU, LHU
      case funct3 is
        when "000" => -- LB
          registers(ird) <= std_logic_vector(resize(signed(d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/4-1 downto 0)),XLEN));
          pc <= pc +4;
        when "001" => -- LH
          registers(ird) <= std_logic_vector(resize(signed(d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/2-1 downto 0)),XLEN));
          pc <= pc +4;
        when "010" => -- LW
          registers(ird) <= std_logic_vector(resize(unsigned(d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(i_imm),XLEN)))))),XLEN));
          pc <= pc +4;
        when "100" => -- LBU   
          registers(ird) <= std_logic_vector(resize(unsigned(d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/4-1 downto 0)),XLEN)); 
          pc <= pc +4;
        when "101" => -- LHU
          registers(ird) <= std_logic_vector(resize(unsigned(d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/2-1 downto 0)),XLEN));
          pc <= pc +4;
        when others => -- Wrong Op
      end case;

    when "0100011" => -- SB, SH, SW
      case funct3 is
        when "000" => -- SB
          d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN)))))(XLEN/4-1 downto 0) <= registers(irs2)(XLEN/4-1 downto 0);
          pc <= pc +4;
        when "001" => -- SH
          d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN)))))(XLEN/2-1 downto 0) <= registers(irs2)(XLEN/2-1 downto 0);
          pc <= pc +4;
        when "010" => -- SW
          d_ram(to_integer(unsigned(std_logic_vector(registers(irs1)) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN))))) <= registers(irs2);
          pc <= pc +4;
        when others => -- Wrong Op
      end case;

    when "0010011" => -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
      case funct3 is 
        when "000" => -- ADDI
          registers(ird) <= std_logic_vector(unsigned(registers(irs1)) + unsigned(resize(signed(i_imm),XLEN)));
          pc <= pc +4;
          --registers(ird) <= (others=>'1');
        when "010" => -- SLTI
          if (signed(registers(irs1)) < signed(resize(signed(i_imm),XLEN))) then
            registers(ird) <= std_logic_vector(to_unsigned(1, XLEN));
            pc <= pc +4;
          else
            registers(ird) <= std_logic_vector(to_unsigned(0, XLEN));
            pc <= pc +4;
          end if;
        when "011" => -- SLTIU
         if (unsigned(registers(irs1)) < unsigned(resize(signed(i_imm),XLEN))) then
           registers(ird) <= std_logic_vector(to_unsigned(1, XLEN));
           pc <= pc +4;
         else
           registers(ird) <= std_logic_vector(to_unsigned(0, XLEN));
           pc <= pc +4;
         end if;
        when "100" => -- XORI
          registers(ird) <= registers(irs1) xor std_logic_vector(resize(signed(i_imm),XLEN));
          pc <= pc +4;
        when "110" => -- ORI
          registers(ird) <= registers(irs1) or std_logic_vector(resize(signed(i_imm),XLEN));
          pc <= pc +4;
        when "111" => -- ANDI
          registers(ird) <= registers(irs1) and std_logic_vector(resize(signed(i_imm),XLEN));
          pc <= pc +4;
        when "001" => -- SLLI
        registers(ird) <= std_logic_vector(registers(irs1) sll to_integer(unsigned(i_imm(4 downto 0))));
        pc <= pc +4;
        when "101" => -- SRLI, SRAI
          case funct7 is 
            when "0000000" => -- SRLI
              registers(ird) <= std_logic_vector(unsigned(registers(irs1)) srl to_integer(unsigned(i_imm(4 downto 0))));
              pc <= pc +4;
            when "0100000" => -- SRAI
              registers(ird) <= std_logic_vector(signed(registers(irs1)) sra to_integer(unsigned(i_imm(4 downto 0))));
              pc <= pc +4;
            when others => -- Wrong Op
          end case;
        when others => -- Wrong Op
      end case;
    
    when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
      case funct3 is 
        when "000" => -- ADD, SUB
          case funct7 is 
            when "0000000" => -- ADD
              registers(ird) <= std_logic_vector(unsigned(registers(irs1)) + unsigned(registers(irs2)));
              pc <= pc +4;
              --registers(ird) <= (others=>'1');
            when "0100000" => -- SUB
              registers(ird) <= std_logic_vector(unsigned(registers(irs1)) - unsigned(registers(irs2)));
              pc <= pc +4;
            when others => -- Wrong Op
          end case;
        when "001" => -- SLL
          registers(ird) <= std_logic_vector(unsigned(registers(irs1)) sll to_integer(unsigned(registers(irs2)(4 downto 0))));
          pc <= pc +4;
        when "010" => -- SLT
          if (signed(registers(irs1)) < signed(registers(irs2))) then
            registers(ird) <= std_logic_vector(to_unsigned(1, XLEN));
            pc <= pc +4;
          else
            registers(ird) <= std_logic_vector(to_unsigned(0, XLEN));
            pc <= pc +4;
          end if;
        when "011" => -- SLTU
          if (unsigned(registers(irs1)) < unsigned(registers(irs2))) then
            registers(ird) <= std_logic_vector(to_unsigned(1, XLEN));
            pc <= pc +4;
          else
            registers(ird) <= std_logic_vector(to_unsigned(0, XLEN));
            pc <= pc +4;
          end if;
        when "100" => -- XOR
          registers(ird) <= registers(irs1) xor registers(irs2);
          pc <= pc +4;
        when "101" => -- SRL, SRA
          case funct7 is 
            when "0000000" => -- SRL 
              registers(ird) <= std_logic_vector(unsigned(registers(irs1)) srl to_integer(unsigned(registers(irs2)(4 downto 0))));
              pc <= pc +4;
            when "0100000" => -- SRA
              registers(ird) <= std_logic_vector(signed(registers(irs1)) sra to_integer(unsigned(registers(irs2)(4 downto 0))));
              pc <= pc +4;
            when others => -- Wrong Op
          end case;
        when "110" => -- OR
          registers(ird) <= registers(irs1) or registers(irs2);
          pc <= pc +4;
        when "111" => -- AND 
          registers(ird) <= registers(irs1) and registers(irs2);
          pc <= pc +4;
        when others => -- Wrong Op
      end case; 

    when "0001111" => -- FENCE 
    when "1110011" => -- ECALL, EBREAK
    when others => -- Wrong Op
    end case;
   end if;
  end if;
 end process;
end architecture; 
