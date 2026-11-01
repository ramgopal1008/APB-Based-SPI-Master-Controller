module SPI_sclk_generator(
	input pclk,
	input preset,
	input [1:0]spi_mode,
	input spiswai,
	input [2:0]sppr,
	input [2:0]spr,
	input cpol,
	input cpha,
	input ss,
	output reg sclk,
	output reg miso_rx_sclk_pos,
	output reg miso_rx_sclk_neg,
	output reg mosi_tx_sclk_pos,
	output reg mosi_tx_sclk_neg,
	output [11:0]baud_rate_div);

// internal wires for baud generation
wire [11:0]baud_rate;
wire pre_sclk;
reg [11:0]count;

//baud rate generation
assign baud_rate= (sppr +1'b1) * (2**(spr+1'b1));
assign baud_rate_div=baud_rate/2;

// pre_sclk generation for the idle conditions
assign pre_sclk= cpol ? 1'b1:1'b0;


//always block for the sclk generation
always@(posedge pclk or negedge preset)
begin
	if(!preset)
	begin
		sclk<=0;
		count<=0;
	end
	else if((~ss)&&(spi_mode==2'b00 || (spi_mode==2'b01 && spiswai==1'b0)))
	begin
		if(count==baud_rate_div -1 )
		begin
			count<= 0;
			sclk<= ~sclk;
		end
		else 
			count<=count+1;
	end
	else
	begin
		sclk<= pre_sclk;
		count<=0;
	end
end


//always block for the miso receiving
always@(posedge pclk or negedge preset)
begin
	if(!preset)
	begin
		miso_rx_sclk_pos<=0;
		miso_rx_sclk_neg<=0;
	end
	else
	begin
		if(cpol == cpha)  
		begin
			if(!sclk)  //for receiving at rising edge
			begin
				if(count==baud_rate_div -1)
					miso_rx_sclk_pos<=1;
				else
					miso_rx_sclk_pos<=0;
			end
			else
				miso_rx_sclk_pos<=0;
		end
		else
		begin
			if(sclk)  //for receiving at falling edge
			begin
				if(count==baud_rate_div -1)
					miso_rx_sclk_neg<=1;
				else
					miso_rx_sclk_neg<=0;
			end
			else
				miso_rx_sclk_neg<=0;
		end
	end
end


// always block for mosi sending the data
always@(posedge pclk or negedge preset)
begin
	if(!preset)
	begin
		mosi_tx_sclk_pos<=0;
		mosi_tx_sclk_neg<=0;
	end
	else
	begin
		if(cpol != cpha)
		begin
			if(sclk)  // for sending at rising edge
			begin
				if(count ==baud_rate_div -2)
					mosi_tx_sclk_neg<=1;
				else 
					mosi_tx_sclk_neg<=0;
			end
			else
				mosi_tx_sclk_neg<=0;
		end
		else
		begin
			if(!sclk) //
			begin
				if(count==baud_rate_div -2)
					mosi_tx_sclk_pos<=1;
				else
					mosi_tx_sclk_pos<=0;
			end
			else
				mosi_tx_sclk_pos<=0;
		end
	end
end


endmodule 
