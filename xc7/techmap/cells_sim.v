// ============================================================================
// Define FFs required by VPR

module FDRE_ZINI (output reg Q, input C, CE, D, R);
  parameter [0:0] ZINI = 1'b0;
  parameter [0:0] IS_C_INVERTED = 1'b0;
  initial Q <= !ZINI;
  generate case (|IS_C_INVERTED)
    1'b0: always @(posedge C) if (R) Q <= 1'b0; else if (CE) Q <= D;
    1'b1: always @(negedge C) if (R) Q <= 1'b0; else if (CE) Q <= D;
  endcase endgenerate
endmodule

module FDSE_ZINI (output reg Q, input C, CE, D, S);
  parameter [0:0] ZINI = 1'b0;
  parameter [0:0] IS_C_INVERTED = 1'b0;
  initial Q <= !ZINI;
  generate case (|IS_C_INVERTED)
    1'b0: always @(posedge C) if (S) Q <= 1'b1; else if (CE) Q <= D;
    1'b1: always @(negedge C) if (S) Q <= 1'b1; else if (CE) Q <= D;
  endcase endgenerate
endmodule

module FDCE_ZINI (output reg Q, input C, CE, D, CLR);
  parameter [0:0] ZINI = 1'b0;
  parameter [0:0] IS_C_INVERTED = 1'b0;
  initial Q <= !ZINI;
  generate case (|IS_C_INVERTED)
    1'b0: always @(posedge C, posedge CLR) if (CLR) Q <= 1'b0; else if (CE) Q <= D;
    1'b1: always @(negedge C, posedge CLR) if (CLR) Q <= 1'b0; else if (CE) Q <= D;
  endcase endgenerate
endmodule

module FDPE_ZINI (output reg Q, input C, CE, D, PRE);
  parameter [0:0] ZINI = 1'b0;
  parameter [0:0] IS_C_INVERTED = 1'b0;
  initial Q <= !ZINI;
  generate case (|IS_C_INVERTED)
    1'b0: always @(posedge C, posedge PRE) if (PRE) Q <= 1'b1; else if (CE) Q <= D;
    1'b1: always @(negedge C, posedge PRE) if (PRE) Q <= 1'b1; else if (CE) Q <= D;
  endcase endgenerate
endmodule

// ============================================================================
// LUT related muxes

module MUXF6(output O, input I0, I1, S);
  assign O = S ? I1 : I0;
endmodule

// ============================================================================
// Carry chain primitives

module CARRY0(output CO_CHAIN, CO_FABRIC, O, input CI, CI_INIT, DI, S);
  parameter CYINIT_FABRIC = 0;
  wire CI_COMBINE;
  if(CYINIT_FABRIC) begin
    assign CI_COMBINE = CI_INIT;
  end else begin
    assign CI_COMBINE = CI;
  end
  assign CO_CHAIN = S ? CI_COMBINE : DI;
  assign CO_FABRIC = S ? CI_COMBINE : DI;
  assign O = S ^ CI_COMBINE;
endmodule

module CARRY(output CO_CHAIN, CO_FABRIC, O, input CI, DI, S);
  assign CO_CHAIN = S ? CI : DI;
  assign CO_FABRIC = S ? CI : DI;
  assign O = S ^ CI;
endmodule

// ============================================================================
// Distributed RAMs

