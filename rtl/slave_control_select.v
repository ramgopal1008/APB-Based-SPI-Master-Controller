module slave_control_select(
	input Pclk,
	input Preset,
	input mstr,
	input spiswai,
	input [1:0]spi_mode,
	input send_data,
	input [11:0]baud_rate_divisor,
	output tip,
	output reg receive_data,
	output reg ss);


wire [15:0]target;
reg [15:0]count;
reg rcv;

assign target= baud_rate_divisor *5'd16;
assign tip= ~ss;


always@(posedge Pclk or negedge Preset)
begin
	if(!Preset)
	begin
		count<=16'hffff;
		ss<=1;
		rcv<=0;
	end
	else
	begin
		if(mstr && (spi_mode==2'b00 || (spi_mode==2'b01 && !spiswai)))
		begin
			if(send_data)
			begin
				ss<=0;
				count<=16'h0;
			end
			else if(count<=target-1'b1)
			begin
				ss<=0;
				count<=count+1'b1;
				if(count== target-1'b1)
					rcv<=1'b1;
				else
					rcv<=1'b0;
			end
			else
			begin
				ss<=1'b1;
				count<=16'hffff;
				rcv<=1'b0;
			end
		end
		else
		begin
			ss<=1'b1;
			count<=16'hffff;
			rcv<=1'b0;
		end
	end

end

always@(posedge Pclk or negedge Preset)
begin
	if(!Preset)
		receive_data<=1'b0;
	else
		receive_data<=rcv;
end

endmodule


