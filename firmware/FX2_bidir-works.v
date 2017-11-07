// Sample code for FX2 USB-2 interface
// (c) Sergey V. Polyakov 2006-forever

module FX2_bidir(
	FX2_CLK, FX2_FD, FX2_SLRD, FX2_SLWR, FX2_flags, 
	FX2_PA_2, FX2_PA_3, FX2_PA_4, FX2_PA_5, FX2_PA_6, FX2_PA_7, 
	FPGA_WORD, FPGA_WORD_AVAILIABLE, FPGA_WORD_ACCEPTED, PCINSTRUCTION
);
//************************************************************************
//FPGA interface
//************************************************************************
input [7:0] FPGA_WORD;
input FPGA_WORD_AVAILIABLE;
output FPGA_WORD_ACCEPTED; 
output [7:0] PCINSTRUCTION;
//************************************************************************
//FIFO interface
//************************************************************************
input FX2_CLK;
inout [7:0] FX2_FD;
input [2:0] FX2_flags; //0:fifo2 data availible; 1:fifo3 data availible; 2:fifo4 not full; 
output FX2_SLRD, FX2_SLWR;

//output FX2_PA_0;
//output FX2_PA_1;
output FX2_PA_2;//fpga->fifo data accept
output FX2_PA_3;//always up
output FX2_PA_4;//fifo address (odd/even)
output FX2_PA_5;//fifo address (higher bit)
output FX2_PA_6;//fifo packet end
input FX2_PA_7;// fifo5 not full

// Rename "FX2" ports into "FIFO" ports, to give them more meaningful names
// FX2 USB signals are active low, take care of them now
// Note: You probably don't need to change anything in this section

// FX2 outputs
wire FIFO_CLK = FX2_CLK;

wire FIFO2_empty = ~FX2_flags[0];	wire FIFO2_data_available = ~FIFO2_empty;
wire FIFO3_empty = ~FX2_flags[1];	wire FIFO3_data_available = ~FIFO3_empty;
wire FIFO4_full = ~FX2_flags[2];	wire FIFO4_ready_to_accept_data = ~FIFO4_full;
wire FIFO5_full = ~FX2_PA_7;		wire FIFO5_ready_to_accept_data = ~FIFO5_full;
//assign FX2_PA_0 = 1'b1;
//assign FX2_PA_1 = 1'b1;
assign FX2_PA_3 = 1'b1;

//regs (before wires)
wire FPGA_WORD_ACCEPTED;
wire [7:0] FIFO_DATAOUT;
wire FIFO_WR;
wire FIFO_DATAOUT_OE;

// FX2 inputs
wire FIFO_RD,  FIFO_PKTEND, FIFO_DATAIN_OE; //, FIFO_DATAOUT_OE, FIFO_WR;
wire FX2_SLRD = ~FIFO_RD;
wire FX2_SLWR = ~FIFO_WR;
assign FX2_PA_2 = ~FIFO_DATAIN_OE;
assign FX2_PA_6 = ~FIFO_PKTEND;

wire [1:0] FIFO_FIFOADR;
assign {FX2_PA_5, FX2_PA_4} = FIFO_FIFOADR;

// FX2 bidirectional data bus
wire [7:0] FIFO_DATAIN = FX2_FD;
//wire [7:0] FIFO_DATAOUT;
assign FX2_FD = FIFO_DATAOUT_OE ? FIFO_DATAOUT : 8'hZZ;

////////////////////////////////////////////////////////////////////////////////
// So now everything is in positive logic
//	FIFO_RD, FIFO_WR, FIFO_DATAIN, FIFO_DATAOUT, FIFO_DATAIN_OE, FIFO_DATAOUT_OE, FIFO_PKTEND, FIFO_FIFOADR
//	FIFO2_empty, FIFO2_data_available
//	FIFO3_empty, FIFO3_data_available
//	FIFO4_full, FIFO4_ready_to_accept_data
//	FIFO5_full, FIFO5_ready_to_accept_data

////////////////////////////////////////////////////////////////////////////////
// Here we wait until we receive some data from either PC or FPGA (default is FPGA).
// If PC speaks, send an end_packet to its fifo to let it grab the collected data.
// Whenever FPGA is ready to transmit data, and the FIFO is not busy talking to PC, 
// accept FPGA's data and signal this back to FPGA
//wire FPGA_WORD_AVAILIABLE;

reg [2:0] state;
always @(posedge FIFO_CLK)
case(state)
/*
	3'b111: if( FPGA_WORD_AVAILIABLE && ~FIFO4_full ) state <= 3'b101;  // listen to FPGA (to send to FIFO4)
			else if( FIFO2_data_available) state <= 3'b001;  // listen to PC at FIFO2
	3'b001: state <= 3'b011;  // turnaround to read 1 byte from PC
	3'b011: state <= 3'b100;  // read 1 byte from PC 
	3'b100: state <= 3'b110;  // turnaround to send an end_packet to fifo4, in responce to PC's byte
	3'b101: if( ~FPGA_WORD_AVAILIABLE || FIFO4_full ) state <= 3'b111;  // write data as it comes
	3'b110: state <= 3'b111;  // send an end packet to FIFO4 and return to 'listen'
	default: state <= 3'b111;
*/
	3'b111: if (FIFO2_data_available) state <= 3'b001;
	        else if (FIFO4_full) state <=3'b101;       // listen to PC at FIFO2 write all FPGA data to FIFO4 as it comes
	3'b101: if (FIFO2_data_available) state <= 3'b001;
	        else if (~FIFO4_full) state <=3'b111;
			//else if (~FIFO4_full) state <=3'b001; // do nothing but listen for the computer but if FIFO4 gets emptied, send more
	3'b001: state <= 3'b011;                           // wait for turnaround to read 1 byte from PC
	3'b011: if (~FIFO2_data_available) state <= 3'b100;// after the data from PC turnaround back to fifo4
	3'b100: state <= 3'b110;                           // wait for turnaround to transmit an end-packet
	3'b110: if (~FIFO4_full) state <= 3'b111;          // transmit an end-packet and return to listen/transmit
			else state <= 3'b101;					   // but if FIFO4 is full return to idle
	default: state <= 3'b111;
endcase

assign FIFO_FIFOADR = {state[2], 1'b0};  // FIFO2 or FIFO4

//transmit info from PC to FPGA
assign FIFO_RD = (state==3'b011);
//should be 7:0
assign PCINSTRUCTION[4:0] = (state==3'b011)? FIFO_DATAIN[4:0]: 0;
//assign PCINSTRUCTION[2:0] = state[2:0];

//transmit info from FPGA to PC


//always @(posedge FIFO_CLK)
//begin
	assign  FPGA_WORD_ACCEPTED = (state==3'b111)&&(FPGA_WORD_AVAILIABLE); 	
	assign  FIFO_DATAOUT = FPGA_WORD;
	assign  FIFO_WR = (state==3'b111)&&(FPGA_WORD_AVAILIABLE);
	assign  FIFO_DATAOUT_OE = (state==3'b111)&&(FPGA_WORD_AVAILIABLE);
//end

assign FIFO_PKTEND = (state==3'b110);//0;
assign FIFO_DATAIN_OE = ~state[2];
//debug
assign PCINSTRUCTION[7:5] = state[2:0];

endmodule