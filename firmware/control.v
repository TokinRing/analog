module control (
 pcinstruction, fifo_full, clock, disableout, discriminator 
);
input [7:0] pcinstruction;
input fifo_full;
input clock;
output disableout;
output [7:0] discriminator;

reg pcstatus;
wire disableout;
reg [7:0] discriminator;

assign disableout = ~(pcstatus & ~fifo_full);

//initial
//begin
//	pcstatus = 1'b0;
//end

always @(posedge clock)
begin
	if ( pcinstruction[2] )
	begin
		pcstatus = 1'b1;
	end
	if ( pcinstruction[1] )
	begin
		pcstatus = 1'b0;
	end
	if ( pcinstruction[0] )
	begin
		discriminator[7:3] <= pcinstruction[7:3];
		discriminator[2:0] <= 0;
	end
end
	
endmodule