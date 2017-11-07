// (c) Sergey V. Polyakov 2006-forever
module clickreg (channel, timer, click, clear, data, ready);

input [2:0] channel;
input [28:0] timer;
input click;
input clear;

reg ready;
reg [31:0] data;

output ready; 
output [31:0] data;

always @(posedge click or posedge clear)
begin
 if (clear)
	begin
	 	ready <= 1'b0;
		data[31:0] <= 32'b0;	
	end
 else
	begin
		data[31:29] <= channel[2:0];
		data[28:0] <= timer[28:0];
		ready <= 1'b1;
	end
end

endmodule