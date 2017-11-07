module count (SIGNAL, TIMER, CODE, MYCLEAR, DATA, NEW_DATA);
input SIGNAL;
input [23:0] TIMER;
input [3:0] CODE;
input CLEAR;
output [31:0] DATA;
output NEW_DATA;

reg [31:0] MYDATA;
reg MYNEW_DATA;

assign NEW_DATA = MYNEW_DATA;
assign DATA = MYDATA;
always @(posedge MYCLEAR)
	begin
 	MYNEW_DATA <= 1'b0;
	//MYDATA <= 32'b00000000000000000000000000000000;
	end

//always @ (posedge SIGNAL)
//	begin
//	DATA[23:0] <= TIMER;
//	DATA[26:24] <= CODE;
//	NEW_DATA <= 1;
//	end
endmodule