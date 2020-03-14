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
//                     UCSD CSE Department
//                     9500 Gilman Dr, La Jolla, CA 92093
//                     U.S.A
//
// --------------------------------------------------------------------

module Lab4_140L (
		input wire       rst,             // reset signal (active high)
		input wire       clk,             // global clock
		input wire       bu_rx_data_rdy,  // data from the uart ready
		input wire [7:0] bu_rx_data,      // data from the uart
		output wire 	 L4_tx_data_rdy,  // data rdy to display
		output wire[7:0] L4_tx_data,      // data to display
		output wire[4:0] L4_led,          //5 LED control - 1: on, 0, off
		output wire      oneSecPluse,     //Generate 0.5 sec high and 0.5 sec low    	  
		output wire[6:0] L4_segment1,     //not used in Lab-2
		output wire[6:0] L4_segment2,     //not used in Lab-2
		output wire[6:0] L4_segment3,     //not used in Lab-2
		output wire[6:0] L4_segment4,     //not used in Lab-2
                                     

		output wire[3:0] di_Mtens,        //not used in Lab-2
		output wire[3:0] di_Mones,        //not used in Lab-2
		output wire[3:0] di_Stens,        //not used in Lab-2
		output wire[3:0] di_Sones,        //not used in Lab-2
		output wire[3:0] di_AMtens,       //not used in Lab-2
		output wire[3:0] di_AMones,       //not used in Lab-2
		output wire[3:0] di_AStens,       //not used in Lab-2
		output wire[3:0] di_ASones,        //not used in Lab-2
        
        // new variables
        output wire l_oneSecPluse,
        output wire dicRun, // middle led to specify clock is running or not
        output wire alarm_state,    // state of alarm: activate/deactivate
        output wire update_alarm,
        output wire trigger_alarm,  // alarm is triggered (1/0)
        output wire control_alarm,  // 
        output wire activate_alarm  // 
    );
    wire[7:0] rx_data;
    wire rx_data_rdy;
    regrce #(8) Lab4U00 (
    .q(rx_data),
    .d(bu_rx_data),
    .ce(bu_rx_data_rdy),    //clock enable
    .rst(rst),              // synchronous reset
    .clk(clk)
    );
    regrce #(1) Lab4U01 (
    .q(rx_data_rdy),
    .d(bu_rx_data_rdy),
    .ce(1'b1),           //clock enable
    .rst(rst),           // synchronous reset
    .clk(clk)
    );
     
    // generate a sync signal
    //
    //                  | < ------- 1 sec -------|
    //
    //   oneSecStrb_____/----\_________......____/----\_______
    //
    //        clk  ___/--\__/--\__/--\.......__/--\__/--
    //
    //wire l_oneSecPluse, l_oneSecStrb;
    wire l_oneSecStrb;
    Half_Sec_Pulse_Per_Sec secuu0 (
			.i_rst (rst),       //reset
			.i_clk (clk),       //system clk 12MHz 
            .o_sec_tick (l_oneSecPluse), //ON-OFF, and with signal
			.o_sec_enab (l_oneSecStrb)
        );

    wire dicSelectLEDdisp;
    wire dicDspMtens, dicDspMones, dicDspStens, dicDspSones; //1:display, 0: don't display
    wire dicLdMtens, dicLdMones, dicLdStens, dicLdSones;     //1:load clk digit, 0: don't load
    // new in lab4
    wire enable_alarm; // enable alarm
    wire dic_ADspMtens, dic_ADspMones, dic_ADspStens, dic_ADspSones;//1:display value, 0: display -
    wire dic_ALdMtens, dic_ALdMones, dic_ALdStens, dic_ALdSones;    //1:load clk digit, 0: don't load 
    dictrl dictrluu0(
        .dicSelectLEDdisp(dicSelectLEDdisp),
	    .dicRun(dicRun),             // clock should run
	    .dicDspMtens(dicDspMtens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspMones(dicDspMones),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspStens(dicDspStens),   // 1: update 7 segment; 0: freeze 7 segment display
	    .dicDspSones(dicDspSones),   // 1: update 7 segment; 0: freeze 7 segment display
        .dicLdMtens(dicLdMtens),
        .dicLdMones(dicLdMones),
        .dicLdStens(dicLdStens),
        .dicLdSones(dicLdSones),
        .dic_ALdMtens(dic_ALdMtens),
        .dic_ALdMones(dic_ALdMones),
        .dic_ALdStens(dic_ALdStens),
        .dic_ALdSones(dic_ALdSones),
        .dic_ADspMtens(dic_ADspMtens),
        .dic_ADspMones(dic_ADspMones),
        .dic_ADspStens(dic_ADspStens),
        .dic_ADspSones(dic_ADspSones),
        
        .enable_alarm(enable_alarm),
        .update_alarm(update_alarm),
        .trigger_alarm(trigger_alarm),
        .control_alarm(control_alarm),
		
        .rx_data_rdy(rx_data_rdy),// new data from uart rdy
        .rx_data(rx_data),        // new data from uart
        .rst(rst),
	    .clk(clk)
    );

   didp didpuu0(
        // output
	    .di_iMtens(di_Mtens), // current 10's minutes
	    .di_iMones(di_Mones), // current 1's minutes
	    .di_iStens(di_Stens), // current 10's second
	    .di_iSones(di_Sones), // current 1's second
        .o_oneSecPluse(oneSecPluse),
        .L4_led(L4_led),
		//loading clock
        .ldMtens(dicLdMtens), // set to 0 in lab3
        .ldMones(dicLdMones), // set to 0 in lab3
        .ldStens(dicLdStens), // set to 0 in lab3
        .ldSones(dicLdSones), // set to 0 in lab3
	    .ld_num(rx_data[3:0]),
        // new
		.di_AMtens(di_AMtens),
        .di_AMones(di_AMones),
        .di_AStens(di_AStens),
        .di_ASones(di_ASones),       
        .di_ldAMtens(dic_ALdMtens),
        .di_ldAMones(dic_ALdMones),
        .di_ldAStens(dic_ALdStens),
        .di_ldASones(dic_ALdSones),
        .alarm_state(alarm_state),
        .enable_alarm(enable_alarm),
        .trigger_alarm(trigger_alarm),
        .update_alarm(update_alarm),
		
        .dicSelectLEDdisp(dicSelectLEDdisp),		
	    .dicRun(dicRun),                // 1: clock runs, 0: clock freeze 
        .i_oneSecPluse(l_oneSecPluse),	// 0.5 sec on, 0.5sec off
	    .i_oneSecStrb(l_oneSecStrb),    // one strobe per sec
	    .rst(rst),
	    .clk(clk) 	  
	);

    // convert to the presentation of 7 segment display
    bcd2segment dec0 (.segment(L4_segment1), .num(di_Sones), .enable(dicDspSones));
    bcd2segment dec1 (.segment(L4_segment2), .num(di_Stens), .enable(dicDspStens));
    bcd2segment dec2 (.segment(L4_segment3), .num(di_Mones), .enable(dicDspMones));
    bcd2segment dec3 (.segment(L4_segment4), .num(di_Mtens), .enable(dicDspMtens));
    
    // new: convert 4-bit num to 8-bit BCD
    wire [7:0] bcd_AMtens;
    wire [7:0] bcd_AMones;
    wire [7:0] bcd_AStens;
    wire [7:0] bcd_ASones;
    
    Num2BCD Mtens(.bcd(bcd_AMtens), .num(di_AMtens));
    Num2BCD Mones(.bcd(bcd_AMones), .num(di_AMones));
    Num2BCD Stens(.bcd(bcd_AStens), .num(di_AStens));
    Num2BCD Sones(.bcd(bcd_ASones), .num(di_ASones));
    
    assign control_alarm = (alarm_state & ~|(di_Mtens ^ di_AMtens) & ~|(di_Mones ^ di_AMones) & ~|(di_Stens ^ di_AStens) & ~|(di_Sones ^ di_ASones) ) ? 1'b1 : 1'b0;
    
    wire [7:0] alarm_AMtens = (dic_ADspMtens) ? bcd_AMtens : "-";
    wire [7:0] alarm_AMones = (dic_ADspMones) ? bcd_AMones : "-";
    wire [7:0] alarm_AStens = (dic_ADspStens) ? bcd_AStens : "-";
    wire [7:0] alarm_ASones = (dic_ADspSones) ? bcd_ASones : "-";
    wire [7:0] alarm_colon = (dic_ADspMones) ? ":" : "-";
    wire [7:0] alarm_status = (trigger_alarm) ? "T" : ((alarm_state) ? "@" : "-");
    

    //wire [7:0] my_b2 = (alarm ctr_sign) ? number:
    
    dispString dspStr (
		  .rdy(L4_tx_data_rdy)
        , .dOut(L4_tx_data)
		, .b0("A") 
		, .b1(alarm_AMtens)
		, .b2(alarm_AMones)
		, .b3(alarm_colon) // :
		, .b4(alarm_AStens) 
		, .b5(alarm_ASones)
        , .b6(alarm_status) // T, @, -
		, .b7(8'h0d)		
		, .go(l_oneSecStrb | l_oneSecPluse)	
		, .rst(rst)
		, .clk(clk)
    );
	
endmodule // Lab4_140L
