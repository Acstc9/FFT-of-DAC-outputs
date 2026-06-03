`timescale 1ns/1ps

module tb_dds_rom_3bit;

    localparam integer CLOCK_PERIOD = 10;
    localparam integer RESET_CYCLES = 2;
    localparam integer STIM_DELAY = 1;

    reg clk;
    reg rst_n;
    wire [2:0] dac_code;
    integer fout;
    integer sample_count;

    dds_rom_3bit uut (
        .clk(clk),
        .rst_n(rst_n),
        .dac_code(dac_code)
    );

    initial begin
        clk = 1'b0;
        forever #(CLOCK_PERIOD / 2) clk = ~clk;
    end

    initial begin
        fout = $fopen("dds_output.txt", "w");
        sample_count = 0;
        $display("Starting DDS testbench. Writing samples to dds_output.txt");

        rst_n = 1'b0;
        repeat (RESET_CYCLES) @(posedge clk);
        #STIM_DELAY;
        rst_n = 1'b1;
        $display("Reset released at time %0t", $time);
    end

    always @(posedge clk) begin
        if (rst_n) begin
            $fwrite(fout, "%0d\n", dac_code);
            $display("sample[%0d] = %0d at time %0t", sample_count, dac_code, $time);
            sample_count = sample_count + 1;

            if (sample_count == 1024) begin
                $fclose(fout);
                $stop;
            end
        end
    end

endmodule
