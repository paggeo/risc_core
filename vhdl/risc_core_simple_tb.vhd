library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;

library std;
use std.textio.all;

entity risc_v_core_simple_tb is 
end entity;


architecture testbench of risc_v_core_simple_tb is 

  -----------------------------------------------------------------------
  -- Component
  -----------------------------------------------------------------------
    component risc_v_core_simple
        port (
            clock : in std_logic;
            reset : in std_logic;
            -- instruction : in std_logic_vector(31 downto 0 );
            adder_1 : in std_logic_vector(3 downto 0);
            adder_2 : in std_logic_vector(3 downto 0);
            output_adder : out std_logic_vector(3 downto 0)
        );
    end component;

  -----------------------------------------------------------------------
  -- Timing constants
  -----------------------------------------------------------------------
  constant clock_period : time := 10 ns;
  constant TIME_DELAY       : time := 50 ns;
  -----------------------------------------------------------------------
  -- DUT signals
  -----------------------------------------------------------------------

  -- General signals
  signal clock                        : std_logic := '0';  -- the master clock
  signal reset                        : std_logic := '0';  -- the master clock


  -- Input signals 
  signal   adder_1 : std_logic_vector(3 downto 0);
  signal   adder_2 : std_logic_vector(3 downto 0);

  -- Output signals 
  signal   output_adder : std_logic_vector(3 downto 0);
  type adder_inputs is record
    adder_1 : std_logic_vector(3 downto 0);
    adder_2 : std_logic_vector(3 downto 0);
  end record;
  type adder_array is array (0 to 7) of adder_inputs;

  -----------------------------------------------------------------------
  -- Function to generate custom input_data
  function custom_ip_table return adder_array is
    variable result : adder_array;
    begin 
        result(0).adder_1 := "0000";
        result(0).adder_2 := "0000";
 
        result(1).adder_1 := "0001";
        result(1).adder_2 := "0010";
 
        result(2).adder_1 := "0001";
        result(2).adder_2 := "0011";
 
        result(3).adder_1 := "0101";
        result(3).adder_2 := "0110";
 
        result(4).adder_1 := "1001";
        result(4).adder_2 := "0010";
 
        result(5).adder_1 := "0100";
        result(5).adder_2 := "0010";
 
        result(6).adder_1 := "1001";
        result(6).adder_2 := "1010";
 
        result(7).adder_1 := "0100";
        result(7).adder_2 := "0010";
        return result;
  end function custom_ip_table;  

  --- Fill custom input_data
  constant IN_DATA : adder_array := custom_ip_table;
  -- Save frame number 
  signal ip_frame : integer := 0;
  
  begin
    dut: risc_v_core_simple
        port map(
            clock => clock,
            reset => reset,
            adder_1 => adder_1,
            adder_2 => adder_2,
            output_adder => output_adder
        );
    
  -----------------------------------------------------------------------
  -- Generate clock
  -----------------------------------------------------------------------
    generate_clock : process
    begin
        clock <= '0';
        wait for clock_period/2;
        clock <= '1';
        wait for clock_period/2;
    end process;
  
  -----------------------------------------------------------------------
  -- Generate data slave channel inputs
  -----------------------------------------------------------------------

  simulation : process
    procedure drive_sample ( data       : adder_inputs ) is
    begin
        adder_1 <= data.adder_1;
        adder_2 <= data.adder_2;
    end procedure drive_sample;
    
    procedure drive_ip ( data       : adder_array ) is
        variable samples : integer;
        variable index   : integer;


    begin
    samples := data'length;
    index  := 0;
    while index < data'length loop
        drive_sample(data(index));
        ip_frame <= index;
        
        report "Entity: data_1=" & "0x"& to_hstring(data(index).adder_1);
        report "Entity: data_2=" & "0x"& to_hstring(data(index).adder_2);
        index := index + 1;

        wait for TIME_DELAY;
    end loop;

    end procedure drive_ip;

    begin 
        wait for TIME_DELAY;
        reset <= '1';
        wait for TIME_DELAY;
        reset <= '0';
        drive_ip(IN_DATA);
        wait for TIME_DELAY;
        report "Not a real failure. Simulation finished successfully. Test completed successfully" severity failure;
        wait ;
  end process;

end architecture;