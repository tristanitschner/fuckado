-- TODO:
-- * use vunit
-- * proper testcases
--      -> do we receive the same number of beats that we requested?
--      -> do we receive the actual data that we send?
-- * make that axis source all asynchronous


library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

use ieee.math_real.all;

use work.all;

use std.env.all;

entity ti_axil_datamover_s2mm_tb is 
end;

architecture a_ti_axil_datamover_s2mm_tb of ti_axil_datamover_s2mm_tb is 
  constant data_width : integer := 32; -- this is identical for stream and axil
  constant stb_width : integer := 4; -- this is identical for stream and axil
  constant addr_width : integer := 32;
  constant mode_indeterminate : boolean := false;

  signal clk :  std_logic := '1';
  signal rst :  std_logic;

  signal m_axil_awvalid :  std_logic;
  signal m_axil_awready :   std_logic;
  signal m_axil_awaddr  :  std_logic_vector(addr_width-1 downto 0);
  signal m_axil_awprot  :  std_logic_vector(2 downto 0);
  signal m_axil_wvalid  :  std_logic;
  signal m_axil_wready  :   std_logic;
  signal m_axil_wdata   :  std_logic_vector(data_width-1 downto 0);
  signal m_axil_wstrb   :  std_logic_vector(stb_width-1 downto 0);
  signal m_axil_bvalid  :   std_logic;
  signal m_axil_bready  :  std_logic;
  signal m_axil_bresp   :   std_logic_vector(1 downto 0);
  signal m_axil_arvalid :  std_logic;
  signal m_axil_arready :   std_logic;
  signal m_axil_araddr  :  std_logic_vector(addr_width-1 downto 0);
  signal m_axil_arprot  :  std_logic_vector(2 downto 0);
  signal m_axil_rvalid  :   std_logic;
  signal m_axil_rready  :  std_logic;
  signal m_axil_rdata   :   std_logic_vector(data_width-1 downto 0);
  signal m_axil_rresp   :   std_logic_vector(1 downto 0);

  signal s_axis_tready  :  std_logic;
  signal s_axis_tvalid  :   std_logic;
  signal s_axis_tdata   :   std_logic_vector(data_width-1 downto 0);

  signal s_axis_c_tready  :  std_logic;
  signal s_axis_c_tvalid  :   std_logic;
  signal s_axis_c_tdata   :   std_logic_vector(2*data_width-1 downto 0);

  procedure wait_cycles(x : natural) is
  begin
    for i in 1 to x loop
      wait until clk = '1';
    end loop;
  end procedure;

begin

  clk <= not clk after 10 ns;

  process is
  procedure transmit_command(
                              address : std_logic_vector(31 downto 0);
                              bytecount : natural
                            ) is
  begin
    s_axis_c_tvalid <= '1';
    s_axis_c_tdata <= address & std_logic_vector(to_unsigned(bytecount, 32));
    while true loop
      wait until clk = '1';
      if s_axis_c_tready and s_axis_c_tvalid then
        exit;
      end if;
    end loop;
    s_axis_c_tvalid <= '0';
  end procedure;

  procedure transmit_data(x : natural) is
  begin
    s_axis_tvalid <= '1';
    for i in 1 to x loop
      s_axis_tdata <= std_logic_vector(to_unsigned(i, 32));
      while true loop
        wait until clk = '1';
        if s_axis_tready and s_axis_tvalid then
          exit;
        end if;
      end loop;
    end loop;
    s_axis_tvalid <= '0';
  end procedure;
    variable seed : integer := 32;
    variable seed2 : integer := 32;
    impure function rand return std_logic is
      variable value : real;
      variable ret : std_logic;
    begin
      uniform(seed, seed2, value);
      ret := '1' when value < 0.5 else '0';
      return ret;
    end function;
    impure function rand return std_logic_vector is
      variable value : real;
      variable ret : std_logic_vector(31 downto 0);
    begin
      for i in ret'range loop
        uniform(seed, seed2, value);
        ret(i) := '1' when value < 0.5 else '0';
      end loop;
      return ret;
    end function;
  begin
    rst <= '1';
    wait_cycles(5);
    rst <= '0';
    wait_cycles(5);
    transmit_command(x"00001000", 10);
    transmit_data(10);
    wait_cycles(10);
    transmit_command(x"00001000", 10);
    transmit_data(10);
    wait_cycles(10);
    -- check for back to back
    s_axis_c_tvalid <= '1';
    s_axis_c_tdata <= x"00100000" & std_logic_vector(to_unsigned(13, 32));
    --transmit_command(x"00200000", 100);
    while true loop
      s_axis_tvalid <= '1';
      s_axis_tdata <= rand;
      wait_cycles(1);
    end loop;
    wait;
  end process;

  -- todo: axil sink
  process is
    variable seed : integer := 32;
    variable seed2 : integer := 32;
    impure function rand return std_logic is
      variable value : real;
      variable ret : std_logic;
    begin
      uniform(seed, seed2, value);
      ret := '1' when value < 0.5 else '0';
      return ret;
    end function;
    impure function rand return std_logic_vector is
      variable value : real;
      variable ret : std_logic_vector(31 downto 0);
    begin
      for i in ret'range loop
        uniform(seed, seed2, value);
        ret(i) := '1' when value < 0.5 else '0';
      end loop;
      return ret;
    end function;
  begin
    while true loop
      --m_axil_awready <= rand;
      --m_axil_wready <= rand;
      m_axil_awready <= '1';
      m_axil_wready <= '1';
      wait_cycles(1);
    end loop;
  end process;

  process is
  begin
    wait_cycles(800);
    std.env.finish;
  end process;

dut : entity work.ti_axil_datamover_s2mm
  generic map (
            data_width         => data_width,
            stb_width          => stb_width,
            addr_width         => addr_width,
            mode_indeterminate => mode_indeterminate
          )
  port map (
         clk              => clk,
         rst              => rst,
         -- other => other,
         m_axil_aclk      => clk,
         m_axil_aresetn   => not rst,
         m_axil_awvalid   => m_axil_awvalid,
         m_axil_awready   => m_axil_awready,
         m_axil_awaddr    => m_axil_awaddr,
         m_axil_awprot    => m_axil_awprot,
         m_axil_wvalid    => m_axil_wvalid,
         m_axil_wready    => m_axil_wready,
         m_axil_wdata     => m_axil_wdata,
         m_axil_wstrb     => m_axil_wstrb,
         m_axil_bvalid    => m_axil_bvalid,
         m_axil_bready    => m_axil_bready,
         m_axil_bresp     => m_axil_bresp,
         m_axil_arvalid   => m_axil_arvalid,
         m_axil_arready   => m_axil_arready,
         m_axil_araddr    => m_axil_araddr,
         m_axil_arprot    => m_axil_arprot,
         m_axil_rvalid    => m_axil_rvalid,
         m_axil_rready    => m_axil_rready,
         m_axil_rdata     => m_axil_rdata,
         m_axil_rresp     => m_axil_rresp,

         s_axis_aclk      => clk,
         s_axis_aresetn   => not rst,
         s_axis_tready    => s_axis_tready,
         s_axis_tvalid    => s_axis_tvalid,
         s_axis_tdata     => s_axis_tdata,

         s_axis_c_aclk    => clk,
         s_axis_c_aresetn => not rst,
         s_axis_c_tready  => s_axis_c_tready,
         s_axis_c_tvalid  => s_axis_c_tvalid,
         s_axis_c_tdata   => s_axis_c_tdata
       -- the command word is divided in two part:
       -- most sigificant 32 bits: address to write to
       -- least siginificant 32 bits: number of beats to wirte to that address
       );


end;
