/* --------------------------------------------------------------------------- 
Este circuito conecta o sistema Nios II gerado no Platform Designer (Qsys) do Quartus 
com os pinos físicos da placa didática
Nota: nreset é ligado a um dos Push-Button da placa – ativo em ‘0’ 
dependendo da placa, os LEDs são ativos em ‘0’, em vez de ‘1’. 
----------------------------------------------------------------------------*/
 
module ut_primo_Nios 
( 
	input clk_50, nreset, // reset e clock 50MHz 
	output [7:0] LED // saída 7 LEDs 
); 

// aqui instanciamos o sistema Nios2 como circuito chamado U01 
primo_Nios2 // nome do arquivo que descreve Nios2 
U01 // nome da instância nesta interface 
( 
	.clk_clk ( clk_50 ), // clk ligado no clock 50MHz 
	.pio_led_export ( LED ), // LEDs nos pinos exportados pio 
	.reset_reset_n ( nreset ) // reset.reset_n 
); 
endmodule
