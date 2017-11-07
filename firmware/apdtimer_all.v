// Copyright (C) 1991-2006 Altera Corporation
// Your use of Altera Corporation's design tools, logic functions 
// and other software and tools, and its AMPP partner logic 
// functions, and any output files any of the foregoing 
// (including device programming or simulation files), and any 
// associated documentation or information are expressly subject 
// to the terms and conditions of the Altera Program License 
// Subscription Agreement, Altera MegaCore Function License 
// Agreement, or other applicable license agreement, including, 
// without limitation, that your use is for the sole purpose of 
// programming logic devices manufactured by Altera and sold by 
// Altera or its authorized distributors.  Please refer to the 
// applicable agreement for further details.

module apdtimer_all(
	Clock,
	Stop_det,
	Start_det,
	Reset_counter,
	Detector_1,
	Detector_2,
	Detector_3,
	Detector_0,
	haltout,
	Start,
	dataready,
	dataout
);

input	Clock;
input	Stop_det;
input	Start_det;
input	Reset_counter;
input	Detector_1;
input	Detector_2;
input	Detector_3;
input	Detector_0;
input	haltout;
input	Start;
output	dataready;
output	[7:0] dataout;

wire	[3:0] ch;
wire	[31:0] dat;
wire	SYNTHESIZED_WIRE_0;
wire	SYNTHESIZED_WIRE_1;
wire	SYNTHESIZED_WIRE_24;
wire	SYNTHESIZED_WIRE_3;
wire	SYNTHESIZED_WIRE_4;
wire	SYNTHESIZED_WIRE_5;
wire	SYNTHESIZED_WIRE_6;
wire	SYNTHESIZED_WIRE_25;
wire	SYNTHESIZED_WIRE_10;
wire	SYNTHESIZED_WIRE_11;
wire	SYNTHESIZED_WIRE_12;
wire	[31:0] SYNTHESIZED_WIRE_13;
wire	[1:0] SYNTHESIZED_WIRE_14;
wire	SYNTHESIZED_WIRE_15;
wire	SYNTHESIZED_WIRE_16;
reg	SRFF_inst5;
wire	SYNTHESIZED_WIRE_18;
wire	SYNTHESIZED_WIRE_19;
wire	SYNTHESIZED_WIRE_23;

assign	dataready = SYNTHESIZED_WIRE_5;



assign	SYNTHESIZED_WIRE_19 = Stop_det | SYNTHESIZED_WIRE_0;

allclickreg	b2v_inst1(.clk(Clock),
.clear(SYNTHESIZED_WIRE_1),.operate(SYNTHESIZED_WIRE_24),.channel(ch),.ready(SYNTHESIZED_WIRE_11),.data(SYNTHESIZED_WIRE_13));

clicklatch	b2v_inst10(.click(SYNTHESIZED_WIRE_3),
.clock(Clock),.data(ch[3]));

clicklatch	b2v_inst11(.click(SYNTHESIZED_WIRE_4),
.clock(Clock),.data(ch[0]));

mycounter	b2v_inst12(.clk(Clock),
.enable(SYNTHESIZED_WIRE_5),.cout(SYNTHESIZED_WIRE_12),.count(SYNTHESIZED_WIRE_14));
assign	SYNTHESIZED_WIRE_5 = SYNTHESIZED_WIRE_6 & SYNTHESIZED_WIRE_25;
assign	SYNTHESIZED_WIRE_10 = SYNTHESIZED_WIRE_24 & Start;
assign	SYNTHESIZED_WIRE_25 =  ~haltout;
assign	SYNTHESIZED_WIRE_3 = Detector_3 & SYNTHESIZED_WIRE_24;

runonce	b2v_inst17(.out(SYNTHESIZED_WIRE_0));

clicklatch	b2v_inst18(.click(SYNTHESIZED_WIRE_10),
.clock(Clock),.data(SYNTHESIZED_WIRE_15));

dcfifo1	b2v_inst2(.wrreq(SYNTHESIZED_WIRE_11),
.rdreq(SYNTHESIZED_WIRE_12),.clock(Clock),.data(SYNTHESIZED_WIRE_13),.empty(SYNTHESIZED_WIRE_16),.q(dat));

lpm_mux1	b2v_inst27(.data0x(dat[7:0]),
.data1x(dat[15:8]),.data2x(dat[23:16]),.data3x(dat[31:24]),.sel(SYNTHESIZED_WIRE_14),.result(dataout));
assign	SYNTHESIZED_WIRE_1 = SYNTHESIZED_WIRE_15 | Reset_counter;
assign	SYNTHESIZED_WIRE_6 =  ~SYNTHESIZED_WIRE_16;
assign	SYNTHESIZED_WIRE_24 = SRFF_inst5 & SYNTHESIZED_WIRE_25;

clicklatch	b2v_inst4(.click(SYNTHESIZED_WIRE_18),
.clock(Clock),.data(ch[1]));
always@(posedge Clock)
begin
	SRFF_inst5 = ~SRFF_inst5 & Start_det | SRFF_inst5 & ~SYNTHESIZED_WIRE_19;
end
assign	SYNTHESIZED_WIRE_4 = Detector_0 & SYNTHESIZED_WIRE_24;
assign	SYNTHESIZED_WIRE_18 = Detector_1 & SYNTHESIZED_WIRE_24;
assign	SYNTHESIZED_WIRE_23 = Detector_2 & SYNTHESIZED_WIRE_24;

clicklatch	b2v_inst9(.click(SYNTHESIZED_WIRE_23),
.clock(Clock),.data(ch[2]));


endmodule
