/*
 * Copyright (c) 2026 QKing
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_example (
    input  wire [7:0] ui_in,
    output wire [7:0] uo_out,
    input  wire [7:0] uio_in,
    output wire [7:0] uio_out,
    output wire [7:0] uio_oe,
    input  wire       ena,
    input  wire       clk,
    input wire       rst_n
);

  wire load_mode = ui_in[7];
  wire [6:0] loader_address = {1'b0, ui_in[5:0]};
  wire [1:0] loader_byte_enable = ui_in[6] ? 2'b10 : 2'b01;
  wire [15:0] program_data_out;
  wire [6:0] cpu_program_address;
  wire [6:0] program_address = load_mode ? loader_address : cpu_program_address;
  wire [15:0] program_data_in = ui_in[6] ? {uio_in, 8'b0} : {8'b0, uio_in};
  wire [1:0] program_byte_enable = load_mode ? loader_byte_enable : 2'b00;
  wire [6:0] data_address;
  wire [7:0] data_write_data;
  wire data_write_enable;
  wire [7:0] data_read_data;
  wire [7:0] cpu_output;
  wire [31:0] register_values;
  wire cpu_halted;
  reg [7:0] selected_register;

  pgrm_ram program_ram (
      .clk(clk),
      .address(program_address),
      .data_in(program_data_in),
      .write_enable(load_mode),
      .byte_write_enable(program_byte_enable),
      .data_out(program_data_out)
  );

  cpu_core cpu (
      .clk(clk),
      .rst_n(rst_n),
      .run_enable(!load_mode),
      .program_address(cpu_program_address),
      .program_data(program_data_out),
      .data_address(data_address),
      .data_write_data(data_write_data),
      .data_write_enable(data_write_enable),
      .data_read_data(data_read_data),
      .output_port(cpu_output),
      .register_values(register_values),
      .halted(cpu_halted)
  );

  dataram data_memory (
      .clk(clk),
      .address(data_address),
      .data_in(data_write_data),
      .write_enable(data_write_enable),
      .data_out(data_read_data)
  );

  always @(*) begin
    case (ui_in[5:4])
      2'd0: selected_register = register_values[7:0];
      2'd1: selected_register = register_values[15:8];
      2'd2: selected_register = register_values[23:16];
      default: selected_register = register_values[31:24];
    endcase
  end

  assign uo_out = selected_register;
  assign uio_out = load_mode ? 8'b0 : cpu_output;
  assign uio_oe = load_mode ? 8'b0 : 8'hff;

  wire _unused = &{ena, rst_n, cpu_halted, 1'b0};

endmodule
