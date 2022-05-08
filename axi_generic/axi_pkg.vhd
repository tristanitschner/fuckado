-- Description:
-- Since generic types is a pain in VHDL, provide serdes functions.
-- NOTE: not supporting axis, for it's simple and not well-defined
-- NOTE: if you use big endian, the functions will not work

library ti;
context ti.should_be_part_of_the_language_itself;

package axi is

type axi_config_t is record
  addr_width : natural;
  data_width : natural;
  strb_width : natural;
  id_width   : natural;
  user_width : natural;
end record;

  function is_valid_axi_config(x : axi_config_t) return boolean;

type axil_aw_t is record
  addr   : std_logic_vector;
  prot   : std_logic_vector(2 downto 0);
end record;
type axil_w_t is record
  data   : std_logic_vector;
  strb   : std_logic_vector(3 downto 0);
end record;
type axil_b_t is record
  resp   : std_logic_vector(1 downto 0);
end record;
type axil_ar_t is record
  addr   : std_logic_vector;
  prot   : std_logic_vector(2 downto 0);
end record;
type axil_r_t is record
  data   : std_logic_vector;
  resp   : std_logic_vector(1 downto 0);
end record;

function axil_aw_ser(x : axil_aw_t) return std_logic_vector;
function axil_aw_des(x : std_logic_vector; addr_width : natural) return axil_aw_t;
function axil_w_ser (x : axil_w_t)  return std_logic_vector;
function axil_w_des (x : std_logic_vector; data_width : natural) return axil_w_t;
function axil_b_ser (x : axil_b_t)  return std_logic_vector;
function axil_b_des (x : std_logic_vector) return axil_b_t;
function axil_ar_ser(x : axil_ar_t) return std_logic_vector;
function axil_ar_des(x : std_logic_vector; addr_width : natural) return axil_ar_t;
function axil_r_ser (x : axil_r_t)  return std_logic_vector;
function axil_r_des (x : std_logic_vector; data_width : natural) return axil_r_t;

type axi_aw_t is record
  addr   : std_logic_vector;
  size   : std_logic_vector(2 downto 0);
  burst  : std_logic_vector(1 downto 0);
  cache  : std_logic_vector(3 downto 0);
  prot   : std_logic_vector(2 downto 0);
  id     : std_logic_vector;
  len    : std_logic_vector(7 downto 0);
  lock   : std_logic;
  qos    : std_logic_vector(3 downto 0);
  region : std_logic_vector(3 downto 0);
  user   : std_logic_vector;
end record;
type axi_w_t is record
  last   : std_logic;
  data   : std_logic_vector;
  strb   : std_logic_vector;
  user   : std_logic_vector;
end record;
type axi_b_t is record
  resp   : std_logic_vector(1 downto 0);
  id     : std_logic_vector;
  user   : std_logic_vector;
end record;
type axi_ar_t is record
  addr   : std_logic_vector;
  size   : std_logic_vector(2 downto 0);
  burst  : std_logic_vector(1 downto 0);
  cache  : std_logic_vector(3 downto 0);
  prot   : std_logic_vector(2 downto 0);
  id     : std_logic_vector;
  len    : std_logic_vector(7 downto 0);
  lock   : std_logic;                    
  qos    : std_logic_vector(3 downto 0);
  region : std_logic_vector(3 downto 0);
  user   : std_logic_vector;
end record;
type axi_r_t is record
  last   : std_logic;
  data   : std_logic_vector;
  resp   : std_logic_vector(1 downto 0);
  id     : std_logic_vector;
  user   : std_logic_vector;
end record;
function axi_aw_ser(x : axi_aw_t) return std_logic_vector;
function axi_aw_des(x : std_logic_vector; conf : axi_config_t) return axi_aw_t;
function axi_w_ser (x : axi_w_t)  return std_logic_vector;
function axi_w_des (x : std_logic_vector; conf : axi_config_t) return axi_w_t;
function axi_b_ser (x : axi_b_t)  return std_logic_vector;
function axi_b_des (x : std_logic_vector; conf : axi_config_t) return axi_b_t;
function axi_ar_ser(x : axi_ar_t) return std_logic_vector;
function axi_ar_des(x : std_logic_vector; conf : axi_config_t) return axi_ar_t;
function axi_r_ser (x : axi_r_t)  return std_logic_vector;
function axi_r_des (x : std_logic_vector; conf : axi_config_t) return axi_r_t;

end package;

library ti;
context ti.should_be_part_of_the_language_itself;

