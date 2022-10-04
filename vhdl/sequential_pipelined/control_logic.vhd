library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity control_logic is 
port (
  clock                   : in std_logic;
  instruction             : in std_logic_vector(XLEN-1 downto 0);
  c_z                     : in std_logic;
  c_alu                   : out std_logic_vector(4 downto 0);
  c_write_enable          : out std_logic;
  c_reg_or_imm_or_sbimm   : out std_logic_vector(1 downto 0);
  c_memory_output_enable  : out std_logic;
  c_memory_write_enable   : out std_logic;
  c_memory_op_type        : out std_logic_vector(2 downto 0);
  c_pc_select             : out std_logic_vector(1 downto 0);
  c_branch_flag           : out std_logic_vector(2 downto 0);
  c_read_memory_or_alu    : out std_logic_vector(1 downto 0)
);
end entity;

architecture rtl of control_logic is 

signal      opcode : opcode_vector := (others=>'0');
signal      funct3 : funct3_vector := (others=>'0');
signal      funct7 : funct7_vector := (others=>'0');
signal      rd     : rd_vector     := (others=>'0');
signal      rs1    : rs1_vector    := (others=>'0');
signal      rs2    : rs2_vector    := (others=>'0');

type opcode_array is array(0 to 4) of opcode_vector;
signal opcode_t : opcode_array:=(others=>(others=>'0'));

type funct3_array is array(0 to 4) of funct3_vector;
signal funct3_t : funct3_array:=(others=>(others=>'0'));

type funct7_array is array(0 to 4) of funct7_vector;
signal funct7_t : funct7_array:=(others=>(others=>'0'));

type rd_array is array(0 to 4) of rd_vector;
signal rd_t : rd_array:=(others=>(others=>'0'));

type rs1_array is array(0 to 4) of rs1_vector;
signal rs1_t : rs1_array:=(others=>(others=>'0'));

type rs2_array is array(0 to 4) of rs2_vector;
signal rs2_t : rs2_array:=(others=>(others=>'0'));

begin 

  fetch_process : process(clock)
  begin 
    if rising_edge(clock) then 
      opcode_t(0) <= instruction(opcode_end downto opcode_start);
      funct3_t(0) <= instruction(funct3_end downto funct3_start);
      funct7_t(0) <= instruction(funct7_end downto funct7_start);

      rd_t(0)  <= instruction(rd_end downto rd_start);
      rs1_t(0) <= instruction(rs1_end downto rs1_start);
      rs2_t(0) <= instruction(rs2_end downto rs2_start);

      opcode_t(1 to 4) <= opcode_t(0 to 3);
      funct3_t(1 to 4) <= funct3_t(0 to 3);
      funct7_t(1 to 4) <= funct7_t(0 to 3);
      rd_t(1 to 4)     <= rd_t(0 to 3);
      rs1_t(1 to 4)    <= rs1_t(0 to 3);
      rs2_t(1 to 4)    <= rs2_t(0 to 3);
    end if;
  end process;


   alu_process : process(funct7_t,funct3_t,opcode_t)
   begin 
    --if rising_edge(clock) then 
      case opcode_t(0) is 
        when "0000011" =>
           c_alu <= '0' & "000" & '0';
        when "0100011" => 
          c_alu <= '0' & "000" & '0';
        when others => 
          c_alu <= funct7_t(0)(5) & funct3_t(0) & opcode_t(0)(5);
      end case;
    --end if;
   end process;

  write_enable_process : process(opcode_t)
  begin 
    --if rising_edge(clock) then 
      if opcode_t(2) = "0100011" then --Store
        c_write_enable <= '0';
      else 
        c_write_enable <= '1';
      end if;
    --end if;
  end process;

  reg_or_imm_process : process(opcode_t)
  begin 
    --if rising_edge(clock) then
      if opcode_t(0) = "0110011" then -- reg
        c_reg_or_imm_or_sbimm <= "00";
      elsif opcode = "0100011" then -- store
        c_reg_or_imm_or_sbimm <= "01";
      else  -- everything else -- Load
        c_reg_or_imm_or_sbimm <= "11";
      end if;
    --end if;
  end process;

  memory_enable : process(opcode_t,funct3_t)
  begin 
    --if rising_edge(clock) then  
      c_memory_op_type <= funct3_t(2);
      if opcode_t(2) = "0000011" then 
        c_memory_write_enable  <= '0';
        c_memory_output_enable <= '1';
        c_read_memory_or_alu  <= "10";
      elsif opcode_t(2) = "0100011" then 
        c_memory_write_enable  <= '1';
        c_memory_output_enable <= '0';
        c_read_memory_or_alu  <= "10";
      elsif opcode_t(2) = "1100011" or opcode_t(2) = "1101111" then -- Branch | Jump
        c_memory_write_enable  <= '0';
        c_memory_output_enable <= '0';
        c_read_memory_or_alu  <= "00";
      else  
        c_memory_write_enable  <= '0';
        c_memory_output_enable <= '0';
        c_read_memory_or_alu  <= "01";
      end if;
    --end if;
  end process;

  write_back_select : process(opcode_t)
  begin 
    --if rising_edge(clock) then 
      if opcode_t(2) = "0000011" then 
        c_read_memory_or_alu  <= "10";
      elsif opcode_t(3) = "0100011" then 
        c_read_memory_or_alu  <= "10";
      elsif opcode_t(3) = "1100011" or opcode_t(2) = "1101111" then -- Branch | Jump
        c_read_memory_or_alu  <= "00";
      else  
        c_read_memory_or_alu  <= "01";
      end if;
    --end if;
  end process;
 
  pc_select_process: process(clock)
  begin 
    c_branch_flag <= funct3_t(2);
    if opcode_t(2) = "1100011" and c_z = '1' then 
      c_pc_select <= "01";
    elsif opcode_t(2) = "1101111" then 
      c_pc_select <= "10";
    else 
      c_pc_select <= "00";
    end if;
  end process;

end architecture;
