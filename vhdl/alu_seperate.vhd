library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity alu_seperate is 
port (
  clock : in std_logic;
  instruction : in std_logic_vector(XLEN-1 downto 0); 
  a : in std_logic_vector(XLEN-1 downto 0);
  b : in std_logic_vector(XLEN-1 downto 0);
  c : out std_logic_vector(XLEN-1 downto 0);
);
end entity; 


architecture rtl of alu_seperate is 


signal      opcode : opcode_vector := (others=>'0');
signal      funct3 : funct3_vector := (others=>'0');
signal      funct7 : funct7_vector := (others=>'0');
signal      i_imm  : i_imm_vector  := (others=>'0');

begin 
  -- decode  
  opcode <= instruction(opcode_end downto opcode_start);
  funct3 <= instruction(funct3_end downto funct3_start);
  funct7 <= instruction(funct7_end downto funct7_start);
  i_imm  <= instruction(i_imm_end downto i_imm_start);

  if rising_edge(clock) then 
    case opcode is 
      when "0010011" =>  -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
        case funct3 is
          when "000" => -- ADDI
            c <= a + b;
          when "010" => -- SLTI
            if (signed(a) < signed(b)) then 
              c <= std_logic_vector(to_unsigned(1, XLEN));
            else 
              c <= std_logic_vector(to_unsigned(0, XLEN));
            end if;
              
          when "011" => -- SLTIU
            if (unsigned(a) < unsigned(b)) then 
              c <= std_logic_vector(to_unsigned(1, XLEN));
            else 
              c <= std_logic_vector(to_unsigned(0, XLEN));
            end if;
          when "100" => -- XORI 
            c <= a xor b;
          when "110" => -- ORI
            c <= a or b; 
          when "111" => -- ANDI
            c <= a and b;
          when "001" => -- SLLI
            c <= std_logic_vector(unsigned(a) sll to_integer(unsigned(b(4 downto 0))));
          when "101" => -- SRLI, SRAI
            case funct7 is 
              when "0000000" => -- SRLI
                c <= std_logic_vector(unsigned(a) srl to_integer(unsigned(b(4 downto 0))));
              when "0100000" => -- SRAI
                c <= std_logic_vector(unsigned(a) sra to_integer(unsigned(b(4 downto 0))));
              when others => -- Wrong OP
            end case;
          when others => -- Wrong OP
        end case;

      when "0110011" => -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
        case funct3 is 
          when "000" => -- ADD, SUB
            case funct7 is 
              when "0000000" => -- ADD
                c <= a + b ;
              when "0100000" => -- SUB
                c <= a - b;
              when others => -- Wrong Op
            end case;
          when "001" => -- SLL
            c <= std_logic_vector(unsigned(a) sll to_integer(unsigned(b(4 downto 0))));
          when "010" => -- SLT
            if (signed(a) < signed(b)) then 
              c <= std_logic_vector(to_unsigned(1, XLEN));
            else
              c <= std_logic_vector(to_unsigned(0, XLEN));
            end if;
          when "011" => -- SLTU
            if (unsigned(a) < unsigned(b)) then 
              c <= std_logic_vector(to_unsigned(1, XLEN));
            else
              c <= std_logic_vector(to_unsigned(0, XLEN));
            end if;
          when "100" => -- XOR
            c <= a xor b;
          when "101" => -- SRL, SRA
            case funct7 is 
              when "0000000" => -- SRL 
                c <= std_logic_vector(unsigned(a) srl to_integer(unsigned(b(4 downto 0))));
              when "0100000" => -- SRA
                c <= std_logic_vector(unsigned(a) sra to_integer(unsigned(b(4 downto 0))));
              when others => -- Wrong Op
            end case;
          when "110" => -- OR
            c <= a or b;
          when "111" => -- AND
            c <= a and b;
          when others => -- Wrong Op
        end case;
    end case;
   
  end if;
    

end architecture;
