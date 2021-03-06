library ieee;
context ieee.ieee_std_context;
use ieee.math_real.all;

library ti;
use ti.common_globals.all;

package common_sim is
  impure function rand return std_logic;
  impure function rand(len : natural) return std_logic_vector;
  impure function rand(max : natural) return natural;

  shared variable globals : globals_t;
end package;

package body common_sim is
  impure function rand return std_logic is
    variable seed1,seed2 : integer;
    variable random      : real;
    variable ret         : std_logic;
  begin
    -- this is some of the most bs code I ever wrote...
    seed1 := globals.seed1_get;
    seed2 := globals.seed2_get;
    uniform(seed1,seed2,random);
    globals.seed1_set(seed1);
    globals.seed2_set(seed2);
    -- report "generated" & real'image(random);
    ret := '1' when random > 0.5 else '0';
    return ret; 
  end function;

  impure function rand(len : natural) return std_logic_vector is
    variable ret : std_logic_vector(len - 1 downto 0);
  begin
    for i in ret'range loop
      ret(i) := rand;
    end loop;
    return ret;
  end function;

  impure function rand(max : natural) return natural is
    variable seed1,seed2 : integer;
    variable random      : real;
    variable ret         : natural;
  begin
    -- this is some of the most bs code I ever wrote...
    seed1 := globals.seed1_get;
    seed2 := globals.seed2_get;
    uniform(seed1,seed2,random);
    globals.seed1_set(seed1);
    globals.seed2_set(seed2);
    -- report "generated" & real'image(random);
    ret := natural(floor(random*(real(max+1))));
    return ret; 
  end function;

end package body;

--------------------------------------------------------------------------------

library ieee;
context ieee.ieee_std_context;
use ieee.math_real.all;

package common is
  type sched_scheme_t is (round_robin, lowest_index_first);

  function zero_vec(len : integer) return std_logic_vector;
  function clog2(x : natural) return natural;
  function reverse(x : std_logic_vector) return std_logic_vector;
  function to_onehot(x : std_logic_vector) return std_logic_vector;
  function from_onehot(x : std_logic_vector) return std_logic_vector;
  function onehot(x : std_logic_vector) return boolean;
  function is_power_of_two(x : natural) return boolean;
--function is_power_of_two(x : integer) return boolean; -- causes an error, if function is declared with natural

  -- this is just here, so I can redefine it, in case I need something different
  subtype long is integer;

end package;

package body common is
  function zero_vec(len : integer) return std_logic_vector is 
    variable ret : std_logic_vector(len - 1 downto 0) := (others => '0');
  begin
    return ret;
  end function;
  -- TODO: rewrite, as cannot be handled by GHDL synthesis
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

  function is_power_of_two(x : natural) return boolean is
    variable i : natural := 0;
    variable ret : boolean := false;
  begin
    assert(x /= 0);
    while true loop
      i := i + 1;
      if 2**i = x then
        ret := true;
      end if;
      if 2**i > x then
        exit;
      end if;
    end loop;
    return ret;
  end function;

  ------------------------------------------------------------------------------

-- Here we provide some functions for the "long" datatype
  function "+" (left: long; right: long) return long is
  begin
    return left + right;
  end function;

end package body;

context should_be_part_of_the_language_itself is
  library ieee;
  context ieee.ieee_std_context;
  library ti;
  use ti.common.all;
end context;

context should_be_part_of_the_language_itself_for_simulation is
  library ieee;
  context ieee.ieee_std_context;
  library ti;
  use ti.common.all;
  use ti.common_sim.all;
end context;
