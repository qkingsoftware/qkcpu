module inst_decoder_tb;

    reg  [15:0] instruction;
    wire  [3:0] opcode;
    wire [1:0] dest;
    wire [1:0] src_a;
    wire [1:0] src_b;
    wire [5:0] address;
    wire [7:0] immediate;

    inst_decoder dut (
        .instruction(instruction),
        .opcode(opcode),
        .dest(dest),
        .src_a(src_a),
        .src_b(src_b),
        .address(address),
        .immediate(immediate)
    );

    initial begin
        // test 1
        instruction = 16'b0000011000000000;
        #1;
        if (opcode == 4'd0 && dest == 4'd1 && src_a == 4'd2 && src_b == 4'd0) begin
            $display("ADD DECODING TEST PASSED!");
        end else begin
            $display("ADD DECODING TEST FAILED!");
        end
        $display("TEST 1 - Opcode: %d, SrcA: %d, SrcB: %d", opcode, src_a, src_b);
        if (address == 6'd0 && immediate == 8'd0) begin
            $display("ADD DECODING TEST PASSED!");
        end else begin
            $display("ADD DECODING TEST FAILED!");
        end

        // test 2 LDI
        instruction = 16'b1000100010101000;
        #1;
        if (opcode == 4'd8 && dest == 2'd2) begin
            $display("LDI DECODING TEST PASSED!");
        end else begin
            $display("LDI DECODING TEST FAILED!");
        end
        $display("TEST 2 - Opcode: %d, Dest: %d", opcode, dest);
        if (address == 6'd0 && immediate == 8'd42) begin
            $display("LDI DECODING TEST PASSED!");
        end else begin
            $display("LDI DECODING TEST FAILED!");
        end

        // test 3 LOAD
        instruction = 16'b1001010110010000;
        #1;
        if (opcode == 4'd9 && dest == 2'd1 &&
            address == 6'd25 && immediate == 8'd0) begin
            $display("LOAD DECODING TEST PASSED!");
        end else begin
            $display("LOAD DECODING TEST FAILED!");
        end
        $display("TEST 3 - Opcode: %d, Register: %d, Address: %d",
                 opcode, dest, address);

        // test 4 STORE
        instruction = 16'b1010010110010000;
        #1;
        if (opcode == 4'd10 && dest == 2'd1 &&
            address == 6'd25 && immediate == 8'd0) begin
            $display("STORE DECODING TEST PASSED!");
        end else begin
            $display("STORE DECODING TEST FAILED!");
        end
        $display("TEST 4 - Opcode: %d, Register: %d, Address: %d",
                 opcode, dest, address);

        // test 5 JMP
        instruction = 16'b1101010100000000;
        #1;
        if (opcode == 4'd13 && address == 6'd20 &&
            immediate == 8'd0) begin
            $display("JMP DECODING TEST PASSED!");
        end else begin
            $display("JMP DECODING TEST FAILED!");
        end
        $display("TEST 5 - Opcode: %d, Address: %d", opcode, address);

        // test 6 JZ
        instruction = 16'b1110100011000000;
        #1;
        if (opcode == 4'd14 && address == 6'd35 &&
            immediate == 8'd0) begin
            $display("JZ DECODING TEST PASSED!");
        end else begin
            $display("JZ DECODING TEST FAILED!");
        end
        $display("TEST 6 - Opcode: %d, Address: %d", opcode, address);
    end
endmodule