/* ----------------------------------------------------------------------------
Descrição: 
Este módulo compara dois bits e indica se são diferentes (Ou-Exclusivo)
-----------------------------------------------------------------------------*/

module paridade_1_bit
  (
  input a, b,              	// entrada: bit "a" e "b" que serão comparados
  output a_xor_b            	// saida: sai 1 se "a" é diferente de "b"
  );
      
  assign a_xor_b = a ^ b;     // XOR

endmodule
