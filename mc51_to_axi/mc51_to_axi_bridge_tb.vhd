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
  constant bus_w       : integer := 32;
  constant id_w        :  integer := 4;
  signal clk           : std_logic := '1';
  signal rstn          : std_logic;

  -- axi master interface
  signal M_AXI_AWADDR  : std_logic_vector(31 downto 0);
  signal M_AXI_AWPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_AWVALID : std_logic := '0';
  signal M_AXI_AWREADY :  std_logic := '0';

  signal M_AXI_WDATA   : std_logic_vector(bus_w - 1 downto 0);
  signal M_AXI_WSTRB   : std_logic_vector((bus_w/8) - 1 downto 0);
  signal M_AXI_WVALID  : std_logic := '0';
  signal M_AXI_WREADY  :  std_logic := '0';

  signal M_AXI_BRESP   :  std_logic_vector(1 downto 0);
  signal M_AXI_BVALID  :  std_logic := '0';
  signal M_AXI_BREADY  : std_logic := '0';

  signal M_AXI_ARADDR  : std_logic_vector(31 downto 0);
  signal M_AXI_ARPROT  : std_logic_vector(2 downto 0);
  signal M_AXI_ARVALID : std_logic := '0';
  signal M_AXI_ARREADY :  std_logic := '0';

  signal M_AXI_RDATA   :  std_logic_vector(bus_w - 1 downto 0);
  signal M_AXI_RRESP   :  std_logic_vector(1 downto 0);
  signal M_AXI_RVALID  :  std_logic := '0';
  signal M_AXI_RREADY  : std_logic := '0';

  -- extended axi master signals
  signal M_AXI_ARID    : std_logic_vector ( id_w - 1 downto 0 );
  signal M_AXI_ARLEN   : std_logic_vector ( 7 downto 0 );
  signal M_AXI_ARSIZE  : std_logic_vector ( 2 downto 0 );
  signal M_AXI_ARBURST : std_logic_vector ( 1 downto 0 );
  signal M_AXI_ARLOCK  : std_logic;
  signal M_AXI_ARCACHE : std_logic_vector ( 3 downto 0 );
  signal M_AXI_RID     :  std_logic_vector ( id_w - 1 downto 0 );
  signal M_AXI_RLAST   :  std_logic;

  signal M_AXI_AWID    : std_logic_vector ( id_w - 1 downto 0 );
  signal M_AXI_AWLEN   : std_logic_vector ( 7 downto 0 );
  signal M_AXI_AWSIZE  : std_logic_vector ( 2 downto 0 );
  signal M_AXI_AWBURST : std_logic_vector ( 1 downto 0 );
  signal M_AXI_AWLOCK  : std_logic;
  signal M_AXI_WLAST   : std_logic;
  signal M_AXI_AWCACHE : std_logic_vector ( 3 downto 0 );

  -- mc51 interface
  signal i_addr          :  std_logic_vector(3 downto 0);
  signal i_data        :  std_logic_vector(7 downto 0);
  signal o_data        : std_logic_vector(7 downto 0);
  signal we            :  std_logic;
  signal cs            :  std_logic;
  
begin
  clk <= not clk after 5 ns;

  process
  begin
    rstn <= '0';
    cs <= '1';
    we <= '1';
    M_AXI_AWREADY <= '0';
    wait until clk;
    rstn <= '1';
    i_addr <= x"8";
    i_data <= x"01";
    wait until clk;
    i_addr <= x"9";
    i_data <= x"02";
    wait until clk;
    i_addr <= x"a";
    i_data <= x"03";
    wait until clk;
    i_addr <= x"b";
    i_data <= x"04";
    wait until clk;
    i_addr <= x"0";
    i_data <= x"01";
    wait until clk;
    we <= '0';
    M_AXI_AWREADY <= '1';
    wait until clk;
    wait until clk;
    wait until clk;
    M_AXI_AWREADY <= '1';
    wait until clk;
    M_AXI_AWREADY <= '0';
    wait until clk;
    M_AXI_WREADY <= '1';
    wait until clk;
    wait until clk;
    wait until clk;
    wait until clk;
    wait until clk;
    wait until clk;
    we <= '1';
    i_addr <= x"0";
    i_data <= x"01";
    M_AXI_AWREADY <= '1';
    M_AXI_WREADY <= '1';
    wait until clk;
    we <= '0';
    for i in 0 to 10 loop
      wait until clk;
    end loop;
    we <= '1';
    i_addr <= x"1";
    i_data <= x"01";
    M_AXI_ARREADY <= '1';
    M_AXI_RVALID <= '1';
    M_AXI_RDATA <= x"deadbeef";
    wait until clk;
    i_addr <= x"8";
    we <= '0';
    for i in 0 to 10 loop
      wait until clk;
    end loop;
    
    std.env.finish;
  end process;

  dut : entity work.mc51_to_axi_bridge(a_mc51_to_axi_bridge)
  port map(
            clk           => clk          ,
            rstn          => rstn         ,
            M_AXI_AWADDR  => M_AXI_AWADDR ,
            M_AXI_AWPROT  => M_AXI_AWPROT ,
            M_AXI_AWVALID => M_AXI_AWVALID,
            M_AXI_AWREADY => M_AXI_AWREADY,
            M_AXI_WDATA   => M_AXI_WDATA  ,
            M_AXI_WSTRB   => M_AXI_WSTRB  ,
            M_AXI_WVALID  => M_AXI_WVALID ,
            M_AXI_WREADY  => M_AXI_WREADY ,
            M_AXI_BRESP   => M_AXI_BRESP  ,
            M_AXI_BVALID  => M_AXI_BVALID ,
            M_AXI_BREADY  => M_AXI_BREADY ,
            M_AXI_ARADDR  => M_AXI_ARADDR ,
            M_AXI_ARPROT  => M_AXI_ARPROT ,
            M_AXI_ARVALID => M_AXI_ARVALID,
            M_AXI_ARREADY => M_AXI_ARREADY,
            M_AXI_RDATA   => M_AXI_RDATA  ,
            M_AXI_RRESP   => M_AXI_RRESP  ,
            M_AXI_RVALID  => M_AXI_RVALID ,
            M_AXI_RREADY  => M_AXI_RREADY ,
            M_AXI_ARID    => M_AXI_ARID   ,
            M_AXI_ARLEN   => M_AXI_ARLEN  ,
            M_AXI_ARSIZE  => M_AXI_ARSIZE ,
            M_AXI_ARBURST => M_AXI_ARBURST,
            M_AXI_ARLOCK  => M_AXI_ARLOCK ,
            M_AXI_ARCACHE => M_AXI_ARCACHE,
            M_AXI_RID     => M_AXI_RID    ,
            M_AXI_RLAST   => M_AXI_RLAST  ,
            M_AXI_AWID    => M_AXI_AWID   ,
            M_AXI_AWLEN   => M_AXI_AWLEN  ,
            M_AXI_AWSIZE  => M_AXI_AWSIZE ,
            M_AXI_AWBURST => M_AXI_AWBURST,
            M_AXI_AWLOCK  => M_AXI_AWLOCK ,
            M_AXI_WLAST   => M_AXI_WLAST  ,
            M_AXI_AWCACHE => M_AXI_AWCACHE,
            i_addr        => i_addr       ,
            i_data        => i_data       ,
            o_data        => o_data       ,
            we            => we           ,
            cs            => cs           
          );

end;
