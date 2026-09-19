`default_nettype none

module tt_um_hardware_dice (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path
    input  wire       ena,      // Always 1 when powered
    input  wire       clk,      // System clock
    input  wire       rst_n     // Active-low reset
);

    wire roll_btn = ui_in[0];
    reg [2:0] dice_val;

    // High-speed counter: cycles 1 through 6 while the button is pressed
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            dice_val <= 3'd1;
        end else if (roll_btn) begin
            if (dice_val >= 3'd6)
                dice_val <= 3'd1;
            else
                dice_val <= dice_val + 1'b1;
        end
    end

    // Hex-to-7-Segment Decoder (Active High for standard TT Demoboard)
    // Segments mapping: [6]=G, [5]=F, [4]=E, [3]=D, [2]=C, [1]=B, [0]=A
    reg [6:0] segments;
    always @(*) begin
        case (dice_val)
            3'd1: segments = 7'b0000110; 
            3'd2: segments = 7'b1011011; 
            3'd3: segments = 7'b1001111; 
            3'd4: segments = 7'b1100110; 
            3'd5: segments = 7'b1101101; 
            3'd6: segments = 7'b1111101; 
            default: segments = 7'b1000000; // Center dash on error
        endcase
    end

    // Wire the decoded segments to the output pins
    assign uo_out[6:0] = segments;
    assign uo_out[7]   = 1'b0; // Decimal point off

    // Ground unused bidirectional IOs
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule
