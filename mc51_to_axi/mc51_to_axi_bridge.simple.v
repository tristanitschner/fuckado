module mc51_to_axi_bridge
  (input  m_axi_clk,
   input  m_axi_resetn,
   input  m_axi_awready,
   input  m_axi_wready,
   input  [1:0] m_axi_bresp,
   input  m_axi_bvalid,
   input  m_axi_arready,
   input  [31:0] m_axi_rdata,
   input  [1:0] m_axi_rresp,
   input  m_axi_rvalid,
   input  [3:0] m_axi_rid,
   input  m_axi_rlast,
   input  [3:0] s_mb_addr,
   input  [7:0] s_mb_wrdata,
   input  s_mb_we,
   input  cs,
   output [31:0] m_axi_awaddr,
   output [2:0] m_axi_awprot,
   output m_axi_awvalid,
   output [31:0] m_axi_wdata,
   output [3:0] m_axi_wstrb,
   output m_axi_wvalid,
   output m_axi_bready,
   output [31:0] m_axi_araddr,
   output [2:0] m_axi_arprot,
   output m_axi_arvalid,
   output m_axi_rready,
   output [3:0] m_axi_arid,
   output [7:0] m_axi_arlen,
   output [2:0] m_axi_arsize,
   output [1:0] m_axi_arburst,
   output m_axi_arlock,
   output [3:0] m_axi_arcache,
   output [3:0] m_axi_awid,
   output [7:0] m_axi_awlen,
   output [2:0] m_axi_awsize,
   output [1:0] m_axi_awburst,
   output m_axi_awlock,
   output m_axi_wlast,
   output [3:0] m_axi_awcache,
   output [7:0] s_mb_rddata);
  wire [135:0] registers;
  wire start_write;
  wire start_read;
  wire [31:0] addr;
  wire [31:0] wdata;
  reg [1:0] state;
  wire n31_o;
  wire n32_o;
  wire [7:0] n34_o;
  wire [7:0] n35_o;
  wire [15:0] n36_o;
  wire [7:0] n37_o;
  wire [23:0] n38_o;
  wire [7:0] n39_o;
  wire [31:0] n40_o;
  wire [7:0] n41_o;
  wire [7:0] n42_o;
  wire [15:0] n43_o;
  wire [7:0] n44_o;
  wire [23:0] n45_o;
  wire [7:0] n46_o;
  wire [31:0] n47_o;
  localparam [3:0] n48_o = 4'b0000;
  localparam [3:0] n49_o = 4'b0000;
  localparam [2:0] n50_o = 3'b000;
  localparam [2:0] n51_o = 3'b000;
  localparam n52_o = 1'b0;
  localparam n53_o = 1'b0;
  localparam [2:0] n56_o = 3'b101;
  localparam [2:0] n59_o = 3'b101;
  localparam [3:0] n60_o = 4'b1111;
  localparam [3:0] n61_o = 4'b1111;
  localparam [1:0] n62_o = 2'b01;
  localparam [1:0] n63_o = 2'b01;
  localparam n64_o = 1'b1;
  localparam [7:0] n65_o = 8'b00000000;
  localparam [7:0] n66_o = 8'b00000000;
  localparam n67_o = 1'b1;
  localparam [3:0] n68_o = 4'b1111;
  wire n72_o;
  wire n73_o;
  wire [30:0] n79_o;
  wire [4:0] n81_o;
  wire n85_o;
  wire n87_o;
  wire n89_o;
  wire n91_o;
  wire n94_o;
  wire n96_o;
  wire [1:0] n98_o;
  wire n99_o;
  wire n100_o;
  wire n102_o;
  wire n104_o;
  wire [1:0] n106_o;
  wire n108_o;
  wire n110_o;
  wire [7:0] n111_o;
  wire [7:0] n112_o;
  wire [7:0] n113_o;
  wire [7:0] n114_o;
  wire n117_o;
  wire [31:0] n118_o;
  wire n119_o;
  wire n120_o;
  wire [31:0] n121_o;
  wire [31:0] n122_o;
  wire [1:0] n124_o;
  wire n126_o;
  wire n128_o;
  wire n131_o;
  wire n132_o;
  wire n133_o;
  wire [1:0] n135_o;
  wire n137_o;
  wire [2:0] n138_o;
  reg n139_o;
  reg n140_o;
  reg n141_o;
  reg n142_o;
  wire n143_o;
  wire n144_o;
  reg n145_o;
  wire [6:0] n146_o;
  wire [6:0] n147_o;
  reg [6:0] n148_o;
  wire n149_o;
  wire n150_o;
  reg n151_o;
  wire [54:0] n152_o;
  wire [54:0] n153_o;
  reg [54:0] n154_o;
  wire [31:0] n155_o;
  wire [31:0] n156_o;
  reg [31:0] n157_o;
  wire [39:0] n158_o;
  wire [39:0] n159_o;
  reg [39:0] n160_o;
  reg [1:0] n161_o;
  wire n162_o;
  wire n163_o;
  wire n164_o;
  wire n165_o;
  wire [135:0] n166_o;
  wire [135:0] n168_o;
  wire [1:0] n169_o;
  reg n177_q;
  reg n178_q;
  reg n179_q;
  reg n180_q;
  reg [135:0] n181_q;
  reg [1:0] n182_q;
  wire [30:0] n188_o;
  wire [4:0] n190_o;
  wire [7:0] n193_o;
  wire n195_o;
  wire n196_o;
  wire n197_o;
  wire n198_o;
  wire n199_o;
  wire n200_o;
  wire n201_o;
  wire n202_o;
  wire n203_o;
  wire n204_o;
  wire n205_o;
  wire n206_o;
  wire n207_o;
  wire n208_o;
  wire n209_o;
  wire n210_o;
  wire n211_o;
  wire n212_o;
  wire n213_o;
  wire n214_o;
  wire n215_o;
  wire n216_o;
  wire n217_o;
  wire n218_o;
  wire n219_o;
  wire n220_o;
  wire n221_o;
  wire n222_o;
  wire n223_o;
  wire n224_o;
  wire n225_o;
  wire n226_o;
  wire n227_o;
  wire n228_o;
  wire n229_o;
  wire n230_o;
  wire n231_o;
  wire n232_o;
  wire n233_o;
  wire n234_o;
  wire n235_o;
  wire n236_o;
  wire n237_o;
  wire n238_o;
  wire [7:0] n239_o;
  wire n240_o;
  wire [7:0] n241_o;
  wire [7:0] n242_o;
  wire n243_o;
  wire [7:0] n244_o;
  wire [7:0] n245_o;
  wire n246_o;
  wire [7:0] n247_o;
  wire [7:0] n248_o;
  wire n249_o;
  wire [7:0] n250_o;
  wire [7:0] n251_o;
  wire n252_o;
  wire [7:0] n253_o;
  wire [7:0] n254_o;
  wire n255_o;
  wire [7:0] n256_o;
  wire [7:0] n257_o;
  wire n258_o;
  wire [7:0] n259_o;
  wire [7:0] n260_o;
  wire n261_o;
  wire [7:0] n262_o;
  wire [7:0] n263_o;
  wire n264_o;
  wire [7:0] n265_o;
  wire [7:0] n266_o;
  wire n267_o;
  wire [7:0] n268_o;
  wire [7:0] n269_o;
  wire n270_o;
  wire [7:0] n271_o;
  wire [7:0] n272_o;
  wire n273_o;
  wire [7:0] n274_o;
  wire [7:0] n275_o;
  wire n276_o;
  wire [7:0] n277_o;
  wire [7:0] n278_o;
  wire n279_o;
  wire [7:0] n280_o;
  wire [7:0] n281_o;
  wire n282_o;
  wire [7:0] n283_o;
  wire [7:0] n284_o;
  wire n285_o;
  wire [7:0] n286_o;
  wire [7:0] n287_o;
  wire n288_o;
  wire [7:0] n289_o;
  wire [135:0] n290_o;
  wire [7:0] n291_o;
  wire [7:0] n292_o;
  wire [7:0] n293_o;
  wire [7:0] n294_o;
  wire [7:0] n295_o;
  wire [7:0] n296_o;
  wire [7:0] n297_o;
  wire [7:0] n298_o;
  wire [7:0] n299_o;
  wire [7:0] n300_o;
  wire [7:0] n301_o;
  wire [7:0] n302_o;
  wire [7:0] n303_o;
  wire [7:0] n304_o;
  wire [7:0] n305_o;
  wire [7:0] n306_o;
  wire [7:0] n307_o;
  wire [1:0] n308_o;
  reg [7:0] n309_o;
  wire [1:0] n310_o;
  reg [7:0] n311_o;
  wire [1:0] n312_o;
  reg [7:0] n313_o;
  wire [1:0] n314_o;
  reg [7:0] n315_o;
  wire [1:0] n316_o;
  reg [7:0] n317_o;
  wire n318_o;
  wire [7:0] n319_o;
  assign m_axi_awaddr = addr;
  assign m_axi_awprot = n50_o;
  assign m_axi_awvalid = n177_q;
  assign m_axi_wdata = wdata;
  assign m_axi_wstrb = n68_o;
  assign m_axi_wvalid = n178_q;
  assign m_axi_bready = n64_o;
  assign m_axi_araddr = addr;
  assign m_axi_arprot = n51_o;
  assign m_axi_arvalid = n179_q;
  assign m_axi_rready = n180_q;
  assign m_axi_arid = n48_o;
  assign m_axi_arlen = n65_o;
  assign m_axi_arsize = n59_o;
  assign m_axi_arburst = n63_o;
  assign m_axi_arlock = n52_o;
  assign m_axi_arcache = n60_o;
  assign m_axi_awid = n49_o;
  assign m_axi_awlen = n66_o;
  assign m_axi_awsize = n56_o;
  assign m_axi_awburst = n62_o;
  assign m_axi_awlock = n53_o;
  assign m_axi_wlast = n67_o;
  assign m_axi_awcache = n61_o;
  assign s_mb_rddata = n193_o;
  /* mc51_to_axi_bridge.vhd:98:10  */
  assign registers = n181_q; // (signal)
  /* mc51_to_axi_bridge.vhd:100:10  */
  assign start_write = n31_o; // (signal)
  /* mc51_to_axi_bridge.vhd:101:10  */
  assign start_read = n32_o; // (signal)
  /* mc51_to_axi_bridge.vhd:104:10  */
  assign addr = n40_o; // (signal)
  /* mc51_to_axi_bridge.vhd:105:10  */
  assign wdata = n47_o; // (signal)
  /* mc51_to_axi_bridge.vhd:108:10  */
  always @*
    state = n182_q; // (isignal)
  initial
    state <= 2'b00;
  /* mc51_to_axi_bridge.vhd:114:30  */
  assign n31_o = registers[0];
  /* mc51_to_axi_bridge.vhd:115:29  */
  assign n32_o = registers[8];
  /* mc51_to_axi_bridge.vhd:119:12  */
  assign n34_o = registers[63:56];
  /* mc51_to_axi_bridge.vhd:120:12  */
  assign n35_o = registers[55:48];
  /* mc51_to_axi_bridge.vhd:119:16  */
  assign n36_o = {n34_o, n35_o};
  /* mc51_to_axi_bridge.vhd:121:12  */
  assign n37_o = registers[47:40];
  /* mc51_to_axi_bridge.vhd:120:16  */
  assign n38_o = {n36_o, n37_o};
  /* mc51_to_axi_bridge.vhd:122:12  */
  assign n39_o = registers[39:32];
  /* mc51_to_axi_bridge.vhd:121:16  */
  assign n40_o = {n38_o, n39_o};
  /* mc51_to_axi_bridge.vhd:125:12  */
  assign n41_o = registers[127:120];
  /* mc51_to_axi_bridge.vhd:126:12  */
  assign n42_o = registers[119:112];
  /* mc51_to_axi_bridge.vhd:125:17  */
  assign n43_o = {n41_o, n42_o};
  /* mc51_to_axi_bridge.vhd:127:12  */
  assign n44_o = registers[111:104];
  /* mc51_to_axi_bridge.vhd:126:17  */
  assign n45_o = {n43_o, n44_o};
  /* mc51_to_axi_bridge.vhd:128:12  */
  assign n46_o = registers[103:96];
  /* mc51_to_axi_bridge.vhd:127:17  */
  assign n47_o = {n45_o, n46_o};
  /* mc51_to_axi_bridge.vhd:165:10  */
  assign n72_o = ~m_axi_resetn;
  /* mc51_to_axi_bridge.vhd:170:19  */
  assign n73_o = cs & s_mb_we;
  /* mc51_to_axi_bridge.vhd:93:12  */
  assign n79_o = {27'b0, s_mb_addr};  //  uext
  /* mc51_to_axi_bridge.vhd:171:24  */
  assign n81_o = n79_o[4:0];  // trunc
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n85_o = n73_o ? 1'b0 : n177_q;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n87_o = n73_o ? 1'b0 : n178_q;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n89_o = n73_o ? 1'b0 : n179_q;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n91_o = n73_o ? 1'b0 : n180_q;
  /* mc51_to_axi_bridge.vhd:181:13  */
  assign n94_o = start_write ? 1'b1 : n85_o;
  /* mc51_to_axi_bridge.vhd:181:13  */
  assign n96_o = start_write ? 1'b1 : n87_o;
  /* mc51_to_axi_bridge.vhd:181:13  */
  assign n98_o = start_write ? 2'b01 : state;
  /* mc51_to_axi_bridge.vhd:177:13  */
  assign n99_o = start_read ? n85_o : n94_o;
  /* mc51_to_axi_bridge.vhd:177:13  */
  assign n100_o = start_read ? n87_o : n96_o;
  /* mc51_to_axi_bridge.vhd:177:13  */
  assign n102_o = start_read ? 1'b1 : n89_o;
  /* mc51_to_axi_bridge.vhd:177:13  */
  assign n104_o = start_read ? 1'b1 : n91_o;
  /* mc51_to_axi_bridge.vhd:177:13  */
  assign n106_o = start_read ? 2'b10 : n98_o;
  /* mc51_to_axi_bridge.vhd:169:11  */
  assign n108_o = state == 2'b00;
  /* mc51_to_axi_bridge.vhd:187:13  */
  assign n110_o = m_axi_arready ? 1'b0 : n179_q;
  /* mc51_to_axi_bridge.vhd:191:43  */
  assign n111_o = m_axi_rdata[31:24];
  /* mc51_to_axi_bridge.vhd:192:43  */
  assign n112_o = m_axi_rdata[23:16];
  /* mc51_to_axi_bridge.vhd:193:43  */
  assign n113_o = m_axi_rdata[15:8];
  /* mc51_to_axi_bridge.vhd:194:43  */
  assign n114_o = m_axi_rdata[7:0];
  /* mc51_to_axi_bridge.vhd:190:13  */
  assign n117_o = m_axi_rvalid ? 1'b0 : n180_q;
  assign n118_o = {n111_o, n112_o, n113_o, n114_o};
  assign n119_o = registers[8];
  /* mc51_to_axi_bridge.vhd:190:13  */
  assign n120_o = m_axi_rvalid ? 1'b0 : n119_o;
  assign n121_o = registers[95:64];
  /* mc51_to_axi_bridge.vhd:190:13  */
  assign n122_o = m_axi_rvalid ? n118_o : n121_o;
  /* mc51_to_axi_bridge.vhd:190:13  */
  assign n124_o = m_axi_rvalid ? 2'b00 : state;
  /* mc51_to_axi_bridge.vhd:186:11  */
  assign n126_o = state == 2'b10;
  /* mc51_to_axi_bridge.vhd:200:15  */
  assign n128_o = m_axi_awready ? 1'b0 : n177_q;
  /* mc51_to_axi_bridge.vhd:203:15  */
  assign n131_o = m_axi_wready ? 1'b1 : n178_q;
  assign n132_o = registers[0];
  /* mc51_to_axi_bridge.vhd:203:15  */
  assign n133_o = m_axi_wready ? 1'b0 : n132_o;
  /* mc51_to_axi_bridge.vhd:203:15  */
  assign n135_o = m_axi_wready ? 2'b00 : state;
  /* mc51_to_axi_bridge.vhd:199:11  */
  assign n137_o = state == 2'b01;
  assign n138_o = {n137_o, n126_o, n108_o};
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n139_o <= n128_o;
      3'b010: n139_o <= n177_q;
      3'b001: n139_o <= n99_o;
    endcase
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n140_o <= n131_o;
      3'b010: n140_o <= n178_q;
      3'b001: n140_o <= n100_o;
    endcase
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n141_o <= n179_q;
      3'b010: n141_o <= n110_o;
      3'b001: n141_o <= n102_o;
    endcase
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n142_o <= n180_q;
      3'b010: n142_o <= n117_o;
      3'b001: n142_o <= n104_o;
    endcase
  assign n143_o = n290_o[0];
  assign n144_o = registers[0];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n145_o <= n133_o;
      3'b010: n145_o <= n144_o;
      3'b001: n145_o <= n143_o;
    endcase
  assign n146_o = n290_o[7:1];
  assign n147_o = registers[7:1];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n148_o <= n147_o;
      3'b010: n148_o <= n147_o;
      3'b001: n148_o <= n146_o;
    endcase
  assign n149_o = n290_o[8];
  assign n150_o = registers[8];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n151_o <= n150_o;
      3'b010: n151_o <= n120_o;
      3'b001: n151_o <= n149_o;
    endcase
  assign n152_o = n290_o[63:9];
  assign n153_o = registers[63:9];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n154_o <= n153_o;
      3'b010: n154_o <= n153_o;
      3'b001: n154_o <= n152_o;
    endcase
  assign n155_o = n290_o[95:64];
  assign n156_o = registers[95:64];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n157_o <= n156_o;
      3'b010: n157_o <= n122_o;
      3'b001: n157_o <= n155_o;
    endcase
  assign n158_o = n290_o[135:96];
  assign n159_o = registers[135:96];
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n160_o <= n159_o;
      3'b010: n160_o <= n159_o;
      3'b001: n160_o <= n158_o;
    endcase
  /* mc51_to_axi_bridge.vhd:168:9  */
  always @*
    case (n138_o)
      3'b100: n161_o <= n135_o;
      3'b010: n161_o <= n124_o;
      3'b001: n161_o <= n106_o;
    endcase
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n162_o = n72_o ? n177_q : n139_o;
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n163_o = n72_o ? n178_q : n140_o;
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n164_o = n72_o ? n179_q : n141_o;
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n165_o = n72_o ? n180_q : n142_o;
  assign n166_o = {n160_o, n157_o, n154_o, n151_o, n148_o, n145_o};
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n168_o = n72_o ? 136'b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000 : n166_o;
  /* mc51_to_axi_bridge.vhd:165:7  */
  assign n169_o = n72_o ? state : n161_o;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n177_q <= n162_o;
  initial
    n177_q <= 1'b0;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n178_q <= n163_o;
  initial
    n178_q <= 1'b0;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n179_q <= n164_o;
  initial
    n179_q <= 1'b0;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n180_q <= n165_o;
  initial
    n180_q <= 1'b0;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n181_q <= n168_o;
  /* mc51_to_axi_bridge.vhd:164:5  */
  always @(posedge m_axi_clk)
    n182_q <= n169_o;
  initial
    n182_q <= 2'b00;
  /* mc51_to_axi_bridge.vhd:93:12  */
  assign n188_o = {27'b0, s_mb_addr};  //  uext
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n190_o = n188_o[4:0];  // trunc
  /* mc51_to_axi_bridge.vhd:215:46  */
  assign n193_o = cs ? n319_o : 8'b00000000;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n195_o = n81_o[4];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n196_o = ~n195_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n197_o = n81_o[3];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n198_o = ~n197_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n199_o = n196_o & n198_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n200_o = n196_o & n197_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n201_o = n195_o & n198_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n202_o = n81_o[2];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n203_o = ~n202_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n204_o = n199_o & n203_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n205_o = n199_o & n202_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n206_o = n200_o & n203_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n207_o = n200_o & n202_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n208_o = n201_o & n203_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n209_o = n81_o[1];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n210_o = ~n209_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n211_o = n204_o & n210_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n212_o = n204_o & n209_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n213_o = n205_o & n210_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n214_o = n205_o & n209_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n215_o = n206_o & n210_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n216_o = n206_o & n209_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n217_o = n207_o & n210_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n218_o = n207_o & n209_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n219_o = n208_o & n210_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n220_o = n81_o[0];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n221_o = ~n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n222_o = n211_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n223_o = n211_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n224_o = n212_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n225_o = n212_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n226_o = n213_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n227_o = n213_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n228_o = n214_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n229_o = n214_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n230_o = n215_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n231_o = n215_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n232_o = n216_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n233_o = n216_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n234_o = n217_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n235_o = n217_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n236_o = n218_o & n221_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n237_o = n218_o & n220_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n238_o = n219_o & n221_o;
  assign n239_o = registers[7:0];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n240_o = n222_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n241_o = n240_o ? s_mb_wrdata : n239_o;
  assign n242_o = registers[15:8];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n243_o = n223_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n244_o = n243_o ? s_mb_wrdata : n242_o;
  assign n245_o = registers[23:16];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n246_o = n224_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n247_o = n246_o ? s_mb_wrdata : n245_o;
  assign n248_o = registers[31:24];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n249_o = n225_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n250_o = n249_o ? s_mb_wrdata : n248_o;
  assign n251_o = registers[39:32];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n252_o = n226_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n253_o = n252_o ? s_mb_wrdata : n251_o;
  assign n254_o = registers[47:40];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n255_o = n227_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n256_o = n255_o ? s_mb_wrdata : n254_o;
  assign n257_o = registers[55:48];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n258_o = n228_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n259_o = n258_o ? s_mb_wrdata : n257_o;
  assign n260_o = registers[63:56];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n261_o = n229_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n262_o = n261_o ? s_mb_wrdata : n260_o;
  assign n263_o = registers[71:64];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n264_o = n230_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n265_o = n264_o ? s_mb_wrdata : n263_o;
  assign n266_o = registers[79:72];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n267_o = n231_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n268_o = n267_o ? s_mb_wrdata : n266_o;
  assign n269_o = registers[87:80];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n270_o = n232_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n271_o = n270_o ? s_mb_wrdata : n269_o;
  assign n272_o = registers[95:88];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n273_o = n233_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n274_o = n273_o ? s_mb_wrdata : n272_o;
  assign n275_o = registers[103:96];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n276_o = n234_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n277_o = n276_o ? s_mb_wrdata : n275_o;
  assign n278_o = registers[111:104];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n279_o = n235_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n280_o = n279_o ? s_mb_wrdata : n278_o;
  assign n281_o = registers[119:112];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n282_o = n236_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n283_o = n282_o ? s_mb_wrdata : n281_o;
  assign n284_o = registers[127:120];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n285_o = n237_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n286_o = n285_o ? s_mb_wrdata : n284_o;
  assign n287_o = registers[135:128];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n288_o = n238_o & n73_o;
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n289_o = n288_o ? s_mb_wrdata : n287_o;
  assign n290_o = {n289_o, n286_o, n283_o, n280_o, n277_o, n274_o, n271_o, n268_o, n265_o, n262_o, n259_o, n256_o, n253_o, n250_o, n247_o, n244_o, n241_o};
  /* mc51_to_axi_bridge.vhd:171:25  */
  assign n291_o = registers[7:0];
  /* mc51_to_axi_bridge.vhd:170:13  */
  assign n292_o = registers[15:8];
  assign n293_o = registers[23:16];
  assign n294_o = registers[31:24];
  assign n295_o = registers[39:32];
  assign n296_o = registers[47:40];
  assign n297_o = registers[55:48];
  assign n298_o = registers[63:56];
  assign n299_o = registers[71:64];
  assign n300_o = registers[79:72];
  assign n301_o = registers[87:80];
  assign n302_o = registers[95:88];
  assign n303_o = registers[103:96];
  assign n304_o = registers[111:104];
  assign n305_o = registers[119:112];
  assign n306_o = registers[127:120];
  assign n307_o = registers[135:128];
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n308_o = n190_o[1:0];
  /* mc51_to_axi_bridge.vhd:215:27  */
  always @*
    case (n308_o)
      2'b00: n309_o <= n291_o;
      2'b01: n309_o <= n292_o;
      2'b10: n309_o <= n293_o;
      2'b11: n309_o <= n294_o;
    endcase
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n310_o = n190_o[1:0];
  /* mc51_to_axi_bridge.vhd:215:27  */
  always @*
    case (n310_o)
      2'b00: n311_o <= n295_o;
      2'b01: n311_o <= n296_o;
      2'b10: n311_o <= n297_o;
      2'b11: n311_o <= n298_o;
    endcase
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n312_o = n190_o[1:0];
  /* mc51_to_axi_bridge.vhd:215:27  */
  always @*
    case (n312_o)
      2'b00: n313_o <= n299_o;
      2'b01: n313_o <= n300_o;
      2'b10: n313_o <= n301_o;
      2'b11: n313_o <= n302_o;
    endcase
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n314_o = n190_o[1:0];
  /* mc51_to_axi_bridge.vhd:215:27  */
  always @*
    case (n314_o)
      2'b00: n315_o <= n303_o;
      2'b01: n315_o <= n304_o;
      2'b10: n315_o <= n305_o;
      2'b11: n315_o <= n306_o;
    endcase
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n316_o = n190_o[3:2];
  /* mc51_to_axi_bridge.vhd:215:27  */
  always @*
    case (n316_o)
      2'b00: n317_o <= n309_o;
      2'b01: n317_o <= n311_o;
      2'b10: n317_o <= n313_o;
      2'b11: n317_o <= n315_o;
    endcase
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n318_o = n190_o[4];
  /* mc51_to_axi_bridge.vhd:215:27  */
  assign n319_o = n318_o ? n307_o : n317_o;
endmodule

