-- GOAL:
-- * given a packet stream of axi bursts, deteced 4k boundaries and split the
--   associated transfer
-- * also detect wlast errors

library ti;
context ti.should_be_part_of_the_language_itself;

entity fourk_boundary_isolator is 
  generic (
            addr_width : natural := 32;
            data_width : natural := 32;
            id_width   : natural := 0;
            user_width : natural := 0
          );
  port (
         s_axi_aclk    : in std_logic;
         s_axi_aresetn : in std_logic;
         s_axi_awvalid  : in  std_logic;
         s_axi_awready  : out std_logic;
         s_axi_awaddr   : in  std_logic_vector(addr_width-1 downto 0);
         s_axi_awsize   : in  std_logic_vector(2 downto 0);
         s_axi_awburst  : in  std_logic_vector(1 downto 0);
         s_axi_awcache  : in  std_logic_vector(3 downto 0);
         s_axi_awprot   : in  std_logic_vector(2 downto 0);
         s_axi_awid     : in  std_logic_vector(id_width-1 downto 0);
         s_axi_awlen    : in  std_logic_vector(7 downto 0);
         s_axi_awlock   : in  std_logic;
         s_axi_awqos    : in  std_logic_vector(3 downto 0);
         s_axi_awregion : in  std_logic_vector(3 downto 0);
         s_axi_awuser   : in  std_logic_vector(user_width-1 downto 0);
         s_axi_wvalid   : in  std_logic;
         s_axi_wready   : out std_logic;
         s_axi_wlast    : in  std_logic;
         s_axi_wdata    : in  std_logic_vector(data_width-1 downto 0);
         s_axi_wstrb    : in  std_logic_vector(clog2(data_width)-1 downto 0);
         s_axi_wuser    : in  std_logic_vector(user_width-1 downto 0);
         s_axi_bvalid   : out std_logic;
         s_axi_bready   : in  std_logic;
         s_axi_bresp    : out std_logic_vector(1 downto 0);
         s_axi_bid      : out std_logic_vector(id_width-1 downto 0);
         s_axi_buser    : out std_logic_vector(user_width-1 downto 0);
         s_axi_arvalid  : in  std_logic;
         s_axi_arready  : out std_logic;
         s_axi_araddr   : in  std_logic_vector(addr_width-1 downto 0);
         s_axi_arsize   : in  std_logic_vector(2 downto 0);
         s_axi_arburst  : in  std_logic_vector(1 downto 0);
         s_axi_arcache  : in  std_logic_vector(3 downto 0);
         s_axi_arprot   : in  std_logic_vector(2 downto 0);
         s_axi_arid     : in  std_logic_vector(id_width-1 downto 0);
         s_axi_arlen    : in  std_logic_vector(7 downto 0);
         s_axi_arlock   : in  std_logic;
         s_axi_arqos    : in  std_logic_vector(3 downto 0);
         s_axi_arregion : in  std_logic_vector(3 downto 0);
         s_axi_aruser   : in  std_logic_vector(user_width-1 downto 0);
         s_axi_rvalid   : out std_logic;
         s_axi_rready   : out std_logic;
         s_axi_rlast    : out std_logic;
         s_axi_rdata    : out std_logic_vector(data_width-1 downto 0);
         s_axi_rresp    : out std_logic_vector(1 downto 0);
         s_axi_rid      : out std_logic_vector(id_width-1 downto 0);
         s_axi_ruser    : out std_logic_vector(user_width-1 downto 0);

         m_axi_aclk    : in std_logic;
         m_axi_aresetn : in std_logic;
         m_axi_awvalid  : out std_logic;
         m_axi_awready  : in  std_logic;
         m_axi_awaddr   : out std_logic_vector(addr_width-1 downto 0);
         m_axi_awsize   : out std_logic_vector(2 downto 0);
         m_axi_awburst  : out std_logic_vector(1 downto 0);
         m_axi_awcache  : out std_logic_vector(3 downto 0);
         m_axi_awprot   : out std_logic_vector(2 downto 0);
         m_axi_awid     : out std_logic_vector(id_width-1 downto 0);
         m_axi_awlen    : out std_logic_vector(7 downto 0);
         m_axi_awlock   : out std_logic;
         m_axi_awqos    : out std_logic_vector(3 downto 0);
         m_axi_awregion : out std_logic_vector(3 downto 0);
         m_axi_awuser   : out std_logic_vector(user_width-1 downto 0);
         m_axi_wvalid   : out std_logic;
         m_axi_wready   : in  std_logic;
         m_axi_wlast    : out std_logic;
         m_axi_wdata    : out std_logic_vector(data_width-1 downto 0);
         m_axi_wstrb    : out std_logic_vector(clog2(data_width)-1 downto 0);
         m_axi_wuser    : out std_logic_vector(user_width-1 downto 0);
         m_axi_bvalid   : in  std_logic;
         m_axi_bready   : out std_logic;
         m_axi_bresp    : in  std_logic_vector(1 downto 0);
         m_axi_bid      : in  std_logic_vector(id_width-1 downto 0);
         m_axi_buser    : in  std_logic_vector(user_width-1 downto 0);
         m_axi_arvalid  : out std_logic;
         m_axi_arready  : in  std_logic;
         m_axi_araddr   : out std_logic_vector(addr_width-1 downto 0);
         m_axi_arsize   : out std_logic_vector(2 downto 0);
         m_axi_arburst  : out std_logic_vector(1 downto 0);
         m_axi_arcache  : out std_logic_vector(3 downto 0);
         m_axi_arprot   : out std_logic_vector(2 downto 0);
         m_axi_arid     : out std_logic_vector(id_width-1 downto 0);
         m_axi_arlen    : out std_logic_vector(7 downto 0);
         m_axi_arlock   : out std_logic;
         m_axi_arqos    : out std_logic_vector(3 downto 0);
         m_axi_arregion : out std_logic_vector(3 downto 0);
         m_axi_aruser   : out std_logic_vector(user_width-1 downto 0);
         m_axi_rvalid   : in  std_logic;
         m_axi_rready   : in  std_logic;
         m_axi_rlast    : in  std_logic;
         m_axi_rdata    : in  std_logic_vector(data_width-1 downto 0);
         m_axi_rresp    : in  std_logic_vector(1 downto 0);
         m_axi_rid      : in  std_logic_vector(id_width-1 downto 0);
         m_axi_ruser    : in  std_logic_vector(user_width-1 downto 0);

        error_word : out std_logic_vector(7 downto 0)
        -- yet to be defined
        -- bresp errors are propagated through the interface
        -- could implement timeout
        -- wlast errors
);
end;

