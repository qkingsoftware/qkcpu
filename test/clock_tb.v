module clock_tb;

wire clk;

initial begin
    $monitor("Time=%0t | clk=%b", $time, clk);
    #40 $finish;
end

clock_gen dut (
    .clk(clk)
);
endmodule
