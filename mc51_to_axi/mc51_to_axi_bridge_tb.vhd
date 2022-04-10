--    Copyright (C) 2022	Tristan Itschner
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
use std.env.all;

entity mc51_to_axi_bridge_tb is 
  end;

architecture a_mc51_to_axi_bridge_tb of mc51_to_axi_bridge_tb is 
  constant bus_w        : integer   := 32;
  constant id_w         : integer   := 4;
  signal   m_axi_clk    : std_logic := '1';
  signal   m_axi_resetn : std_logic;

  -- axi master interface
  signal m_axi_awaddr  : std_logic_vector(31 downto 0);
  signal m_axi_awprot  : std_logic_vector(2 downto 0);
  signal m_axi_awvalid : std_logic := '0';
  signal m_axi_awready : std_logic := '0';

  signal m_axi_wdata   : std_logic_vector(bus_w - 1 downto 0);
  signal m_axi_wstrb   : std_logic_vector((bus_w/8) - 1 downto 0);
  signal m_axi_wvalid  : std_logic := '0';
  signal m_axi_wready  : std_logic := '0';

  signal m_axi_bresp   : std_logic_vector(1 downto 0);
  signal m_axi_bvalid  : std_logic := '0';
  signal m_axi_bready  : std_logic := '0';

  signal m_axi_araddr  : std_logic_vector(31 downto 0);
  signal m_axi_arprot  : std_logic_vector(2 downto 0);
  signal m_axi_arvalid : std_logic := '0';
  signal m_axi_arready : std_logic := '0';

  signal m_axi_rdata   : std_logic_vector(bus_w - 1 downto 0);
  signal m_axi_rresp   : std_logic_vector(1 downto 0);
  signal m_axi_rvalid  : std_logic := '0';
  signal m_axi_rready  : std_logic := '0';

  -- extended axi master signals
  signal m_axi_arid    : std_logic_vector ( id_w - 1 downto 0 );
  signal m_axi_arlen   : std_logic_vector ( 7 downto 0 );
  signal m_axi_arsize  : std_logic_vector ( 2 downto 0 );
  signal m_axi_arburst : std_logic_vector ( 1 downto 0 );
  signal m_axi_arlock  : std_logic;
  signal m_axi_arcache : std_logic_vector ( 3 downto 0 );
  signal m_axi_rid     : std_logic_vector ( id_w - 1 downto 0 );
  signal m_axi_rlast   : std_logic;

  signal m_axi_awid    : std_logic_vector ( id_w - 1 downto 0 );
  signal m_axi_awlen   : std_logic_vector ( 7 downto 0 );
  signal m_axi_awsize  : std_logic_vector ( 2 downto 0 );
  signal m_axi_awburst : std_logic_vector ( 1 downto 0 );
  signal m_axi_awlock  : std_logic;
  signal m_axi_wlast   : std_logic;
  signal m_axi_awcache : std_logic_vector ( 3 downto 0 );

  -- mc51 interface
  signal s_mb_addr   : std_logic_vector(3 downto 0);
  signal s_mb_wrdata : std_logic_vector(7 downto 0);
  signal s_mb_rddata : std_logic_vector(7 downto 0);
  signal s_mb_we     : std_logic;
  signal cs          : std_logic;

