library ti;
context ti.should_be_part_of_the_language_itself_for_simulation;

use ti.axi.all;

entity axi_pkg_tb is 
end;

architecture a_axi_pkg_tb of axi_pkg_tb is 
  signal clk : std_logic := '1';

  constant axil_addr_width : natural := 32;
  constant axil_data_width : natural := 64;
  signal axil_aw : axil_aw_t(addr(axil_addr_width - 1 downto 0));
  signal axil_w  : axil_w_t(data(axil_data_width  - 1 downto 0));
  signal axil_b  : axil_b_t;
  signal axil_ar : axil_ar_t(addr(axil_addr_width - 1 downto 0));
  signal axil_r  : axil_r_t(data(axil_data_width  - 1 downto 0));

  constant axi_conf : axi_config_t := (
    addr_width => 32,
    data_width => 128,
    strb_width => 16,
    id_width   => 3,
    user_width => 0
  );
  signal axi_aw : axi_aw_t(addr(axi_conf.addr_width - 1 downto 0), id(axi_conf.id_width     - 1 downto 0), user(axi_conf.user_width - 1 downto 0));
  signal axi_w  : axi_w_t(data(axi_conf.data_width  - 1 downto 0), user(axi_conf.user_width - 1 downto 0), strb(axi_conf.strb_width - 1 downto 0));
  signal axi_b  : axi_b_t(id(axi_conf.id_width      - 1 downto 0), user(axi_conf.user_width - 1 downto 0));
  signal axi_ar : axi_ar_t(addr(axi_conf.addr_width - 1 downto 0), id(axi_conf.id_width     - 1 downto 0), user(axi_conf.user_width - 1 downto 0));
  signal axi_r  : axi_r_t(data(axi_conf.data_width  - 1 downto 0), user(axi_conf.user_width - 1 downto 0), id(axi_conf.id_width     - 1 downto 0));
begin

  assert(is_valid_axi_config(axi_conf));

  clk <= not clk after 10 ns;

  process is
  begin
    wait for 1000*10 ns;
    std.env.finish;
  end process;

  process (all) is
  begin
    if rising_edge(clk) then
      -- axil
      assert(axil_aw = axil_aw_des(axil_aw_ser(axil_aw), axil_addr_width));
      assert(axil_w  = axil_w_des(axil_w_ser(axil_w),    axil_data_width));
      assert(axil_b  = axil_b_des(axil_b_ser(axil_b)));
      assert(axil_ar = axil_ar_des(axil_ar_ser(axil_ar), axil_addr_width));
      assert(axil_r  = axil_r_des(axil_r_ser(axil_r),    axil_data_width));
      -- axi
      assert(axi_aw = axi_aw_des(axi_aw_ser(axi_aw), axi_conf));
      assert(axi_w  = axi_w_des(axi_w_ser(axi_w),    axi_conf));
      assert(axi_b  = axi_b_des(axi_b_ser(axi_b),    axi_conf));
      assert(axi_ar = axi_ar_des(axi_ar_ser(axi_ar), axi_conf));
      assert(axi_r  = axi_r_des(axi_r_ser(axi_r),    axi_conf));
    end if;
  end process;

  process (all) is
  begin
    if rising_edge(clk) then
    -- axil
    axil_aw.addr <= rand(axil_aw.addr'length);
    axil_aw.prot <= rand(axil_aw.prot'length);
    axil_w.data  <= rand(axil_w.data'length);
    axil_w.strb  <= rand(axil_w.strb'length);
    axil_b.resp  <= rand(axil_b.resp'length);
    axil_ar.addr <= rand(axil_ar.addr'length);
    axil_ar.prot <= rand(axil_ar.prot'length);
    axil_r.data  <= rand(axil_r.data'length);
    axil_r.resp  <= rand(axil_r.resp'length);

    -- axi
    axi_aw.addr   <= rand(axi_aw.addr'length);
    axi_aw.size   <= rand(axi_aw.size'length);
    axi_aw.burst  <= rand(axi_aw.burst'length);
    axi_aw.cache  <= rand(axi_aw.cache'length);
    axi_aw.prot   <= rand(axi_aw.prot'length);
    axi_aw.id     <= rand(axi_aw.id'length);
    axi_aw.len    <= rand(axi_aw.len'length);
    axi_aw.lock   <= rand;
    axi_aw.qos    <= rand(axi_aw.qos'length);
    axi_aw.region <= rand(axi_aw.region'length);
    axi_aw.user   <= rand(axi_aw.user'length);
    axi_w.last    <= rand;
    axi_w.data    <= rand(axi_w.data'length);
    axi_w.strb    <= rand(axi_w.strb'length);
    axi_w.user    <= rand(axi_w.user'length);
    axi_b.resp    <= rand(axi_b.resp'length);
    axi_b.id      <= rand(axi_b.id'length);
    axi_b.user    <= rand(axi_b.user'length);
    axi_ar.addr   <= rand(axi_ar.addr'length);
    axi_ar.size   <= rand(axi_ar.size'length);
    axi_ar.burst  <= rand(axi_ar.burst'length);
    axi_ar.cache  <= rand(axi_ar.cache'length);
    axi_ar.prot   <= rand(axi_ar.prot'length);
    axi_ar.id     <= rand(axi_ar.id'length);
    axi_ar.len    <= rand(axi_ar.len'length);
    axi_ar.lock   <= rand;
    axi_ar.qos    <= rand(axi_ar.qos'length);
    axi_ar.region <= rand(axi_ar.region'length);
    axi_ar.user   <= rand(axi_ar.user'length);
    axi_r.last    <= rand;
    axi_r.data    <= rand(axi_r.data'length);
    axi_r.resp    <= rand(axi_r.resp'length);
    axi_r.id      <= rand(axi_r.id'length);
    axi_r.user    <= rand(axi_r.user'length);

  end if;

  end process;

end;
