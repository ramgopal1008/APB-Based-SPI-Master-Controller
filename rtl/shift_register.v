module shift_register(
	input pclk,
	input preset,
	input ss,
	input send_data,
	input lsbfe,
	input cpol,
	input cpha,
	input miso_rx_sclk_pos,
	input miso_rx_sclk_neg,
	input mosi_tx_sclk_pos,
	input mosi_tx_sclk_neg,
	input [7:0]data_mosi,
	input miso,
	input receive_data,
	output reg mosi,
	output [7:0]data_miso
);

reg [7:0]temp_reg;
reg [7:0]shift_reg;

reg [2:0] count1_lsb,
	count1_msb,
	count2_lsb,
	count2_msb;

assign data_miso = receive_data ? temp_reg : 8'd0;

//to drive the data into the shift register
always@(posedge pclk or negedge preset)
begin
	if(!preset)
		shift_reg<=8'd0;
	else if(send_data)
		shift_reg<=data_mosi;
end

//for sending the data through the mosi output
always@(posedge pclk or negedge preset)
begin
	if(!preset)
	begin
		mosi<=1'b0;
		count1_lsb<=3'd0;
		count1_msb<=3'd7;
	end
	else if(ss)
	begin
		count1_lsb<=3'd0;
		count1_msb<=3'd7;
	end
	else
	begin
		if(cpha != cpol)
		begin
			if(mosi_tx_sclk_neg)
			begin
				if(lsbfe)
				begin
					mosi<=shift_reg[count1_lsb];
					count1_lsb<=count1_lsb+3'd1;
				end
				else
				begin
					mosi<=shift_reg[count1_msb];
					count1_msb<=count1_msb-3'd1;
				end
			end
		end
		else
		begin
			if(mosi_tx_sclk_pos)
			begin
				if(lsbfe)
				begin
					mosi<=shift_reg[count1_lsb];
					count1_lsb<=count1_lsb+3'd1;
				end
				else
				begin
					mosi<=shift_reg[count1_msb];
					count1_msb<=count1_msb-3'd1;
				end
			end
		end
	end
end

//to store the miso values into the temp register
always@(posedge pclk or negedge preset)
begin
	if(!preset)
	begin
		temp_reg<=8'd0;
		count2_lsb<=3'd0;
		count2_msb<=3'd7;
	end
	else if(ss)
	begin
		count2_lsb<=3'd0;
		count2_msb<=3'd7;
	end
	else
	begin
		if(cpol != cpha)
		begin
			if(miso_rx_sclk_neg)
			begin
				if(lsbfe)
				begin
					temp_reg[count2_lsb]<=miso;
					count2_lsb<=count2_lsb+3'd1;
				end
				else
				begin
					temp_reg[count2_msb]<=miso;
					count2_msb<=count2_msb-3'd1;
				end
			end
		end
		else
		begin
			if(miso_rx_sclk_pos)
			begin
				if(lsbfe)
				begin
					temp_reg[count2_lsb]<=miso;
					count2_lsb<=count2_lsb+3'd1;
				end
				else
				begin
					temp_reg[count2_msb]<=miso;
					count2_msb<=count2_msb-3'd1;
				end
			end
		end
	end
end

endmodule

