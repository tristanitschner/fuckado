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
  output wire s_axi_bvalid,
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
assign s_axi_wready = (s_axi_wvalid && !awfire) ? 0 : !awstate;

always @(posedge clk) begin
  if (wfire) begin
    wstate <= 1;
    // put write logic here, assert s_axi_bvalid when done and accordingly bresp
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

endmodule
