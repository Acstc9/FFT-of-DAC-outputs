module dds_rom_3bit #(
    parameter integer QUADRANT_ADDR_WIDTH = 6,
    parameter integer DAC_WIDTH = 3
) (
    input  wire       clk,
    input  wire       rst_n,
    output reg  [DAC_WIDTH-1:0] dac_code
);

    localparam integer PHASE_WIDTH = QUADRANT_ADDR_WIDTH + 2;
    localparam integer ROM_DEPTH = (1 << QUADRANT_ADDR_WIDTH);
    localparam [DAC_WIDTH-1:0] MID_SCALE = (1 << (DAC_WIDTH - 1));
    localparam [DAC_WIDTH-1:0] MAX_MAG = MID_SCALE - 1'b1;
    localparam [DAC_WIDTH-1:0] LEVEL1 = MAX_MAG / 3;
    localparam [DAC_WIDTH-1:0] LEVEL2 = (MAX_MAG * 2) / 3;

    reg [PHASE_WIDTH-1:0] phase;
    reg [DAC_WIDTH-1:0] rom [0:ROM_DEPTH-1];
    wire [1:0] quadrant;
    wire [QUADRANT_ADDR_WIDTH-1:0] quadrant_pos;
    wire [QUADRANT_ADDR_WIDTH-1:0] rom_addr;
    wire [DAC_WIDTH-1:0] mag;

    integer i;

    assign quadrant = phase[PHASE_WIDTH-1:PHASE_WIDTH-2];
    assign quadrant_pos = phase[PHASE_WIDTH-3:PHASE_WIDTH-QUADRANT_ADDR_WIDTH-2];
    assign rom_addr = (quadrant == 2'b01 || quadrant == 2'b11) ?
                      ((ROM_DEPTH - 1) - quadrant_pos) :
                      quadrant_pos;
    assign mag = rom[rom_addr];

    initial begin
        for (i = 0; i < ROM_DEPTH; i = i + 1) begin
            if (i < ((ROM_DEPTH * 7) / 64))
                rom[i] = {DAC_WIDTH{1'b0}};
            else if (i < ((ROM_DEPTH * 21) / 64))
                rom[i] = LEVEL1;
            else if (i < ((ROM_DEPTH * 36) / 64))
                rom[i] = LEVEL2;
            else
                rom[i] = MAX_MAG;
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase <= {PHASE_WIDTH{1'b0}};
        else
            phase <= phase + 1'b1;
    end

    always @(*) begin
        if (quadrant[1] == 1'b0)
            dac_code = MID_SCALE + mag;  // upper half of waveform
        else
            dac_code = MID_SCALE - mag;  // lower half of waveform
    end

endmodule
