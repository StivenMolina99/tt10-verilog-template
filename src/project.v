/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`timescale 1ns / 1ps


module tt_um_ccollatz_SergioOliveros(
    input clk, //Clock
    input ena, //Start
    input rst_n, //Reset
    input [7:0] uio_in,
    input [7:0] ui_in, //Numero de entrada - N
    output wire [7:0] uio_out, //Contador de iteraciones - c
    output wire [7:0] uo_out, //Busy - busy
    output wire [7:0] uio_oe 
    //output reg [7:0] n
    );
   
    assign uio_oe = 8'b11111111;
    
    parameter inicio = 2'b00;
    parameter par = 2'b01;
    parameter impar = 2'b11;
    parameter mantener = 2'b10;
    
    wire start;
    reg busy;
    assign uo_out = {{7{1'b0}}, busy};
    assign start = ~rst_n;
     
    wire [7:0] rca, eca;
    reg [7:0] n;
    reg ec,rc;
    reg [1:0] rn;
    reg [1:0] presente = inicio;
    reg [1:0] futuro;
    reg [7:0] uio_outr;
    assign uio_out = uio_outr;
    ////////////////Datapath 1//////////////////
    always@(posedge clk) begin
        uio_outr <= rca;               
    end 
   
    assign eca = (ec)?(8'b1+uio_outr):uio_outr;
    assign rca = (rc)?8'b0:eca;

    
    always@(posedge clk)
        case (rn)
            2'b00: n <= n;
            2'b01: n <= n/8'd2;
            2'b10: n <= ((8'd3)*n)+(8'd1);
            default: n <= ui_in;
        endcase 
           ////////////////Maquina de estados//////////////////
    ////////////////Registro de estados//////////////////
    always@(posedge clk)
        presente <= futuro;
    ////////////////Logica del estado siguiente//////////////////
    always@(*) begin
        case(presente)
            inicio:
                if(start)
                    if(ui_in[0] <= 1'b0)
                        futuro <= par;
                    else 
                        futuro <= impar;
                else 
                    futuro <= inicio;
                    
            par:
                if (n!=8'd2 && n[1] == 1'b0)
                    futuro <= par;
                else if (n!=8'd2 && n[1] != 1'b0) 
                    futuro <= impar;
                else 
                    futuro <= mantener;
                    
            impar:
                futuro <= par;              
            mantener:
                futuro <= mantener;
            default:
                futuro <= inicio;
        endcase
    end
    ////////////////Logica de salida//////////////////
    always@(*)
        case(presente)  
        inicio: {ec,rc,rn[1],rn[0],busy} = 5'b01110;
        par: {ec,rc,rn[1],rn[0],busy} = 5'b10011;
        impar: {ec,rc,rn[1],rn[0],busy} = 5'b10101;
        mantener: {ec,rc,rn[1],rn[0],busy} = 5'b00000;
        default: {ec,rc,rn[1],rn[0],busy} = 5'b00000;
    endcase
endmodule
