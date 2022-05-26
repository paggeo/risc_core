library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
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


    begin 

    registers(0) <= zero;  -- x0 constant zero

    main : process(clock,reset)
        begin 
            if rising_edge(clock) then 
                if reset = '1' then 
                    pc <= (others=>'0');
                    registers <= (others=> (others=> '0'));
                else 
                  -- fetch  
                  opcode <= instruction(opcode_end downto opcode_start);
                  funct3 <= instruction(funct3_end downto funct3_start);
                  funct7 <= instruction(funct7_end downto funct7_start);

                  rd  <= instruction(rd_end downto rd_start);
                  rs1 <= instruction(rs1_end downto rs1_start);
                  rs2 <= instruction(rs2_end downto rs2_start);

                  i_imm         <= instruction(i_imm_end downto i_imm_start);
                  sb_first_imm  <= instruction(sb_first_imm_end downto sb_first_imm_start);
                  sb_second_imm <= instruction(sb_second_imm_end downto sb_second_imm_start);
                  uj_imm        <= instruction(uj_imm_end downto uj_imm_start);



                  -- Decode
                  -- First "change pc"  instructions else pc <= pc + 4;
                  if (opcode = "1100011") then -- BEQ, BNE, BLT, BGE, BLTU, BGEU
                    if    (funct3 = "000") then -- BEQ
                    elsif (funct3 = "001") then -- BNE
                    elsif (funct3 = "100") then -- BLT
                    elsif (funct3 = "101") then -- BGE
                    elsif (funct3 = "110") then -- BLTU
                    elsif (funct3 = "111") then -- BGEU
                    end if;

                  elsif (opcode = "0010111") then -- AUIPC
                  
                  elsif (opcode = "1101111") then -- JAL
                  
                  elsif (opcode = "1100111") then -- JALR

                  else 
                    pc <= pc + 4; -- If not "change pc" instructions pc <= pc + 4;
                    if (opcode = "0110111") then -- LUI
                    elsif (opcode = "0000011") then -- LB, LH, LW, LBU, LHU
                      if    (funct3 = "000") then -- LB
                      elsif (funct3 = "001") then -- LH
                      elsif (funct3 = "010") then -- LW
                      elsif (funct3 = "100") then -- LBU
                      elsif (funct3 = "101") then -- LHU
                      end if;
                    elsif (opcode = "0100011") then -- SB, SH, SW
                      if    (funct3 = "000") then -- SB
                      elsif (funct3 = "001") then -- SH
                      elsif (funct3 = "010") then -- SW
                      end if;
                    elsif (opcode = "0010011") then -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                      if    (funct3 = "000") then -- ADDI
                        registers(unsigned(rd)) <= std_logic_vector(unsigned(registers(unsigned(rs1))) + unsigned(resize(i_imm,XLEN))); 
                          
                      elsif (funct3 = "010") then -- SLTI
                        if (signed(resigters(unsigned(rs1))) < signed(resize(i_imm,XLEN))) then 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(1, XLEN));
                        else 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(0, XLEN));
                        end if;

                      elsif (funct3 = "011") then -- SLTIU
                        if (unsigned(resigters(unsigned(rs1))) < unsigned(resize(i_imm,XLEN))) then 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(1, XLEN));
                        else 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(0, XLEN));
                        end if;

                      elsif (funct3 = "100") then -- XORI
                            registers(unsigned(rd)) <= registers(unsigned(rs1) xor std_logic_vector(resize(i_imm,XLEN));

                      elsif (funct3 = "110") then -- ORI
                            registers(unsigned(rd)) <= registers(unsigned(rs1) or std_logic_vector(resize(i_imm,XLEN));

                      elsif (funct3 = "111") then -- ANDI
                            registers(unsigned(rd)) <= registers(unsigned(rs1) and std_logic_vector(resize(i_imm,XLEN));

                      elsif (funct3 = "001") then -- SLLI 
                            registers(unsigned(rd)) <= registers(unsigned(rs1)) sll to_integer(i_imm(4 downto 0));

                      elsif (funct3 = "101") then -- SRLI, SRAI 
                            if (funct7 = "0000000") then -- SRLI
                              registers(unsigned(rd)) <= registers(unsigned(rs1)) srl to_integer(i_imm(4 downto 0));
                      
                            elsif (funct7 = "0100000") then -- SRAI
                              registers(unsigned(rd)) <= registers(unsigned(rs1)) sra to_integer(i_imm(4 downto 0));
                            end if;

                      end if;

                    elsif (opcode = "0110011") then -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                      if (funct3 = "000") then -- ADD, SUB
                         if (funct7 = "0000000") then -- ADD
                            registers(unsigned(rd)) <= std_logic_vector(unsigned(registers(unsigned(rs1))) + unsigned(register(unsigned(rs2)));
                         
                         elsif (funct7 = "0100000") then -- SUB
                            registers(unsigned(rd)) <= std_logiv_vector(unsigned(registers(unsigned(rs1))) - unsigned(register(unsigned(rs2))));
                          end if;

                      elsif (funct3 = "001") then -- SLL
                            registers(unsigned(rd)) <= registers(unsigned(rs1)) sll to_integer(unsigned(registers(unsigned(rs2)))(4 downto 0));

                      elsif (funct3 = "010") then -- SLT
                          if ( signed(registers(unsigned(rs1))) < signed(registers(unsigned(rs2))) ) then
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(1, XLEN));
                          
                          else 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(0, XLEN));
                          end if;

                      elsif (funct3 = "011") then -- SLTU
                          if ( unsigned(registers(unsigned(rs1))) < unsigned(registers(unsigned(rs2))) ) then
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(1, XLEN));
                          else 
                            registers(unsigned(rd)) <= std_logic_vector(to_unsigned(0, XLEN));
                          end if;

                      elsif (funct3 = "100") then -- XOR
                            registers(unsigned(rd)) <= registers(unsigned(rs1)) xor registers(unsigned(rs2)); 

                      elsif (funct3 = "101") then -- SRL, SRA
                            if (funct7 = "0000000") then -- SRL
                              registers(unsigned(rd)) <= registers(unsigned(rs1)) srl to_integer(unsigned(registers(unsigned(rs2)))(4 downto 0));
                            elsif (funct7 = "0100000") then -- SRA
                              registers(unsigned(rd)) <= registers(unsigned(rs1)) sra to_integer(unsigned(registers(unsigned(rs2)))(4 downto 0));
                            end if;
                            
                      elsif (funct3 = "110") then -- OR
                            registers(unsigned(rd)) <= registers(unsigned(rs1)) or registers(unsigned(rs2)); 

                      elsif (funct3 = "111") then -- AND
                            registers(unsigned(rd)) <= registers(unsigned(rs1)) and registers(unsigned(rs2)); 
                      end if;

                    elsif (opcode = "0001111") then -- FENCE
                    elsif (opcode = "1110011") then -- ECALL, EBREAK
                    end if;
                  end if; 
                end if; 
            end if;
    end process;
end architecture; 
