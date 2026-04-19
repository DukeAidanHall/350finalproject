/*
Top module for connect 4 game

Hierarchy:

Top: "top.v"
    wrapper: "Wrapper.v"
        CPU: "processor.v"
        imem: "ROM.v"
            compliedMips: "connectFour.mem"
        dmem: "RAM.v"
        regfile: "regfile.v"
    servo: "ServoController.v"
        serializer: "PWMSerializer.v"


Notes:
Register Mapped Input (must add code to make CPU see hardware as a register)
    $dmem[400] drop flag (BTNC)
    $dmem[401] reset flag (BTND)
    $dmem[402] column flag (calculated from servo state)

*/
module top (
    input clock, // system clock input
    input BTNC, // center button press
    input BTNR, // right button press
    input BTNL, // left button press
    input BTND, // down button press
    
    output[8:0] LED, // debug LEDs
    output servoSignal, // servo 1 (left/right)
    output servoSignal2, // servo 2 (drop)
    );

    reg MediumCounter = 0;
    reg oldBTND = 0;
    reg resetFlag = 0;

    always @(posedge clk) begin //Builds the medium speed clock
        if(counter < 32'd50000000) begin
            counter <= counter+1;
        end else begin
            counter <= 0;
            MediumCounter <= ~MediumCounter;
        end
      end

    always @(posedge MediumCounter) begin
        oldBTND <= BTND;
        if(BTND && !(oldBTND)) begin //Reset on any BTND press
            resetFlag <= 1;
        end
    end

    Wrapper CPUWrapper(.clock(clock), .reset(resetFlag));

    ServoController Servo(.clk(clock), .BTNC_In(BTNC), .BTNR_In(BTNR), 
    .BTNL_In(BTNL), .LED_Out(LED), .servoSignal_Out(servoSignal),
    .servoSignal2_Out(servoSignal2));

endmodule