// FIR 16 stages; 16 bit samples. Could be parameterized.

module fir (input logic signed [15:0] in,
       input logic input_ready, ck, rst ,
       output logic signed [15:0] out,
       output logic output_ready);

typedef logic signed [15:0] sample_array;
sample_array samples [0:15];

// generate coefficients from Octave/Matlab lecture 7.1
// disp(sprintf('%d,',round(fir1(15,0.5)*32768)))

const sample_array coefficients [0:15] =
		
     '{-81, -134,  318, 645,
     -1257, -2262, 4522, 14633,
     14633, 4522, -2262,-1257,
     645, 318, -134, -81};

logic unsigned [3:0] address; //clog2 of 16 is 4

logic signed [31:0] sum;

typedef enum logic [1:0] {waiting, loading, processing, saving} state_type;
state_type state, next_state;
logic load, count, reset_accumulator;


always_ff @(posedge ck)
  if (load)
    begin
    for (int i=15; i >= 1; i--)
      samples[i] <= samples[i-1];
    samples[0] <= in;
    end

// accumulator register
always_ff @(posedge ck)
  if (reset_accumulator)
    sum <= '0;
  else
    sum <= sum + samples[address] * coefficients[address];
    
always_ff @(posedge ck)
  if (output_ready)
    out <= sum[30:15];
    
// address counter
// implement a synchronous counter that counts up through all 16 values of address
// when a count signal is true
always_ff @(posedge ck)
	if(count)
		address <= address+1;
		
	else if(reset_accumulator)
		address <= 0;

// controller state machine 
// implement a state machine to control the FIR
always_ff @(posedge ck, posedge rst)
	begin
	if (rst)
		state <= waiting;
	else
		state <= next_state;
	end
	
always_comb
	begin
	reset_accumulator = '0;
	load = '0;
	output_ready = '0;
	count = '0;
	unique case(state)
		waiting:
			begin
			reset_accumulator = '1;
			//output_ready = '0;
			if (input_ready)
				next_state = loading;
			else
				next_state = waiting;
			end
		loading:
			begin
			load = '1;
			reset_accumulator = '1;
			next_state = processing;
			end
		processing:
			begin
			//load = '0;
			//reset_accumulator = '0;
			count = '1;
			if (address < 15)
				next_state = processing;
			else
				next_state = saving;
			//next_state = (address < 15) ? processing : saving;
			end
		saving:
			begin
			//count = '0;
			output_ready = '1;
			next_state = waiting;
			end
			
			default next_state = waiting;
	endcase
	end
endmodule


