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

entity fifo2 is 
  generic (
            addr_w : integer := 4;
            data_w : integer := 8
          );
  port (
         rdata  : out std_logic_vector(data_w - 1 downto 0);
         rempty : out std_logic;
         wfull  : out std_logic;
         wdata  : in  std_logic_vector(data_w - 1 downto 0);
         winc   : in  std_logic;
         wclk   : in  std_logic;
         wrst_n : in  std_logic;
         rinc   : in  std_logic;
         rclk   : in  std_logic;
         rrst_n : in  std_logic
       );
end;

architecture a_fifo2 of fifo2 is 
  signal wptr,rptr,waddr,raddr : std_logic_vector(addr_w - 1 downto 0);
  signal aempty_n,afull_n : std_logic;
begin
  async_cmp_inst : entity work.async_cmp
  generic map (
                addr_w => addr_w
              )
  port map(
            aempty_n => aempty_n,
            afull_n  => afull_n,
            wptr     => wptr,
            rptr     => rptr,
            wrst_n   => wrst_n
          );
  fifomem_inst : entity work.fifomem
  generic map (
                data_w => data_w,
                addr_w => addr_w
              )
  port map(
            rdata  => rdata,
            wdata  => wdata,
            waddr  => wptr,
            raddr  => rptr,
            wclken => winc,
            wclk   => wclk
          );
  rptr_empty_inst : entity work.rptr_empty
  generic map (
                addr_w => addr_w
              )
  port map (
             rempty   => rempty,
             rptr     => rptr,
             aempty_n => aempty_n,
             rinc     => rinc,
             rclk     => rclk,
             rrst_n   => rrst_n
           );
  wptr_full_inst : entity work.wptr_full
  generic map (
                addr_w => addr_w
              )
  port map (
             wfull   => wfull,
             wptr    => wptr,
             afull_n => afull_n,
             winc    => winc,
             wclk    => wclk,
             wrst_n  => wrst_n
           );
end;
