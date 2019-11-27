/*
 * Copyright (C)2006-2019 AQUAXIS TECHNOLOGY.
 *  Don't remove this header. 
 * When you use this source, there is a need to inherit this header.
 *
 * License: MIT License
 *
 * For further information please contact.
 *	URI:    http://www.aquaxis.com/
 *	E-Mail: info(at)aquaxis.com
 */
module aq_ram25x16 (
	input			CLKA,
	input			WEA,
	input [15:0]	ADDRA,
	input [24:0]	DINA,
	
	input			CLKB,
	input [15:0]	ADDRB,
	output [24:0]	DOUTB
);

reg [24:0]	array [0:2048];

always @( posedge CLKA ) begin
	if( WEA ) begin
		array[ ADDRA[10:0] ] = DINA[24:0];
	end
end

reg [24:0] data;
always @( posedge CLKB ) begin
	data[24:0]	= array[ ADDRB[10:0] ];
end

assign DOUTB[24:0] = data[24:0];

endmodule
