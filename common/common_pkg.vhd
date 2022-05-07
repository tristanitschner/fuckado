library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use ieee.math_real.all;

package common is
  type sched_scheme_t is (round_robin, lowest_index_first);

  function clog2(x : natural) return natural;
  function reverse(x : std_logic_vector) return std_logic_vector;
  function to_onehot(x : std_logic_vector) return std_logic_vector;
  function from_onehot(x : std_logic_vector) return std_logic_vector;
  function onehot(x : std_logic_vector) return boolean;

end package;

package body common is
  function clog2(x : natural) return natural is
  begin
    return integer(ceil(log2(real(x))));
  end function;

  function reverse(x : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(x'reverse_range);
  begin
    for i in x'range loop
      result(i) := x(i);
    end loop;
    return result;
  end function;

  function onehot(x : std_logic_vector) return boolean is
    variable count : integer := 0;
  begin
    for i in x'range loop
      if x(i) = '1' then
        count := count + 1;
      end if;
    end loop;
    return (count = 1);
  end function;

  function to_onehot(x : std_logic_vector) return std_logic_vector is
    variable result : x'subtype ((2**x'length)-1 downto 0) := (others => '0');
  begin
    result(to_integer(unsigned(x))) := '1';
    if x'ascending then
      return reverse(result);
    else
      return result;
    end if;
  end function;

  function from_onehot(x : std_logic_vector) return std_logic_vector is
    variable result : x'subtype (clog2(x'length)-1 downto 0);
  begin
    assert onehot(x);
    for i in x'range loop
      if x(i) = '1' then
        result := std_logic_vector(to_unsigned(i-x'low, result'length));
        exit;
      end if;
    end loop;
    if x'ascending then
      return reverse(result);
    else
      return result;
    end if;
  end function;

end package body;
