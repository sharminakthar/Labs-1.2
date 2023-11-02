/////////////////////////////////////////////////////////////////////
// Design unit: sequencer
//            :
// File name  : sequencer.sv
//            :
// Description: Code for M4 Lab exercise
//            : Outline code for sequencer
//            :
// Limitations: None
//            : 
// System     : SystemVerilog IEEE 1800-2005
//            :
// Author     : 
//            : School of Electronics and Computer Science
//            : University of Southampton
//            : Southampton SO17 1BJ, UK
//            : 
//
// Revision   : Version 1.0 
/////////////////////////////////////////////////////////////////////

module sequencer (input logic start, clock, Q0, n_rst,
 output logic add, shift, ready, reset);
 
	enum {idle, adding, shifting, stopped} present_state, next_state;
	logic [0:2] count = 4;
	logic enable = '0;
	
	always_ff @(posedge clock, negedge n_rst)
		begin: SEQ
		if (!n_rst)
			present_state <= idle;
		else
			present_state <= next_state;
		end
		
	always_ff @(posedge clock, negedge n_rst)
		if (!n_rst)
			count <= 4;
		else if(enable)
			count <= count - 1;
		else if(count ==0)
			count <= 4;
			
	always_comb 
		begin: COM
		add = '0;
		shift = '0;
		ready = '0;
		reset = '0;
		enable = '0;
		next_state = present_state;
		unique case (present_state)
			idle: begin
				reset = '1;
				if (start)
					next_state = adding;
				end
			adding: begin
				enable = '1;
				if (Q0)
					add = '1;
				next_state = shifting;
				end
			shifting: begin
				shift = '1;
				if (count>0)
					next_state = adding;
				else
					next_state = stopped;
				end
			stopped: begin
				ready = '1;
				if(start)
					next_state = idle;
				end
			endcase
	end
endmodule
 