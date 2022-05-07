-- Goal: A simple axi stream to axil datamover that support back to back
-- transactions.
--
-- Port
-- IN: axis
-- OUT: axil
-- CONTROL: axis (custom, similar to xilinx axi datamover command word)

-- Ideas:
-- use skidbuffers?

library ieee;
use ieee.numeric_std.all;
use ieee.std_logic_1164.all;

library work;

entity ti_axil_datamover_s2mm is 
  generic (
            data_width : integer := 32; -- this is identical for stream and axil
            stb_width : integer := 4; -- this is identical for stream and axil
            addr_width : integer := 32;
            mode_indeterminate : boolean := false
          );
  port (
         clk : in std_logic;
         rst : in std_logic;
         -- other ports
         m_axil_aclk    : in  std_logic;
         m_axil_aresetn : in  std_logic;
         m_axil_awvalid : out std_logic;
         m_axil_awready : in  std_logic;
         m_axil_awaddr  : out std_logic_vector(addr_width-1 downto 0);
         m_axil_awprot  : out std_logic_vector(2 downto 0);
         m_axil_wvalid  : out std_logic;
         m_axil_wready  : in  std_logic;
         m_axil_wdata   : out std_logic_vector(data_width-1 downto 0);
         m_axil_wstrb   : out std_logic_vector(stb_width-1 downto 0);
         m_axil_bvalid  : in  std_logic;
         m_axil_bready  : out std_logic;
         m_axil_bresp   : in  std_logic_vector(1 downto 0);
         m_axil_arvalid : out std_logic;
         m_axil_arready : in  std_logic;
         m_axil_araddr  : out std_logic_vector(addr_width-1 downto 0);
         m_axil_arprot  : out std_logic_vector(2 downto 0);
         m_axil_rvalid  : in  std_logic;
         m_axil_rready  : out std_logic;
         m_axil_rdata   : in  std_logic_vector(data_width-1 downto 0);
         m_axil_rresp   : in  std_logic_vector(1 downto 0);

         s_axis_aclk    : in  std_logic;
         s_axis_aresetn : in  std_logic;
         s_axis_tready  : out std_logic;
         s_axis_tvalid  : in  std_logic;
         s_axis_tdata   : in  std_logic_vector(data_width-1 downto 0);

         s_axis_c_aclk    : in  std_logic;
         s_axis_c_aresetn : in  std_logic;
         s_axis_c_tready  : out std_logic;
         s_axis_c_tvalid  : in  std_logic;
         s_axis_c_tdata   : in  std_logic_vector(2*data_width-1 downto 0)
       -- the command word is divided in two part:
       -- most sigificant 32 bits: address to write to
       -- least siginificant 32 bits: number of beats to wirte to that address
       );
end;
architecture a_ti_axil_datamover_s2mm of ti_axil_datamover_s2mm is 
  signal c_address : unsigned(data_width-1 downto 0);
  signal c_btt : unsigned(data_width-1 downto 0); -- beats to transfer
  signal awcount : unsigned(data_width-1 downto 0); -- TODO: make its width variable
  signal wcount : unsigned(data_width-1 downto 0); -- TODO: make its width variable

  signal m_axil_awfire : std_logic;
  signal m_axil_wfire : std_logic;
  signal m_axil_bfire : std_logic;
  signal s_axis_fire : std_logic;
  signal s_axis_c_fire : std_logic;

-- response values
constant OKAY   : std_logic_vector := "00";
constant EXOKAY : std_logic_vector := "01";
constant SLVERR : std_logic_vector := "10";
constant DECERR : std_logic_vector := "11";

begin

  handshakes: block is
  begin
    m_axil_awfire <= m_axil_awready  and m_axil_awvalid;
    m_axil_wfire  <= m_axil_wready   and m_axil_wvalid;
    m_axil_bfire  <= m_axil_bready   and m_axil_bvalid;
    s_axis_fire   <= s_axis_tready   and s_axis_tvalid;
    s_axis_c_fire <= s_axis_c_tready and s_axis_c_tvalid;
  end block;

  command_word_logic: block is
  begin
    process (all) is
    begin
    if rising_edge(clk) then
      -- debug begin
      if m_axil_wfire = '1' and wcount = c_btt - "1" then
        c_address <= (others => '0');
        c_btt <= (others => '0');
      end if;
      -- debug end
      if s_axis_c_fire then
        c_address <= unsigned(s_axis_c_tdata(63 downto 32));
        c_btt <= unsigned(s_axis_c_tdata(31 downto 0));
      end if;
      if rst then
        c_address <= (others => '0');
        c_btt <= (others => '0');
      end if;
    end if;
    end process;
  end block;

  main_logic: block is
    signal active : boolean;
    signal dest_address : unsigned(m_axil_awaddr'range);
    signal aw_before_w_flag : std_logic;
  begin
    active <= wcount < c_btt; -- this looks funny

    transaction_counter: process (all) is
    begin
      if rising_edge(clk) then
        if m_axil_awfire then
          awcount <= awcount + "1";
        end if;
        if m_axil_wfire then
          wcount <= wcount + "1";
        end if;
        if wcount = c_btt - "1" and m_axil_wfire = '1' then
          awcount <= (others => '0');
          wcount <= (others => '0');
        end if;
        if rst then
          awcount <= (others => '0');
          wcount <= (others => '0');
        end if;
      end if;
    end process;

    -- we accept the command, if we have nothing to do anyways, or we're on the
    -- last beat of a transaction
    s_axis_c_tready <= '1' when not active or (m_axil_wfire = '1' and wcount = c_btt - "1") else '0';
    s_axis_tready <= m_axil_wfire;
    m_axil_awvalid <= '1' when active and s_axis_tvalid = '1' and awcount = wcount else '0';
    m_axil_wvalid <= '1' when active and s_axis_tvalid = '1' and (m_axil_awfire = '1' or wcount < awcount) else '0';

    m_axil_wdata <= s_axis_tdata;
    m_axil_awaddr <= std_logic_vector(c_address + (wcount sll 2));
  end block;

  m_axil_unused: block is
  begin
    m_axil_arvalid <= '0';
    m_axil_araddr  <= (others => '0');
    m_axil_arprot  <= (others => '0');
    m_axil_rready  <= '0';
    m_axil_bready  <= '1'; 
    -- we _could_ count the write response channel transactions, but since the
    -- axi protocol is broken anyways (no drop signal / timeout) and these may
    -- come anytime in the future, there's really no need
    -- might implement a timeout TODO
  end block;


end architecture;
