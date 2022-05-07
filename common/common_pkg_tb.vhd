library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use std.env.all;

use work.common.all;

entity common_tb is 
end;

architecture a_common_tb of common_tb is 
begin

  process is
    variable result : std_logic_vector(1 downto 0);
  begin
    -- test the clog2 function:
    assert(2 = clog2(4));
    assert(3 = clog2(8)) report "clog2(8) = " & integer'image(clog2(8));
    assert(4 = clog2(16)) report "clog2(16) = " & integer'image(clog2(16));
    assert(5 = clog2(32)) report "clog2(32) = " & integer'image(clog2(32));
    assert(5 = clog2(31)) report "clog2(31) = " & integer'image(clog2(32));

    -- test the reverse function:
    assert("0001" = reverse("1000"));

    -- test the onehot function:
    -- (note that, by default, vectors are 'big-endian'
    result := from_onehot("0010");
    assert("0010" = reverse(to_onehot(2x"1"))) report "to_onehot(x 1 ) " & to_hstring(reverse(to_onehot(x"1")));
    assert(from_onehot("0010") = 2x"1") report "from_onehot(0010) = " & to_hstring(from_onehot("10")) & " len: " & integer'image(result'length);

    -- test the onehot function
    assert(onehot("0010") = true);
    assert(onehot("1010") = false);
    assert(onehot("0000") = false);
    std.env.finish;
  end process;

end;
