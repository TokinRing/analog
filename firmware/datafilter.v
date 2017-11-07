module datafilter (
datain, readyin, dataout, readyout
);

input [63:0] datain;
input readyin;

output [63:0] dataout;
output readyout;

wire [63:0] dataout;
wire readyout;

parameter [23:0]constant = 63;

assign dataout = (datain[55:32] > constant)?datain:0;
assign readyout = (datain[55:32] > constant)?readyin:0;

endmodule