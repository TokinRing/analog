// Fast Multisource Pulse Registration System
// Module:
// mycounter
// Simple counter 0 through 7 which loops itself back
// (c) Sergey V. Polyakov 2006-forever

module mycounter (clk, enable, count, cout);

input clk;
input enable;
output [2:0] count;
output cout;

reg [2:0] count;
reg cout;
reg state;

//initial
//begin
//	count <= 3'b00;
//	cout <=0;
//	state <=0;
//end

always @ (posedge clk)
begin
	count = count + enable;
	if (count == 3'b111 && state == 0)
	begin
		cout <= 1'b1;
		state <= 1'b1;
	end
	else if ( state == 1 )
	begin
		cout <= 1'b0;
	end
	if (count != 3'b111 )
	begin
		state <= 0;
	end
end

endmodule