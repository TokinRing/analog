// megafunction wizard: %LPM_MUX%VBB%
// GENERATION: STANDARD
// VERSION: WM1.0
// MODULE: lpm_mux 

// ============================================================
// File Name: lpm_mux2.v
// Megafunction Name(s):
// 			lpm_mux
// ============================================================
// ************************************************************
// THIS IS A WIZARD-GENERATED FILE. DO NOT EDIT THIS FILE!
//
// 6.0 Build 202 06/20/2006 SP 1 SJ Web Edition
// ************************************************************

//Copyright (C) 1991-2006 Altera Corporation
//Your use of Altera Corporation's design tools, logic functions 
//and other software and tools, and its AMPP partner logic 
//functions, and any output files any of the foregoing 
//(including device programming or simulation files), and any 
//associated documentation or information are expressly subject 
//to the terms and conditions of the Altera Program License 
//Subscription Agreement, Altera MegaCore Function License 
//Agreement, or other applicable license agreement, including, 
//without limitation, that your use is for the sole purpose of 
//programming logic devices manufactured by Altera and sold by 
//Altera or its authorized distributors.  Please refer to the 
//applicable agreement for further details.

module lpm_mux2 (
	data0x,
	data1x,
	data2x,
	data3x,
	data4x,
	data5x,
	data6x,
	data7x,
	sel,
	result);

	input	[7:0]  data0x;
	input	[7:0]  data1x;
	input	[7:0]  data2x;
	input	[7:0]  data3x;
	input	[7:0]  data4x;
	input	[7:0]  data5x;
	input	[7:0]  data6x;
	input	[7:0]  data7x;
	input	[2:0]  sel;
	output	[7:0]  result;

endmodule

// ============================================================
// CNX file retrieval info
// ============================================================
// Retrieval info: CONSTANT: LPM_SIZE NUMERIC "8"
// Retrieval info: CONSTANT: LPM_TYPE STRING "LPM_MUX"
// Retrieval info: CONSTANT: LPM_WIDTH NUMERIC "8"
// Retrieval info: CONSTANT: LPM_WIDTHS NUMERIC "3"
// Retrieval info: USED_PORT: data0x 0 0 8 0 INPUT NODEFVAL data0x[7..0]
// Retrieval info: USED_PORT: data1x 0 0 8 0 INPUT NODEFVAL data1x[7..0]
// Retrieval info: USED_PORT: data2x 0 0 8 0 INPUT NODEFVAL data2x[7..0]
// Retrieval info: USED_PORT: data3x 0 0 8 0 INPUT NODEFVAL data3x[7..0]
// Retrieval info: USED_PORT: data4x 0 0 8 0 INPUT NODEFVAL data4x[7..0]
// Retrieval info: USED_PORT: data5x 0 0 8 0 INPUT NODEFVAL data5x[7..0]
// Retrieval info: USED_PORT: data6x 0 0 8 0 INPUT NODEFVAL data6x[7..0]
// Retrieval info: USED_PORT: data7x 0 0 8 0 INPUT NODEFVAL data7x[7..0]
// Retrieval info: USED_PORT: result 0 0 8 0 OUTPUT NODEFVAL result[7..0]
// Retrieval info: USED_PORT: sel 0 0 3 0 INPUT NODEFVAL sel[2..0]
// Retrieval info: CONNECT: result 0 0 8 0 @result 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 56 data7x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 48 data6x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 40 data5x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 32 data4x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 24 data3x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 16 data2x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 8 data1x 0 0 8 0
// Retrieval info: CONNECT: @data 0 0 8 0 data0x 0 0 8 0
// Retrieval info: CONNECT: @sel 0 0 3 0 sel 0 0 3 0
// Retrieval info: LIBRARY: lpm lpm.lpm_components.all
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2.v TRUE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2.inc FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2.cmp FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2.bsf TRUE FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2_inst.v FALSE
// Retrieval info: GEN_FILE: TYPE_NORMAL lpm_mux2_bb.v TRUE
