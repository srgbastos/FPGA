module clk_div
  (
  input clk, reset,                    // entrada: clk, reset
  output reg clkOut                    // sai clkOut - clk dividido
  );

// quando instanciar este divisor de clock, redefinir parâmetro NclkDIV
  parameter NclkDIV= 1000000;          // ktd do divisor clk p/ gerar clkOut 
  
  reg  [24:0] ckConta;                 // contador p/ div clk (24 bits)
  
// divide clock do sistema pelo valor em NclkDIV
  always @(posedge clk or negedge reset)  // na ▲ clk ou ▼ de reset
    begin
    if (!reset)                         // reset reinicia clkNrd
      begin
      ckConta <= 25'b0;                // zera contador clock
      clkOut <= 'b0;                   // zera FF clkNovo
      end
    else if (ckConta==NclkDIV)         // (não é reset) qdo atinge NclkDIV
      begin
      ckConta <= 25'b0;                // reinicia contador ckConta
      clkOut <= ~clkOut;               // e inverte sinal clkNovo	 
      end
    else                               // enquanto não atinge NclkDIV
      ckConta <= ckConta + 'b1;        // apenas incrementa ckConta
    end

endmodule