module DPRAM128 (
  output O6,
  input  DI1, CLK, WE, WA7,
  input [5:0] A, WA
);
  parameter [63:0] INIT = 64'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  parameter HIGH_WA7_SELECT = 1'b0;
  wire [5:0] A;
  wire [5:0] WA;
  reg [63:0] mem;
  initial mem <= INIT;
  assign O6 = mem[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;
  always @(posedge clk) if (WE & (WA7 == HIGH_WA7_SELECT)) mem[WA] <= DI1;
endmodule

module SPRAM128 (
  output O6,
  input  DI1, CLK, WE, WA7,
  input [5:0] A
);
  parameter [63:0] INIT = 64'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  parameter HIGH_WA7_SELECT = 1'b0;
  wire [5:0] A;
  reg [63:0] mem;
  initial mem <= INIT;
  assign O6 = mem[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;
  always @(posedge clk) if (WE & (WA7 == HIGH_WA7_SELECT)) mem[A] <= DI1;
endmodule

module DPRAM64 (
  output O6,
  input  DI1, CLK, WE, WA7, WA8,
  input [5:0] A, WA
);
  parameter [63:0] INIT = 64'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  parameter WA7USED = 1'b0;
  parameter WA8USED = 1'b0;
  parameter HIGH_WA7_SELECT = 1'b0;
  parameter HIGH_WA8_SELECT = 1'b0;
  wire [5:0] A;
  wire [5:0] WA;
  reg [63:0] mem;
  initial mem <= INIT;
  assign O6 = mem[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;

  wire WA7SELECT = !WA7USED | (WA7 == HIGH_WA7_SELECT);
  wire WA8SELECT = !WA8USED | (WA8 == HIGH_WA8_SELECT);
  wire address_selected = WA7SELECT & WA8SELECT;
  always @(posedge clk) if (WE & address_selected) mem[WA] <= DI1;
endmodule

module SPRAM64 (
  output O6,
  input  DI1, CLK, WE, WA7, WA8,
  input [5:0] A
);
  parameter [63:0] INIT = 64'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  parameter WA7USED = 1'b0;
  parameter WA8USED = 1'b0;
  parameter HIGH_WA7_SELECT = 1'b0;
  parameter HIGH_WA8_SELECT = 1'b0;
  wire [5:0] A;
  reg [63:0] mem;
  initial mem <= INIT;
  assign O6 = mem[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;

  wire WA7SELECT = !WA7USED | (WA7 == HIGH_WA7_SELECT);
  wire WA8SELECT = !WA8USED | (WA8 == HIGH_WA8_SELECT);
  wire address_selected = WA7SELECT & WA8SELECT;
  always @(posedge clk) if (WE & address_selected) mem[A] <= DI1;
endmodule

module DPRAM32 (
  output O6, O5,
  input  DI1, DI2, CLK, WE,
  input [4:0] A, WA
);
  parameter [31:0] INIT_00 = 32'h0;
  parameter [31:0] INIT_01 = 32'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  wire [4:0] A;
  wire [4:0] WA;
  reg [31:0] mem1;
  reg [31:0] mem2;
  initial mem1 <= INIT_00;
  initial mem2 <= INIT_01;
  assign O6 = mem1[A];
  assign O5 = mem2[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;
  always @(posedge clk) if (WE) begin
    mem1[WA] <= DI1;
    mem2[WA] <= DI2;
  end
endmodule

module SPRAM32 (
  output O6, O5,
  input  DI1, DI2, CLK, WE,
  input [4:0] A
);
  parameter [31:0] INIT_00 = 32'h0;
  parameter [31:0] INIT_01 = 32'h0;
  parameter IS_WCLK_INVERTED = 1'b0;
  wire [4:0] A;
  reg [31:0] mem1;
  reg [31:0] mem2;
  initial mem1 <= INIT_00;
  initial mem2 <= INIT_01;
  assign O6 = mem1[A];
  assign O5 = mem2[A];
  wire clk = CLK ^ IS_WCLK_INVERTED;
  always @(posedge clk) if (WE) begin
    mem1[A] <= DI1;
    mem2[A] <= DI2;
  end
endmodule


// To ensure that all DRAMs are co-located within a SLICEM, this block is
// a simple passthrough black box to allow a pack pattern for dual port DRAMs.
module DRAM_2_OUTPUT_STUB(
    input SPO, DPO,
    output SPO_OUT, DPO_OUT
);
  wire SPO_OUT;
  wire DPO_OUT;
  assign SPO_OUT = SPO;
  assign DPO_OUT = DPO;
endmodule

module DRAM_4_OUTPUT_STUB(
    input DOA, DOB, DOC, DOD,
    output DOA_OUT, DOB_OUT, DOC_OUT, DOD_OUT
);
  assign DOA_OUT = DOA;
  assign DOB_OUT = DOB;
  assign DOC_OUT = DOC;
  assign DOD_OUT = DOD;
endmodule

// ============================================================================
// Block RAMs

module RAMB18E1_VPR (
	input CLKARDCLK,
	input CLKBWRCLK,
	input ENARDEN,
	input ENBWREN,
	input REGCLKARDRCLK,
	input REGCEAREGCE,
	input REGCEB,
	input REGCLKB,
	input RSTRAMARSTRAM,
	input RSTRAMB,
	input RSTREGARSTREG,
	input RSTREGB,

	input [1:0]  ADDRBTIEHIGH,
	input [13:0] ADDRBWRADDR,
	input [1:0]  ADDRATIEHIGH,
	input [13:0] ADDRARDADDR,
	input [15:0] DIADI,
	input [15:0] DIBDI,
	input [1:0] DIPADIP,
	input [1:0] DIPBDIP,
	input [3:0] WEA,
	input [7:0] WEBWE,

	output [15:0] DOADO,
	output [15:0] DOBDO,
	output [1:0] DOPADOP,
	output [1:0] DOPBDOP
);
	parameter IN_USE = 1'b0;

	parameter ZINIT_A = 18'h0;
	parameter ZINIT_B = 18'h0;

	parameter ZSRVAL_A = 18'h0;
	parameter ZSRVAL_B = 18'h0;

	parameter INITP_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INITP_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter INIT_00 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_01 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_02 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_03 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_04 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_05 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_06 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_07 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_08 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_09 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_0F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_10 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_11 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_12 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_13 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_14 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_15 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_16 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_17 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_18 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_19 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_1F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_20 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_21 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_22 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_23 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_24 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_25 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_26 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_27 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_28 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_29 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_2F = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_30 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_31 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_32 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_33 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_34 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_35 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_36 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_37 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_38 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_39 = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3A = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3B = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3C = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3D = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3E = 256'h0000000000000000000000000000000000000000000000000000000000000000;
	parameter INIT_3F = 256'h0000000000000000000000000000000000000000000000000000000000000000;

	parameter ZINV_CLKARDCLK = 1'b1;
	parameter ZINV_CLKBWRCLK = 1'b1;
	parameter ZINV_ENARDEN = 1'b1;
	parameter ZINV_ENBWREN = 1'b1;
	parameter ZINV_RSTRAMARSTRAM = 1'b1;
	parameter ZINV_RSTRAMB = 1'b1;
	parameter ZINV_RSTREGARSTREG = 1'b1;
	parameter ZINV_RSTREGB = 1'b1;
	parameter ZINV_REGCLKARDRCLK = 1'b1;
	parameter ZINV_REGCLKB = 1'b1;

	parameter DOA_REG = 1'b0;
	parameter DOB_REG = 1'b0;

	parameter integer SDP_READ_WIDTH_36 = 1'b0;
	parameter integer READ_WIDTH_A_18 = 1'b0;
	parameter integer READ_WIDTH_A_9 = 1'b0;
	parameter integer READ_WIDTH_A_4 = 1'b0;
	parameter integer READ_WIDTH_A_2 = 1'b0;
	parameter integer READ_WIDTH_A_1 = 1'b1;
	parameter integer READ_WIDTH_B_18 = 1'b0;
	parameter integer READ_WIDTH_B_9 = 1'b0;
	parameter integer READ_WIDTH_B_4 = 1'b0;
	parameter integer READ_WIDTH_B_2 = 1'b0;
	parameter integer READ_WIDTH_B_1 = 1'b1;

	parameter integer SDP_WRITE_WIDTH_36 = 1'b0;
	parameter integer WRITE_WIDTH_A_18 = 1'b0;
	parameter integer WRITE_WIDTH_A_9 = 1'b0;
	parameter integer WRITE_WIDTH_A_4 = 1'b0;
	parameter integer WRITE_WIDTH_A_2 = 1'b0;
	parameter integer WRITE_WIDTH_A_1 = 1'b1;
	parameter integer WRITE_WIDTH_B_18 = 1'b0;
	parameter integer WRITE_WIDTH_B_9 = 1'b0;
	parameter integer WRITE_WIDTH_B_4 = 1'b0;
	parameter integer WRITE_WIDTH_B_2 = 1'b0;
	parameter integer WRITE_WIDTH_B_1 = 1'b1;

	parameter WRITE_MODE_A_NO_CHANGE = 1'b0;
	parameter WRITE_MODE_A_READ_FIRST = 1'b0;
	parameter WRITE_MODE_B_NO_CHANGE = 1'b0;
	parameter WRITE_MODE_B_READ_FIRST = 1'b0;
endmodule
