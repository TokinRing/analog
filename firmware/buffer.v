module buffer (
datain, clock,
dataout
);

input clock;
input [7:0]datain;

output [7:0] dataout;
reg [7:0]dataout;

reg [7:0]datastore;

//initial
//	begin
//		datastore <= 8'b0;
//		dataout <= 8'b0;
//	end

always @ (posedge clock)
	begin
		dataout = datastore;
		datastore = datain;
	end

endmodule