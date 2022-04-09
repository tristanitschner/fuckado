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
         clk : in std_logic;
         rstn : in std_logic;

         -- axi master interface
         M_AXI_AWADDR  : out std_logic_vector(31 downto 0);
         M_AXI_AWPROT  : out std_logic_vector(2 downto 0);
         M_AXI_AWVALID : out std_logic := '0';
         M_AXI_AWREADY : in  std_logic := '0';

         M_AXI_WDATA   : out std_logic_vector(bus_w - 1 downto 0);
         M_AXI_WSTRB   : out std_logic_vector((bus_w/8) - 1 downto 0);
         M_AXI_WVALID  : out std_logic := '0';
         M_AXI_WREADY  : in  std_logic := '0';

         M_AXI_BRESP   : in  std_logic_vector(1 downto 0);
         M_AXI_BVALID  : in  std_logic := '0';
         M_AXI_BREADY  : out std_logic := '0';

         M_AXI_ARADDR  : out std_logic_vector(31 downto 0);
         M_AXI_ARPROT  : out std_logic_vector(2 downto 0);
         M_AXI_ARVALID : out std_logic := '0';
         M_AXI_ARREADY : in  std_logic := '0';

         M_AXI_RDATA   : in  std_logic_vector(bus_w - 1 downto 0);
         M_AXI_RRESP   : in  std_logic_vector(1 downto 0);
         M_AXI_RVALID  : in  std_logic := '0';
         M_AXI_RREADY  : out std_logic := '0';

          -- extended axi master signals
         M_AXI_ARID    : out std_logic_vector ( id_w - 1 downto 0 );
         M_AXI_ARLEN   : out std_logic_vector ( 7 downto 0 );
         M_AXI_ARSIZE  : out std_logic_vector ( 2 downto 0 );
         M_AXI_ARBURST : out std_logic_vector ( 1 downto 0 );
         M_AXI_ARLOCK  : out std_logic;
         M_AXI_ARCACHE : out std_logic_vector ( 3 downto 0 );
         M_AXI_RID     : in  std_logic_vector ( id_w - 1 downto 0 );
         M_AXI_RLAST   : in  std_logic;

         M_AXI_AWID    : out std_logic_vector ( id_w - 1 downto 0 );
         M_AXI_AWLEN   : out std_logic_vector ( 7 downto 0 );
         M_AXI_AWSIZE  : out std_logic_vector ( 2 downto 0 );
         M_AXI_AWBURST : out std_logic_vector ( 1 downto 0 );
         M_AXI_AWLOCK  : out std_logic;
         M_AXI_WLAST   : out std_logic;
         M_AXI_AWCACHE : out std_logic_vector ( 3 downto 0 );

         -- mc51 interface
         i_addr   : in  std_logic_vector(3 downto 0);
         i_data : in  std_logic_vector(7 downto 0);
         o_data : out std_logic_vector(7 downto 0);
         we     : in  std_logic;
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

  -- define the handshakes
  signal aw_hs : std_logic; 
  signal w_hs  : std_logic; 
  signal b_hs  : std_logic; 
  signal ar_hs : std_logic; 
  signal r_hs  : std_logic; 

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

  aw_hs <= M_AXI_AWREADY and M_AXI_AWVALID;
  w_hs  <= M_AXI_WREADY  and M_AXI_WVALID;
  b_hs  <= M_AXI_BREADY  and M_AXI_BVALID;
  ar_hs <= M_AXI_ARREADY and M_AXI_ARVALID;
  r_hs  <= M_AXI_RREADY  and M_AXI_RVALID;

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
  M_AXI_ARID    <= (others => '0');
  M_AXI_AWID    <= (others => '0');
  M_AXI_AWPROT  <= "000";
  M_AXI_ARPROT  <= "000";
  
  M_AXI_ARLOCK  <= '0';
  M_AXI_AWLOCK  <= '0';

  M_AXI_AWSIZE  <= to_std_logic_vector(clog2(bus_w), m_axi_awsize'length);
  M_AXI_ARSIZE  <= to_std_logic_vector(clog2(bus_w), m_axi_arsize'length);

  M_AXI_ARCACHE <= "1111";
  M_AXI_AWCACHE <= "1111";
  
  M_AXI_AWBURST <= BURST_INC;
  M_AXI_ARBURST <= BURST_INC;

  M_AXI_BREADY <= '1';

  M_AXI_WDATA <= wdata;
  M_AXI_AWADDR <= addr;
  M_AXI_ARADDR <= addr;

  M_AXI_ARLEN <= x"00";
  M_AXI_AWLEN <= x"00";

  M_AXI_WLAST <= '1';

  M_AXI_WSTRB <= x"f";

  -- logic for the handshake signals / main state machine
  process (all)
  begin
    if rising_edge(clk) then
      if not rstn then
        registers <= (others => (others => '0'));
      else
        case state is
          when idle =>
            if cs and we then
              registers(index(i_addr)) <= i_data;
            end if;
            if start_read then
              state <= read;
              M_AXI_ARVALID <= '1';
              M_AXI_RREADY <= '1';
            elsif start_write then
              state <= write;
              M_AXI_AWVALID <= '1';
              M_AXI_WVALID <= '1';
            end if;

          when read =>
            if ar_hs then 
              M_AXI_ARVALID <= '0';
            end if;
            if r_hs then 
              registers(11) <= M_AXI_RDATA(31 downto 24);
              registers(10) <= M_AXI_RDATA(23 downto 16);
              registers(9)  <= M_AXI_RDATA(15 downto 8);
              registers(8)  <= M_AXI_RDATA(7  downto 0);
              M_AXI_RREADY <= '0';
              state <= idle;
              registers(1)(0) <= '0';
            end if;

          when write =>
              if aw_hs then 
                M_AXI_AWVALID <= '0';
              end if;
              if w_hs then 
                M_AXI_WVALID <= '1';
                state <= idle;
              registers(0)(0) <= '0';
            end if;
          when others => 
            report "unreachable" severity failure;
        end case;
      end if;
    end if;
  end process;

  o_data <= registers(index(i_addr)) when cs else (others => '0');
end;
