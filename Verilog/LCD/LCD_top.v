/* Descrição:
Circuito controlador do display LCD. PinPlanner:
CLOCK_50 - PIN_23	
LCD_DATA[7] - PIN_49
LCD_DATA[6] - PIN_46
LCD_DATA[5] - PIN_44
LCD_DATA[4] - PIN_43
LCD_DATA[3] - PIN_42
LCD_DATA[2] - PIN_39
LCD_DATA[1] - PIN_38
LCD_DATA[0] - PIN_34
LCD_EN - PIN_33	
LCD_RS - PIN_31	
LCD_RW - PIN_32	
*/

module LCD_top
(
	input CLOCK_50,  //50 MHz
	output LCD_RW,   //LCD Read/Write Select, 0 = Write, 1 = Read
	output LCD_EN,   //LCD Enable
	output LCD_RS,   //LCD Command/Data Select, 0 = Command, 1 = Data
	output [7:0] LCD_DATA //LCD Data bus 8 bits
);

wire DLY_RST; // fio para conectar a saída do módulo Reset_Delay

// instância do clock_divider
Reset_Delay r0
(
	.iCLK(CLOCK_50),
	.oRESET(DLY_RST)
);

// instância do LCD_test
LCD_TEST u5
(	
	.iCLK(CLOCK_50),
   .iRST_N(DLY_RST),
   .LCD_DATA(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_EN(LCD_EN),
   .LCD_RS(LCD_RS)   
);

endmodule

