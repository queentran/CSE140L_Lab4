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
//
//Finite State Machine of Control Path
// using 3 always 
module dicClockFsm (
		output reg dicRun,     // clock is running //1: clicking, 0: disable
		output reg dicDspMtens,
		output reg dicDspMones,
		output reg dicDspStens,
		output reg dicDspSones, //presentable
        // load time
        output reg dicLdMtens,
        output reg dicLdMones,
        output reg dicLdStens,
        output reg dicLdSones,
        // present alarm
        output reg dic_ADspMtens,
		output reg dic_ADspMones,
		output reg dic_ADspStens,
		output reg dic_ADspSones,
        // load alarm
        output reg dic_ALdMtens,
		output reg dic_ALdMones,
		output reg dic_ALdStens,
		output reg dic_ALdSones,
        
        output reg enable_alarm, // enable alarm
        output reg trigger_alarm, // trigger alarm
        output reg update_alarm,

        // old input
        input      det_cr,
        input      det_S,      // S/s detected
		input      rst,//reset key ESC
		input      clk,
        // new input
        input       det_L,
        input       det_A,
        input       det_atSign,
        input       det_num0to5,                 
        input       det_num,
        input       control_alarm // for trigger state        
    );
    
    // new in lab4
    // we need 5 bits for each state to fulfill all the states
    // we have some extra states to solve asynchronous and latch issues
    reg [4:0]  cState; // change to 5-bit to match 5-bit states
    reg [4:0]  nState; // change to 5-bit to match 5-bit states

    // only 2 states:
    //  RUN: dicRun = 1;  dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    //  STOP: dicRun = 0; dicDspMtens = 1; dicDspMones = 1; dicDspStens = 1; dicDspSones= 1;
    localparam
    //STOP    =1'b0, 
    //RUN     =1'b1,
    STOP = 5'b00000,
    RUN = 5'b00001,
    // load_time states
    LOAD_TIME_1 = 5'b00010,
    LOAD_TIME_2 = 5'b00011,
    LOAD_TIME_3 = 5'b00100,
    LOAD_TIME_4 = 5'b00101,
    LOAD_TIME_5 = 5'b00110,
    
    EXTRA_STATE_TIME_1 = 5'b00111,
    EXTRA_STATE_TIME_2 = 5'b01000,
    EXTRA_STATE_TIME_3 = 5'b01001,
    EXTRA_STATE_TIME_4 = 5'b01010,
    EXTRA_STATE_TIME_5 = 5'b01011,
    
    // load_alarm states
    LOAD_ALARM_1 = 5'b01100,
    LOAD_ALARM_2 = 5'b01101,
    LOAD_ALARM_3 = 5'b01110,
    LOAD_ALARM_4 = 5'b01111,
    LOAD_ALARM_5 = 5'b10000,
    
    EXTRA_STATE_ALARM_1 = 5'b10001,
    EXTRA_STATE_ALARM_2 = 5'b10010,
    EXTRA_STATE_ALARM_3 = 5'b10011,
    EXTRA_STATE_ALARM_4 = 5'b10100,
    EXTRA_STATE_ALARM_5 = 5'b10101,
    
    // alarm states
    ACTIVATE_ALARM = 5'b10110,
    DEACTIVATE_ALARM = 5'b10111,
    TRIGGER_ALARM = 5'b11000,
    
    EXTRA_STATE_1 = 5'b11001,
    EXTRA_STATE_2 = 5'b11010,
    EXTRA_STATE_3 = 5'b11011,
    EXTRA_STATE_4 = 5'b11100,
    EXTRA_STATE_5 = 5'b11101;
                              
   
   
    //
    // state machine next state
    //
    //FSM.1 add code to set nState to STOP or RUN
    //      if det_S -- nState = RUN
    //      if det_cr -- nState = STOP
    //      5% of points assigned to lab3
    always @(*) begin
        if (rst)
	        nState = STOP;
        else
            //nState = 1'bx;
            case (cState)
                RUN:
                begin
                    nState = (det_cr) ? STOP : ((det_L) ? LOAD_TIME_1 : ((det_A) ? LOAD_ALARM_1 : ((det_atSign) ? ACTIVATE_ALARM : ((control_alarm & update_alarm) ? TRIGGER_ALARM : RUN))));
                end 
                STOP:
                begin
                    nState = (det_S) ? RUN : ((det_L) ? LOAD_TIME_1 : ((det_A) ? LOAD_ALARM_1 : ((det_atSign) ? ACTIVATE_ALARM : ((control_alarm & update_alarm) ? TRIGGER_ALARM : STOP))));
                end
                
                EXTRA_STATE_TIME_1: 
                begin
                end
                EXTRA_STATE_TIME_2: 
                begin 
                end
                EXTRA_STATE_TIME_3: 
                begin 
                end
                EXTRA_STATE_TIME_4: 
                begin
                end
                EXTRA_STATE_TIME_5: 
                begin 
                end
                LOAD_TIME_1:
                begin
                    nState = (det_num0to5) ? LOAD_TIME_2 : LOAD_TIME_1;
                end
                LOAD_TIME_2:
                begin
                    nState = (det_num) ? LOAD_TIME_3 : LOAD_TIME_2;
                end
                LOAD_TIME_3:
                begin
                    nState = (det_num0to5) ? LOAD_TIME_4 : LOAD_TIME_3;
                end
                LOAD_TIME_4:
                begin
                    nState = (det_num) ? LOAD_TIME_5 : LOAD_TIME_4;
                end
                LOAD_TIME_5:
                begin
                    nState = (det_cr) ? STOP : ((det_S) ? RUN : ((det_atSign) ? ACTIVATE_ALARM : LOAD_TIME_5));
                end
                
                EXTRA_STATE_ALARM_1: 
                begin
                end
                EXTRA_STATE_ALARM_2: 
                begin
                end
                EXTRA_STATE_ALARM_3: 
                begin
                end
                EXTRA_STATE_ALARM_4: 
                begin
                end
                EXTRA_STATE_ALARM_5: 
                begin
                end
                LOAD_ALARM_1:
                begin
                    nState = (det_num0to5) ? LOAD_ALARM_2 : ((det_atSign) ? ACTIVATE_ALARM : LOAD_ALARM_1);
                end
                LOAD_ALARM_2:
                begin
                    nState = (det_num) ? LOAD_ALARM_3 : ((det_atSign) ? ACTIVATE_ALARM : LOAD_ALARM_2);
                end
                LOAD_ALARM_3:
                begin
                    nState = (det_num0to5) ? LOAD_ALARM_4 : ((det_atSign) ? ACTIVATE_ALARM : LOAD_ALARM_3);
                end
                LOAD_ALARM_4:
                begin
                    nState = (det_num) ? LOAD_ALARM_5 : ((det_atSign) ? ACTIVATE_ALARM : LOAD_ALARM_4);
                end
                LOAD_ALARM_5:
                begin
                    nState = (det_cr) ? STOP : ((det_S) ? RUN: ((det_atSign) ? ACTIVATE_ALARM : LOAD_ALARM_5));
                end
                
                DEACTIVATE_ALARM:
                begin
                    nState = (det_atSign) ? ACTIVATE_ALARM : ((det_S) ? RUN : ((det_cr) ? STOP : ((det_A) ? LOAD_ALARM_1 : DEACTIVATE_ALARM)));
                end
                
                ACTIVATE_ALARM:
                begin
                    nState = (det_atSign) ? DEACTIVATE_ALARM : ((det_S) ? RUN : ((det_cr) ? STOP : ((control_alarm & update_alarm) ? TRIGGER_ALARM : ACTIVATE_ALARM)));
                end
                
                TRIGGER_ALARM:
                begin
                    nState = (det_atSign) ? DEACTIVATE_ALARM : ((det_A) ? LOAD_ALARM_1 : TRIGGER_ALARM);
                end
                
                EXTRA_STATE_1: 
                begin
                end 
                EXTRA_STATE_2: 
                begin
                end 
                EXTRA_STATE_3: 
                begin
                end 
                EXTRA_STATE_4: 
                begin
                end 
                EXTRA_STATE_5: 
                begin
                end 

                default :
                    nState = STOP;
            endcase
    end

    //
    // state machine outputs
    //
    //FSM.2 add code to set the output signals of 
    //      STOP and RUN states
	//      5% of points assigned to Lab3
    always @(*) begin
        if (rst) begin
            dicRun = 1'b0;
            dicDspMtens = 1'b0;
            dicDspMones = 1'b0;
            dicDspStens = 1'b0;
            dicDspSones = 1'b0;
            dicLdMtens = 1'b0;
            dicLdMones = 1'b0;
            dicLdStens = 1'b0;
            dicLdSones = 1'b0;
            dic_ADspMtens = 1'b0;
            dic_ADspMones = 1'b0;
            dic_ADspStens = 1'b0;
            dic_ADspSones = 1'b0;
            dic_ALdMtens = 1'b0;
            dic_ALdMones = 1'b0;
            dic_ALdStens = 1'b0;
            dic_ALdSones = 1'b0;
            enable_alarm = 1'b0;
            update_alarm = 1'b0;
            trigger_alarm = 1'b0;
        end
        else begin
            case (cState)
                STOP : begin
                    dicRun = 1'b0; 
                    dicDspMtens = 1'b1;
                    dicDspMones = 1'b1;
                    dicDspStens = 1'b1;
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;	    
                end
                RUN : begin
                    dicRun = 1'b1; 
                    dicDspMtens = 1'b1;
                    dicDspMones = 1'b1;
                    dicDspStens = 1'b1;
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_TIME_1 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b0; 
                    dicDspStens = 1'b0; 
                    dicDspSones = 1'b0;
                    dicLdMtens = 1'b1;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_TIME_2 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b0; 
                    dicDspSones = 1'b0;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b1;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_TIME_3 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b0;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b1;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_TIME_4 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b1;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_TIME_5 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                end
                LOAD_ALARM_1 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b1;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMtens = 1'b1;
                end
                LOAD_ALARM_2 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b1;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMones = 1'b1;
                end
                LOAD_ALARM_3 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b1;
                    dic_ALdSones = 1'b0;
                    dic_ADspStens = 1'b1;
                end
                LOAD_ALARM_4 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b1;
                    dic_ADspSones = 1'b1;
                end
                LOAD_ALARM_5 : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMtens = 1'b1;
                    dic_ADspMones = 1'b1;
                    dic_ADspStens = 1'b1;
                    dic_ADspSones = 1'b1;
                end
                DEACTIVATE_ALARM : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMtens = 1'b1;
                    dic_ADspMones = 1'b1;
                    dic_ADspStens = 1'b1;
                    dic_ADspSones = 1'b1;
                    enable_alarm = 1'b1;
                    update_alarm = 1'b0;
                    trigger_alarm = 1'b0;
                end
                ACTIVATE_ALARM : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMtens = 1'b1;
                    dic_ADspMones = 1'b1;
                    dic_ADspStens = 1'b1;
                    dic_ADspSones = 1'b1;
                    enable_alarm = 1'b1;
                    update_alarm = 1'b1;
                    trigger_alarm = 1'b0;
                end
                TRIGGER_ALARM : begin
                    dicDspMtens = 1'b1; 
                    dicDspMones = 1'b1; 
                    dicDspStens = 1'b1; 
                    dicDspSones = 1'b1;
                    dicLdMtens = 1'b0;
                    dicLdMones = 1'b0;
                    dicLdStens = 1'b0;
                    dicLdSones = 1'b0;
                    dic_ALdMtens = 1'b0;
                    dic_ALdMones = 1'b0;
                    dic_ALdStens = 1'b0;
                    dic_ALdSones = 1'b0;
                    dic_ADspMtens = 1'b1;
                    dic_ADspMones = 1'b1;
                    dic_ADspStens = 1'b1;
                    dic_ADspSones = 1'b1;
                    trigger_alarm = 1'b1;
                end
            endcase
        end
    end
    always @(posedge clk) begin
        cState <= nState;
    end
   
endmodule