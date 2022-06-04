library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use ieee.math_real.all;

entity lookup_table is 
  generic (
            input_width  : natural := 48;
            output_width : natural := 8
          );
  port (
         clk   : in  std_logic;
         phase : in  std_logic_vector(input_width - 1 downto 0);
         sig_o : out std_logic_vector(output_width - 1 downto 0)
       );
end;

architecture a_lookup_table of lookup_table is 
  type rom is array (integer range <>) of signed(output_width - 1 downto 0);

  impure function fillrom return rom is 
    variable t : rom(2**input_width - 1 downto 0);
  begin
    for i in t'range loop
      --t(i) := to_unsigned(natural((((real(max_phase)/2.0) - 1.0))*sin(MATH_2_PI*real(i)/real(max_phase)) 
      --+ (real(max_phase)/2.0 - 1.0)),t(i)'length);
      t(i) := to_signed(integer((((real(2**output_width)/2.0) - 1.0))*sin(MATH_PI*real(i)/real(2*2**output_width))), t(i)'length);
    end loop;
    return t;
  end function;

  constant table : rom(2**input_width - 1 downto 0) := fillrom;
  attribute ram_style : string;
  attribute ram_style of table : constant is "block";
begin

  sig_o <= std_logic_vector(table(to_integer(unsigned(phase)))) when rising_edge(clk);

end;
