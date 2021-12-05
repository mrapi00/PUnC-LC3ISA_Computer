//==============================================================================
// Control Unit for PUnC LC3 Processor
//==============================================================================

`include "Defines.v"

module PUnCControl(
	// External Inputs
	input  wire        	clk,            // Clock
	input  wire        	rst,            // Reset

	// Input Signals from DataPath
	input [15:0]		ir,
	input				nzp_true,

	//Instruction Register Controls
	output reg 			IR_clr,
	output reg			IR_ld,

	//Program Counter Controls
	output reg			PC_ld,
	output reg			PC_clr,
	output reg			PC_inc,
	output reg	[1:0]	PC_sel,		  

	//Memory Controls
	output reg			Mem_rd,
	output reg			Mem_wr,
	output reg	[1:0]	Mem_R_addr_sel,
	output reg 	[1:0]	Mem_W_addr_sel,

	//Register File Controls
	output reg	[1:0]	RF_W_data_sel,
	output reg			RF_W_addr_sel,
	output reg			RF_R0_addr_sel,
	output reg			RF_W_wr,
	output reg			RF_R0_rd,
	output reg			RF_R1_rd,

	//prev Register Control
	output reg 			prev_ld,

	//NZP Circuit Controls
	output reg			nzp_ld,
	output reg			nzp_clr,

	//ALU Controls
	output reg	[1:0]	alu_sel,
	output reg			alu_first_val
);

	// FSM States
	localparam STATE_INIT		= 3'd0;
	localparam STATE_FETCH		= 3'd1;
	localparam STATE_DECODE		= 3'd2;
	localparam STATE_EXECUTE	= 3'd3;
	localparam STATE_EXECUTE2	= 3'd4;
	localparam STATE_HALT		= 3'd5;
	

	// State, Next State
	reg [4:0] state, next_state;

	// Output Combinational Logic
	always @( * ) begin
		// Default values for outputs
		IR_clr 				= 1'd0;
		IR_ld 				= 1'd0;
		PC_ld 				= 1'd0;
		PC_clr 				= 1'd0;
		PC_inc 				= 1'd0;
		PC_sel 				= 2'd0;		
		Mem_rd 			= 1'd0;
		Mem_wr 			= 1'd0;
		Mem_R_addr_sel 	= 2'd0;
		Mem_W_addr_sel 	= 2'd0;
		RF_W_data_sel 		= 2'd0;
		RF_W_addr_sel 		= 1'd0;
		RF_R0_addr_sel 		= 1'd0; 
		RF_W_wr 			= 1'd0;
		RF_R0_rd 			= 1'd0;
		RF_R1_rd 			= 1'd0;
		prev_ld 			= 1'd0;
		nzp_ld 				= 1'd0;
		nzp_clr 			= 1'd0;
		alu_sel 			= 2'd0;
		alu_first_val 			= 1'd0;

		// Add your output logic here
		case (state)
			STATE_INIT: begin
				PC_clr  	= 1'd1;
				IR_clr		= 1'd1;
				nzp_clr		= 1'd1;
			end

			STATE_FETCH: begin
				PC_inc 			= 1'd1;
				IR_ld			= 1'd1;
				//Mem_rd			= 1'd1;
				//Mem_R_addr_sel = `Mem_R_Addr_Sel_PC; 
			end

			STATE_DECODE: begin
			end

			STATE_EXECUTE: begin
				case(ir[`OC])
					`OC_ADD:begin
						RF_W_data_sel 	= `RF_W_Data_Sel_ALU;
						RF_W_addr_sel 	= `RF_W_Addr_Sel_11_9;
						RF_W_wr 		= 1'b1;
						RF_R0_addr_sel 	= `RF_R0_Addr_Sel_2_0;
						RF_R1_rd		= 1'b1;
						nzp_ld			= 1'b1;
						alu_sel			= `ALU_Sel_ADD;

						if(ir[5] == 0) begin
							RF_R0_rd 	= 1'b1;
							alu_first_val	= `ALU_FIRST_VAL_Sel_R0_Data;
						end
						
						else begin
							RF_R0_rd	= 1'b0;
							alu_first_val	= `ALU_FIRST_VAL_4_0;
						end
					end

					`OC_AND:begin
						RF_W_data_sel 	= `RF_W_Data_Sel_ALU;
						RF_W_addr_sel 	= `RF_W_Addr_Sel_11_9;
						RF_W_wr 		= 1'b1;
						RF_R1_rd		= 1'b1;
						nzp_ld			= 1'b1;
						alu_sel			= `ALU_Sel_AND;

						if(ir[5] == 0) begin
							RF_R0_rd 	= 1'b1;
							RF_R0_addr_sel 	= `RF_R0_Addr_Sel_2_0;
							alu_first_val	= `ALU_FIRST_VAL_Sel_R0_Data;
						end
						
						else begin
							RF_R0_rd	= 1'b0;
							alu_first_val	= `ALU_FIRST_VAL_4_0;
						end
					end

					`OC_BR: begin
						if (nzp_true == 1'b1) begin
							PC_ld 	= 1'b1;
							PC_sel 	= `PC_Data_Sel_PC_8_0;
						end
					end

					`OC_JMP: begin
						PC_ld 		= 1'b1;
						PC_sel 		= `PC_Data_Sel_RF_R1_Data;
						RF_R1_rd 	= 1'b1;
					end

					`OC_JSR: begin
						RF_W_data_sel 	= `RF_W_Data_Sel_PC;
						RF_W_addr_sel 	= `RF_W_Addr_Sel_R7;
						RF_W_wr			= 1'b1;
					end

					`OC_LD:begin
						Mem_rd 				= 1'b1;
						Mem_R_addr_sel 		= `Mem_R_Addr_Sel_PC_8_0;
						RF_W_data_sel 		= `RF_W_Data_Sel_Mem_R;
						RF_W_addr_sel 		= `RF_W_Addr_Sel_11_9;
						RF_W_wr 			= 1'b1;
						nzp_ld 				= 1'b1;
					end

					`OC_LDI:begin
						Mem_rd = 1'b1;
						Mem_R_addr_sel 		= `Mem_R_Addr_Sel_PC_8_0;
						RF_W_data_sel 		= `RF_W_Data_Sel_Mem_R;
						RF_W_addr_sel 		= `RF_W_Addr_Sel_11_9;
						RF_W_wr 			= 1'b1;
						nzp_ld				= 1'b1;
					end

					`OC_LDR:begin
						Mem_rd 				= 1'b1;
						Mem_R_addr_sel 		= `Mem_R_Addr_Sel_RF_R1_5_0;
						RF_W_data_sel 		= `RF_W_Data_Sel_Mem_R;
						RF_W_addr_sel 		= `RF_W_Addr_Sel_11_9;
						RF_W_wr 			= 1'b1;
						RF_R1_rd			= 1'b1;
						nzp_ld				= 1'b1;
					end

					`OC_LEA:begin
						RF_W_data_sel 		= `RF_W_Data_Sel_PC_8_0;
						RF_W_addr_sel 		= `RF_W_Addr_Sel_11_9;
						RF_W_wr 			= 1'b1;
						nzp_ld				= 1'b1;
					end

					`OC_NOT:begin
						RF_W_data_sel 	= `RF_W_Data_Sel_ALU;
						RF_W_addr_sel 	= `RF_W_Addr_Sel_11_9;
						RF_W_wr 		= 1'b1;
						RF_R1_rd		= 1'b1;
						nzp_ld			= 1'b1;
						alu_sel			= `ALU_Sel_NOT_B;
					end

					`OC_ST:begin
						Mem_wr 		= 1'b1;
						Mem_W_addr_sel	= `Mem_W_Addr_Sel_PC_8_0;
						RF_R0_addr_sel	= `RF_R0_Addr_Sel_11_9;
						RF_R0_rd		= 1'b1;
					end

					`OC_STI:begin
						Mem_rd			= 1'b1;
						Mem_R_addr_sel	= `Mem_R_Addr_Sel_PC_8_0;
						prev_ld			= 1'b1;
					end

					`OC_STR:begin
						Mem_wr 		= 1'b1;
						Mem_W_addr_sel	= `Mem_W_Addr_Sel_RF_R1_5_0;
						RF_R1_rd		= 1'b1;
					end

					`OC_HLT:begin					
					end

				endcase
			end

			STATE_EXECUTE2:begin
				case(ir[`OC])
					`OC_JSR: begin
						PC_ld 	= 1'b1;
						if(ir[11] == 1'b1) begin
							PC_sel 	= `PC_Data_Sel_PC_10_0;
						end
						else begin
							PC_sel 	= `PC_Data_Sel_RF_R1_Data;
						end			
					end

					`OC_LDI: begin
						Mem_rd = 1'b1;
						Mem_R_addr_sel 	= `Mem_R_Addr_Sel_RF_R0_Data;
						RF_W_data_sel 		= `RF_W_Data_Sel_Mem_R;
						RF_W_addr_sel 		= `RF_W_Addr_Sel_11_9;
						RF_W_wr 			= 1'b1;
						RF_R0_addr_sel		= `RF_R0_Addr_Sel_11_9;
						RF_R0_rd			= 1'b1;
						nzp_ld 				= 1'b1;
					end				

					`OC_STI:begin
						Mem_wr 		= 1'b1;
						Mem_W_addr_sel	= `Mem_W_Addr_Sel_prev_Data;
						RF_R0_addr_sel	= `RF_R0_Addr_Sel_11_9;
						RF_R0_rd		= 1'b1;
					end
				endcase
			end
		endcase
	end

	// Next State Combinational Logic
	always @( * ) begin
		//Default value for next state
		next_state = state;

		//Next-state logic
		case (state)
		 STATE_INIT: begin
            next_state = STATE_FETCH;
         end
         STATE_FETCH: begin
            next_state = STATE_DECODE;
         end
         STATE_DECODE: begin
            next_state = STATE_EXECUTE;
         end
         STATE_EXECUTE: begin
            if (ir[`OC] == `OC_JSR | ir[`OC] ==`OC_LDI | ir[`OC] == `OC_STI) begin
            	next_state = STATE_EXECUTE2;
            end
			else if(ir[`OC] == `OC_HLT) begin
			  next_state = STATE_EXECUTE;
			end
            else begin
               next_state = STATE_FETCH;
            end
         end
         STATE_EXECUTE2: begin
            next_state = STATE_FETCH;
         end
		endcase
	end

	// State Update Sequential Logic
	always @(posedge clk) begin
		if (rst) begin
         state <= STATE_INIT;
      end
      else begin
         state <= next_state;
      end
	end

endmodule