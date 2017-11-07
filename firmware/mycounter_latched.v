module mycounter_latched (clk, enable, count, cout);

input clk;
input enable;
output [1:0] count;
output cout;

reg [1:0] count;
reg cout;

initial
begin
	count <= 2'b00;
	//cout <=1;
end

always @ (posedge clk)
begin
	count = count + enable;
	if (count == 2'b00)
	  begin
		 cout <= 1'b1;
	  end
	else 
	  begin
		 cout <= 1'b0;
	  end
end

endmodule