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

entity mc51_to_axi_bridge is 
  generic (
    bus_w : natural := 32;
    id_w : natural := 4
          );
  port (
         m_axi_clk : in std_logic;
         m_axi_resetn : in std_logic;

         -- axi master interface
         m_axi_awaddr  : out std_logic_vector(31 downto 0);
         m_axi_awprot  : out std_logic_vector(2 downto 0);
         m_axi_awvalid : out std_logic := '0';
         m_axi_awready : in  std_logic := '0';

         m_axi_wdata   : out std_logic_vector(bus_w - 1 downto 0);
         m_axi_wstrb   : out std_logic_vector((bus_w/8) - 1 downto 0);
         m_axi_wvalid  : out std_logic := '0';
         m_axi_wready  : in  std_logic := '0';

         m_axi_bresp   : in  std_logic_vector(1 downto 0);
         m_axi_bvalid  : in  std_logic := '0';
         m_axi_bready  : out std_logic := '0';

         m_axi_araddr  : out std_logic_vector(31 downto 0);
         m_axi_arprot  : out std_logic_vector(2 downto 0);
         m_axi_arvalid : out std_logic := '0';
         m_axi_arready : in  std_logic := '0';

         m_axi_rdata   : in  std_logic_vector(bus_w - 1 downto 0);
         m_axi_rresp   : in  std_logic_vector(1 downto 0);
         m_axi_rvalid  : in  std_logic := '0';
         m_axi_rready  : out std_logic := '0';

          -- extended axi master signals
         m_axi_arid    : out std_logic_vector ( id_w - 1 downto 0 );
         m_axi_arlen   : out std_logic_vector ( 7 downto 0 );
         m_axi_arsize  : out std_logic_vector ( 2 downto 0 );
         m_axi_arburst : out std_logic_vector ( 1 downto 0 );
         m_axi_arlock  : out std_logic;
         m_axi_arcache : out std_logic_vector ( 3 downto 0 );
         m_axi_rid     : in  std_logic_vector ( id_w - 1 downto 0 );
         m_axi_rlast   : in  std_logic;

         m_axi_awid    : out std_logic_vector ( id_w - 1 downto 0 );
         m_axi_awlen   : out std_logic_vector ( 7 downto 0 );
         m_axi_awsize  : out std_logic_vector ( 2 downto 0 );
         m_axi_awburst : out std_logic_vector ( 1 downto 0 );
         m_axi_awlock  : out std_logic;
         m_axi_wlast   : out std_logic;
         m_axi_awcache : out std_logic_vector ( 3 downto 0 );

         -- mc51 interface
         s_mb_addr   : in  std_logic_vector(3 downto 0);
         s_mb_wrdata : in  std_logic_vector(7 downto 0);
         s_mb_rddata : out std_logic_vector(7 downto 0);
         s_mb_we     : in  std_logic;
         cs     : in  std_logic
       );
end;
architecture a_mc51_to_axi_bridge of mc51_to_axi_bridge is 
  -- signal / variable / component declarations
  function clog2(x : positive) return positive is
  begin
    return positive(ceil(log2(real(x))));
  end function;
  function to_std_logic_vector(x : positive; len : positive) return std_logic_vector is
  begin
    return std_logic_vector(to_unsigned(x, len));
  end function;
  function index(x : std_logic_vector) return integer is
  begin
    return to_integer(unsigned(x));
  end function;
  constant BURST_INC : std_logic_vector := "01";

  type reg_t is array (16 downto 0) of std_logic_vector(7 downto 0);
  signal registers : reg_t;

  signal start_write : std_logic;
  signal start_read : std_logic;
  signal done : std_logic;

  signal addr : std_logic_vector(31 downto 0);
  signal wdata : std_logic_vector(31 downto 0);

  type state_t is (idle, write, read);
  signal state : state_t := idle;
  
begin
  assert (bus_w mod 8 = 0) report "bus width must be a multiple of 8." severity failure;

  -- assign these
  start_write <= registers(0)(0);
  start_read <= registers(1)(0);
  done <= registers(3)(0);

  addr <=
  registers(7) & 
  registers(6) & 
  registers(5) & 
  registers(4);  

  wdata <=
  registers(15) & 
  registers(14) & 
  registers(13) & 
  registers(12);

  -- unused signals
  m_axi_arid    <= (others => '0');
  m_axi_awid    <= (others => '0');
  m_axi_awprot  <= "000";
  m_axi_arprot  <= "000";
  
  m_axi_arlock  <= '0';
  m_axi_awlock  <= '0';

  m_axi_awsize  <= to_std_logic_vector(clog2(bus_w), m_axi_awsize'length);
  m_axi_arsize  <= to_std_logic_vector(clog2(bus_w), m_axi_arsize'length);

  m_axi_arcache <= "1111";
  m_axi_awcache <= "1111";
  
  m_axi_awburst <= burst_inc;
  m_axi_arburst <= burst_inc;

  m_axi_bready <= '1';

  m_axi_wdata <= wdata;
  m_axi_awaddr <= addr;
  m_axi_araddr <= addr;

  m_axi_arlen <= x"00";
  m_axi_awlen <= x"00";

  m_axi_wlast <= '1';

  m_axi_wstrb <= x"f";

  -- logic for the handshake signals / main state machine
  process (all)
  begin
    if rising_edge(m_axi_clk) then
      if not m_axi_resetn then
        registers <= (others => (others => '0'));
        m_axi_arvalid <= '0';
        m_axi_rready  <= '0';
        m_axi_awvalid <= '0';
        m_axi_wvalid  <= '0';
      else
        case state is
          when idle =>
            if cs and s_mb_we then
              registers(index(s_mb_addr)) <= s_mb_wrdata;
            end if;
            if start_read then
              state <= read;
              m_axi_arvalid <= '1';
              m_axi_rready <= '1';
            elsif start_write then
              state <= write;
              m_axi_awvalid <= '1';
              m_axi_wvalid <= '1';
            end if;
          when read =>
            if m_axi_arready then 
              m_axi_arvalid <= '0';
            end if;
            if m_axi_rvalid then 
              registers(11) <= m_axi_rdata(31 downto 24);
              registers(10) <= m_axi_rdata(23 downto 16);
              registers(9)  <= m_axi_rdata(15 downto 8);
              registers(8)  <= m_axi_rdata(7  downto 0);
              m_axi_rready <= '0';
              state <= idle;
              registers(1)(0) <= '0';
            end if;
          when write =>
              if m_axi_awready then 
                m_axi_awvalid <= '0';
              end if;
              if m_axi_wready then 
                m_axi_wvalid <= '1';
                state <= idle;
              registers(0)(0) <= '0';
            end if;
          when others => 
            report "unreachable" severity failure;
        end case;
      end if;
    end if;
  end process;

  s_mb_rddata <= registers(index(s_mb_addr)) when cs else (others => '0');
end;
