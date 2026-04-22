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
Memory Mapped Input
    dmem[400] drop flag (BTNC)
    dmem[401] reset flag (BTND)
    dmem[402] column flag (calculated from servo state)

Memory Mapped Output
    dmem[300] error (LED 14)
    dmem[501] player 1 won (LED 11)
    dmem[502] player 2 won (LED 12)

Code Below
*/
module top (
    input clk, // system clock input
    input BTNC, // center button press
    input BTNR, // right button press
    input BTNL, // left button press
    input BTND, // down button press
    input leftButtonExt, //exterior left press 
    input rightButtonExt, //exterior right press 
    input dropButtonExt, //exterior drop press 
    input resetButtonExt, //exterior reset press
    //input aiButtonExt, //exterior ai press (TRIAL)
    
    output[14:0] LED, // debug LEDs
    output servoSignal, // servo 1 (left/right)
    output servoSignal2, // servo 2 (drop)
    output player1win,
    output player2win
    );
    
    reg [31:0] counter = 0;
    reg [31:0] MediumCounter = 0;
    reg oldBTND = 0;
    reg [31:0] BTNDPress = 0;
    reg oldBTNC = 0;
    reg [31:0] BTNCPress = 0;
    reg aiEnabled = 0;
    reg player2Turn = 0;

    wire [31:0] column;

    wire Err;
    wire Win1;
    wire Win2;
    assign LED[14] = Err;
    assign LED[11] = Win1;
    assign player1win = Win1;
    assign LED[12] = Win2;
    assign player2win = Win2;
    assign LED[13] = aiEnabled;

    reg [31:0] aiDelay = 31'd100;

    always @(posedge clk) begin //Builds the medium speed clock
        if(counter < 32'd50000000) begin
            counter <= counter+1;
        end else begin
            counter <= 0;
            MediumCounter <= ~MediumCounter;
        end
      end

    always @(posedge MediumCounter) begin
        oldBTND <= resetButtonExt;
        if(resetButtonExt && !(oldBTND)) begin //BTND press
            BTNDPress <= 32'b1;
        end
        else begin
            BTNDPress <= 32'b0;
        end
        oldBTNC <= (dropButtonExt2);
        if(dropButtonExt2 && !(oldBTNC)) begin //BTNC press
            BTNCPress <= 32'b1;
            if(player2Turn == 0) begin
                player2Turn <= 1'b1;
            end
            else begin
                player2Turn <= 1'b0;
            end
        end
        else begin
            BTNCPress <= 32'b0;
        end
        if(BTND) begin
            if(aiEnabled == 0) begin
                aiEnabled <= 1'b1;
            end
            else begin
                aiEnabled <= 1'b0;
            end
        end
    end
    
    wire [31:0] column_adjusted;
    assign column_adjusted = column+3;
    
    wire [8:0] LED80;
    assign LED[8:0] = LED80;
    
    //Control Params for AI
    reg [0] BTNDPress_02 = 0;
    reg [31:0] BTNCPress2 = 0;
    reg [31:0] BTNDPress = 0;
    reg dropButtonExt2 = 0;
    reg rightButtonExt2 = 0;
    reg leftButtonExt2 = 0;

    reg initialColumn = 0;

    always @(posedge clk) begin //Builds the medium speed clock
        if(player2Turn && aiEnabled) begin
            if(aiDelay<15) begin
                initialColumn <= column;

                BTNDPress_02 <= 0;
                BTNCPress2 <= 0;
                BTNDPress <= 0;
                dropButtonExt2 <= 0;
                rightButtonExt2 <= 0;
                leftButtonExt2 <= 0;
            end
            else if (aiDelay<25) begin
                if(initialColum == 0) begin
                    rightButtonExt2 <= 1'b1;
                end
                else if(initialColum == 1) begin
                    rightButtonExt2 <= 1'b1;
                end
                else if(initialColum == 2) begin
                    rightButtonExt2 <= 1'b1;
                end
                else if(initialColum == 3) begin
                    rightButtonExt2 <= 1'b1;
                end
                else if(initialColum == 4) begin
                    rightButtonExt2 <= 1'b1;
                end
                else if(initialColum == 5) begin
                    leftButtonExt2 <= 1'b1;
                end
                else if(initialColum == 6) begin
                    leftButtonExt2 <= 1'b1;
                end
            end
            else if(aiDelay < 30) begin
                if(initialColum == 0) begin
                    rightButtonExt2 <= 1'b0;
                end
                else if(initialColum == 1) begin
                    rightButtonExt2 <= 1'b0;
                end
                else if(initialColum == 2) begin
                    rightButtonExt2 <= 1'b0;
                end
                else if(initialColum == 3) begin
                    rightButtonExt2 <= 1'b0;
                end
                else if(initialColum == 4) begin
                    rightButtonExt2 <= 1'b0;
                end
                else if(initialColum == 5) begin
                    leftButtonExt2 <= 1'b0;
                end
                else if(initialColum == 6) begin
                    leftButtonExt2 <= 1'b0;
                end
            end

            else if(aiDelay < 40) begin
                if(initialColum == 0) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 1) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 2) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 3) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 4) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 5) begin
                    dropButtonExt2 <= 1'b1;
                end
                else if(initialColum == 6) begin
                    dropButtonExt2 <= 1'b1;
                end
            end

            else if(aiDelay < 40) begin
                if(initialColum == 0) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 1) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 2) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 3) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 4) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 5) begin
                    dropButtonExt2 <= 1'b0;
                end
                else if(initialColum == 6) begin
                    dropButtonExt2 <= 1'b0;
                end
            end

        end else begin
            aiDelay <= 32'd0;
            BTNDPress_02 <= BTNDPress[0];
            BTNCPress2 <= BTNCPress;
            BTNDPress2 <= BTNDPress;
            dropButtonExt2 <= dropButtonExt;
            rightButtonExt2 <= rightButtonExt;
            leftButtonExt2 <= leftButtonExt;
        end
    end

    Wrapper CPUWrapper(.clock(clk), .reset(BTNDPress_02), .BTNC_In(BTNCPress2), 
    .BTND_In(BTNDPress2), .Column_In(column_adjusted), .Err_out(Err), 
    .Win1_out(Win1), .Win2_out(Win2));

    ServoController Servo(.clk(clk), .BTNC_In(dropButtonExt2), .BTNR_In(rightButtonExt2), 
    .BTNL_In(leftButtonExt2), .LED_Out(LED80), .servoSignal_Out(servoSignal),
    .servoSignal2_Out(servoSignal2), .currentColumn(column));

endmodule
