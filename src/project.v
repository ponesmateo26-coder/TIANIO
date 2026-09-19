`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    
    output wire [7:0] uo_out,   
    input  wire [7:0] uio_in,   
    output wire [7:0] uio_out,  
    output wire [7:0] uio_oe,   
    input  wire       ena,      
    input  wire       clk,      
    input  wire       rst_n     
);

    wire roll_btn = ui_in[0];
    reg [2:0] dice_val;

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

    reg [6:0] segments;
    always @(*) begin
        case (dice_val)
            3'd1: segments = 7'b0000110; 
            3'd2: segments = 7'b1011011; 
            3'd3: segments = 7'b1001111; 
            3'd4: segments = 7'b1100110; 
            3'd5: segments = 7'b1101101; 
            3'd6: segments = 7'b1111101; 
            default: segments = 7'b1000000; 
        endcase
    end

    assign uo_out[6:0] = segments;
    assign uo_out[7]   = 1'b0; 
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule
