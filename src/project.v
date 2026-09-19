`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,    // DIP switches for fractal offset
    output wire [7:0] uo_out,   // VGA outputs
    input  wire [7:0] uio_in,   // Unused
    output wire [7:0] uio_out,  // Unused
    output wire [7:0] uio_oe,   // Unused
    input  wire       ena,      
    input  wire       clk,      // 25.175 MHz pixel clock
    input  wire       rst_n     
);

    wire hsync;
    wire vsync;
    wire [9:0] x;
    wire [9:0] y;
    wire video_active;

    // Instantiate the sync generator (defined below)
    hvsync_generator sync_gen (
        .clk(clk),
        .reset(~rst_n),
        .hsync(hsync),
        .vsync(vsync),
        .display_on(video_active),
        .hpos(x),
        .vpos(y)
    );

    // Fractal Generation: XOR the X and Y coordinates, offset by the input switches
    wire [7:0] pattern = (x[7:0] ^ y[7:0]) + ui_in;

    // Map the 8-bit pattern to the 6-bit VGA DAC (2 bits per color)
    wire [1:0] r = video_active ? pattern[7:6] : 2'b00;
    wire [1:0] g = video_active ? pattern[5:4] : 2'b00;
    wire [1:0] b = video_active ? pattern[3:2] : 2'b00;

    // Route signals to the Tiny VGA Pmod pinout
    assign uo_out[0] = r[1];
    assign uo_out[4] = r[0];
    assign uo_out[1] = g[1];
    assign uo_out[5] = g[0];
    assign uo_out[2] = b[1];
    assign uo_out[6] = b[0];
    assign uo_out[3] = vsync;
    assign uo_out[7] = hsync;

    // Tie off unused bidirectional pins
    assign uio_out = 8'b00000000;
    assign uio_oe  = 8'b00000000;

endmodule

// ------------------------------------------------------------------
// VGA Sync Generator Sub-Module
// Generates industry-standard 640x480 @ 60Hz VGA timing signals
// ------------------------------------------------------------------
module hvsync_generator(
    input  wire clk,
    input  wire reset,
    output wire hsync,
    output wire vsync,
    output wire display_on,
    output reg  [9:0] hpos,
    output reg  [9:0] vpos
);

    localparam H_DISPLAY = 640;
    localparam H_FRONT   = 16;
    localparam H_SYNC    = 96;
    localparam H_BACK    = 48;
    localparam H_MAX     = H_DISPLAY + H_FRONT + H_SYNC + H_BACK - 1;

    localparam V_DISPLAY = 480;
    localparam V_FRONT   = 10;
    localparam V_SYNC    = 2;
    localparam V_BACK    = 33;
    localparam V_MAX     = V_DISPLAY + V_FRONT + V_SYNC + V_BACK - 1;

    always @(posedge clk) begin
        if (reset) begin
            hpos <= 0;
            vpos <= 0;
        end else begin
            if (hpos == H_MAX) begin
                hpos <= 0;
                if (vpos == V_MAX)
                    vpos <= 0;
                else
                    vpos <= vpos + 1;
            end else begin
                hpos <= hpos + 1;
            end
        end
    end

    assign hsync = ~(hpos >= (H_DISPLAY + H_FRONT) && hpos < (H_DISPLAY + H_FRONT + H_SYNC));
    assign vsync = ~(vpos >= (V_DISPLAY + V_FRONT) && vpos < (V_DISPLAY + V_FRONT + V_SYNC));
    assign display_on = (hpos < H_DISPLAY) && (vpos < V_DISPLAY);

endmodule
