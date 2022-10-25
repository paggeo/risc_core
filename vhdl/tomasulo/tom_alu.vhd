library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

-- Need only a ,b and what operation to do 
-- b can be either content of a register or a singed_extended imm 
-- A mux gives a XLEN vector to alu
-- ALU does not care

-- Returns C a XLEN vector in 1 clock circle
entity alu is 
port (
  clock : in std_logic;
  -- I need this because reg_to_reg supports also sub
  -- while reg_to_imm do not
  reg_or_imm : in std_logic; -- opcode[5] = 0 then imm els reg
  funct3 : in funct3_vector; -- 3 bits
  funct7 : in std_logic; -- funct7 [5] 
  a : in std_logic_vector(XLEN-1 downto 0);
  b : in std_logic_vector(XLEN-1 downto 0);
  c : out std_logic_vector(XLEN-1 downto 0)
);
end entity; 

architecture rtl of alu is 

begin 
  alu_process : process(reg_or_imm,funct3,funct7,a,b)
  begin 
    --if rising_edge(clock) then 
      case funct3 is 
        when "000" => -- ADDI | ADD , SUB
          if reg_or_imm = '0' then -- ADDI
            c <= a + b;
          else 
            case funct7 is  -- ADD,SUB
              when '0' => -- ADD 
                c <= a + b;
              when '1' => -- SUB
                c <= a - b;
              when others => -- Wrong Op
            end case;
          end if;
        when "010" => -- SLTI | SLT
          if (signed(a) < signed(b)) then 
            c <= std_logic_vector(to_unsigned(1, XLEN));
          else 
            c <= std_logic_vector(to_unsigned(0, XLEN));
          end if;
        when "011" => -- SLTIU | SLTU
          if (unsigned(a) < unsigned(b)) then 
            c <= std_logic_vector(to_unsigned(1, XLEN));
          else 
            c <= std_logic_vector(to_unsigned(0, XLEN));
          end if;
        when "100" => -- XORI | XOR
          c <= a xor b;
        when "110" => -- ORI | OR
          c <= a or b;
        when "111" => -- ANDI | AND
          c <= a and b;
        when "001" => -- SLLI | SLL
          c <= std_logic_vector(unsigned(a) sll to_integer(unsigned(b(4 downto 0))));
        when "101" => -- SRLI, SRAI | SRL, SRAI
          case funct7 is
            when '0' => -- SRLI | SRL
              c <= std_logic_vector(unsigned(a) srl to_integer(unsigned(b(4 downto 0))));
            when '1' => -- SRAI | SRA
              c <=  std_logic_vector(signed(a) sra to_integer(unsigned(b(4 downto 0))));
            when others => -- Wrong OP
          end case;
        when others => -- Wrong OP
      end case;
    --end if;
  end process;
    

end architecture;