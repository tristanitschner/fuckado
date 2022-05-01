-- This shall implement the logic necessary to hold exactly one packet (or frag-
-- ment). The idea is that two of these are compined in a pingpong buffer 
-- fashion. When one complete packet is inside a holder, metadata maybe extracted
-- in a manner, that uses only a small amount of logic. This metadata, which may
-- be mac / id address of an ethernet packet, can then be used for routing 
-- purposes. Also the length of the packet is determined and can be appended
-- to the start of the packet by the overlaying entity. Of course a stream
-- arbiter is necessary.
library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

package stream_pkg is
  subtype stream_t is std_logic_vector(31 downto 0); -- adjust your payload type here, this is for _one_ beat
  type stream_array_t is array (integer range <>) of stream_t;
end package;

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use work.stream_pkg.all;

entity packet_holder is 
  generic (
            max_packet_length : integer := 256 -- comply with axi full
          );
  port (
         clk : in std_logic;
         rst : in std_logic;

         i_stream : in  stream_t;
         i_ready  : out std_logic;
         i_valid  : in  std_logic;
         i_last   : in  std_logic;

         o_stream : out stream_t;
         o_ready  : in  std_logic;
         o_valid  : out std_logic;
         o_last   : out std_logic;

         -- metadata, add your own here:
         -- example for destination address in case of an ethernet frame (without preamble)
         destination_addr : out std_logic_vector(6*8 - 1 downto 0);
         packetlength : out std_logic_vector(stream_t'range)
       );
end;
architecture a_packet_holder of packet_holder is 
  signal storage : stream_array_t(max_packet_length - 1 downto 0);
  type state_t is (empty, filling, filled, clearing);
  signal state : state_t;
  signal fillcount : integer range 0 to max_packet_length - 1;
  signal i_hs, o_hs : boolean;
  signal len : unsigned(stream_t'range);
begin
  handshakes: block is
  begin
    i_hs <= i_ready = '1' and i_valid = '1';
    o_hs <= o_ready = '1' and o_valid = '1';
  end block;

  fillcount_p: process (all) is 
  begin
    if rising_edge(clk) then
      if i_hs and o_hs then
        null;
      elsif i_hs then 
        fillcount <= fillcount + 1;
      elsif o_hs then
        fillcount <= fillcount - 1;
      end if;
    end if;
    if rst then
      fillcount <= 0;
    end if;
  end process;

  write: process (all) is
  begin
    if rising_edge(clk) then
      if i_hs then
        storage(fillcount) <= i_stream;
      end if;
    end if;
  end process;

  -- read logic
  o_stream <= storage(fillcount);

  main: process (all) is
  begin
    if rising_edge(clk) then
      len <= to_unsigned(0, len'length); -- todo: remove for low logic
      -- example for destination address in case of an ethernet frame (without preamble)
      destination_addr <= (others => '0');
      case state is
        when empty =>
          if i_hs then
            state <= filling;
          end if;
        when filling =>
          if i_hs and i_last = '1' then
            state <= filled;
          end if;
        when filled =>
          if o_hs then
            state <= clearing;
            packetlength <= std_logic_vector(to_unsigned(fillcount + 1, len'length));
            -- example for destination address in case of an ethernet frame (without preamble)
            destination_addr <= storage(0) & storage(1)(15 downto 0);
          end if;
        when clearing =>
          if o_hs and o_last = '1' then
            state <= empty;
          end if;
        when others =>
          assert true report "unreachable" severity failure;
      end case;
      if rst then
        state <= empty;
      end if;
    end if;
  end process;

  i_ready <= '1' when state = empty or state = filling else '0';
  o_valid <= '1' when state = filled or state = clearing else '0';
  o_last <= '1' when state = clearing and fillcount = 0 else '0';

end;
