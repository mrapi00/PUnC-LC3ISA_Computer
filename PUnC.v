//==============================================================================
// Module for PUnC LC3 Processor
//==============================================================================

`include "PUnCDatapath.v"
`include "PUnCControl.v"

module PUnC(
	// External Inputs
	input  wire        clk,            // Clock
	input  wire        rst,            // Reset

	// Debug Signals
	input  wire [15:0] mem_debug_addr,
	input  wire [2:0]  rf_debug_addr,
	output wire [15:0] mem_debug_data,
	output wire [15:0] rf_debug_data,
	output wire [15:0] pc_debug_data
);

	//----------------------------------------------------------------------
	// Interconnect Wires
	//----------------------------------------------------------------------
	//Instruction Register Controls
	wire 			IR_clr;
	wire			IR_ld;
	wire	[15:0]	ir;

	//Program Counter Controls
	wire			PC_ld;
	wire			PC_clr;
	wire			PC_inc;
	wire	[1:0]	PC_sel;	  

	//Memory Controls
	wire			Mem_rd;
	wire			Mem_wr;
	wire	[1:0]	Mem_R_addr_sel;
	wire 	[1:0]	Mem_W_addr_sel;

	//Register File Controls
	wire	[1:0]	RF_W_data_sel;
	wire			RF_W_addr_sel;
	wire			RF_R0_addr_sel;
	wire			RF_W_wr;
	wire			RF_R0_rd;
	wire			RF_R1_rd;

	//Temp Register Control
	wire 			prev_ld;

	//NZP Circuit Controls
	wire			nzp_ld;
	wire			nzp_clr;
	wire			nzp_true;

	//ALU Controls
	wire	[1:0]	ALU_sel;
	wire			alu_first_val;
  
	//----------------------------------------------------------------------
	// Control Module
	//----------------------------------------------------------------------
	PUnCControl ctrl(
		.clk            	(clk),
		.rst            	(rst),
		
		.ir					(ir),	
		.nzp_true			(nzp_true),
		
		.IR_clr				(IR_clr),
		.IR_ld				(IR_ld),
		
		.PC_ld				(PC_ld), 
		.PC_clr				(PC_clr),
		.PC_inc				(PC_inc),
		.PC_sel				(PC_sel),
		
		.Mem_rd				(Mem_rd),
		.Mem_wr				(Mem_wr),
		.Mem_R_addr_sel		(Mem_R_addr_sel),
		.Mem_W_addr_sel		(Mem_W_addr_sel),
		
		.RF_W_data_sel		(RF_W_data_sel),
		.RF_W_addr_sel		(RF_W_addr_sel),
		.RF_R0_addr_sel		(RF_R0_addr_sel),
		.RF_W_wr			(RF_W_wr),
		.RF_R0_rd			(RF_R0_rd),
		.RF_R1_rd			(RF_R1_rd),
		
		.prev_ld			(prev_ld),
		
		.nzp_ld				(nzp_ld),
		.nzp_clr			(nzp_clr),
		
		.ALU_sel			(ALU_sel),
		.alu_first_val		(alu_first_val)		
	);

	//----------------------------------------------------------------------
	// Datapath Module
	//----------------------------------------------------------------------
	PUnCDatapath dpath(
		.clk            	(clk),
		.rst            	(rst),
		
		.ir_to_controller	(ir),
		.nzp_true			(nzp_true),
		
		.ir_clr				(IR_clr),
		.ir_ld				(IR_ld),
		
		.pc_ld				(PC_ld), 
		.pc_clr				(PC_clr),
		.pc_inc				(PC_inc),
		.pc_sel				(PC_sel),

		.mem_rd				(Mem_rd),
		.mem_wr				(Mem_wr),
		.mem_r_addr_sel		(Mem_R_addr_sel),
		.mem_w_addr_sel		(Mem_W_addr_sel),
		
		.rf_w_data_sel		(RF_W_data_sel),
		.rf_w_addr_sel		(RF_W_addr_sel),
		.rf_r0_addr_sel		(RF_R0_addr_sel),
		.rf_w_wr			(RF_W_wr),
		.rf_r0_rd			(RF_R0_rd),
		.rf_r1_rd			(RF_R1_rd),
		
		.prev_ld			(prev_ld),
		
		.nzp_ld				(nzp_ld),
		.nzp_clr			(nzp_clr),
		
		.alu_sel			(ALU_sel),
		.alu_first_val_sel	(alu_first_val),

		.mem_debug_addr   	(mem_debug_addr),
		.rf_debug_addr    	(rf_debug_addr),
		.mem_debug_data   	(mem_debug_data),
		.rf_debug_data    	(rf_debug_data),
		.pc_debug_data    	(pc_debug_data)
	);

endmodule