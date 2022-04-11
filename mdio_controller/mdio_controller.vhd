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
use ieee.math_real.all;

entity mdio_controller is 
  generic (
            clock_frequency : integer := 100000; -- kHz
            invert_reset    : boolean := false
          );
  port (
         i_clk : in std_logic;
         i_rst : in std_logic;
         -- slave
         read     : in  std_logic;
         write    : in  std_logic;
         data_i   : in  std_logic_vector(15 downto 0);
         data_o   : out std_logic_vector(15 downto 0);
         phy_addr : in  std_logic_vector(4  downto 0);
         reg_addr : in  std_logic_vector(4  downto 0);

         -- master
         mdc    : out std_logic;
         mdio_i : in  std_logic;
         mdio_o : out std_logic;
         mdio_t : out std_logic
       );
end;

architecture a_mdio_controller of mdio_controller is 
  constant counter_ceiling : integer := integer(floor(real(clock_frequency)/real(2*2500)));
  signal rst :        std_logic;
  signal phy_addr_r : std_logic_vector(4 downto 0);
  signal reg_addr_r : std_logic_vector(4 downto 0);
  signal w_data :     std_logic_vector(15 downto 0);
begin
  rst_gen: if invert_reset generate
    rst <= not i_rst;
  else generate
    rst <= i_rst;
  end generate;

  mdc_proc : process(all)
    variable counter : integer := 0;
  begin
    if rst then
      counter := 0;
    elsif rising_edge(i_clk) then
      if counter = 0 then
        counter := counter_ceiling;
        mdc <= not mdc;
      else 
        counter := counter - 1;
      end if;
    end if;
  end process;

  main : block
    type state_t is (idle, preamble, start_of_frame, op_code, phy_address, register_address, turn_around, data);
    signal state : state_t := idle;
    signal cnt : integer := 0;
    signal read_flag : boolean;
  begin
    process(all)
    begin
      if rst then
        state <= idle;
        mdio_o <= '0';
        mdio_t <= '1';
      elsif rising_edge(mdc) or falling_edge(mdc) then
        case state is 
          when idle => 
            if read then
              cnt <= 0;
              state <= preamble;
              read_flag <= true;
              phy_addr_r <= phy_addr;
              reg_addr_r <= reg_addr;
            elsif write then
              cnt <= 0;
              state <= preamble;
              read_flag <= false;
              phy_addr_r <= phy_addr;
              reg_addr_r <= reg_addr;
              w_data <= data_i;
            else
              cnt <= 0;
            end if;
          when preamble => 
            if not mdc then
              if cnt < 31 then
                cnt <= cnt + 1;
              else
                cnt <= 0;
                state <= start_of_frame;
              end if;
            end if;
          when start_of_frame => 
            if not mdc then
              if cnt = 0 then
                mdio_o <= '0';
                cnt <= cnt + 1;
              else
                mdio_o <= '1';
                cnt <= 0;
                state <= op_code;
              end if;
            end if;
          when op_code => 
            if not mdc then
              if cnt = 0 then
                mdio_o <= '1' when read_flag else '0';
                cnt <= cnt + 1;
              else
                mdio_o <= '0' when read_flag else '1';
                cnt <= 0;
                state <= phy_address;
              end if;
            end if;
          when phy_address => 
            if not mdc then
              if cnt < 4 then
                mdio_o <= phy_addr(4 - cnt);
                cnt <= cnt + 1;
              else
                mdio_o <= phy_addr(4 - cnt);
                cnt <= 0;
                state <= register_address;
              end if;
            end if;
          when register_address => 
            if not mdc then
              if cnt < 4 then
                mdio_o <= phy_addr(4 - cnt);
                cnt <= cnt + 1;
              else
                mdio_o <= phy_addr(4 - cnt);
                cnt <= 0;
                state <= turn_around;
              end if;
            end if;
          when turn_around => 
            if not mdc then
              if cnt = 0 then
                cnt <= cnt + 1;
                mdio_t <= '0' when read_flag else '1';
              else
                cnt <= 0;
                state <= data;
              end if;
            end if;
          when data => 
            if read_flag then
              if mdc then -- rising edge
                if cnt < 15 then
                  data_o(15 - cnt) <= mdio_i;
                else
                  data_o(15 - cnt) <= mdio_i;
                  state <= idle;
                end if;
              end if;
            else -- writing
              if not mdc then -- falling edge
                if cnt < 15 then
                  mdio_o <= w_data(15 - cnt);
                else
                  mdio_o <= w_data(15 - cnt);
                  state <= idle;
                end if;
              end if;
            end if;
          when others => 
            report "unreachable" severity failure;
        end case;
      end if;
    end process;
  end block;

end;
