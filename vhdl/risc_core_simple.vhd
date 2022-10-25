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

                  
                  
                  -- Decode - Execute - Memory
                  if (opcode = "1100011") then -- BEQ, BNE, BLT, BGE, BLTU, BGEU
                    if    (funct3 = "000") then -- BEQ
                      if(registers(to_integer(unsigned(rs1))) = registers(to_integer(unsigned(rs2)))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    elsif (funct3 = "001") then -- BNE
                      if(registers(to_integer(unsigned(rs1))) /= registers(to_integer(unsigned(rs2)))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    elsif (funct3 = "100") then -- BLT
                      if(signed(registers(to_integer(unsigned(rs1)))) < signed(registers(to_integer(unsigned(rs2))))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    elsif (funct3 = "101") then -- BGE
                      if(signed(registers(to_integer(unsigned(rs1)))) >= signed(registers(to_integer(unsigned(rs2))))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    elsif (funct3 = "110") then -- BLTU
                      if(unsigned(registers(to_integer(unsigned(rs1)))) < unsigned(registers(to_integer(unsigned(rs2))))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    elsif (funct3 = "111") then -- BGEU
                      if(unsigned(registers(to_integer(unsigned(rs1)))) >= unsigned(registers(to_integer(unsigned(rs2))))) then 
                        pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm(sb_second_imm'length-1) & sb_first_imm(sb_first_imm'length-1) & sb_second_imm(sb_second_imm'length-2 downto 0) & sb_first_imm(sb_first_imm'length-2 downto 0))),XLEN));
                      else 
                        pc <= pc +4;
                      end if;
                    end if;

                  

                  elsif (opcode = "1101111") then -- JAL
                    pc <= pc + std_logic_vector(resize(signed(std_logic_vector'(uj_imm(uj_imm'length-1) & uj_imm(7 downto 0) & uj_imm(8) & uj_imm(18 downto 9))),XLEN));
                    registers(to_integer(unsigned(rd))) <= pc + 4 + std_logic_vector(resize(signed(std_logic_vector'(uj_imm(uj_imm'length-1) & uj_imm(7 downto 0) & uj_imm(8) & uj_imm(18 downto 9))),XLEN));
                  
                  -- TODO: Fix this
                  elsif (opcode = "1100111") then -- JALR 
                    pc <= pc + std_logic_vector'(test(XLEN-1 downto 1) & "0");
                    registers(to_integer(unsigned(rd)))  <= pc + 4 + std_logic_vector'(test(XLEN-1 downto 1) & "0") ;

                  else 
                    pc <= pc + 4; -- If not "change pc" instructions pc <= pc + 4;
                    if (opcode = "0010111") then -- AUIPC
                        registers(to_integer(unsigned(rd))) <=pc  + std_logic_vector'(uj_imm & "000000000000");
                    elsif (opcode = "0110111") then -- LUI
                        registers(to_integer(unsigned(rd))) <= std_logic_vector'(uj_imm & "000000000000");
                    elsif (opcode = "0000011") then -- LB, LH, LW, LBU, LHU
                      if    (funct3 = "000") then -- LB
                        registers(to_integer(unsigned(rd))) <= std_logic_vector(resize(signed(d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/4 downto 0)),XLEN));
                      elsif (funct3 = "001") then -- LH
                        registers(to_integer(unsigned(rd))) <= std_logic_vector(resize(signed(d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/2 downto 0)),XLEN));
                      elsif (funct3 = "010") then -- LW
                        registers(to_integer(unsigned(rd))) <= d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(i_imm),XLEN)))));
                        
                      elsif (funct3 = "100") then -- LBU
                        registers(to_integer(unsigned(rd))) <= std_logic_vector(resize(unsigned(d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/4 downto 0)),XLEN));
                      elsif (funct3 = "101") then -- LHU
                        registers(to_integer(unsigned(rd))) <= std_logic_vector(resize(unsigned(d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(i_imm),XLEN)))))(XLEN/2 downto 0)),XLEN));
                      end if;
                    elsif (opcode = "0100011") then -- SB, SH, SW
                      if    (funct3 = "000") then -- SB
                        d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN)))))(XLEN/4 downto 0) <= registers(to_integer(unsigned(rs2)))(XLEN/4 downto 0);
                      elsif (funct3 = "001") then -- SH
                        d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN)))))(XLEN/2 downto 0) <= registers(to_integer(unsigned(rs2)))(XLEN/2 downto 0);
                      elsif (funct3 = "010") then -- SW
                        d_ram(to_integer(unsigned(std_logic_vector(registers(to_integer(unsigned(rs1)))) + std_logic_vector(resize(signed(std_logic_vector'(sb_second_imm & sb_first_imm)),XLEN))))) <= registers(to_integer(unsigned(rs2)));
                      end if;
                      
                    elsif (opcode = "0010011") then -- ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLI, SRAI
                      if    (funct3 = "000") then -- ADDI
                        registers(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(rs1)))) + unsigned(resize(signed(i_imm),XLEN))); 
                          
                      elsif (funct3 = "010") then -- SLTI
                        if (signed(registers(to_integer(unsigned(rs1)))) < signed(resize(signed(i_imm),XLEN))) then 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(1, XLEN));
                        else 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(0, XLEN));
                        end if;

                      elsif (funct3 = "011") then -- SLTIU
                        if (unsigned(registers(to_integer(unsigned(rs1)))) < unsigned(resize(signed(i_imm),XLEN))) then 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(1, XLEN));
                        else 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(0, XLEN));
                        end if;

                      elsif (funct3 = "100") then -- XORI
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) xor std_logic_vector(resize(signed(i_imm),XLEN));

                      elsif (funct3 = "110") then -- ORI
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) or std_logic_vector(resize(signed(i_imm),XLEN));

                      elsif (funct3 = "111") then -- ANDI
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) and std_logic_vector(resize(signed(i_imm),XLEN));

                      elsif (funct3 = "001") then -- SLLI 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(registers(to_integer(unsigned(rs1))) sll to_integer(unsigned(i_imm(4 downto 0))));

                      elsif (funct3 = "101") then -- SRLI, SRAI 
                            if (funct7 = "0000000") then -- SRLI
                              registers(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(rs1)))) srl to_integer(unsigned(i_imm(4 downto 0))));
                            elsif (funct7 = "0100000") then -- SRAI
                              registers(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(rs1)))) sra to_integer(unsigned(i_imm(4 downto 0))));
                            end if;

                      end if;

                    elsif (opcode = "0110011") then -- ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRA, OR, AND
                      if (funct3 = "000") then -- ADD, SUB
                         if (funct7 = "0000000") then -- ADD
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(rs1)))) + unsigned(registers(to_integer(unsigned(rs2)))));
                         
                         elsif (funct7 = "0100000") then -- SUB
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(unsigned(registers(to_integer(unsigned(rs1)))) - unsigned(registers(to_integer(unsigned(rs2)))));
                          end if;

                      elsif (funct3 = "001") then -- SLL
                            registers(to_integer(unsigned(rd))) <= std_logic_vector((unsigned(registers(to_integer(unsigned(rs1)))) sll to_integer(unsigned(registers(to_integer(unsigned(rs2)))(4 downto 0)))));

                      elsif (funct3 = "010") then -- SLT
                          if (signed(registers(to_integer(unsigned(rs1)))) < signed(registers(to_integer(unsigned(rs2))))) then
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(1, XLEN));
                          
                          else 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(0, XLEN));
                          end if;

                      elsif (funct3 = "011") then -- SLTU
                          if (unsigned(registers(to_integer(unsigned(rs1)))) < unsigned(registers(to_integer(unsigned(rs2))))) then
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(1, XLEN));
                          else 
                            registers(to_integer(unsigned(rd))) <= std_logic_vector(to_unsigned(0, XLEN));
                          end if;

                      elsif (funct3 = "100") then -- XOR
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) xor registers(to_integer(unsigned(rs2))); 

                      elsif (funct3 = "101") then -- SRL, SRA
                            if (funct7 = "0000000") then -- SRL
                              registers(to_integer(unsigned(rd))) <= std_logic_vector((unsigned(registers(to_integer(unsigned(rs1)))) srl to_integer(unsigned(registers(to_integer(unsigned(rs2)))(4 downto 0)))));
                            elsif (funct7 = "0100000") then -- SRA
                              registers(to_integer(unsigned(rd))) <= std_logic_vector((unsigned(registers(to_integer(unsigned(rs1)))) sra to_integer(unsigned(registers(to_integer(unsigned(rs2)))(4 downto 0)))));

                            end if;
                            
                      elsif (funct3 = "110") then -- OR
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) or registers(to_integer(unsigned(rs2))); 

                      elsif (funct3 = "111") then -- AND
                            registers(to_integer(unsigned(rd))) <= registers(to_integer(unsigned(rs1))) and registers(to_integer(unsigned(rs2))); 
                      end if;

                    elsif (opcode = "0001111") then -- FENCE
                        pc <= (others=>'0');
                    elsif (opcode = "1110011") then -- ECALL, EBREAK
                        pc <= (others=>'0');
                    end if;
                  end if; 
                end if; 
            end if;
    end process;
end architecture; 