begin
  m_axi_clk <= not m_axi_clk after 5 ns;

  process
  begin
    m_axi_resetn <= '0';
    cs <= '1';
    s_mb_we <= '1';
    m_axi_awready <= '0';
    wait until m_axi_clk;
    m_axi_resetn <= '1';
    s_mb_addr <= x"8";
    s_mb_wrdata <= x"01";
    wait until m_axi_clk;
    s_mb_addr <= x"9";
    s_mb_wrdata <= x"02";
    wait until m_axi_clk;
    s_mb_addr <= x"a";
    s_mb_wrdata <= x"03";
    wait until m_axi_clk;
    s_mb_addr <= x"b";
    s_mb_wrdata <= x"04";
    wait until m_axi_clk;
    s_mb_addr <= x"0";
    s_mb_wrdata <= x"01";
    wait until m_axi_clk;
    s_mb_we <= '0';
    m_axi_awready <= '1';
    wait until m_axi_clk;
    wait until m_axi_clk;
    wait until m_axi_clk;
    m_axi_awready <= '1';
    wait until m_axi_clk;
    m_axi_awready <= '0';
    wait until m_axi_clk;
    m_axi_wready <= '1';
    wait until m_axi_clk;
    wait until m_axi_clk;
    wait until m_axi_clk;
    wait until m_axi_clk;
    wait until m_axi_clk;
    wait until m_axi_clk;
    s_mb_we <= '1';
    s_mb_addr <= x"0";
    s_mb_wrdata <= x"01";
    m_axi_awready <= '1';
    m_axi_wready <= '1';
    wait until m_axi_clk;
    s_mb_we <= '0';
    for i in 0 to 10 loop
      wait until m_axi_clk;
    end loop;
    s_mb_we <= '1';
    s_mb_addr <= x"1";
    s_mb_wrdata <= x"01";
    m_axi_arready <= '1';
    m_axi_rvalid <= '1';
    m_axi_rdata <= x"deadbeef";
    wait until m_axi_clk;
    s_mb_addr <= x"8";
    s_mb_we <= '0';
    for i in 0 to 10 loop
      wait until m_axi_clk;
    end loop;

    std.env.finish;
  end process;

  dut : entity work.mc51_to_axi_bridge(a_mc51_to_axi_bridge)
  port map(
            m_axi_clk           => m_axi_clk          ,
            m_axi_resetn          => m_axi_resetn         ,
            m_axi_awaddr  => m_axi_awaddr ,
            m_axi_awprot  => m_axi_awprot ,
            m_axi_awvalid => m_axi_awvalid,
            m_axi_awready => m_axi_awready,
            m_axi_wdata   => m_axi_wdata  ,
            m_axi_wstrb   => m_axi_wstrb  ,
            m_axi_wvalid  => m_axi_wvalid ,
            m_axi_wready  => m_axi_wready ,
            m_axi_bresp   => m_axi_bresp  ,
            m_axi_bvalid  => m_axi_bvalid ,
            m_axi_bready  => m_axi_bready ,
            m_axi_araddr  => m_axi_araddr ,
            m_axi_arprot  => m_axi_arprot ,
            m_axi_arvalid => m_axi_arvalid,
            m_axi_arready => m_axi_arready,
            m_axi_rdata   => m_axi_rdata  ,
            m_axi_rresp   => m_axi_rresp  ,
            m_axi_rvalid  => m_axi_rvalid ,
            m_axi_rready  => m_axi_rready ,
            m_axi_arid    => m_axi_arid   ,
            m_axi_arlen   => m_axi_arlen  ,
            m_axi_arsize  => m_axi_arsize ,
            m_axi_arburst => m_axi_arburst,
            m_axi_arlock  => m_axi_arlock ,
            m_axi_arcache => m_axi_arcache,
            m_axi_rid     => m_axi_rid    ,
            m_axi_rlast   => m_axi_rlast  ,
            m_axi_awid    => m_axi_awid   ,
            m_axi_awlen   => m_axi_awlen  ,
            m_axi_awsize  => m_axi_awsize ,
            m_axi_awburst => m_axi_awburst,
            m_axi_awlock  => m_axi_awlock ,
            m_axi_wlast   => m_axi_wlast  ,
            m_axi_awcache => m_axi_awcache,
            s_mb_addr        => s_mb_addr       ,
            s_mb_wrdata        => s_mb_wrdata       ,
            s_mb_rddata        => s_mb_rddata       ,
            s_mb_we            => s_mb_we           ,
            cs            => cs           
          );

end;
