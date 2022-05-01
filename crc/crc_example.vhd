-- SPDX-License-Identifier: GPL-3.0-or-later
-- (c) Tristan Itschner 2022

-- This entity is an example of how to speedup CRC calculation in VHDL.
-- Here the crc32 sum is calculated 8 bits each clock. See crc_pkg.vhd for the
-- exact crc32 polynomial used. Data must be byte-aligned.
-- Once the sof (start of frame) signal is raised for one clock, calculation 
-- starts until the eof (end of frame) data is raised. The data during the 
-- assertion of sof / eof is included in the calculation. There is no ready / 
-- valid handshake, hence new data _must_ be provided on each new cycle. The
-- resultant crc sum is provided on the crc output signal until the next eof
-- signal is encountered.

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library ti;
use ti.crc.all;

entity crc_example is 
  port (
         clk  : in  std_logic;
         sof  : in  std_logic;
         eof  : in  std_logic;
         data : in  std_logic_vector(8 - 1 downto 0);
         crc  : out std_logic_vector(32 - 1 downto 0)
       );
end;
architecture a_crc_example of crc_example is 
  signal r : std_logic_vector(32 - 1 downto 0) := (others => '0');

begin

  process(all) is 
  begin
    if rising_edge(clk) then
      if    sof then r <= crc32table8(to_integer(unsigned(not(data))));
      elsif eof then r <= not((r srl 8) xor crc32table8(to_integer(unsigned(crc(8 - 1 downto 0) xor data))));
      else         crc <=     (r srl 8) xor crc32table8(to_integer(unsigned(crc(8 - 1 downto 0) xor data)));
      end if;
    end if;
  end process;

end;
