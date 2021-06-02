/* ----------------------------------------------------------------------------
Descrição: 
Projeto que monta a estrutura de um Gerador de paridade par
ATENÇÃO: este é o arquivo TOP-LEVEL do projeto
-----------------------------------------------------------------------------*/

module Gerador_de_Paridade
  (
  input [3:0] D_in,    		// entradas
  output [3:0] D_out,     	// saídas
  output Paridade_par		// indicador de paridade par
  );
  
  wire [1:0] x;        			// interligar os módulos instanciados

paridade_1_bit Bit_0_1 	// use o nome do módulo, em seguida um nome local
    (                 				// "port map": mapear sinais daquele módulo neste!
    .a      (D_in[0]),   		// o sinal "a" do mód importado liga ao D_in[0] nesse mód
    .b      (D_in[1]),   		// o sinal "b" do mód importado liga ao D_in[1] nesse mód 
    .a_xor_b (x[0]));  		// o a_xor_b do mód importado liga ao x[0] aqui

paridade_1_bit Bit_2_3 (
    .a      (D_in[2]),
    .b      (D_in[3]), 
    .a_xor_b (x[1]));  

paridade_1_bit Saida (
    .a      (x[0]),
    .b      (x[1]), 
    .a_xor_b (Paridade_par));  

	assign D_out = D_in;
  
endmodule