architecture a_fourk_boundary_isolator of fourk_boundary_isolator is 
  signal s_axi_awfire : std_logic;
  signal s_axi_wfire  : std_logic;
  signal s_axi_bfire  : std_logic;
  signal s_axi_arfire : std_logic;
  signal s_axi_rfire  : std_logic;

  signal m_axi_awfire : std_logic;
  signal m_axi_wfire  : std_logic;
  signal m_axi_bfire  : std_logic;
  signal m_axi_arfire : std_logic;
  signal m_axi_rfire  : std_logic;

-- response values
constant OKAY   : std_logic_vector := "00";
constant EXOKAY : std_logic_vector := "01";
constant SLVERR : std_logic_vector := "10";
constant DECERR : std_logic_vector := "11";

begin

  handshakes: block is
  begin
    s_axi_awfire <= s_axi_awready and s_axi_awvalid;
    s_axi_wfire  <= s_axi_wready  and s_axi_wvalid;
    s_axi_bfire  <= s_axi_bready  and s_axi_bvalid;
    s_axi_arfire <= s_axi_arready and s_axi_arvalid;
    s_axi_rfire  <= s_axi_rready  and s_axi_rvalid;

    m_axi_awfire <= m_axi_awready and m_axi_awvalid;
    m_axi_wfire  <= m_axi_wready  and m_axi_wvalid;
    m_axi_bfire  <= m_axi_bready  and m_axi_bvalid;
    m_axi_arfire <= m_axi_arready and m_axi_arvalid;
    m_axi_rfire  <= m_axi_rready  and m_axi_rvalid;
  end block;

-- if we have a aw transaction
-- check if it crosses a 4k boundary
-- yes -> generate two transactions
--     -> insert additional wlast on right beat
--     -> insert additional b response
-- no -> transaction passes through

-- do the same for the ar channel


end;
