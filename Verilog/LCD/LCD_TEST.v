module LCD_TEST
( 	input iCLK,iRST_N,
	output [7:0] LCD_DATA,
	output LCD_RW,LCD_EN,LCD_RS
);

    //Internal Wires/Registers
    reg [5:0]  LUT_INDEX; // Look-Up Table. Reg para percorrer todo o texto
    reg [8:0]  LUT_DATA; // Look-Up Table. Recebe o dado (caractere ou comando)
    reg [5:0]  mLCD_ST; // Eestados da FSM
    reg [17:0] mDLY; // Registrador para gerar 5.2 ms (temporização do LCD)
    reg        mLCD_Start;
    reg [7:0]  mLCD_DATA;
    reg        mLCD_RS;
    wire       mLCD_Done;

    parameter    LCD_INTIAL  = 0;
    parameter    LCD_LINE1   = 5;
    parameter    LCD_CH_LINE = LCD_LINE1+16;
    parameter    LCD_LINE2   = LCD_LINE1+16+1;
    parameter    LUT_SIZE    = LCD_LINE1+32+1;

    always@(posedge iCLK or negedge iRST_N)
    begin
        if(!iRST_N)
        begin
            LUT_INDEX  <= 0;
            mLCD_ST    <= 0;
            mDLY       <= 0;
            mLCD_Start <= 0;
            mLCD_DATA  <= 0;
            mLCD_RS    <= 0; // instrução
        end
        else
        begin
            if(LUT_INDEX<LUT_SIZE)
            begin
                case(mLCD_ST)
                0:    begin
                        mLCD_DATA  <= LUT_DATA[7:0];
                        mLCD_RS    <= LUT_DATA[8];
                        mLCD_Start <= 1;
                        mLCD_ST    <= 1; // vai para o estado 1
                    end
                1:    begin
                        if(mLCD_Done)
                        begin
                        mLCD_Start <= 0;
                        mLCD_ST    <= 2; // vai para o estado 2
                        end
                    end
                2:    begin
                        if(mDLY<18'h3FFFE) // 5.2ms
                        mDLY <= mDLY+1;
                        else
                        begin
                           mDLY    <= 0;
                           mLCD_ST <= 3; // vai para o estado 3
                        end
                    end
                3:    begin
                        LUT_INDEX  <= LUT_INDEX+1;
                        mLCD_ST    <= 0;	// volta para o estado 0
                    end
                endcase
            end
        end
    end

  always
  begin
	case(LUT_INDEX)
   // Inicializa o display
   LCD_INTIAL+0:	LUT_DATA	<=	9'h038; // Function Set: Length=8bits, N=2lines
   LCD_INTIAL+1:  LUT_DATA <= 9'h00C; // Display ON
   LCD_INTIAL+2:  LUT_DATA <= 9'h001; // Clear Display
   LCD_INTIAL+3:  LUT_DATA <= 9'h006; // Entry Mode Set
	
	// Comando para posicionar o cursor. A 1a linha vai da posição 80 até 8F
   LCD_INTIAL+4:  LUT_DATA <= 9'h086; // Set ddram address
	
   // Texto para a Linha 1
   LCD_LINE1+0:	LUT_DATA	<=	9'h14F; // O
   LCD_LINE1+1:   LUT_DATA <= 9'h16C; // l
   LCD_LINE1+2:   LUT_DATA <= 9'h161; // a
	// LCD_LINE1+3:	LUT_DATA	<=	9'h161; // Espaço para usar a linha toda
	// LCD_LINE1+4:	LUT_DATA	<=	9'h161; // 
	// LCD_LINE1+5:   LUT_DATA <= 9'h161; //
	// LCD_LINE1+6:   LUT_DATA <= 9'h161; // 
	// LCD_LINE1+7:   LUT_DATA <= 9'h161; // 
	// LCD_LINE1+8:   LUT_DATA <= 9'h161; // 
	// LCD_LINE1+9:   LUT_DATA <= 9'h161; // 
	// LCD_LINE1+10:  LUT_DATA <= 9'h161; // 
	// LCD_LINE1+11:  LUT_DATA <= 9'h161; //
   	// LCD_LINE1+12:  LUT_DATA <= 9'h161; // 
   	// LCD_LINE1+13:  LUT_DATA <= 9'h161; // 
   	// LCD_LINE1+14:  LUT_DATA <= 9'h161; // 
   	// LCD_LINE1+15:  LUT_DATA <= 9'h161; // 
   
	// Comando para posicionar o cursor. A 2a linha vai da posição C0 até CF
   LCD_CH_LINE:	LUT_DATA	<=	9'h0C5;
	
	// Texto para a Linha 2
   LCD_LINE2+0:	LUT_DATA	<=	9'h14D; // M
   LCD_LINE2+1:	LUT_DATA <= 9'h175; // u
   LCD_LINE2+2:   LUT_DATA <= 9'h16E; // n
   LCD_LINE2+3:   LUT_DATA <= 9'h164; // d
   LCD_LINE2+4:   LUT_DATA <= 9'h16F; // o
	LCD_LINE2+5:	LUT_DATA	<=	9'h121; // !
	// LCD_LINE2+6:   LUT_DATA	<= 9'h121; // Espaço para usar a linha toda 
	// LCD_LINE2+7:   LUT_DATA <= 9'h121; // 
	// LCD_LINE2+8:   LUT_DATA <= 9'h121; // 
	// LCD_LINE2+9:   LUT_DATA <= 9'h121; // 
	// LCD_LINE2+10:  LUT_DATA <= 9'h121; // 
	// LCD_LINE2+11:  LUT_DATA <= 9'h121; // 
	// LCD_LINE2+12:  LUT_DATA <= 9'h121; // 
	// LCD_LINE2+13:  LUT_DATA <= 9'h121; // 
	// LCD_LINE2+14:  LUT_DATA <= 9'h121;
	// LCD_LINE2+15:  LUT_DATA <= 9'h121;
	default:			LUT_DATA	<=	9'h002; // Return Home
	endcase
end

// Faz a instância do controlador LCD
LCD_Controller u0
(  .iDATA(mLCD_DATA),
   .iRS(mLCD_RS),
   .iStart(mLCD_Start),
   .oDone(mLCD_Done),
   .iCLK(iCLK),
   .iRST_N(iRST_N),
   .LCD_DATA(LCD_DATA),
   .LCD_RW(LCD_RW),
   .LCD_EN(LCD_EN),
   .LCD_RS(LCD_RS)
);

endmodule

