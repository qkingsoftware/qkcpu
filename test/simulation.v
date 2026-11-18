`default_nettype none
`timescale 1ns / 1ps

module full_cpu_diag_tb;
    reg clk;
    reg rst_n;
    reg ena;
    reg [7:0] ui_in;
    reg [7:0] uio_in;
    wire [7:0] uo_out;
    wire [7:0] uio_out;
    wire [7:0] uio_oe;

    tt_um_QKCPU dut (
        .ui_in(ui_in),
        .uo_out(uo_out),
        .uio_in(uio_in),
        .uio_out(uio_out),
        .uio_oe(uio_oe),
        .ena(ena),
        .clk(clk),
        .rst_n(rst_n)
    );

    initial begin
        clk = 0;
        forever #50 clk = ~clk;
    end

    
    function [15:0] ALU_OP(input [3:0] op, input [1:0] dst, input [1:0] a, input [1:0] b);
        ALU_OP = {op, dst, a, b, 6'b000000};
    endfunction

    function [15:0] LDI(input [1:0] dst, input [7:0] imm);
        LDI = {4'b1000, dst, imm, 2'b00};
    endfunction

    function [15:0] LD_DIR(input [1:0] dst, input [5:0] addr);
        LD_DIR = {4'b1001, dst, addr, 3'b000, 1'b0};
    endfunction

    function [15:0] LD_IND(input [1:0] dst, input [1:0] addr_reg);
        LD_IND = {4'b1001, dst, addr_reg, 7'b0000000, 1'b1};
    endfunction

    
    function [15:0] ST_DIR(input [5:0] addr);
        ST_DIR = {4'b1010, 2'b00, addr, 4'b0000};
    endfunction

    function [15:0] ST_IND(input [1:0] src, input [1:0] addr_reg);
        ST_IND = {4'b1010, 2'b00, src, addr_reg, 5'b00000, 1'b1};
    endfunction

    function [15:0] MOV(input [1:0] dst, input [1:0] src);
        MOV = {4'b1011, dst, src, 8'b00000000};
    endfunction

    function [15:0] OUT_OP(input [1:0] src);
        OUT_OP = {4'b1100, 1'b0, 1'b0, src, 8'b00000000};
    endfunction

    function [15:0] IN_OP(input [1:0] dst);
        IN_OP = {4'b1100, 1'b1, 1'b0, dst, 8'b00000000};
    endfunction

    function [15:0] JMP(input [5:0] target);
        JMP = {4'b1101, target, 4'b0000, 2'b00};
    endfunction

    function [15:0] JZ(input [5:0] target, input [1:0] test_reg);
        JZ = {4'b1101, target, test_reg, 2'b00, 2'b01};
    endfunction

    function [15:0] JNZ(input [5:0] target, input [1:0] test_reg);
        JNZ = {4'b1101, target, test_reg, 2'b00, 2'b10};
    endfunction

    function [15:0] CALL(input [5:0] target);
        CALL = {4'b1110, target, 6'b000000};
    endfunction

    localparam [15:0] HALT = 16'hF000;
    localparam [15:0] NOP  = 16'hF001;
    localparam [15:0] RET  = 16'hF002;

    localparam [1:0] R0 = 2'd0, R1 = 2'd1, R2 = 2'd2, R3 = 2'd3;

    integer pass_count = 0;
    integer fail_count = 0;

    task check(input cond, input [8*64-1:0] msg);
        begin
            if (cond) begin
                $display("  [PASS] %0s", msg);
                pass_count = pass_count + 1;
            end else begin
                $display("  [FAIL] %0s", msg);
                fail_count = fail_count + 1;
            end
        end
    endtask

    task load_inst(input [5:0] idx, input [15:0] inst);
        begin
            @(negedge clk);
            ui_in  = 8'h80 | {idx, 1'b0};
            uio_in = inst[7:0];
            @(posedge clk); #1;

            @(negedge clk);
            ui_in  = 8'h80 | {idx, 1'b1};
            uio_in = inst[15:8];
            @(posedge clk); #1;
        end
    endtask

    task reset_cpu;
        begin
            rst_n = 0; ena = 1; ui_in = 8'h80; uio_in = 8'h00;
            repeat (4) @(posedge clk);
            rst_n = 1;
            repeat (2) @(posedge clk);
        end
    endtask

    
    task read_halted_reg(input [1:0] rsel, output [7:0] val);
        begin
            @(negedge clk);
            ui_in = {2'b00, rsel, 4'b0000};
            #5;
            val = uo_out;
        end
    endtask

    reg [7:0] r0_val, r1_val, r2_val, r3_val;
    integer c, p;
    integer pwm_cnts [0:7];

    initial begin
        $dumpfile("full_diag.fst");
        $dumpvars(0, full_cpu_diag_tb);
        
        $display("\nPart 1");
        reset_cpu();

        load_inst(6'd0,  LDI(R0, 8'd20));           
        load_inst(6'd1,  LDI(R1, 8'd6));            
        load_inst(6'd2,  ALU_OP(4'h0, R2, R0, R1)); 
        load_inst(6'd3,  ALU_OP(4'h1, R2, R2, R1)); 
        load_inst(6'd4,  ALU_OP(4'h2, R2, R2, R1)); 
        load_inst(6'd5,  ALU_OP(4'h3, R2, R2, R1)); 
        load_inst(6'd6,  ALU_OP(4'h4, R2, R2, R0)); 
        load_inst(6'd7,  ALU_OP(4'h5, R2, R2, R0)); 
        load_inst(6'd8,  ALU_OP(4'h6, R2, R1, R0)); 
        load_inst(6'd9,  ALU_OP(4'h7, R2, R2, R0)); 
        load_inst(6'd10, MOV(R3, R2));              
        load_inst(6'd11, OUT_OP(R3));               
        
        load_inst(6'd12, ST_DIR(6'd48));            
        load_inst(6'd13, LD_DIR(R0, 6'd48));        
        
        load_inst(6'd14, LDI(R1, 8'h25));           
        load_inst(6'd15, LDI(R2, 8'h5A));           
        load_inst(6'd16, ST_IND(R2, R1));           
        load_inst(6'd17, LD_IND(R2, R1));           
        
        load_inst(6'd18, LDI(R1, 8'd0));            
        load_inst(6'd19, JZ(6'd21, R1));            
        load_inst(6'd20, LDI(R0, 8'hEE));           
        load_inst(6'd21, JNZ(6'd23, R2));           
        load_inst(6'd22, LDI(R0, 8'hEE));           
        load_inst(6'd23, JMP(6'd25));               
        load_inst(6'd24, LDI(R0, 8'hEE));           
        
        load_inst(6'd25, CALL(6'd30));              
        load_inst(6'd26, NOP);                      
        load_inst(6'd27, IN_OP(R1));                
        load_inst(6'd28, HALT);                     
        
        load_inst(6'd30, LDI(R3, 8'h77));           
        load_inst(6'd31, RET);                      

        
        @(negedge clk);
        ui_in = 8'h05;

        
        repeat (70) @(posedge clk);
        #1;
        check(uo_out == 8'd6, "Runtime OUT instruction drives uo_out (expected 6)");

        
        repeat (150) @(posedge clk);
        #1;

        read_halted_reg(R0, r0_val);
        read_halted_reg(R1, r1_val);
        read_halted_reg(R2, r2_val);
        read_halted_reg(R3, r3_val);

        $display("  Final Halted Registers: R0=0x%02h (%0d), R1=0x%02h (%0d), R2=0x%02h (%0d), R3=0x%02h (%0d)",
                 r0_val, r0_val, r1_val, r1_val, r2_val, r2_val, r3_val, r3_val);

        check(r0_val == 8'd6,   "ALU chain + Direct STORE/LOAD + JZ/JNZ/JMP (R0 == 6)");
        check(r2_val == 8'h5A,  "Indirect STORE/LOAD [R1] to SRAM (R2 == 0x5A)");
        check(r3_val == 8'h77,  "CALL / RET subroutine execution (R3 == 0x77)");
        check(r1_val == 8'h05,  "IN instruction reads ui_in pins (R1 == 0x05)");
        check(uio_oe == 8'h00,  "Unused bidirectional uio pins stay Hi-Z (uio_oe == 0x00)");

        
        
        
        $display("\nPart 2");
        reset_cpu();

        load_inst(6'd0,  LDI(R1, 8'd0));   load_inst(6'd1,  LDI(R2, 8'h70)); load_inst(6'd2,  ST_IND(R1, R2)); 
        load_inst(6'd3,  LDI(R1, 8'd64));  load_inst(6'd4,  LDI(R2, 8'h71)); load_inst(6'd5,  ST_IND(R1, R2)); 
        load_inst(6'd6,  LDI(R1, 8'd128)); load_inst(6'd7,  LDI(R2, 8'h72)); load_inst(6'd8,  ST_IND(R1, R2)); 
        load_inst(6'd9,  LDI(R1, 8'd192)); load_inst(6'd10, LDI(R2, 8'h73)); load_inst(6'd11, ST_IND(R1, R2)); 
        load_inst(6'd12, LDI(R1, 8'd255)); load_inst(6'd13, LDI(R2, 8'h74)); load_inst(6'd14, ST_IND(R1, R2)); 

        load_inst(6'd15, LDI(R1, 8'h02));  
        load_inst(6'd16, LDI(R2, 8'h60));  load_inst(6'd17, ST_IND(R1, R2)); 
        load_inst(6'd18, LDI(R2, 8'h61));  load_inst(6'd19, ST_IND(R1, R2)); 
        load_inst(6'd20, LDI(R2, 8'h62));  load_inst(6'd21, ST_IND(R1, R2)); 
        load_inst(6'd22, LDI(R2, 8'h63));  load_inst(6'd23, ST_IND(R1, R2)); 
        load_inst(6'd24, LDI(R2, 8'h64));  load_inst(6'd25, ST_IND(R1, R2)); 

        load_inst(6'd26, LDI(R1, 8'h03));  load_inst(6'd27, LDI(R2, 8'h65)); load_inst(6'd28, ST_IND(R1, R2)); 
        load_inst(6'd29, LDI(R1, 8'h01));  load_inst(6'd30, LDI(R2, 8'h66)); load_inst(6'd31, ST_IND(R1, R2)); 
        load_inst(6'd32, LDI(R1, 8'h00));  load_inst(6'd33, LDI(R2, 8'h67)); load_inst(6'd34, ST_IND(R1, R2)); 
        load_inst(6'd35, LD_IND(R3, R2));  
        load_inst(6'd36, HALT);

        
        @(negedge clk);
        uio_in = 8'b1000_0000;
        ui_in  = 8'b0011_0000; 

        repeat (220) @(posedge clk);
        #1;

        check(uio_oe == 8'b0111_1111, "uio_oe == 0x7F (pins 0..6 driving, pin 7 Hi-Z input)");
        check(uio_out[5] == 1'b1 && uio_out[6] == 1'b0, "Digital GPIO outputs: uio[5]=1, uio[6]=0");
        check(uo_out == 8'd1, "PIN7 input read via MMIO 0x67 into R3 (R3 == 1)");

        
        for (p = 0; p < 8; p = p + 1) pwm_cnts[p] = 0;
        for (c = 0; c < 256; c = c + 1) begin
            @(posedge clk); #1;
            for (p = 0; p < 8; p = p + 1) begin
                if (uio_out[p]) pwm_cnts[p] = pwm_cnts[p] + 1;
            end
        end

        $display("  PWM High Cycles (out of 256): ch0=%0d, ch1=%0d, ch2=%0d, ch3=%0d, ch4=%0d",
                 pwm_cnts[0], pwm_cnts[1], pwm_cnts[2], pwm_cnts[3], pwm_cnts[4]);

        check(pwm_cnts[0] == 0,   "PWM ch0 (duty=0)   == 0/256 cycles");
        check(pwm_cnts[1] == 64,  "PWM ch1 (duty=64)  == 64/256 cycles (25%)");
        check(pwm_cnts[2] == 128, "PWM ch2 (duty=128) == 128/256 cycles (50%)");
        check(pwm_cnts[3] == 192, "PWM ch3 (duty=192) == 192/256 cycles (75%)");
        check(pwm_cnts[4] == 256, "PWM ch4 (duty=255) == 256/256 cycles (100%)");

        $display(" SUMMARY: %0d PASSED, %0d FAILED", pass_count, fail_count);
        $finish;
    end
endmodule

`default_nettype wire