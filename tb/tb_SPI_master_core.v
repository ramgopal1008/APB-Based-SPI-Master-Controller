module tb_SPI_master_core;
	reg Pclk;
	reg Preset;
	reg [2:0]Paddr;
	reg Pwrite;
	reg Psel;
	reg Penable;
	reg [7:0]PWdata;
	reg miso;
	wire ss;
	wire sclk;
	wire spi_int_req;
	wire mosi;
	wire [7:0]PRdata;
	wire Pready;
	wire Pslverr;

SPI_master_core dut(
	.Pclk(Pclk),
	.Preset(Preset),
	.Paddr(Paddr),
	.Pwrite(Pwrite),
	.Psel(Psel),
	.Penable(Penable),
	.PWdata(PWdata),
	.miso(miso),
	.ss(ss),
	.sclk(sclk),
	.spi_int_req(spi_int_req),
	.mosi(mosi),
	.PRdata(PRdata),
	.Pready(Pready),
	.Pslverr(Pslverr));

always #5 Pclk<= ~Pclk;

task initialize;
	begin
		Pclk<=1'b0;
		Paddr<=3'b000;
		Pwrite<=0;
		Psel<=0;
		Penable<=0;
		PWdata<=8'd0;
		miso<=0;
	end
endtask

task reset;
	begin
		Preset<=1;
		@(negedge Pclk);
		Preset<=0;
		@(negedge Pclk);
		Preset<=1;
		@(negedge Pclk);
	end
endtask

task write_cr1(input [7:0]PWdata_i);
	begin
		@(posedge Pclk);   //setup phase
		Paddr<=3'b000;
		Pwrite<=1'b1;
		Psel<=1'b1;
		Penable<=1'b0;
		PWdata<=PWdata_i;

		@(posedge Pclk);   //access phase
		Penable<=1'b1;

		@(posedge Pclk);
		while(Pready !== 1'b1)
			@(posedge Pclk);

		Psel<=1'b0;
		Penable<=1'b0;
		Pwrite<=1'b0;
	end
endtask

task write_cr2(input [7:0]PWdata_i);
	begin
		@(posedge Pclk);
		Paddr<=3'b001;
		Pwrite<=1'b1;
		Psel<=1'b1;
		Penable<=1'b0;
		PWdata<=PWdata_i;

		@(posedge Pclk);
		Penable<=1'b1;

		@(posedge Pclk);
		while(Pready !== 1'b1)
			@(posedge Pclk);

		Psel<=1'b0;
		Penable<=1'b0;
		Pwrite<=1'b0;
	end
endtask

task write_baud_reg(input [7:0]PWdata_i);
	begin
		@(posedge Pclk);
		Paddr<=3'b010;
		Pwrite<=1'b1;
		Psel<=1'b1;
		Penable<=1'b0;
		PWdata<=PWdata_i;

		@(posedge Pclk);
		Penable<=1'b1;

		@(posedge Pclk);
		while(Pready !== 1'b1)
			@(posedge Pclk);

		Psel<=1'b0;
		Penable<=1'b0;
		Pwrite<=1'b0;
	end
endtask

task data_reg(input [7:0]PWdata_i);
	begin
		@(posedge Pclk);
		Paddr<=3'b101;
		Pwrite<=1'b1;
		Psel<=1'b1;
		Penable<=1'b0;
		PWdata<=PWdata_i;

		@(posedge Pclk);
		Penable<=1'b1;

		@(posedge Pclk);
		while(Pready !== 1'b1)
			@(posedge Pclk);

		Psel<=1'b0;
		Penable<=1'b0;
		Pwrite<=1'b0;
	end
endtask

task drive_pos_miso(input lsbfe_i,input [7:0]miso_data);
	integer i;
	begin
		wait(~ss);
		if(lsbfe_i)
		begin
			miso<=miso_data[0];
			for(i=1;i<8;i=i+1)
			begin
				@(negedge sclk);
				miso<=miso_data[i];
			end
		end
		else
		begin
			miso<=miso_data[7];
			for(i=6;i>=0;i=i-1)
			begin
				@(negedge sclk);
				miso<=miso_data[i];
			end
		end
	end
endtask

task drive_neg_miso(input lsbfe_i,input [7:0]miso_data);
	integer i;
	begin
		wait(~ss);
		if(lsbfe_i)
		begin
			miso<=miso_data[0];
			for(i=1;i<8;i=i+1)
			begin
				@(posedge sclk);
				miso<=miso_data[i];
			end
		end
		else
		begin
			miso<=miso_data[7];
			for(i=6;i>=0;i=i-1)
			begin
				@(posedge sclk);
				miso<=miso_data[i];
			end
		end
	end
endtask

task read_reg(input [2:0]Paddr_i);
	begin
		@(posedge Pclk);   //setup phase
		Paddr<=Paddr_i;
		Pwrite<=1'b0;
		Psel<=1'b1;
		Penable<=1'b0;

		@(posedge Pclk);   //access phase
		Penable<=1'b1;

		@(posedge Pclk);
		while(Pready !== 1'b1)
			@(posedge Pclk);

		Psel<=1'b0;
		Penable<=1'b0;
	end
endtask
initial begin
	initialize;
	reset;

	write_cr1(8'b1111_0011);
	read_reg(3'b000);

	write_cr1(8'b0000_0100);
	read_reg(3'b000);

	write_cr2(8'b0001_1011);


	write_cr1(8'b1111_1011);
	read_reg(3'b000);

	write_cr2(8'b0001_1011);
	read_reg(3'b001);

	write_baud_reg(8'b0001_0000);
	read_reg(3'b010);

	fork
		data_reg(8'b1100_1101);
		drive_neg_miso(1'b1,8'b1001_1101);
	join

	wait(ss == 1'b1);
	read_reg(3'b101);
	

	write_cr1(8'b1111_1110);
	read_reg(3'b000);

	write_cr2(8'b0001_1011);
	read_reg(3'b001);

	write_baud_reg(8'b0011_0000);
	read_reg(3'b010);

	fork
		data_reg(8'b1100_1101);
		drive_pos_miso(1'b1,8'b1001_1101);
	join

	wait(ss == 1'b1);
	read_reg(3'b101);




	
	write_cr1(8'b1011_1111);
	read_reg(3'b000);

	write_cr2(8'b0001_1011);
	read_reg(3'b001);

	write_cr2(8'b0001_1001);
	read_reg(3'b000);

	write_cr1(8'b1111_1111);
	read_reg(3'b000);

	write_baud_reg(8'b0011_0000);
	read_reg(3'b010);

	fork
		data_reg(8'b1100_1101);
		drive_pos_miso(1'b1,8'b1001_1101);
	join

	wait(ss == 1'b1);
	read_reg(3'b101);


	#200;
	#1000;
	$finish;
end

endmodule

