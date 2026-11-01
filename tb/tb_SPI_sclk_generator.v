module tb_SPI_sclk_generator;
reg pclk, preset;
reg [1:0]spi_mode;
reg spiswai;
reg [2:0]sppr,spr;
reg cpol,cpha,ss;
wire sclk,
	miso_rx_sclk_pos,
	miso_rx_sclk_neg,
	mosi_tx_sclk_pos,
	mosi_tx_sclk_neg;
wire [11:0]baud_rate_div;
wire [11:0]baud_calc;
SPI_sclk_generator dut(
	.pclk(pclk),
	.preset(preset),
	.spi_mode(spi_mode),
	.spiswai(spiswai),
	.sppr(sppr),
	.spr(spr),
	.cpol(cpol),
	.cpha(cpha),
	.ss(ss),
	.sclk(sclk),
	.miso_rx_sclk_pos(miso_rx_sclk_pos),
	.miso_rx_sclk_neg(miso_rx_sclk_neg),
	.mosi_tx_sclk_pos(mosi_tx_sclk_pos),
	.mosi_tx_sclk_neg(mosi_tx_sclk_neg),
	.baud_rate_div(baud_rate_div));

always #5 pclk <= ~pclk;

assign baud_calc=(sppr +1'b1) * (2**(spr+1'b1));
task initialize;
	begin
		pclk<=0;
		spi_mode<=0;
		spiswai<=0;
		sppr<=0;
		spr<=0;
		cpol<=0;
		cpha<=0;
		ss<=0;
	end
endtask

task reset;
	begin
		preset<=0;
		
		@(negedge pclk);
		@(negedge pclk);
		preset<=1;
	end
endtask
 
task spi_modes(input [1:0]x,y);
	begin
		spi_mode<=x;
		spiswai<=y;
		@(negedge pclk);
	end
endtask

task drive_inputs(input [2:0]sppr_i,[2:0]spr_i,cpol_i,cpha_i);
	begin
		sppr<=sppr_i;
		spr<=spr_i;
		cpol<=cpol_i;
		cpha<=cpha_i;
		@(negedge pclk);
	end
endtask
task slave_select(input ss_i);
	begin
		ss<=ss_i;
		@(negedge pclk);
	end
endtask

initial begin
	initialize;
	reset;
	slave_select(1'b1);
	@(negedge pclk);
	@(negedge pclk);
	@(negedge pclk);
	spi_modes(2'b00,1'b1);
	drive_inputs(3'd1,3'd1,1'b1,1'b1);
	slave_select(1'b0);

	repeat(baud_calc)
	begin
		@(negedge sclk);
	end
	slave_select(1'b1);
	drive_inputs(3'd0,3'd1,1'b0,1'b0);
	slave_select(1'b0);

	repeat(baud_calc)
	begin
		@(negedge sclk);
	end
	drive_inputs(3'd1,3'd1,1'b1,1'b0);
	slave_select(1'b0);

	repeat(baud_calc)
	begin
		@(negedge sclk);
	end
	slave_select(1'b1);
end

endmodule
	
