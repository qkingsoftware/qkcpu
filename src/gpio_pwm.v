// Okay, I thought this would be complex, but it wasn't that bad
// I just had to create an mmio space
// easier than expected
// OFC that means that I added PWM as well

`default_nettype none

module gpio_pwm (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       bus_we,
    input  wire [6:0] bus_addr,
    input  wire [7:0] bus_wdata,
    output reg  [7:0] bus_rdata,
    output wire       mmio_hit,

    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe
);

    assign mmio_hit = (bus_addr >= 7'h60);
    reg [1:0] pin_mode [0:7];
    reg [7:0] pin_out_val;
    reg [7:0] pwm_duty [0:7];

    reg [7:0] pwm_cnt;
    reg [7:0] pwm_period;

    integer i;
    always @(posedge clk) begin
        if (!rst_n) begin
            pwm_cnt     <= 8'd0;
            pin_out_val <= 8'd0;
            bus_rdata   <= 8'd0;
            for (i = 0; i < 8; i = i + 1) begin
                pin_mode[i] <= 2'b00;
                pwm_duty[i] <= 8'd0;
            end
        end else begin
            pwm_cnt <= (pwm_cnt >= pwm_period) ? 8'd0 : pwm_cnt + 8'd1;

            if (bus_we && mmio_hit) begin
                if (bus_addr >= 7'h60 && bus_addr <= 7'h67) begin
                    if (bus_wdata == 8'h00) begin
                        pin_mode[bus_addr[2:0]] <= 2'b00;
                    end else if (bus_wdata == 8'h02) begin
                        pin_mode[bus_addr[2:0]] <= 2'b10;
                    end else if (bus_wdata[0] == 1'b1) begin
                        pin_mode[bus_addr[2:0]]    <= 2'b01;
                        pin_out_val[bus_addr[2:0]] <= bus_wdata[1];
                    end else if (bus_wdata == 8'h04) begin
                    pin_mode[bus_addr[2:0]] <= 2'b11;    
                    end
                end else if (bus_addr >= 7'h70 && bus_addr <= 7'h77) begin
                    pwm_duty[bus_addr[2:0]] <= bus_wdata;
                end
            end

            if (bus_addr >= 7'h60 && bus_addr <= 7'h67) begin
                bus_rdata <= {7'd0, uio_in[bus_addr[2:0]]};
            end else if (bus_addr >= 7'h70 && bus_addr <= 7'h77) begin
                bus_rdata <= pwm_duty[bus_addr[2:0]];
            end else if (bus_addr == 7'h78) begin
                bus_rdata <= uio_in;
            end else if (bus_addr == 7'h79) begin
                bus_rdata <= pwm_period;
            end else if (bus_addr == 7'h79) begin
                bus_rdata <= pwm_period;    
            end else begin
                bus_rdata <= 8'd0;
            end
        end
    end

    genvar g;
    generate
        for (g = 0; g < 8; g = g + 1) begin : gen_pin_io
            wire pwm_sig = (pwm_duty[g] == 8'hFF) ? 1'b1 : (pwm_cnt < pwm_duty[g]);

            assign uio_oe[g]  = (pin_mode[g] != 2'b00);
            assign uio_out[g] = (pin_mode[g] == 2'b10) ? pwm_sig : pin_out_val[g];
        end
    endgenerate

endmodule

`default_nettype wire