/* Descrição: O circuito multiplexado pode receber 2 entradas de 4 bits e mostrar nos displays.
A taxa de multiplexação de 1000 Hz garante que o olho humano não perceberá oscilações.
Usando o clock da placa de 50Mhz e os 2 MSBits de um contador de 18 bits
dá para gerar uma taxa de atualização de 50MHz/(2^16), ao redor de 763 Hz.
*/

module sevenseg(
 input clock, // clock no pino 23 do kit (50MHz)
 input [3:0] ent1, ent2, // entrada1 com 4 chaves, entrada2 com 4 chaves
 output a, b, c, d, e, f, g, dp, // display de 7 segmentos e o dp (dot point)
 output [3:0] an // habilita os catodos an[3] an[2]...
 );
 
localparam N = 18; // pode ser alterado para mudar a frequência
 
reg [N-1:0]count; // para o contador de 18 bits que vai permitir
                  // multiplexar em 1000Hz aprox. (763Hz)
 
always @ (posedge clock)
 begin
   count <= count + 1;
 end
 
reg [3:0]sseg; // Registrador de 4 bits para guardar a entrada
reg [3:0]an_temp; // Registrador para habilitar os catodos
 
always @ (*) // O asterisco indica: qualquer alteração...
 begin
  case(count[N-1:N-2]) // Usa apenas os 2 MSB's bits do contador 
  
   2'b00: // Caso os 2 MSB's sejam 00, habilita o display
    begin // da unidade (menos significativo)
     sseg = ent1; // Entrada1 será conectada
	  an_temp = 4'b0001; // habilita catodo da direita (unidade)
    end
   2'b01: // 01, habilita o display da dezena
    begin
     sseg = ent2;
	  an_temp = 4'b0010;
    end
   2'b10: // 10...centena...
    begin
     sseg = 4'd0; // mostra o número 0
     an_temp = 4'b0100;
    end
   2'b11: // 11... milhar
    begin
     sseg = 4'h0; // mostra o número 0
     an_temp = 4'b1000;
    end
  endcase
 end
assign an = an_temp; // conecta o registrador an_temp nos pinos an...
 
reg [6:0] sseg_temp; // Registrador de 7 bits para guardar o valor
                     // binário de cada entrada nos leds a, b, c...
always @ (*)
 begin
  case(sseg)
	4'b0000: sseg_temp = 7'b0111111; // acende os LEDs para formar 0
	4'b0001: sseg_temp = 7'b0000110; // acende os LEDs para formar 1
	4'b0010: sseg_temp = 7'b1011011; // acende os LEDs para formar 2
	4'b0011: sseg_temp = 7'b1001111; // acende os LEDs para formar 3
	4'b0100: sseg_temp = 7'b1100110; // acende os LEDs para formar 4
	4'b0101: sseg_temp = 7'b1101101; // acende os LEDs para formar 5
	4'b0110: sseg_temp = 7'b1111101; // acende os LEDs para formar 6
	4'b0111: sseg_temp = 7'b0000111; // acende os LEDs para formar 7
	4'b1000: sseg_temp = 7'b1111111; // acende os LEDs para formar 8
	4'b1001: sseg_temp = 7'b1101111; // acende os LEDs para formar 9
	4'b1010: sseg_temp = 7'b1110111; // acende os LEDs para formar A
	4'b1011: sseg_temp = 7'b1111100; // acende os LEDs para formar b
	4'b1100: sseg_temp = 7'b0111001; // acende os LEDs para formar C
	4'b1101: sseg_temp = 7'b1011110; // acende os LEDs para formar d
	4'b1110: sseg_temp = 7'b1111001; // acende os LEDs para formar E
	4'b1111: sseg_temp = 7'b1110001; // acende os LEDs para formar F
	default: sseg_temp = 7'b1000000; // se entrada inválida mostra '-'
  endcase
 end

// concatena as saídas dos leds ao registrador
assign {g, f, e, d, c, b, a} = sseg_temp; 
assign dp = 1'b0; // como não usamos o dot point, zeramos
endmodule

