module tb_apb_slave_interface;
	reg Pclk;
	reg Preset;
	reg [2:0]Paddr;
	reg Pwrite;
	reg Psel;
	reg Penable;
	reg [7:0]PWdata;
	reg ss;
	reg [7:0]miso_data;
	reg receive_data;
	reg tip;

	wire [7:0]PRdata;
	wire mstr;
	wire cpol;
	wire cpha;
	wire lsbfe;
	wire spiswai;
	wire [2:0]sppr;
	wire [2:0]spr;
	wire spi_int_req;
	wire Pready;
	wire Pslverr;
	wire send_data;
	wire [7:0]mosi_data;
	wire [1:0]spi_mode;

apb_slave_interface dut(
	.Pclk(Pclk),
	.Preset(Preset),
	.Paddr(Paddr),
	.Pwrite(Pwrite),
	.Psel(Psel),
	.Penable(Penable),
	.PWdata(PWdata),
	.ss(ss),
	.miso_data(miso_data),
	.receive_data(receive_data),
	.tip(tip),
	.PRdata(PRdata),
	.mstr(mstr),
	.cpol(cpol),
	.cpha(cpha),
	.lsbfe(lsbfe),
	.spiswai(spiswai),
	.sppr(sppr),
	.spr(spr),
	.spi_int_req(spi_int_req),
	.Pready(Pready),
	.Pslverr(Pslverr),
	.send_data(send_data),
	.mosi_data(mosi_data),
	.spi_mode(spi_mode));

always #5 Pclk<=~Pclk;

task initialize;
	begin
		Pclk=0;
		Preset=1;
		Paddr=3'b000;
		Pwrite=0;
		Psel=0;
		Penable=0;
		PWdata=8'd0;
		ss=1;
		miso_data=8'd0;
		receive_data=0;

		//your DUT reports Pslverr when tip is 0
		tip=1;
	end
endtask

task reset;
	begin
		@(negedge Pclk);
		Preset<=0;
		repeat(2) @(negedge Pclk);
		Preset<=1;
	end
endtask

task write_data(
	input [2:0]Paddr_i,
	input [7:0]PWdata_i,
	input ss_i);
	begin
		//setup phase
		@(negedge Pclk);
		Paddr<=Paddr_i;
		PWdata<=PWdata_i;
		ss<=ss_i;
		Pwrite<=1;
		Psel<=1;
		Penable<=0;

		//access phase
		@(negedge Pclk);
		Penable<=1;

		//wait for the transfer completion edge
		wait(Pready === 1'b1);
		@(posedge Pclk);

		//end the transfer
		@(negedge Pclk);
		Psel<=0;
		Penable<=0;
		Pwrite<=0;
	end
endtask

task read(input [2:0]Paddr_i);
	begin
		//setup phase
		@(negedge Pclk);
		Paddr<=Paddr_i;
		Pwrite<=0;
		Psel<=1;
		Penable<=0;

		//access phase
		@(negedge Pclk);
		Penable<=1;

		//wait for the transfer completion edge
		wait(Pready === 1'b1);
		@(posedge Pclk);

		//end the transfer
		@(negedge Pclk);
		Psel<=0;
		Penable<=0;
	end
endtask

task drive_miso(input [7:0]miso_data_i);
	begin
		@(negedge Pclk);
		miso_data<=miso_data_i;
		receive_data<=1;

		@(negedge Pclk);
		receive_data<=0;
	end
endtask

initial
begin
	initialize;
	reset;

	write_data(3'b000,8'b0111_0111,1'b0);
	read(3'b000);

	write_data(3'b001,8'b0001_0010,1'b0);
	read(3'b001);

	write_data(3'b010,8'b0001_1010,1'b0);
	read(3'b010);

	write_data(3'b101,8'b0011_1101,1'b0);
	read(3'b101);

	drive_miso(8'b1010_0101);
	read(3'b101);
	read(3'b011);

	#200;
	$finish;
end


endmodule
