module tb_shift_register;
reg pclk,preset;
reg [1:0]spi_mode;
reg [2:0]sppr,spr;
reg spiswai;
reg cpol,cpha,ss;

reg send_data,lsbfe;  //reg to drive the instances of shift register
reg [7:0]data_mosi;
reg miso,receive_data;
reg [7:0]miso_reg; //for stimulus purpose
wire sclk;
wire miso_rx_sclk_pos,
	miso_rx_sclk_neg,
	mosi_tx_sclk_pos,
	mosi_tx_sclk_neg;
wire [11:0]baud_rate_div;

wire mosi;
wire [7:0]data_miso; 

wire [11:0]baud_calc;
SPI_sclk_generator dut1(
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

shift_register dut2(
	.pclk(pclk),
	.preset(preset),
	.ss(ss),
	.send_data(send_data),
	.lsbfe(lsbfe),
	.cpol(cpol),
	.cpha(cpha),
	.miso_rx_sclk_pos(miso_rx_sclk_pos),
	.miso_rx_sclk_neg(miso_rx_sclk_neg),
	.mosi_tx_sclk_pos(mosi_tx_sclk_pos),
	.mosi_tx_sclk_neg(mosi_tx_sclk_neg),
	.data_mosi(data_mosi),
	.miso(miso),
	.receive_data(receive_data),
	.mosi(mosi),
	.data_miso(data_miso));

always #5 pclk<= ~pclk;

assign baud_calc=(sppr +1'b1) * (2**(spr+1'b1));
task initialize;
	begin
		pclk<=0;
		preset<=1;
		miso_reg<=0;
		spi_mode<=0;
		spiswai<=0;
		sppr<=0;
		spr<=0;
		cpol<=0;
		cpha<=0;
		ss<=1;
		send_data<=0;
		lsbfe<=0;
		data_mosi<=8'd0;
		miso<=0;
		receive_data<=0;
	end
endtask

task reset;
	begin
		preset<=0;
		repeat(3)
			@(negedge pclk);
		preset<=1;
	end
endtask


task spi_clk_trig(input cpol_i,cpha_i);
	begin
		cpol<=cpol_i;
		cpha<=cpha_i;
		@(negedge pclk);
	end
endtask

task slave_select(input ss_i);
	begin
		ss<=ss_i;
	end
endtask

task spi_baud(input [1:0]spi_mode_i,input spiswai_i,input [2:0]sppr_i,spr_i);
	begin
		spi_mode<=spi_mode_i;
		spiswai<=spiswai_i;
		sppr<=sppr_i;
		spr<=spr_i;
		@(negedge pclk);
	end
endtask
task drive_miso_data;
	begin
		receive_data<=1'b1;
		@(negedge pclk);
		receive_data<=1'b0;
		@(negedge pclk);
	end
endtask

task drive_mosi_data;
	begin
		send_data<=1'b1;
		@(negedge pclk);
		send_data<=1'b0;
		@(negedge pclk);
	end
endtask

task drive_shift_reg(input lsbfe_i,input [7:0]data_mosi_i);
	begin
		lsbfe<=lsbfe_i;
		data_mosi<=data_mosi_i;
		@(negedge pclk);
	end
endtask
//to drive the miso bits from the register
task drive_miso_byte(input [7:0]miso_byte);
	integer i;
	begin
		miso_reg=miso_byte;
		ss<=1'b0;
		for(i=0; i<8; i=i+1)
		begin
			if(lsbfe)
				miso<=miso_reg[i];
			else
				miso<=miso_reg[7-i];

			if(cpol != cpha)
				@(posedge miso_rx_sclk_neg);
			else
				@(posedge miso_rx_sclk_pos);

			//allow the shift register to sample before changing miso
			repeat(2)
				@(negedge pclk);
		end
		ss<=1'b1;
		@(negedge pclk);
	end
endtask

initial begin
	initialize;
	reset;
	spi_baud(2'b00,1'b0,3'd0,3'd2);

	//cpol=0, cpha=0, lsb first
	spi_clk_trig(1'b0,1'b0);
	drive_shift_reg(1'b1,8'b1100_1011);
	drive_mosi_data;
	drive_miso_byte(8'b1101_0010);
	drive_miso_data;

	//cpol=0, cpha=0, msb first
	spi_clk_trig(1'b0,1'b0);
	drive_shift_reg(1'b0,8'b1101_1011);
	drive_mosi_data;
	drive_miso_byte(8'b0101_1010);
	drive_miso_data;

	//cpol=0, cpha=1, lsb first
	spi_clk_trig(1'b0,1'b1);
	drive_shift_reg(1'b1,8'b1010_1001);
	drive_mosi_data;
	drive_miso_byte(8'b1001_0110);
	drive_miso_data;

	//cpol=0, cpha=1, msb first
	spi_clk_trig(1'b0,1'b1);
	drive_shift_reg(1'b0,8'b1100_1111);
	drive_mosi_data;
	drive_miso_byte(8'b1111_0000);
	drive_miso_data;

	//cpol=1, cpha=0, lsb first
	spi_clk_trig(1'b1,1'b0);
	drive_shift_reg(1'b1,8'b1100_1011);
	drive_mosi_data;
	drive_miso_byte(8'b0110_1001);
	drive_miso_data;

	//cpol=1, cpha=0, msb first
	spi_clk_trig(1'b1,1'b0);
	drive_shift_reg(1'b0,8'b0110_1010);
	drive_mosi_data;
	drive_miso_byte(8'b1101_0010);
	drive_miso_data;

	//cpol=1, cpha=1, lsb first
	spi_clk_trig(1'b1,1'b1);
	drive_shift_reg(1'b1,8'b1100_1011);
	drive_mosi_data;
	drive_miso_byte(8'b1101_0010);
	drive_miso_data;

	//cpol=1, cpha=1, msb first
	spi_clk_trig(1'b1,1'b1);
	drive_shift_reg(1'b0,8'b1100_1011);
	drive_mosi_data;
	drive_miso_byte(8'b1101_0010);
	drive_miso_data;

	#200;
	$finish;
end

endmodule