package body axi is

  function is_valid_axi_config(x : axi_config_t) return boolean is
  begin
    return (x.strb_width = x.data_width/8)
    and (x.data_width = 8   or
         x.data_width = 16  or
         x.data_width = 32  or
         x.data_width = 64  or
         x.data_width = 128 or
         x.data_width = 256 or
         x.data_width = 512 or
         x.data_width = 1024);
  end function;

  -- axil serdes functions:
  function axil_aw_ser(x : axil_aw_t) return std_logic_vector is
    variable retval : std_logic_vector(x.addr'length + x.prot'length - 1 downto 0);
  begin
    assert(x.addr'length = 32 or x.addr'length = 64);
    retval := x.addr & x.prot;
    return retval;
  end function;
  function axil_aw_des(x : std_logic_vector; addr_width : natural) return axil_aw_t is
    variable retval : axil_aw_t(addr(addr_width-1 downto 0));
  begin
    retval.addr := x(x'high downto x'length - addr_width);
    retval.prot := x(2 downto 0);
    return retval;
  end function;

  function axil_w_ser(x : axil_w_t) return std_logic_vector is
    variable retval : std_logic_vector(x.data'length + x.strb'length - 1 downto 0);
  begin
    retval := x.data & x.strb;
    return retval;
  end function;
  function axil_w_des(x : std_logic_vector; data_width : natural) return axil_w_t is
    variable retval : axil_w_t(data(data_width-1 downto 0));
  begin
    retval.data := x(x'high downto x'length - data_width);
    retval.strb := x(3 downto 0);
    return retval;
  end function;

  function axil_b_ser (x : axil_b_t)  return std_logic_vector is
  begin
    return x.resp;
  end function;
  function axil_b_des (x : std_logic_vector) return axil_b_t is
    variable retval : axil_b_t;
  begin
    retval.resp := x;
    return retval;
  end function;

  function axil_ar_ser(x : axil_ar_t) return std_logic_vector is
    variable retval : std_logic_vector(x.addr'length + x.prot'length - 1 downto 0);
  begin
    assert(x.addr'length = 32 or x.addr'length = 64);
    retval := x.addr & x.prot;
    return retval;
  end function;
  function axil_ar_des(x : std_logic_vector; addr_width : natural) return axil_ar_t is
    variable retval : axil_ar_t(addr(addr_width-1 downto 0));
  begin
    retval.addr := x(x'high downto x'length - addr_width);
    retval.prot := x(2 downto 0);
    return retval;
  end function;

  function axil_r_ser(x : axil_r_t) return std_logic_vector is
    variable retval : std_logic_vector(x.data'length + x.resp'length - 1 downto 0);
  begin
    retval := x.data & x.resp;
    return retval;
  end function;
  function axil_r_des(x : std_logic_vector; data_width : natural) return axil_r_t is
    variable retval : axil_r_t(data(data_width-1 downto 0));
  begin
    retval.data := x(x'high downto x'length - data_width);
    retval.resp := x(1 downto 0);
    return retval;
  end function;

  -- axi serdes functions:
  function axi_aw_ser(x : axi_aw_t) return std_logic_vector is
    variable retval : std_logic_vector( x.addr  'length + 
                                        x.size  'length + 
                                        x.burst 'length + 
                                        x.cache 'length + 
                                        x.prot  'length + 
                                        x.id    'length + 
                                        x.len   'length + 
                                        1               + 
                                        x.qos   'length + 
                                        x.region'length + 
                                        x.user  'length - 1 downto 0);
  begin
    retval := 
    x.addr   &
    x.size   &
    x.burst  &
    x.cache  &
    x.prot   &
    x.id     &
    x.len    &
    x.lock   &
    x.qos    &
    x.region &
    x.user;
    return retval;
  end function;
  function axi_aw_des(x : std_logic_vector; conf : axi_config_t) return axi_aw_t is
    variable retval  : axi_aw_t(addr(conf.addr_width-1 downto 0), id(conf.id_width-1 downto 0), user(conf.user_width-1 downto 0));
    -- it's vhdl, so no need to wonder that the code is wholly unreadable ;)
    variable index0  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length + retval.region 'length + retval.user 'length;
    variable index1  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length + retval.region 'length;
    variable index2  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length;
    variable index3  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1;
    variable index4  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length;
    variable index5  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length;
    variable index6  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length;
    variable index7  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length;
    variable index8  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length;
    variable index9  : natural := retval.addr 'length + retval.size 'length;
    variable index10 : natural := retval.addr 'length;
  begin
    retval.addr   := x(x'high downto x'high - index10 + 1);
    retval.size   := x(x'high - index10 downto x'high - index9 + 1);
    retval.burst  := x(x'high - index9  downto x'high - index8 + 1);
    retval.cache  := x(x'high - index8  downto x'high - index7 + 1);
    retval.prot   := x(x'high - index7  downto x'high - index6 + 1);
    retval.id     := x(x'high - index6  downto x'high - index5 + 1);
    retval.len    := x(x'high - index5  downto x'high - index4 + 1);
    retval.lock   := x(x'high - index4);
    retval.qos    := x(x'high - index3  downto x'high - index2 + 1);
    retval.region := x(x'high - index2  downto x'high - index1 + 1);
    retval.user   := x(x'high - index1  downto x'high - index0 + 1);
    return retval;
  end function;

  function axi_w_ser(x : axi_w_t) return std_logic_vector is
    variable retval : std_logic_vector(1 + x.data'length + x.strb'length + x.user'length - 1 downto 0);
  begin
    retval := x.last & x.data & x.strb & x.user;
    return retval;
  end function;
  function axi_w_des(x : std_logic_vector; conf : axi_config_t) return axi_w_t is
    variable retval : axi_w_t(data(conf.data_width-1 downto 0),strb(conf.strb_width-1 downto 0),user(conf.user_width-1 downto 0));
    variable index0 : natural := 1 + retval.data'length + retval.strb'length + retval.user'length;
    variable index1 : natural := 1 + retval.data'length + retval.strb'length;
    variable index2 : natural := 1 + retval.data'length;
    variable index3 : natural := 1;
  begin
    retval.last := x(x'high);
    retval.data := x(x'high - index3 downto x'high - index2 + 1);
    retval.strb := x(x'high - index2 downto x'high - index1 + 1);
    retval.user := x(x'high - index1 downto x'high - index0 + 1);
    return retval;
  end function;

  function axi_b_ser (x : axi_b_t)  return std_logic_vector is
    variable retval : std_logic_vector(x.resp'length + x.id'length + x.user'length - 1 downto 0);
  begin
    retval :=  x.resp & x.id & x.user;
    return retval;
  end function;
  function axi_b_des (x : std_logic_vector; conf : axi_config_t) return axi_b_t is
    variable retval : axi_b_t(id(conf.id_width-1 downto 0), user(conf.user_width-1 downto 0));
  begin
    retval.resp := x(x'high downto x'high - retval.resp'length + 1);
    retval.id   := x(x'high - retval.resp'length downto x'high - retval.resp'length - retval.id'length + 1);
    retval.user := x(retval.user'length - 1 downto 0);
    return retval;
  end function;

  function axi_ar_ser(x : axi_ar_t) return std_logic_vector is
    variable retval : std_logic_vector( x.addr  'length + 
                                        x.size  'length + 
                                        x.burst 'length + 
                                        x.cache 'length + 
                                        x.prot  'length + 
                                        x.id    'length + 
                                        x.len   'length + 
                                        1               + 
                                        x.qos   'length + 
                                        x.region'length + 
                                        x.user  'length - 1 downto 0);
  begin
    retval := 
    x.addr   &
    x.size   &
    x.burst  &
    x.cache  &
    x.prot   &
    x.id     &
    x.len    &
    x.lock   &
    x.qos    &
    x.region &
    x.user;
    return retval;
  end function;
  function axi_ar_des(x : std_logic_vector; conf : axi_config_t) return axi_ar_t is
    variable retval  : axi_ar_t(addr(conf.addr_width-1 downto 0), id(conf.id_width-1 downto 0), user(conf.user_width-1 downto 0));
    -- it's vhdl, so no need to wonder that the code is wholly unreadable ;)
    variable index0  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length + retval.region 'length + retval.user 'length;
    variable index1  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length + retval.region 'length;
    variable index2  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1 + retval.qos 'length;
    variable index3  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length + 1;
    variable index4  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length + retval.len 'length;
    variable index5  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length + retval.id 'length;
    variable index6  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length + retval.prot 'length;
    variable index7  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length + retval.cache 'length;
    variable index8  : natural := retval.addr 'length + retval.size 'length + retval.burst 'length;
    variable index9  : natural := retval.addr 'length + retval.size 'length;
    variable index10 : natural := retval.addr 'length;
  begin
    retval.addr   := x(x'high downto x'high - index10 + 1);
    retval.size   := x(x'high - index10 downto x'high - index9 + 1);
    retval.burst  := x(x'high - index9  downto x'high - index8 + 1);
    retval.cache  := x(x'high - index8  downto x'high - index7 + 1);
    retval.prot   := x(x'high - index7  downto x'high - index6 + 1);
    retval.id     := x(x'high - index6  downto x'high - index5 + 1);
    retval.len    := x(x'high - index5  downto x'high - index4 + 1);
    retval.lock   := x(x'high - index4);
    retval.qos    := x(x'high - index3  downto x'high - index2 + 1);
    retval.region := x(x'high - index2  downto x'high - index1 + 1);
    retval.user   := x(x'high - index1  downto x'high - index0 + 1);
    return retval;
  end function;

  function axi_r_ser(x : axi_r_t) return std_logic_vector is
    variable retval : std_logic_vector(1 + x.data'length + x.resp'length + x.id'length + x.user'length - 1 downto 0);
  begin
    retval := x.last & x.data & x.resp & x.id & x.user;
    return retval;
  end function;
  function axi_r_des(x : std_logic_vector; conf : axi_config_t) return axi_r_t is
  begin
    return axi_r_t'(
    last => x(x'high), 
    data => x(x'high - 1 downto x'high - 1 - conf.data_width + 1), 
    resp => x(x'high - 1 - conf.data_width downto x'high - 1 - conf.data_width - 2 + 1), 
    id => x(conf.id_width + conf.user_width - 1 downto conf.user_width), 
    user => x(conf.user_width - 1 downto 0));
  end function;

end package body;
