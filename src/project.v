`default_nettype none

module tt_um_QKCPU (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input  wire       rst_n
);

    wire load_mode = ui_in[7];
    wire [6:0] loader_address = ui_in[6:0];

    wire [6:0]  cpu_program_address;
    wire [7:0]  cpu_program_data;
    wire [6:0]  cpu_data_address;
    wire [7:0]  cpu_data_write_data;
    wire        cpu_data_write_enable;
    wire [7:0]  cpu_data_read_data;
    wire [7:0]  sram_data_read_data;
    wire [7:0]  mmio_data_read_data;
    wire        mmio_hit;
    wire [7:0]  cpu_output;
    wire [31:0] register_values;
    wire        cpu_halted;

    wire [7:0]  gpio_uio_out;
    wire [7:0]  gpio_uio_oe;

    wire [6:0] prgm_ram_addr = load_mode ? loader_address : cpu_program_address;
    wire [7:0] prgm_ram_din  = uio_in;
    wire       prgm_ram_we   = load_mode;
    wire [7:0] prgm_ram_dout;

    // Prevent MMIO writes (0x60..0x7F) from writing into SRAM1
    wire sram1_we = cpu_data_write_enable && !mmio_hit;

    assign cpu_program_data   = prgm_ram_dout;
    assign cpu_data_read_data = mmio_hit ? mmio_data_read_data : sram_data_read_data;

    cpu_core cpu (
        .clk(clk),
        .rst_n(rst_n),
        .run_enable(!load_mode),
        .input_port(ui_in),
        .program_address(cpu_program_address),
        .program_data(cpu_program_data),
        .data_address(cpu_data_address),
        .data_write_data(cpu_data_write_data),
        .data_write_enable(cpu_data_write_enable),
        .data_read_data(cpu_data_read_data),
        .output_port(cpu_output),
        .register_values(register_values),
        .halted(cpu_halted)
    );

    gpio_pwm u_gpio_pwm (
        .clk(clk),
        .rst_n(rst_n),
        .bus_we(cpu_data_write_enable),
        .bus_addr(cpu_data_address),
        .bus_wdata(cpu_data_write_data),
        .bus_rdata(mmio_data_read_data),
        .mmio_hit(mmio_hit),
        .uio_in(uio_in),
        .uio_out(gpio_uio_out),
        .uio_oe(gpio_uio_oe)
    );

`ifdef SYNTH
    reg [7:0] sram0_mem [0:127];
    reg [7:0] sram1_mem [0:127];
    reg [7:0] sram0_q;
    reg [7:0] sram1_q;

    always @(posedge clk) begin
        if (ena) begin
            if (prgm_ram_we)
                sram0_mem[prgm_ram_addr] <= prgm_ram_din;
            sram0_q <= sram0_mem[prgm_ram_addr];

            if (sram1_we)
                sram1_mem[cpu_data_address] <= cpu_data_write_data;
            sram1_q <= sram1_mem[cpu_data_address];
        end
    end

    assign prgm_ram_dout       = sram0_q;
    assign sram_data_read_data = sram1_q;

`elsif __pnr__
    wire VPWR;
    wire VGND;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 u_sram0 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~prgm_ram_we),
        .WEN  (8'h00),
        .A    (prgm_ram_addr),
        .D    (prgm_ram_din),
        .Q    (prgm_ram_dout)
    );

    gf180mcu_fd_ip_sram__sram128x8m8wm1 u_sram1 (
        .VDD  (VPWR),
        .VSS  (VGND),
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~sram1_we),
        .WEN  (8'h00),
        .A    (cpu_data_address),
        .D    (cpu_data_write_data),
        .Q    (sram_data_read_data)
    );

`else
    wire model_vdd = 1'b1;
    wire model_vss = 1'b0;

    gf180mcu_fd_ip_sram__sram128x8m8wm1 u_sram0 (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~prgm_ram_we),
        .WEN  (8'h00),
        .A    (prgm_ram_addr),
        .D    (prgm_ram_din),
        .Q    (prgm_ram_dout),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );

    gf180mcu_fd_ip_sram__sram128x8m8wm1 u_sram1 (
        .CLK  (clk),
        .CEN  (~(ena & rst_n)),
        .GWEN (~sram1_we),
        .WEN  (8'h00),
        .A    (cpu_data_address),
        .D    (cpu_data_write_data),
        .Q    (sram_data_read_data),
        .VDD  (model_vdd),
        .VSS  (model_vss)
    );
`endif

    reg [7:0] selected_register;
    always @(*) begin
        case (ui_in[5:4])
            2'd0: selected_register = register_values[7:0];
            2'd1: selected_register = register_values[15:8];
            2'd2: selected_register = register_values[23:16];
            default: selected_register = register_values[31:24];
        endcase
    end

    assign uo_out  = (load_mode || cpu_halted) ? selected_register : cpu_output;

    assign uio_out = load_mode ? 8'h00 : gpio_uio_out;
    assign uio_oe  = load_mode ? 8'h00 : gpio_uio_oe;

endmodule

`default_nettype wire