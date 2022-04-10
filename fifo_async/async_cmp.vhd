--    Copyright (C) 2022	Tristan Itschner
--
--    This program is free software: you can redistribute it and/or modify
--    it under the terms of the GNU General Public License as published by
--    the Free Software Foundation, either version 3 of the License, or
--    (at your option) any later version.
--
--    This program is distributed in the hope that it will be useful,
--    but WITHOUT ANY WARRANTY; without even the implied warranty of
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--    GNU General Public License for more details.
--
--    You should have received a copy of the GNU General Public License
--    along with this program.  If not, see <https://www.gnu.org/licenses/>.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

entity async_cmp is 
  generic (
            addr_w : integer := 4
          );
  port (
         aempty_n : out std_logic;
         afull_n  : out std_logic;
         wptr     : in  std_logic_vector(addr_w - 1 downto 0);
         rptr     : in  std_logic_vector(addr_w - 1 downto 0);
         wrst_n   : in  std_logic
       );
end;

architecture a_async_cmp of async_cmp is 
  signal dirset_n, dirclr_n, direction : std_logic;
  constant N : integer := addr_w - 1;
  function bool_to_std_logic(x : boolean) return std_logic is
    variable retval : std_logic;
  begin
    retval := '1' when x else '0';
    return retval;
  end function;
begin

  dirset_n <= not ((wptr(N) xor rptr(N - 1)) and not (wptr(N - 1) xor rptr(N)));
  dirclr_n <= not (((not wptr(N) xor rptr(N - 1)) and (wptr(N - 1) xor rptr(N))) or not wrst_n);

  aempty_n <= not(bool_to_std_logic(wptr = rptr) and not direction);
  afull_n <= not(bool_to_std_logic(wptr = rptr) and not direction);

  process(all)
  begin
    if rising_edge(dirset_n) or falling_edge(dirset_n) or falling_edge(dirclr_n) then
      direction <= '0' when not dirclr_n else
                   '1'; -- when not dirset_n else
    --'1';
    end if;
  end process;

end;
