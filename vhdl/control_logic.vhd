library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity control_logic is 
port (
  instruction             : in std_logic_vector(XLEN-1 downto 0);
  c_alu                   : out std_logic_vector(4 downto 0);
  c_write_enable          : out std_logic;
  c_reg_or_imm_or_sbimm   : out std_logic_vector(1 downto 0);
  c_memory_output_enable  : out std_logic;
  c_memory_write_enable   : out std_logic;
  c_memory_op_type        : out std_logic_vector(2 downto 0);
  c_read_memory_or_alu      : out std_logic_vector(1 downto 0)
);
end entity;

architecture rtl of control_logic is 

signal      opcode : opcode_vector := (others=>'0');
signal      funct3 : funct3_vector := (others=>'0');
signal      funct7 : funct7_vector := (others=>'0');
signal      rd     : rd_vector     := (others=>'0');
signal      rs1    : rs1_vector    := (others=>'0');
signal      rs2    : rs2_vector    := (others=>'0');

begin 

opcode <= instruction(opcode_end downto opcode_start);
funct3 <= instruction(funct3_end downto funct3_start);
funct7 <= instruction(funct7_end downto funct7_start);

rd  <= instruction(rd_end downto rd_start);
rs1 <= instruction(rs1_end downto rs1_start);
rs2 <= instruction(rs2_end downto rs2_start);

c_alu <= funct7(5) & funct3 & opcode(5);

  write_enable_process : process(opcode)
  begin 
    if opcode = "0100011" then --Store
      c_write_enable <= '0';
    else 
      c_write_enable <= '1';
    end if;
  end process;

  reg_or_imm_process : process(opcode)
  begin 
    if opcode = "0110011" then -- reg
      c_reg_or_imm_or_sbimm <= "00";
    elsif opcode = "0100011" then -- store
      c_reg_or_imm_or_sbimm <= "01";
    else  -- everything else -- Load
      c_reg_or_imm_or_sbimm <= "11";
    end if;
  end process;

  memory_enable : process(opcode,funct3)
  begin 
    c_memory_op_type <= funct3;
    if opcode = "0000011" then 
      c_memory_write_enable  <= '0';
      c_memory_output_enable <= '1';
      c_read_memory_or_alu  <= "10";
    elsif opcode = "0100011" then 
      c_memory_write_enable  <= '0';
      c_memory_output_enable <= '1';
      c_read_memory_or_alu  <= "10";
    else  
      c_memory_write_enable  <= '0';
      c_memory_output_enable <= '0';
      c_read_memory_or_alu  <= "01";
    end if;
  end process;

end architecture;
