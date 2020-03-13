// --------------------------------------------------------------------
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<
// --------------------------------------------------------------------
// Copyright (c) 2019 by UCSD CSE 140L
// --------------------------------------------------------------------
//
// Permission:
//
//   This code for use in UCSD CSE 140L.
//   It is synthesisable for Lattice iCEstick 40HX.  
//
// Disclaimer:
//
//   This Verilog source code is intended as a design reference
//   which illustrates how these types of functions can be implemented.
//   It is the user's responsibility to verify their design for
//   consistency and functionality through the use of formal
//   verification methods.  
//
// -------------------------------------------------------------------- //           
//                     Lih-Feng Tsaur
//                     Bryan Chin
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module dictrl(
        output    dicSelectLEDdisp, //select LED
	    output 	  dicRun,           // clock should run
	    output 	  dicDspMtens,
	    output 	  dicDspMones,
	    output 	  dicDspStens,
	    output 	  dicDspSones,
        output    dicLdMtens,
        output    dicLdMones,
        output    dicLdStens,
        output    dicLdSones,
        // present alarm
        output dic_ADspMtens,
		output dic_ADspMones,
		output dic_ADspStens,
		output dic_ADspSones,
        // load alarm
        output dic_ALdMtens,
		output dic_ALdMones,
		output dic_ALdStens,
		output dic_ALdSones,
        
        output enable_alarm, // enable alarm
        output trigger_alarm, // trigger alarm
        output update_alarm,
        
		input   control_alarm, // enable/disable trigger alarm (1/0)
        input 	    rx_data_rdy,// new data from uart rdy
        input [7:0] rx_data,    // new data from uart
        input 	  rst,
	    input 	  clk               
    );
	//assign dicLdMtens = 1'b0;
	//assign dicLdMones = 1'b0;
	//assign dicLdStens = 1'b0;
	//assign dicLdSones = 1'b0;
	
    wire    det_cr;
    wire    det_S;
    // new variables
    wire    det_L;
    wire    det_A;
    wire    det_atSign;
    wire    det_num0to5;
    wire    det_num;
    
    wire    new_dicLdMtens;
    wire    new_dicLdMones;
    wire    new_dicLdStens;
    wire    new_dicLdSones;
    
    wire new_dic_ALdMtens;
	wire new_dic_ALdMones;
	wire new_dic_ALdStens;
	wire new_dic_ALdSones;
   
    decodeKeys dek ( 
        .det_cr(det_cr),
		.det_S(det_S),             
        .det_N(dicSelectLEDdisp),
        .det_L(det_L),
        .det_A(det_A),
        .det_atSign(det_atSign),
        .det_num0to5(det_num0to5),
        .det_num(det_num),
		.charData(rx_data),      .charDataValid(rx_data_rdy)
    );
    
    assign dicLdMtens = (det_num0to5) ? new_dicLdMtens : 0;
    assign dicLdMones = (det_num) ? new_dicLdMones : 0;
    assign dicLdStens = (det_num0to5) ? new_dicLdStens : 0;
    assign dicLdSones =(det_num) ? new_dicLdSones : 0;

    assign dic_ALdMtens = (det_num0to5) ? new_dic_ALdMtens : 0;
    assign dic_ALdMones = (det_num) ? new_dic_ALdMones : 0;
    assign dic_ALdStens = (det_num0to5) ? new_dic_ALdStens : 0;
    assign dic_ALdSones = (det_num) ? new_dic_ALdSones : 0;
    
    dicClockFsm dicfsm (
		    .dicRun(dicRun),
		    .dicDspMtens(dicDspMtens), .dicDspMones(dicDspMones),
		    .dicDspStens(dicDspStens), .dicDspSones(dicDspSones),
            .dicLdMtens(new_dicLdMtens), .dicLdMones(new_dicLdMones),
		    .dicLdStens(new_dicLdStens), .dicLdSones(new_dicLdSones),
            .dic_ADspMtens(dic_ADspMtens), .dic_ADspMones(dic_ADspMones),
		    .dic_ADspStens(dic_ADspStens), .dic_ADspSones(dic_ADspSones),
            .dic_ALdMtens(new_dic_ALdMtens), .dic_ALdMones(new_dic_ALdMones),
		    .dic_ALdStens(new_dic_ALdStens), .dic_ALdSones(new_dic_ALdSones),
            .enable_alarm(enable_alarm),
            .trigger_alarm(trigger_alarm),
            .update_alarm(update_alarm),
            .control_alarm(control_alarm),
            .det_L(det_L),
            .det_A(det_A),
            .det_atSign(det_atSign),
            .det_num0to5(det_num0to5),
            .det_num(det_num),
            .det_cr(det_cr),
		    .det_S(det_S), 
		    .rst(rst),
		    .clk(clk)
    );
   
endmodule


