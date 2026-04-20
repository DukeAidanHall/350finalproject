module ServoController(
    input clk,             // System Clock Input 100 Mhz
    input BTNC_In,
    input BTNR_In,
    input BTNL_In,

    output[8:0] LED_Out,
    output servoSignal_Out,    // Signal to the servo
    output servoSignal2_Out,
    output [31:0] currentColumn
    );      
   
    reg[9:0] duty_cycle;

    reg[31:0] spincounter = 0;
    reg MediumCounter = 0;
      reg[31:0] counter = 0;
      reg updateLeft = 0;
      reg updateRight = 0;
      reg[6:0] button_state = 0;
      assign LED_Out[4:0] = button_state[4:0];
      reg oldUpdateLeft = 0;
      reg oldUpdateRight = 0;
      assign LED_Out[8] = updateLeft;
      assign LED_Out[7] = updateRight;
      reg prevUpdateLeft = 0;
      reg prevUpdateRight = 0;
      reg[6:0] newState = 0;
      reg[31:0] counter3 = 0;

      //maintain currentColumn
      assign currentColumn[6:0] = button_state[6:0];
      assign currentColumn[31:7] = 25'b0;
     
      always @(posedge clk) begin //Builds the medium speed clock
            if(counter < 32'd50000000) begin
                  counter <= counter+1;
            end else begin
                counter <= 0;
                MediumCounter <= ~MediumCounter;
            end
      end
   
    always @(posedge MediumCounter) begin //If left button was just pressed, send update BTNL_In
        oldUpdateRight <= BTNR_In;
        oldUpdateLeft <= BTNL_In;
        if(oldUpdateLeft && !(BTNL_In) && (!updateDrop2)) begin
            updateLeft <= 1;
        end
        else begin
            updateLeft <= 0;
        end
        if(oldUpdateRight && !(BTNR_In)&& (!updateDrop2)) begin
            updateRight <= 1;
        end
        else begin
            updateRight <= 0;
        end
    end
   
    always @(posedge clk) begin //Button state
        prevUpdateLeft <= updateLeft;
        prevUpdateRight <= updateRight;
        if((updateRight && !prevUpdateRight) && (button_state < 6)) begin
            newState <= button_state + 1;
            spincounter <= 0;
        end
        else if((updateLeft && !prevUpdateLeft) && (button_state > 0)) begin
            newState <= button_state - 1;
            spincounter <= 0;
        end
        else begin
        if(counter3 < 32'd50000000) begin
                  counter3 <= counter3+1;
            end else begin
                counter3 <= 0;
                spincounter = spincounter + 1;
            end
        end
    end
   
      always @(posedge clk) begin //Assign Duty Cycle
        if (spincounter > 8) begin
            button_state <= newState;
        end else if ((spincounter < 5) && (spincounter > 2) && (button_state > newState)) begin //7
            duty_cycle = 10'd102;
        end else if ((spincounter < 5) && (spincounter > 2) && (button_state < newState)) begin //7
            duty_cycle = 10'd1;
        end
        else begin
            duty_cycle = 10'd0;
        end
    end

    PWMSerializer #(.PERIOD_WIDTH_NS(32'd20000000)) ServoSerializer(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle), .signal(servoSignal_Out)); //Servo control

    reg[9:0] duty_cycle2;

    reg[31:0] spincounter2 = 13;
    reg MediumCounter2 = 0;
      reg[31:0] counter2 = 0;
      reg updateDrop2 = 0;
      reg oldUpdateDrop2 = 0;
      reg prevUpdateDrop2 = 0;
      reg[31:0] counter32 = 0;
      assign LED_Out[6] = updateDrop2;
     
      always @(posedge clk) begin //Builds the medium speed clock
            if(counter2 < 32'd50000000) begin
                  counter2 <= counter2+1;
            end else begin
                counter2 <= 0;
                MediumCounter2 <= ~MediumCounter2;
            end
      end
   
    always @(posedge MediumCounter2) begin //If left button was just pressed, send update BTNL_In
        oldUpdateDrop2 <= BTNC_In && !BTNL_In && !BTNR_In;
        if(oldUpdateDrop2 && !(BTNC_In) && (button_state == newState)) begin
            updateDrop2 <= 1;
        end
        else begin
            updateDrop2 <= 0;
        end
    end
   
    always @(posedge clk) begin //Button state
        prevUpdateDrop2 <= updateDrop2;
        if((updateDrop2 && !prevUpdateDrop2)) begin
            spincounter2 <= 0;
        end
        else begin
        if(counter32 < 32'd50000000) begin
                  counter32 <= counter32+1;
            end else begin
                counter32 <= 0;
                spincounter2 = spincounter2 + 1;
            end
        end
    end
   
      always @(posedge clk) begin //Assign Duty Cycle
       if ((spincounter2 < 7) && (spincounter2 > 2)) begin
            duty_cycle2 = 10'd1;
        end else if (spincounter2 >6 && spincounter2 < 12) begin
            duty_cycle2 = 10'd102;
        end
        else begin
            duty_cycle2 = 10'd0;
        end
    end
   
    PWMSerializer #(.PERIOD_WIDTH_NS(32'd20000000)) ServoSerializer2(.clk(clk), .reset(1'b0), .duty_cycle(duty_cycle2), .signal(servoSignal2_Out)); //Servo control

   
endmodule
