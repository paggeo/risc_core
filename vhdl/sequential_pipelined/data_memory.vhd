library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;


entity data_memory is 
port(
  clock     : in std_logic;
  address   : in std_logic_vector(XLEN-1 downto 0);
  memory_output_enable  : in std_logic;
  memory_write_enable   : in std_logic;
  memory_op_type        : in std_logic_vector(2 downto 0);
  write_data            : in std_logic_vector(XLEN-1 downto 0);
  read_data             : out std_logic_vector(XLEN-1 downto 0)
);
end data_memory; 

architecture rtl of data_memory is 

signal data_memory        : data_ram := data_ram_fillup; -- Fill this

begin
  load_process : process(clock)
  begin 
    if rising_edge(clock) then 
        if address < d_ram_size then 
          if memory_output_enable = '1' then 
            case memory_op_type is 
              when "000" => -- LB
                read_data <= std_logic_vector(resize(signed(data_memory(to_integer(unsigned(address)))(XLEN/4-1 downto 0)),XLEN));
              when "001" => -- LH
                read_data <= std_logic_vector(resize(signed(data_memory(to_integer(unsigned(address)))(XLEN/2-1 downto 0)),XLEN));
              when "010" => -- LW
                read_data <= std_logic_vector(resize(signed(data_memory(to_integer(unsigned(address)))),XLEN));
              when "100" => -- LBU
                read_data <= std_logic_vector(resize(unsigned(data_memory(to_integer(unsigned(address)))(XLEN/4-1 downto 0)),XLEN));
              when "101" => -- LHU
                read_data <= std_logic_vector(resize(unsigned(data_memory(to_integer(unsigned(address)))(XLEN/2-1 downto 0)),XLEN));
              when others => -- Wrong Op
            end case;
          else 
            read_data <= (others=>'0');
          end if;
        else 
            read_data <= (others=>'0');
        end if;
    end if;
  end process;

  store_process : process(clock)
  begin 
    if rising_edge(clock) then 
      if address <= d_ram_size then 
        if memory_write_enable = '1' then 
          case memory_op_type is 
            when "000" => -- SB
              data_memory(to_integer(unsigned(address)))(XLEN/4-1 downto 0) <= write_data(XLEN/4-1 downto 0);
            when "001" => -- SH
              data_memory(to_integer(unsigned(address)))(XLEN/2-1 downto 0) <= write_data(XLEN/2-1 downto 0);
            when "010" => -- SW
              data_memory(to_integer(unsigned(address))) <= write_data;
            when others=> -- Wrong Op
          end case;
        else -- Do nothing
        end if;
      else
      end if;
    end if;
  end process;

end architecture;
