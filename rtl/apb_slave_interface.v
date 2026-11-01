module apb_slave_interface(
	input Pclk,
	input Preset,
	input [2:0]Paddr,
	input Pwrite,
	input Psel,
	input Penable,
	input [7:0]PWdata,
	input ss,
	input [7:0]miso_data,
	input receive_data,
	input tip,
	output reg[7:0]PRdata,
	output mstr,
	output cpol,
	output cpha,
	output lsbfe,
	output spiswai,
	output [2:0]sppr,
	output [2:0]spr,
	output spi_int_req,
	output Pready,
	output Pslverr,
	output reg send_data,
	output reg [7:0]mosi_data,
	output reg [1:0]spi_mode);

localparam idle=2'b00,
	setup=2'b01,
	access=2'b10;

localparam spi_run=2'b00,
	spi_wait=2'b01,
	spi_stop=2'b10;

localparam cr2_mask=8'b0001_1011,
	    br_mask=8'b0111_0111;

wire wr_en;
wire rd_en;
wire ssoe;
wire sptie;
wire spe;
wire spie;
wire modfen;
wire modf;

reg sptef;
reg spif;
reg [1:0]pstate,nstate;
reg [1:0]spi_nmode;

reg [7:0]control_reg1;
reg [7:0]control_reg2;
reg [7:0]data_reg;
reg [7:0]baud_reg;
reg [7:0]status_reg;

always@(posedge Pclk or negedge Preset)
begin
	if(!Preset)
		pstate<=idle;
	else 
		pstate<=nstate;
end

always@(*)
begin
	case(pstate)
		idle:
		begin
			if(Psel==1 && !Penable)
				nstate = setup;
			else
				nstate = idle;
		end
		setup:
		begin
			if(Psel && Penable)
				nstate = access;
			else if(Psel && !Penable)
				nstate = setup;
			else
				nstate = idle;
		end
		access:
		begin
			if(Psel)
				nstate = setup;
			else
				nstate = idle;
		end
		default: nstate = idle;
		
		endcase
end

assign Pready=(pstate == access) ? 1'b1:1'b0;
assign Pslverr = (pstate == access) ? ~tip : 1'b0;
assign wr_en = ((pstate == access) && (Pwrite)); 
assign rd_en = ((pstate == access) && (!Pwrite));

always @(posedge Pclk or negedge Preset)
begin
	if(!Preset)
	begin
		control_reg1<=8'b0000_0100;
		control_reg2<=8'b0000_0000;
		    data_reg<=8'b0000_0000;
		    baud_reg<=8'b0000_0000;
		    send_data<=1'b0;
		    mosi_data<=8'b0000_0000;
	end
	else if(wr_en)
	begin
		case(Paddr)
			3'b000:
				control_reg1<=PWdata;
			3'b001:
				control_reg2<=(PWdata & cr2_mask);
			3'b010:
				baud_reg<=(PWdata & br_mask);
			3'b101:
				data_reg<=PWdata;
			default:
				data_reg<=PWdata;
		endcase
	end
	else if((data_reg == PWdata) && (data_reg != miso_data) && (spi_mode==spi_run || spi_mode==spi_wait))
		begin
			send_data<=1;
			mosi_data<=data_reg;
			data_reg<=0;
		end
	else if((receive_data) && (spi_mode==spi_run || spi_mode==spi_wait))
	begin
		send_data<=0;
		data_reg<=miso_data;
	end
	else
		send_data<=0;

end

always@(*)
begin
	if(rd_en)
	begin
		case(Paddr)
			3'b000:
				PRdata=control_reg1;
			3'b001:
				PRdata=control_reg2;
			3'b010:
				PRdata=baud_reg;
			3'b011:
				PRdata=status_reg;
			3'b101:
				PRdata=data_reg;
			default: 
				PRdata=8'd0;
		endcase
	end
	else
		PRdata=8'd0;
end

assign lsbfe=control_reg1[0];
assign ssoe=control_reg1[1];
assign cpha=control_reg1[2];
assign cpol=control_reg1[3];
assign mstr=control_reg1[4];
assign sptie=control_reg1[5];
assign spe=control_reg1[6];
assign spie=control_reg1[7];

assign spiswai=control_reg2[1];
assign modfen=control_reg2[4];

assign sppr=baud_reg[6:4];
assign spr=baud_reg[2:0];

assign modf=((~ss) && (mstr) && (modfen) && (!ssoe));

assign spi_int_req = (!spie && !sptie) ? 0:
		     (spie && !sptie) ? (spif || modf): 
		     (!spie && sptie) ? sptef : (spif || sptef || modf);

always@(posedge Pclk or negedge Preset)
begin
	if(!Preset)
		spi_mode<=spi_run;
	else
		spi_mode<=spi_nmode;
end

always@(*)
begin
	case(spi_mode)
		spi_run:
		begin
			if(!spe)
				spi_nmode=spi_wait;
			else
				spi_nmode=spi_run;
		end
		spi_wait:
		begin
			if(spe)
				spi_nmode=spi_run;
			else
			begin
				if(spiswai)
					spi_nmode=spi_stop;
				else
					spi_nmode=spi_wait;
			end
		end
		spi_stop:
		begin
			if(spe)
				spi_nmode=spi_run;
			else
			begin
				if(!spiswai)
					spi_nmode=spi_wait;
				else
					spi_nmode=spi_stop;
			end
		end
		default:
			spi_nmode=spi_run;
	endcase
end


always@(*)
begin
	if(!Preset)
	begin
		status_reg=8'b0010_0000;
		sptef = 1'b0;
		spif = 1'b0;
	end


	else
	begin
		if(data_reg==8'd0)
			sptef = 1'b1;
		else
			sptef = 1'b0;

		if(data_reg !=8'd0)
			spif = 1'b1;
		else 
			spif = 1'b0;
		status_reg={spif,1'b0,sptef,modf,4'd0};
	end
end

	
endmodule


