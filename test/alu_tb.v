module alu_tb;

reg  [7:0] a;
reg  [7:0] b;
reg  [3:0] opcode;
wire [7:0] result;

alu dut (
    .a(a),
    .b(b),
    .opcode(opcode),
    .result(result)
);

initial begin
    // ADD
    a = 8'd20;
    b = 8'd30;
    opcode = 4'b0000;

    #10;

    if (result == 8'd50) begin
        $display("ADD: YAY YOU GOT IT!");
    end else begin
        $display("ADD: YOU ARE A FAILURE");
    end

    // SUB

    a = 8'd20;
    b = 8'd5;
    opcode = 4'b0001;

    #10;

    if (result == 8'd15) begin
        $display("SUB: YAY YOU GOT IT!");
    end else begin
        $display("SUB: YOU ARE A FAILURE");
    end

    // AND

    a = 8'd12;
    b = 8'd10;
    opcode = 4'b0010;

    #10;

    if (result == 8'd8) begin
        $display("AND: YAY YOU GOT IT!");
    end else begin
        $display("AND: YOU ARE A FAILURE");
    end

    // OR

    a = 8'd12;
    b = 8'd10;
    opcode = 4'b0011;

    #10;

    if (result == 8'd14) begin
        $display("OR: YAY YOU GOT IT!");
    end else begin
        $display("OR: YOU ARE A FAILURE");
    end

    // XOR

    a = 8'd12;
    b = 8'd10;
    opcode = 4'b0100;

    #10;

    if (result == 8'd6) begin
        $display("XOR: YAY YOU GOT IT!");
    end else begin
        $display("XOR: YOU ARE A FAILURE");
    end

    // NOT

    a = 8'd15;
    opcode = 4'b0101;

    #10;

    if (result == 8'd240) begin
        $display("NOT: YAY YOU GOT IT!");
    end else begin
        $display("NOT: YOU ARE A FAILURE");
    end

    // SHL

    a = 8'd12;
    opcode = 4'b0110;

    #10;

    if (result == 8'd24) begin
        $display("SHL: YAY YOU GOT IT!");
    end else begin
        $display("SHL: YOU ARE A FAILURE");
    end

    // SHR

    a = 8'd12;
    opcode = 4'b0111;

    #10;

    if (result == 8'd6) begin
        $display("SHR: YAY YOU GOT IT!");
    end else begin
        $display("SHR: YOU ARE A FAILURE");
    end

    // ADD OVERFLOW TEST
    a = 8'd200;
    b = 8'd100;
    opcode = 4'b0000;

    #10;

    if (result == 8'd44) begin
        $display("ADD OVERFLOW: YAY YOU GOT IT!");
    end else begin
        $display("ADD OVERFLOW: YOU ARE A FAILURE");
    end




end

endmodule