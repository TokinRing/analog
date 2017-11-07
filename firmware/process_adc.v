module process_adc (
 adc, halt, clk, discriminator,
 count, ready, state
);

input [7:0] adc;
input [7:0] discriminator;
input halt;
input clk;

output [63:0] count;
output ready;
output state;

wire [63:0] count;
reg ready;

reg state;
reg [23:0]counter;
reg [31:0]integrator;
reg [7:0]max;

//initial
//begin
//	state <= 1'b0;
//	ready <= 1'b0;
//end

//wire [8:0] adc_full;
//wire [8:0] is_larger;

//assign adc_full[8] = 1'b1;
//assign adc_full[7:0] = adc;
//assign is_larger = adc_full - discriminator;

assign count[31:0] = integrator;
assign count[55:32] = counter;
assign count[63:56] = max;

always @ (posedge clk)
begin

/*	if (adc>discriminator)
	begin
		if (state)
		begin
			counter <= counter + 1'b1;
			integrator<=integrator+adc;			
			max<=(max>adc)?max:adc;
			ready <= 1'b0;			
		end
		else
		begin
			state <= 1'b1;
			counter <= 1'b1;
			integrator<=adc;			
			max<=(max>adc)?max:adc;
			ready <= 1'b0;			
		end
	end
	else
	begin
		if (state)
		begin
			state <= 1'b0;
			ready <= 1'b1;
		end
		else
		begin
			ready <= 1'b0;
		end
	end */
	
	

	if (~halt)
	begin
	case (state)
		1'b0: begin
				  if (adc[7:0]>discriminator[7:0]) 
				  //if (is_larger[8]) 
				  begin
					state<=1'b1;
					counter<=24'b1;
					integrator<=adc;
					max<=adc;
				  end
				  ready<=1'b0;
			  end
			
		1'b1: begin
				if (adc[7:0]>discriminator[7:0])
				//if (is_larger[8])
				begin
					counter <= counter + 1'b1;
					integrator<=integrator+adc;
					//max<=(max>adc)?max:adc;
					if (max<adc)
					begin
						max<=adc;
					end
				end
				else
				begin
					ready<=1'b1;
					state<=1'b0;
				end
			  end
	endcase
	end
	else
	begin
		ready<=1'b0;
	end

end
endmodule