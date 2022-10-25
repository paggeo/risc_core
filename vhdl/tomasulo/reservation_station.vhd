library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.numeric_std.all;

library work;
use work.common.all;

entity reservation_station is 
generic ( 
  width : integer := 3
);
port(
  clock       : in std_logic;
  valid_in    : in std_logic;
  op_in       : in opcode_vector;
  funct3_in   : in funct3_vector;
  funct7_in   : in funct7_vector;
  rs1_s         : in std_logic_vector(XLEN-1 downto 0);  
  rs2_s         : in std_logic_vector(XLEN-1 downto 0);  

  rs1_q         : in std_logic_vector(XLEN-1 downto 0);  
  rs2_q         : in std_logic_vector(XLEN-1 downto 0);  
  rs1_v         : in std_logic;
  rs2_v         : in std_logic;
 
  -- Common Data Bus
  cdb_data_out    : in std_logic_vector(XLEN-1 downto 0);
  cdb_source_out  : in std_logic_vector(XLEN-1 downto 0);
  cdb_valid_out   : in std_logic;

  rd1         : out std_logic_vector(XLEN-1 downto 0);  
  rd2         : out std_logic_vector(XLEN-1 downto 0);  
  op_out      : out opcode_vector;
  funct3_out  : out funct3_vector;
  funct7_out  : out funct7_vector;
  valid_out   : out std_logic
  -- Here we need to say where we are in the register result status
);

end entity;

architecture rtl of reservation_station is 

type valid_operant is record 
  so : std_logic_vector(XLEN-1 downto 0);
  v  : std_logic;
end record;

type reservation_station_type is record 
  busy   : std_logic;
  op     : opcode_vector;
  funct3 : funct3_vector;
  funct7 : funct7_vector;
  sj     : valid_operant;
  sk     : valid_operant;
  qj     : std_logic_vector(XLEN-1 downto 0);
  qk     : std_logic_vector(XLEN-1 downto 0);
end record;

constant vo_zero : valid_operant := (so => (others=>'0'),v =>'0');
constant rsa_zero : reservation_station_type :=
(busy   => '0',
op     => (others=>'0'),
funct3 => (others=>'0'),
funct7 => (others=>'0'),
sj     => vo_zero,
sk     => vo_zero,
qj     => (others=>'0'),
qk     => (others=>'0'));

constant rsa_one : reservation_station_type :=
(busy   => '1',
op     => (others=>'0'),
funct3 => (others=>'0'),
funct7 => (others=>'0'),
sj     => vo_zero,
sk     => vo_zero,
qj     => (others=>'0'),
qk     => (others=>'0'));

type reservation_station_array is array(natural range <>) of reservation_station_type;
signal rsa_t : reservation_station_array(1 to width+1) := (others=>rsa_zero);
--signal rsa_t : reservation_station_array(1 to width+1) := (rsa_one,rsa_one,rsa_zero,rsa_zero);

--TODO: In the end we would need a fifo. But this is a problem in sequential logic

signal zeros : std_logic_vector(XLEN-1 downto 0):= (others=>'0');

begin 

