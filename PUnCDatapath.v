//==============================================================================
// Datapath for PUnC LC3 Processor
//==============================================================================

`include "Memory.v"
`include "RegisterFile.v"
`include "Defines.v"

module PUnCDatapath(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// DEBUG Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data,

	// Add more ports here
	input wire 			pc_ld,
	input wire 			pc_clr,
	input wire 			pc_inc,
	input wire [1:0] 	pc_sel,

	input wire 			ir_ld,
	input wire 			ir_clr,

	input wire 			mem_rd,
	input wire 			mem_wr,
	input wire [1:0] 	mem_r_addr_sel,
	input wire [1:0] 	mem_w_addr_sel,

	input wire [1:0] 	rf_w_data_sel,
	input wire 			rf_w_addr_sel,
	input wire 			rf_w_wr,
	
	input wire 			rf_rp_addr_sel,
	input wire 			rf_rp_rd,
	input wire 			rf_rq_rd,

	input wire 			temp_ld,

	input wire 			nzp_ld,
	input wire 			nzp_clr,

	input wire [1:0] 	alu_sel,
	input wire 			alu_first_val_sel,

	output wire 		nzp_true,
	output wire [15:0] 	ir_to_controller

);

	// Local Registers
	reg  [15:0] pc;
	reg  [15:0] ir;
	assign ir_to_controller = ir;

	reg  	[15:0] 		pc_w_data;

	reg 	[15:0]		ir_sext_10_0;
	reg 	[15:0]		ir_sext_8_0;
	reg 	[15:0]		ir_sext_5_0;
	reg 	[15:0] 		ir_sext_4_0;

	reg 	[15:0] 		temp;

	reg 	[15:0] 		mem_r_addr;
	reg 	[15:0] 		mem_w_addr;
	wire 	[15:0] 		mem_r_data;

	reg 	[2:0] 		rf_w_addr;
	reg 	[15:0]		rf_w_data;
	reg 	[2:0]		rf_rp_addr;
	wire 	[15:0]		rf_rp_data;
	wire 	[15:0]		rf_rq_data;

	reg n;	
	reg z; 
	reg p;
	assign nzp_true = (ir[11] & n) | (ir[10] & z) | (ir[9] & p);
  
	reg [15:0] alu_first_val;
	reg [15:0] alu_out;


	// Declare other local wires and registers here

	// Assign PC debug net
	assign pc_debug_data = pc;


	//----------------------------------------------------------------------
	// Memory Module
	//----------------------------------------------------------------------

	// 1024-entry 16-bit memory (connect other ports)
	Memory mem(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (mem_r_addr),
		.r_addr_1 (mem_debug_addr),
		.w_addr   (mem_w_addr),
		.w_data   (rf_rp_data),
		.w_en     (mem_wr),
		.r_data_0 (mem_r_data),
		.r_data_1 (mem_debug_data)
	);

	//----------------------------------------------------------------------
	// Register File Module
	//----------------------------------------------------------------------

	// 8-entry 16-bit register file (connect other ports)
	RegisterFile rfile(
		.clk      (clk),
		.rst      (rst),
		.r_addr_0 (),
		.r_addr_1 (),
		.r_addr_2 (rf_debug_addr),
		.w_addr   (),
		.w_data   (),
		.w_en     (),
		.r_data_0 (),
		.r_data_1 (),
		.r_data_2 (rf_debug_data)
	);

	//----------------------------------------------------------------------
	// Add all other datapath logic here
	//----------------------------------------------------------------------

endmodule
