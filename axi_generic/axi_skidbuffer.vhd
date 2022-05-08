library ti;
context ti.should_be_part_of_the_language_itself;

use ti.axi.all;

entity axi_skidbuffer is 
  generic (
            axi_config : axi_config_t := (data_width => 64, 
                                          addr_width => 32, 
                                          user_width => 0, 
                                          id_width => 0, 
                                          strb_width => 8)
          );
  port (
         axi_aclk    : in  std_logic;
         axi_aresetn : in  std_logic;

         s_axi_awvalid : in  std_logic;
         s_axi_awready : out std_logic;
         s_axi_aw      : in  axi_aw_t;
         s_axi_wvalid  : in  std_logic;
         s_axi_wready  : out std_logic;
         s_axi_w       : in  axi_w_t;
         s_axi_bvalid  : out std_logic;
         s_axi_bready  : in  std_logic;
         s_axi_b       : out axi_b_t;
         s_axi_arvalid : in  std_logic;
         s_axi_arready : out std_logic;
         s_axi_ar      : in  axi_ar_t;
         s_axi_rvalid  : out std_logic;
         s_axi_rready  : in  std_logic;
         s_axi_r       : out axi_r_t;

         m_axi_awvalid : out std_logic;
         m_axi_awready : in  std_logic;
         m_axi_aw      : out axi_aw_t;
         m_axi_wvalid  : out std_logic;
         m_axi_wready  : in  std_logic;
         m_axi_w       : out axi_w_t;
         m_axi_bvalid  : in  std_logic;
         m_axi_bready  : out std_logic;
         m_axi_b       : in  axi_b_t;
         m_axi_arvalid : out std_logic;
         m_axi_arready : in  std_logic;
         m_axi_ar      : out axi_ar_t;
         m_axi_rvalid  : in  std_logic;
         m_axi_rready  : out std_logic;
         m_axi_r       : in  axi_r_t
       );
end;

architecture a_axi_skidbuffer of axi_skidbuffer is 
  signal awbuf : std_logic_vector(axi_aw_len(axi_config)-1 downto 0);
  signal wbuf  : std_logic_vector(axi_w_len(axi_config)-1  downto 0);
  signal bbuf  : std_logic_vector(axi_b_len(axi_config)-1  downto 0);
  signal arbuf : std_logic_vector(axi_ar_len(axi_config)-1 downto 0);
  signal rbuf  : std_logic_vector(axi_r_len(axi_config)-1  downto 0);
begin

  aw_skidbuffer: entity ti.skidbuffer 
  generic map (
            width => awbuf'length
          )
  port map (
         clk     => axi_aclk,
         rst     => not axi_aresetn,
         input   => axi_aw_ser(s_axi_aw),
         i_valid => s_axi_awvalid,
         i_ready => s_axi_awready,
         output  => awbuf,
         o_valid => m_axi_awvalid,
         o_ready => m_axi_awready
       );
  m_axi_aw <= axi_aw_des(awbuf, axi_config);

  w_skidbuffer: entity ti.skidbuffer 
  generic map (
            width => wbuf'length
          )
  port map (
         clk     => axi_aclk,
         rst     => not axi_aresetn,
         input   => axi_w_ser(s_axi_w),
         i_valid => s_axi_wvalid,
         i_ready => s_axi_wready,
         output  => wbuf,
         o_valid => m_axi_wvalid,
         o_ready => m_axi_wready
       );
  m_axi_w <= axi_w_des(wbuf, axi_config);

  b_skidbuffer: entity ti.skidbuffer 
  generic map (
            width => bbuf'length
          )
  port map (
         clk     => axi_aclk,
         rst     => not axi_aresetn,
         input   => axi_b_ser(m_axi_b),
         i_valid => m_axi_bvalid,
         i_ready => m_axi_bready,
         output  => bbuf,
         o_valid => s_axi_bvalid,
         o_ready => s_axi_bready
       );
  s_axi_b <= axi_b_des(bbuf, axi_config);

  ar_skidbuffer: entity ti.skidbuffer 
  generic map (
            width => arbuf'length
          )
  port map (
         clk     => axi_aclk,
         rst     => not axi_aresetn,
         input   => axi_ar_ser(s_axi_ar),
         i_valid => s_axi_arvalid,
         i_ready => s_axi_arready,
         output  => arbuf,
         o_valid => m_axi_arvalid,
         o_ready => m_axi_arready
       );
  m_axi_ar <= axi_ar_des(arbuf, axi_config);


  r_skidbuffer: entity ti.skidbuffer 
  generic map (
            width => rbuf'length
          )
  port map (
         clk     => axi_aclk,
         rst     => not axi_aresetn,
         input   => axi_r_ser(m_axi_r),
         i_valid => m_axi_rvalid,
         i_ready => m_axi_rready,
         output  => rbuf,
         o_valid => s_axi_rvalid,
         o_ready => s_axi_rready
       );
  s_axi_r <= axi_r_des(rbuf, axi_config);

end;
