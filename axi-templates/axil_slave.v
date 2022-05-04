`define FORMAL 

module axil_slave #(
  parameter axil_addr_width = 32,
  parameter axil_data_width = 32
)(
  input  wire s_axi_aclk,
  input  wire s_axi_aresetn,
  input  wire s_axi_awvalid,
  output wire s_axi_awready,
  input  wire [axil_addr_width-1:0]s_axi_awaddr,
  input  wire [2:0]s_axi_awprot, // ignore
  input  wire s_axi_wvalid,
  output wire s_axi_wready,
  input  wire [axil_data_width-1:0]s_axi_wdata,
  input  wire [$clog2(axil_data_width)-1:0]s_axi_wstrb,
  output reg s_axi_bvalid,
  input  wire s_axi_bready,
  output wire [1:0]s_axi_bresp,
  input  wire s_axi_arvalid,
  output wire s_axi_arready,
  input  wire [axil_addr_width-1:0]s_axi_araddr,
  input  wire [2:0]s_axi_arprot, // ignore
  output wire s_axi_rvalid,
  input  wire s_axi_rready,
  output wire [axil_data_width-1:0]s_axi_rdata,
  output wire [1:0]s_axi_rresp
);

// let's make the code somewhat readable
wire clk = s_axi_aclk;
wire rst = !s_axi_aresetn;

// sanity check
always assert((axil_data_width % 8) == 0);
wire awfire = s_axi_awvalid && s_axi_awready;
wire wfire = s_axi_wvalid && s_axi_wready;
wire bfire = s_axi_bvalid && s_axi_bready;
wire arfire = s_axi_arvalid && s_axi_arready;
wire rfire = s_axi_rvalid && s_axi_rready;

// response values
localparam OKAY   = 'b00;
localparam EXOKAY = 'b01;
localparam SLVERR = 'b10;
localparam DECERR = 'b11;

assign s_axi_bresp = OKAY;
assign s_axi_rresp = OKAY;

// write logic
reg [axil_addr_width-1:0]address_latched = 0;
wire [axil_addr_width-1:0]address = awfire ? s_axi_awaddr : address_latched;

reg awstate = 0;
reg wstate  = 0;
reg arstate = 0;
reg rstate  = 0;

reg [axil_addr_width-1:0] awaddr_l = 0;
wire [axil_addr_width-1:0] awaddr;

reg [axil_addr_width-1:0] araddr;

assign awaddr = (awfire && wfire) ? s_axi_awaddr : awaddr_l;

always @(posedge clk) begin
  if (awfire) begin
    awstate <= 1;
    awaddr_l <= s_axi_awaddr;
  end
  if (awstate && bfire) awstate <= 0;
end

// prevent protocol errors (this is against the spec)
//assign s_axi_wready = (s_axi_wvalid && !awfire) ? 0 : !awstate;

always @(posedge clk) begin
  if (wfire) begin
    wstate <= 1;
    // put write logic here, assert s_axi_bvalid when done and accordingly bresp
    s_axi_bvalid <= 1;
  end
  if (wstate && bfire) begin
    wstate <= 0;
    s_axi_bvalid <= 0;
  end
end

// todo : protocol error when there is a whandshake but no awhandshake at the
// same time or beforehand
assign s_axi_wready = s_axi_awready || (awstate && !wstate);

/* read logic */
// note that read logic is independent of write logic

assign s_axi_arready = !arstate;

always @(posedge clk) begin
  if (arfire) begin
    araddr <= s_axi_araddr;
    arstate <= 1;
    // put your read logic here
    // once you are done, assert rvalid 
  end
  if (rfire) arstate <= 0;
end

reg [31:0] tickcount = 0;
reg wfire_happened = 0;
reg f_past_valid = 0;
always @(posedge(clk)) f_past_valid <= 1;
always @(posedge(clk)) tickcount <= tickcount + 1;
always @(posedge(clk)) if (wfire) wfire_happened <= 1;

`ifdef FORMAL
  initial assume (rst);

 //     if ($rose(s_axi_awvalid)) assume($stable(s_axi_awvalid));
  reg awvalided = 0;
  always @(posedge clk) begin
    // this is in fact the least amount of logic required to say
    // "once awvalid is asserted, it must stay asserted until the handshake
    // occurs"
    // (including dealing with back to back transfers)
    if (s_axi_awvalid && !awfire) 
      awvalided <= 1;
    if (awvalided && awfire)
      awvalided <= 0;
    if (rst)
      awvalided <= 0;
    if (awvalided) assume(s_axi_awvalid);
  end

  reg wvalided = 0;
  always @(posedge clk) begin
    if (s_axi_wvalid && !wfire) 
      wvalided <= 1;
    if (wvalided && wfire)
      wvalided <= 0;
    if (rst)
      wvalided <= 0;
    if (wvalided) assume(s_axi_wvalid);
  end

  reg bvalided = 0;
  always @(posedge clk) begin
    if (s_axi_bvalid && !bfire) 
      bvalided <= 1;
    if (bvalided && bfire)
      bvalided <= 0;
    if (rst)
      bvalided <= 0;
    if (bvalided) assume(s_axi_bvalid);
  end

  reg arvalided = 0;
  always @(posedge clk) begin
    if (s_axi_arvalid && !arfire) 
      arvalided <= 1;
    if (arvalided && arfire)
      arvalided <= 0;
    if (rst)
      arvalided <= 0;
    if (arvalided) assume(s_axi_arvalid);
  end

  reg rvalided = 0;
  always @(posedge clk) begin
    if (s_axi_rvalid && !rfire) 
      rvalided <= 1;
    if (rvalided && rfire)
      rvalided <= 0;
    if (rst)
      rvalided <= 0;
    if (rvalided) assume(s_axi_rvalid);
  end

  // TODO: does this support back to back transactions?
  reg [15:0] arcnt,rcnt = 0;
  always @(posedge clk) begin
    if (arfire) arcnt <= arcnt + 1;
    if (rfire) rcnt <= rcnt + 1;
    if (rst) begin
      arcnt <= 0;
      rcnt <= 0;
    end
  end
  always @(posedge clk) if (done) assume (arcnt == rcnt);

  reg rvalidvalid = 0;
  always @(posedge clk) begin
    //if (arfire && !rfire) 
    //  rvalidvalid <= 1;
    //if (arcnt == rcnt)
    //  rvalidvalid <= 0;
    if (arcnt == rcnt) assume(!s_axi_rvalid);
    //assume (arcnt >= rcnt);
    //if (!rvalidvalid || arcnt == rcnt) assume(!s_axi_rvalid);
  end 

  reg [15:0] awcnt,wcnt,bcnt = 0;
  always @(posedge clk) begin
    if (awfire) awcnt <= awcnt + 1;
    if (wfire) wcnt <= wcnt + 1;
    if (bfire) bcnt <= bcnt + 1;
    if (rst) begin
      awcnt <= 0;
      wcnt <= 0;
      bcnt <= 0;
    end
  end
  always @(posedge clk) if (done) assume (wcnt == awcnt && wcnt == bcnt);
  always @(posedge clk) if (bcnt == wcnt) assume (!s_axi_bready);

  always @(posedge clk) if(f_past_valid) assume(!rst);

  reg done = 0;
  always @(posedge clk)
    if (!rst) begin
      done <= (tickcount == 30
      && $past(s_axi_awvalid && !s_axi_awready)
      && rcnt == 9
      && wcnt == 9);
      // Assumptions for master
      // A3-38
      // awvalid must stay asserted until awfire
      //if (($rose(s_axi_awvalid) || $past(s_axi_awvalid)) && !(awfire)) assume($stable(s_axi_awvalid));
      // A3-39
      // same for wvalid
 //     if (($rose(s_axi_wvalid) || $past(s_axi_wvalid)) && !(wfire)) assume($stable(s_axi_wvalid));
      // bvalid must stay assebted
//      if (($rose(s_axi_bvalid) || $past(s_axi_bvalid)) && !(bfire)) assume($stable(s_axi_bvalid));

      // wlast must be asserted on thei last beat of a burst
      //
      // arvalid must stay asserted
//      if (($rose(s_axi_arvalid) || $past(s_axi_arvalid)) && !(arfire)) assume($stable(s_axi_arvalid));
      // rvalid must stay asserted
//      if (($rose(s_axi_rvalid) || $past(s_axi_rvalid)) && !(rfire)) assume($stable(s_axi_rvalid));

      // rlast -> todo
    
      //cover property ($stable(!rst));
      cover property (done);
      //cover property (tickcount == 100 && $past(awfire) && awfire);
    end

`endif

endmodule
