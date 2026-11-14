`timescale 1ns / 1ps

module clock_gen (
    output reg clk
);

initial begin
    clk = 0;
    
    forever begin
        #5  clk = ~clk;
    end
end
endmodule