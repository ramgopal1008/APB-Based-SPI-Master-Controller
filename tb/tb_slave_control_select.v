module tb_slave_control_select;
	reg Pclk;
	reg Preset;
	reg mstr;
	reg spiswai;
	reg [1:0]spi_mode;
	reg send_data;
	reg [11:0]baud_rate_divisor;
	wire tip;
	wire receive_data;
	wire ss;

slave_control_select dut(
	.Pclk(Pclk),
	.Preset(Preset),
	.mstr(mstr),
	.spiswai(spiswai),
	.spi_mode(spi_mode),
	.send_data(send_data),
	.baud_rate_divisor(baud_rate_divisor),
	.tip(tip),
	.receive_data(receive_data),
	.ss(ss));

always #5 Pclk <= ~Pclk;

task initialize;
	begin
		Pclk<=1'b0;
		mstr<=1'b0;
		spiswai<=1'b0;
		spi_mode<=2'b00;
		send_data<=1'b0;
		baud_rate_divisor<=12'd1;
	end
endtask

task reset;
	begin
		Preset<=0;
		repeat(2)
		@(negedge Pclk);
		Preset<=1;
	end
endtask

task drive_data(input mstr_i,input [1:0]spi_mode_i,input spiswai_i,input [11:0]baud_val);
	begin
		mstr<=mstr_i;
		spi_mode<=spi_mode_i;
		spiswai<=spiswai_i;
		baud_rate_divisor<=baud_val;
		@(negedge Pclk);
	end
endtask

task send_data_i;
	begin
		send_data<=1'b1;
		@(negedge Pclk);
		send_data<=1'b0;
		@(negedge Pclk);
	end
endtask

initial begin
	initialize;
	reset;
	drive_data(1'b1,2'b01,1'b1,12'd2);
	send_data_i;
	drive_data(1'b1,2'b00,1'b0,12'd2);
	send_data_i;

	#2000;
	$finish;
end
endmodule