main : process(clock)
begin 
  -- Store
  if rising_edge(clock) then 
    if valid_in = '1' then 
      L1 : for i in 0 to width loop
        if rsa_t(i+1).busy = '0' then 
          rsa_t(i+1).busy <= '1';
          rsa_t(i+1).op <= op_in;
          rsa_t(i+1).funct3 <= funct3_in; 
          rsa_t(i+1).funct7 <= funct7_in;
          rsa_t(i+1).sj.so <= rs1_s;

          rsa_t(i+1).sj.v <= rs1_v;
          rsa_t(i+1).sk.so <= rs2_s; 
          rsa_t(i+1).sk.v <= rs2_v;
   
          rsa_t(i+1).qj <= rs1_q;
          rsa_t(i+1).qk <= rs2_q;
          exit L1; -- This would fill up the reservation station from the top 
       end if;
     end loop L1; 
    end if;
    -- Output
    L2 : for i in 0 to width loop
    -- Maybe we can add a signal from alu to check if it is free - Sequetial logic again
      if rsa_t(i+1).sj.v = '1' and rsa_t(i+1).sk.v = '1' and rsa_t(i+1).qj = zeros and rsa_t(i+1).qk = zeros and rsa_t(i+1).busy = '1' then 
        rd1         <= rsa_t(i+1).sj.so;
        rd2         <= rsa_t(i+1).sk.so;
        op_out      <= rsa_t(i+1).op;
        funct3_out  <= rsa_t(i+1).funct3;
        funct7_out  <= rsa_t(i+1).funct7;
        valid_out   <= '1';
        rsa_t(i+1).busy <= '0';
        exit L2; -- This ensures we would only would have one output, the first one from the top
      else 
        rd1         <= (others=>'0');
        rd2         <= (others=>'0');
        op_out      <= (others=>'0');
        funct3_out  <= (others=>'0');
        funct7_out  <= (others=>'0');
        valid_out   <= '0';
      end if;
    end loop L2;
    
    -- Update
    if cdb_valid_out = '1' then  
      L3 : for i in 0 to width loop -- Here we want to inform every reservation station - No exit
        if rsa_t(i+1).qj = cdb_source_out and rsa_t(i+1).busy = '1' then 
          rsa_t(i+1).sj.so <= cdb_data_out;
          rsa_t(i+1).sj.v <= '1';
          rsa_t(i+1).qj <= (others=>'0'); 
        end if; 
        if rsa_t(i+1).qk = cdb_source_out and rsa_t(i+1).busy = '1' then 
          rsa_t(i+1).sk.so <= cdb_data_out;
          rsa_t(i+1).sk.v <= '1';
          rsa_t(i+1).qk <= (others=>'0'); 
        end if; 
      end loop;
    end if;
  end if;
end process;
-- Stupid language can't understand multiple driven, all in one process
--  main : process(valid_in,op_in,funct3_in,funct7_in,rs1_s,rs1_v,rs2_s,rs2_v,rs1_q,rs2_q)
-- begin 
--   if valid_in = '1' then 
--     L1 : for i in 0 to width loop
--       if rsa_t(i+1).busy = '0' then 
--         rsa_t(i+1).busy <= '1';
--         rsa_t(i+1).op <= op_in;
--         rsa_t(i+1).funct3 <= funct3_in; 
--         rsa_t(i+1).funct7 <= funct7_in;
--         rsa_t(i+1).sj.so <= rs1_s;
--         rsa_t(i+1).sj.v <= rs1_v;
--         rsa_t(i+1).sk.so <= rs2_s; 
--         rsa_t(i+1).sk.v <= rs2_v;
--  
--         rsa_t(i+1).qj <= rs1_q;
--         rsa_t(i+1).qk <= rs2_q;
--         exit L1; -- This would fill up the reservation station from the top 
--      end if;
--   end loop L1;
--end if;
-- end process;

-- reservation_station_output : process(rsa_t)
-- begin 
--  L2 : for i in 0 to width loop
--     -- Maybe we can add a signal from alu to check if it is free - Sequetial logic again
--   if rsa_t(i+1).sj.v = '1' and rsa_t(i+1).sk.v = '1' and rsa_t(i+1).qj = zeros and rsa_t(i+1).qk = zeros and rsa_t(i+1).busy = '1' then 
--       rd1         <= rsa_t(i+1).sj.so;
--       rd2         <= rsa_t(i+1).sk.so;
--       op_out      <= rsa_t(i+1).op;
--       funct3_out  <= rsa_t(i+1).funct3;
--       funct7_out  <= rsa_t(i+1).funct7;
--       valid_out   <= '1';
--       rsa_t(i+1).busy <= '0';
--       exit L2; -- This ensures we would only would have one output, the first one from the top
--     end if;
--   end loop L2;
-- end process;

-- update : process (cdb_data_out,cdb_source_out,cdb_valid_out)
-- begin 
--  if cdb_valid_out = '1' then  
--    L3 : for i in 0 to width loop -- Here we want to inform every reservation station - No exit
--       if rsa_t(i+1).qj = cdb_source_out and rsa_t(i+1).busy = '1' then 
--        rsa_t(i+1).sj.so <= cdb_data_out;
--       rsa_t(i+1).sj.v <= '1';
--      rsa_t(i+1).qj <= zeros; 
--   end if; 
--  if rsa_t(i+1).qk = cdb_source_out and rsa_t(i+1).busy = '1' then 
--   rsa_t(i+1).sk.so <= cdb_data_out;
--  rsa_t(i+1).sk.v <= '1';
-- rsa_t(i+1).qk <= zeros; 
--         end if; 
--     end loop;
--   end if;
-- end process;

end architecture;