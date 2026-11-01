module SPI_master_core(
	input Pclk,
	input Preset,
	input [2:0]Paddr,
	input Pwrite,
	input Psel,
	input Penable,
	input [7:0]PWdata,
	input miso,
	output ss,
	output sclk,
	output spi_int_req,
	output mosi,
	output [7:0]PRdata,
	output Pready,
	output Pslverr);

wire [1:0]spi_mode;
wire spiswai;
wire [2:0]sppr;
wire [2:0]spr;
wire cpol;
wire cpha;
wire send_data;
wire lsbfe;
wire [7:0]data_mosi;
wire receive_data;
wire [7:0]data_miso;
wire tip;
wire mstr;
wire miso_rx_sclk_pos;
wire miso_rx_sclk_neg;
wire mosi_tx_sclk_pos;
wire mosi_tx_sclk_neg;
wire [11:0]baud_rate_div;


SPI_sclk_generator buad_gen(
	.pclk(Pclk),
	.preset(Preset),
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

shift_register shift_reg(
	.pclk(Pclk),
	.preset(Preset),
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


apb_slave_interface slave_interface(
	.Pclk(Pclk),
	.Preset(Preset),
	.Paddr(Paddr),
	.Pwrite(Pwrite),
	.Psel(Psel),
	.Penable(Penable),
	.PWdata(PWdata),
	.ss(ss),
	.miso_data(data_miso),
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
	.mosi_data(data_mosi),
	.spi_mode(spi_mode));

slave_control_select slave_select(
	.Pclk(Pclk),
	.Preset(Preset),
	.mstr(mstr),
	.spiswai(spiswai),
	.spi_mode(spi_mode),
	.send_data(send_data),
	.baud_rate_divisor(baud_rate_div),
	.tip(tip),
	.receive_data(receive_data),
	.ss(ss));

endmodule
	



