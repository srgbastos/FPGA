/* ----------------------------------------------------------------------------
MODULO "Driver Codificador de Spike Train" == SpikeDriver_SPI ==
autor:   João Ranhel
versão:  1.0          data: 04_03_2019
--
Este módulo recebe NÚMEROS por meio de porta serial, e converte em SPIKES.
o circuito gera spikes para até 256 neurônios pulsantes (nrds) com código:
(a)"rate coding": taxa de disparo proporcional ao valor enviado (0=silente)
(b)"phase coding": tempo de retardo com relação a 1 nrd base dentre 16 grupos
(c)"popularion coding": disparo ± em torno de um limiar dentre 16 grupos. 
ENTRADAS: 
- via mod "SPI_slv_dpRAM" escreve-se a DPRAM#1, 
um circ. externo escreve até 256 valores de 16 bits pela "port-b",
cada Word(16) tem:    tipoNrd=5bits | ValIN=11bits |
tipoNrd: 
• 00000=nrd "rate code" (RC): valIN é delay p/ freqs (1 Hz ... ~666 Hz)
valIN = int((2000-freq*2)/freq);  onde "freq" é a frequência desejada.
• 01bbbb=nrd "phase coding" (PH) e bbbb tem o indx da LUT c/ nrd que faz sync
(valIN = delay com relação ao nrd indexado na LUT da base do grupo bbb)
• 10bbbb=nrd "pop code" (PP), bbbb=indx do grupo na LUT c/ val limiar
PPR:if(ValIN<(limiar<<2)){disparo=ValIN}else{zero}
ValLIM = int( ((2000-freq*2)/freq)<<2 ). O valor é multiplicado p/ 4.
ValIN: 11 bits que controlam delay ou limiar p/ disparo.

- via "SPI_slv_dpRAM" escreve-se na DPRAM#2 (64W x 8bits) 
(a) escreve-se 16 vars 8 bits (add 0x00 até 0x0F), forma LUT com 16 indxs
de nrds cujos disparos são usados para "phase coding";
ex: se nrd 7 é ref, depois que nrd 7 dispara, nrd X conta delay valIN(X)ms;
se nrd 7 dispara em alta freq (delay menor que valIN(X), nrd X não dispara.
(b) escreve-se 16 vars 8 bits (add 0x10 até 0x1F), com uma LUT C/ vals de
limiares (delaysX4) p/ 16 grupos de nrds codificados em 'population code'
ex: ValLIM=250, quaQuer delay menor que (250x4) gera freq saída, ou seja,
se valIN < 1000 começa a disparar. F=1/T; 1/(999)ms => acima de ~1 Hz.
ex: ValLIM=1, quaQuer delay menor que (1x4) gera saída = F=1/(3ms)=333Hz
(c) escreve-se 32 indxs de nrds (add 0x20 até 0x3F), que terão as saídas
ligadas diretamente aos fios em paralelo de saída Firin_Out (FiredOut).

- via "SPI_slv_dpRAM" lê-se de uma DPRAM#3 (32W x 8bits = 256 bits).
O LSB do end 0x00 da DPRAM3 tem 1 bit(=1) se nrd #0 disparou; (=0) se não, 
O MSB do end 0x1F da DPRAM3 tem 1 bit(=1) se nrd #255 disparou; (=0) se não, 

- TODOS os "Adds" das DPRAMs devem estar entre 0x0300 até 0x3FFF (maior).

SAÍDA:
32 fios geram saída em paralelo de até 32 nrds, chamada FiredOut. Os indxs
dos nrds que disparam está nos ends (add 0x20 até 0x3F) da DPRAM2.
O módulo (SLAVE) usa SPI de 4 fios (CPOL=0 CPHA=0 OU 1,1) p/ enviar resultados
sck  ==> clock da interface que vem do MESTRE que controla barramento
mosi ==> dado de entrada (1 bit serial) do mestre para este escravo
miso ==> dado de saída (1 bit serial) daqui p/ mestre 
nss  ==> chip select (em NÍVEL LOW enquanto há comunicação M<=>S)
OBS: o sinal sck é enviado como clk da memória no "port b"
--
Funcionamento:
1. o mestre baixa=↓nss (nss=0 ativo; nss=1 final)
2. mestre coloca bit de dado (para SRcmd)
3. mestre pulsa "sck" (↓sck e ↑sck)ou(↑sck e ↓sck) - strCapture ↑sck
4. depois de 14 pulsos, SRcmd = |Add14| ... |Add0| ? | ? |
   4.1 o circ copia SRcmd[13:0] p/ "RAdd"
5. No 15o. pulso o sinal SRcmd[1] é copiado (ler=1; escrever=0)
6. se SRCmd[1]=0, (memory write)
  6.1 até 15o ↑sck o circ copia MOSI e desloca SRin,
  6.2 na ↓sck qdo (SZW-1), o circ gera wen_a;
  6.3 prox ↑sck, copia {SRin[SZWD-2:0], mosi} p/ memória
  6.4 prox ↓sck baixa wen_a;
  6.5 O valor do RAdd (= Add_a) é inc 2 sck após wen_a (++RAdd)
  6.5 se SRcmd[0]=1 (modo contínuo), repete de 6.1 (até que item 8 ocorra)
7. se SRCmd[1]=1, (memory read)
  7.1 qdo chegar o 15o. pulso de comando, habilita ren_a p/ ler memoria
  7.2 na do 16o. pulso ↑sck o circ lê memória (retido em Q_a)
  7.2 na prox ↓sck copia Q_a p/ SRout e volta ren_a=0
  7.3 O valor do RAdd (= Add_a) é inc 2 sck após ren_a (++RAdd)
  7.3 a cada ↓sck desloca SRout até SZW-1, 
  7.4 se SRcmd[0]=1, em (SZW-1), prox ↑sck, lê mem p/ Q_a e repete 7.2
8. quando ↑nss volta para reset

OBS: ** alterar o módulo DPRAM (IP da Intel) "dpRAM_01" e ajustar:
        SZWD = para o tamanho da palavra (8/16/32 bits) de memória
        SZADD = tamanho do bus add da memória (e.g. p/ 1K, SZADD=10)
Params do IP DPRAM: clk_a, clk_b, wen_a, wen_b separados, o resto default
ADD0 é end inicial desse módulo de RAM; e ADDF = ADD0+((2**SZADD)-1).
-----------------------------------------------------------------------------*/
module SpikeDriver_SPI                 // este modulo 256 nrds
  (
  input clk, nreset,                   // clk e reset do sistema
  input lsck, lmosi, lnss,             // input do SPI
  output lmiso,                        // saída SPI
  output reg [SZPFIRED-1:0] FiredOut   // saída Parallel Firing OUt
  );
  parameter SZWD1=16;                  // tam WRD da DPRAM#1 ports a/b
  parameter SZADD1 = 8;                // tam do BUS de end da DPRAM#1  
  parameter SZWD2=8;                   // tam WRD da DPRAM#2 ports a/b
  parameter SZADD2 = 6;                // tam do BUS de end da DPRAM#2 
  parameter SZWD3A = 1;                // larg word port-a (1...1024 bits)
  parameter SZADD3A = 8;               // larg bus Add mem port-a (256 bits)
  parameter SZWD3B = 16;               // larg word port-b:SPI (32,16,8 bits)
  parameter SZADD3B = 4;               // larg bus add mem port-b (16 wrds)

  parameter ADD0 = 14'h3800;           // end da DPRAM#1 no sistema
  parameter ADD1 = 14'h3900;           // end da DPRAM#2 no sistema
  parameter ADD2 = 14'h3940;           // end da DPRAM#3 no sistema

  localparam SZPFIRED=32;              // tam saídas paralelas FiredOut 
  localparam [SZWD1-1:0] ZEROWD1 = {{(SZWD1-1){1'b0}}, 1'b0}; 
  localparam [SZWD1-1:0] FIREDSTT1 = {4'b0001,{(SZWD1-8){1'b0}}, 4'd0};  
  localparam [SZWD1-1:0] FIREDSTT2 = {4'b0010,{(SZWD1-8){1'b0}}, 4'd0}; 
  localparam [SZWD1-1:0] FIREDSTT3 = {4'b0100,{(SZWD1-8){1'b0}}, 4'd0}; 
  localparam [SZWD1-1:0] FIREDSTT4 = {4'b1000,{(SZWD1-8){1'b0}}, 4'd0};  
  localparam [SZADD1-1:0] RESADDN = {{(SZADD1-1){1'b0}}, 1'b0};
  localparam [SZADD1-1:0] ULTADDN = {{(SZADD1-1){1'b1}}, 1'b1};
  localparam [SZADD3A-1:0] RESADDFRD = {{(SZADD3A-1){1'b0}}, 1'b0};
  localparam [SZADD3A-1:0] ULTADDFRD = {{(SZADD3A-1){1'b1}}, 1'b1};
  localparam [SZADD2-1:0] RESADDLST = {{(SZADD2-1){1'b0}}, 1'b0};
  localparam [SZADD2-1:0] FIRADDLST = {1'b1,{(SZADD2-2){1'b0}}, 1'b0};
  localparam [SZADD2-1:0] ULTADDLST = {{(SZADD2-1){1'b1}}, 1'b1};
  
// regs, flags e fios para construir o sistema
  reg [SZWD1-1:0] Res1;                // reg rasc guarda Resultado 1o. mod
  reg [SZADD1-1:0] AddN;               // Add do nrd under test
  reg [SZADD2-1:0] AddLST;             // add da mem dpRAM#2
  reg fadd2_a;                         // flag ctrl mux end mem2 port a
  reg fadd3_a;                         // flag ctrl mux end mem3 port a
  reg wen34_a;                         // hab gravação port_a mem #3 e #4
// logica para habilitar e desabilitar clks nas dpRAMs 
  reg hclk_14a;                        // hab clk mems #1 e #4
  reg hclk_3a;                         // hab clk mem #3 
  reg hclk_2a;                         // hab clk mem #3   
  wire clk14_a, clk3_a, clk2_a;        // sinais de clk p/ mems
  assign clk14_a = clk & hclk_14a;     // clock gated p/ mems #1 e #4
  assign clk3_a = clk & hclk_3a;       // clock gated p/ mem #3
  assign clk2_a = clk & hclk_2a;       // clock gated p/ mem #2
  
// lógica para geração do sinal de saída lmiso
  wire lmiso1, lmiso2, lmiso3;
  assign lmiso = lmiso1 | lmiso2 | lmiso3;  
  
  reg [3:0] stt;                       // vetor p/ controlar estado da máq
  // estados da máquina
  parameter S0=0, S1=1, S2=2, S3=3, S4=4, S5=5, S6=6, S7=7;
// ↑cLK (50MHz) lê dados e copia resultado de volta
always @(posedge clk or negedge nreset or negedge clk2K)
  begin
    if (nreset=='b0 || clk2K=='b0)     // se nreset ou clk2K = '0'
      begin
        stt <= S0;
      end
    else
      begin
        case(stt)
        S0:                            // S0: certifica subida de clk2K 
          begin
            if (clk2K=='b1) begin stt<=S0; end 
            else begin stt<=S1; end
          end
        S1:                            // S1: clk2 está em '0' espera subida
          begin
            if (clk2K=='b0) begin stt<=S1; end 
            else begin stt<=S2; end    // vai p/ S2 iniciar varredura AddN 
          end
        S2:                            // nessa subida lê Q4_a[AddN]
          begin
            stt <= S3;
          end
        S3:                            // salva dados em D3_a e D4_a[AddN]
          begin
            if (AddN==ULTADDN) begin stt <= S4; end // ult AddN vai p/ S4
            else begin stt <= S2; end  // se não, fica em stt S2 até ult AddN
          end
  // fase de convolução p/ check do FiredOut
        S4:                            // ajusta 1o. add convolução Q2_a
          begin
            stt <= S5;
          end
        S5:                            // lê valor da mem baseado no indx
          begin
            if (AddLST==ULTADDLST) begin stt <= S7; end // últ AddLST p/ S7
            else begin stt <= S6; end  // se não fica em stt S6
          end
        S6:                            // calc e inc AddLST
          begin
            stt <= S5;
          end
        S7:                            // final do ciclo c/ clk2K em '1'
          begin
            stt <= S7;
          end
        endcase
      end
  end
  
// ↓cLK (50MHz) faz calcs, controla AddN, wen_, 
always @(negedge clk or negedge nreset or negedge clk2K)
  begin
    if (nreset=='b0 || clk2K=='b0)     // se nreset ou clk2K = '0'
      begin
        AddN <= RESADDN;               // reset do indx de nrd
        Res1 <= ZEROWD1;               // zera resultado Res1
        wen34_a <= 'b0;                // reset wen34_a (contadores)
        fadd3_a <= 'b0;                // ctrl end mem 3 (fired) p/ AddN
        fadd2_a <= 'b0;                // ctrl end mem 2 (indx) PH e PP
        fadd3_a <= 'b0;                // ctrl end mem 4 (saída 
        hclk_14a <= 'b0;               // desabilita clk mems #1 e #4
        hclk_3a <= 'b0;                // desabilita clk mem #3
        hclk_2a <= 'b0;                // desabilita clk mem #2
      end
    else
      begin 
        case(stt)                      // qual o estado da máquina atual?
        S1:
          begin
            hclk_14a <= 'b1;           // habilita clk mems #1 e #4
            hclk_3a <= 'b1;            // habilita clk mem #3
          end
        S2:                            // calc FIRED e novo AddN
          begin
            wen34_a<='b1;              // hab wen34_a, grava dpRAM#4 e #3
            if (Q4_a == ZEROWD1)       // se val desse nrd=0 ( FIRED !!! )
              begin
                fired <= 'b1;          // dispara o nrd
                Res1 <= FIREDSTT1;     // disparou e está no estágio 1
              end
            else if (Q4_a==FIREDSTT1)  // se val desse nrd = FIREDSTT1
              begin
                fired <= 'b1;          // continua disparado
                Res1 <= FIREDSTT2;     // disparou e está no estágio 2
              end
            else if (Q4_a==FIREDSTT2)  // se val desse nrd = FIREDSTT2
              begin
                fired <= 'b1;          // continua disparado
                Res1 <= FIREDSTT3;     // disparou e está no estágio 3
              end  
            else if (Q4_a==FIREDSTT3)  // se val desse nrd = FIREDSTT2
              begin
                fired <= 'b1;          // continua disparado
                Res1 <= FIREDSTT4;     // disparou e está no estágio 3
              end  
            else if (Q4_a==FIREDSTT4)  // se val desse nrd = FIREDSTT3
              begin
                fired <= 'b0;          // continua disparado
                Res1 <= WQ1_a;          // recarrega valor da mem
              end
            else                       // se não zerou (NOT FIRED) 
              begin
                fired <= 'b0;          // normalmente não dispara o nrd
                Res1 <= Q4_a-'b1;      // apenas decrementa 1 unidade
              end  
            // teste para ver outros outros modos de disparo (PP e PC)
            case (WQ1_a[SZWD1-1:SZWD1-2])// teste para tipo de código/geração
            (2'b01):                   // PH: gerar codigo "phase coding"
              begin
                if (Q2_a=='b1)         // se nrd inx p/ M2 disparou
                  begin
                    Res1 <= WQ1_a;      // recarrega valor da mem
                  end
              end 
            (2'b10):                   // PP: gerar cod "population coding"
              begin
                if (WQ1_a <= (Q2_a << 2))
                  begin
                    Res1 <= WQ1_a;      // recarrega valor da mem
                  end
                else
                  begin
                    Res1 <= {{(SZWD1-1){1'b0}},1'b1};
                  end
              end
            endcase
          end
        S3:
          begin
            wen34_a<='b0;              // desab wen34_a, grava dpRAM#4 e #3
            AddN <= AddN + 'b1;        // inc o AddN do neuroide
          end
  // fase de convolução p/ check do FiredOut
        S4:                            // 1O. lê indx do nrd na lista dpRAM#2
          begin
            hclk_14a <= 'b0;           // desabilita clk mems #1 e #4
            hclk_2a <= 'b1;            // habilita clk mem #2
            fadd3_a <= 'b1;            // end mem 3 (fired) p/ AddF
            AddLST <= FIRADDLST;       // 1o. end lista fired (addLST=0)
          end
        S5:                            // copia bit da mem#3 p/ FiredOUt
          begin
            FiredOut[AddLST] <= Q3_a;  // FiredOut[AddLST]<=M#3[Q2_a[AddLST]]
          end
        S6:                            // inc AddLST
          begin
            AddLST <= AddLST + 'b1;    // inc o AddLST da lista p/ FiredOut
          end
        S7:                            // espera sinal clk2k descer
          begin
            hclk_3a <= 'b0;            // desabilita clk mem #3
            hclk_2a <= 'b0;            // desabilita clk mem #2
          end 
        endcase
      end
  end

  
// DPRAM#1: mestre escreve tipo/vals que controlam a conversão/geração spikes
  wire [SZADD1-1:0] Add1_a;            // endereço port B da DPRAM#1
  wire wen1_a;                         // clk e wen locais p/ port_b DPRAM#1
  assign wen1_a = 'b0;                 // nunca escreve pela port b  
  wire [SZWD1-1:0] WQ1_a;              // saída Qb DPRAM#1
  
  SPI_slv_dpRAM_256x16 #(              // mód SPI_slv_dpRAM_256x16 (params)
    .SZWDA  ( SZWD1 ),                 // larg word port-a (1...1024 bits)
    .SZADDA ( SZADD1 ),                // larg bus Address mem port-a
    .SZWDB  ( SZWD1 ),                 // larg word port-b:SPI (32,16,8 bits)
    .SZADDB ( SZADD1 ),                // larg bus Address SPI port-b
    .ADD0   ( ADD0 )                   // end inicial da memória
    ) slv_U1 (                         // nome do componente/instancia
    .sck    ( lsck ),                  // ligar local sck no "sck" do SPI
    .mosi   ( lmosi ),                 // ligar local mosi no "mosi" do SPI 
    .nss    ( lnss ),                  // ligar local nss no "nss" do SPI 
    .miso   ( lmiso1 ),                // ligar local miso no "miso" do SPI 
    .Add_a  ( Add1_a ),                // bus address da port a
    .clk_a  ( clk14_a ),               // clk da memória na port a 
    .wen_a  ( wen1_a ),                // write enable da mem na port a
    .D_a    ( D1_a ),                  // dado p/ a mem via port a
    .Q_a    ( WQ1_a )                   // dado vindo da memória via port a
    );   

    
// DPRAM#2: 16 indxs "PH", 16 lims "PP" <<2, 32 indxs nrds Fired paralelo 
  wire [SZADD2-1:0] Add2_a;            // endereço port 'a' da DPRAM#2
  assign add2_a = fadd2_a? WQ1_a[SZWD1-3:SZWD1-6] : AddLST;
  wire wen2_a;                         // clk e wen locais p/ port_a DPRAM#1
  assign wen2_a = 'b0;                 // nunca escreve pela port a
  wire [SZWD2-1:0] D2_a;               // input Da DPRAM#2
  wire [SZWD2-1:0] Q2_b;               // saída Qb DPRAM#2
  
  SPI_slv_dpRAM_64x8 #(                // mód SPI_slv_dpRAM_64x8 (params)
    .SZWDA  ( SZWD2 ),                 // larg word port-a (1...1024 bits)
    .SZADDA ( SZADD2 ),                // larg bus Address mem port-a
    .SZWDB  ( SZWD2 ),                 // larg word port-b:SPI (32,16,8 bits)
    .SZADDB ( SZADD2 ),                // larg bus Address SPI port-b
    .ADD0   ( ADD1 )                   // end inicial da memória
    ) slv_U2 (                         // nome do componente/instancia
    .sck    ( lsck ),                  // ligar local sck no "sck" do SPI
    .mosi   ( lmosi ),                 // ligar local mosi no "mosi" do SPI 
    .nss    ( lnss ),                  // ligar local nss no "nss" do SPI 
    .miso   ( lmiso2 ),                // ligar local miso no "miso" do SPI 
    .Add_a  ( add2_a ),                // bus address da port a (after mux)
    .clk_a  ( clk2_a ),                // clk da memória na port a 
    .wen_a  ( wen2_a ),                // write enable da mem na port a
    .D_a    ( D2_a ),                  // dado p/ a mem via port a
    .Q_a    ( Q2_a )                   // dado vindo da memória via port a
    );   
    
// instanciamento DPRAM#3
  reg fired;                           // ff-d fired =1 qdo nrd disparou;
  wire [SZADD1-1:0] Add3_a;            // Add da port "a" mem 3 (fired)
  assign Add3_a=fadd3_a? AddN: Q2_a;   // mux controla quem endereça Add3_a
  wire Q3_a;                           // fio conectado ao bit Qa, não usado
 
SPI_slv_dpRAM_256x1_16x16 #(           // mód SPI_slv_dpRAM_64x8 (params)
    .SZWDA  ( SZWD3A ),                // larg word port-a (1...1024 bits)
    .SZADDA ( SZADD3A ),               // larg bus Address mem port-a
    .SZWDB  ( SZWD3B ),                // larg word port-b:SPI (32,16,8 bits)
    .SZADDB ( SZADD3B ),               // larg bus Address SPI port-b
    .ADD0   ( ADD2 )                   // end inicial da memória
    ) slv_U3 (                         // nome do componente/instancia
    .sck    ( lsck ),                  // ligar local sck no "sck" do SPI
    .mosi   ( lmosi ),                 // ligar local mosi no "mosi" do SPI 
    .nss    ( lnss ),                  // ligar local nss no "nss" do SPI 
    .miso   ( lmiso3 ),                // ligar local miso no "miso" do SPI 
    .Add_a  ( Add3_a ),                // bus address da port a (after mux)
    .clk_a  ( clk3_a ),                // clk da memória na port a 
    .wen_a  ( wen3_a ),                // write enable da mem na port a
    .D_a    ( fired ),                 // dado p/ a mem via port a
    .Q_a    ( Q3_a )                   // dado vindo da memória - não usado
    );   

// instanciamento DPRAM#4 (contadores e controle maq de estados)
  wire [SZADD1-1:0] Add4_a, Add4_b;    // ends port A e B da DPRAM#4
  wire clk4_a, clk4_b;                 // clks da DPRAM#4
  wire [SZWD1-1:0] D4_b;               // entrada Db DPRAM#4
  wire wen4_b;                         // wen locais p/ port_b DPRAM#4
  assign wen4_b = 'b0;                 // nunca escreve pela port b
  wire [SZWD1-1:0] Q4_a, Q4_b;         // saídas Qa e Qb DPRAM#4
  
  dpRAM_256x16	                       // inst IP DRPRAM (On Chip Memory)
   DP_U04 (                            // nome desse componente/inst
	.address_a ( Add4_a ),               // add4_a 
	.address_b ( Add4_b ),               // add4_b
	.clock_a   ( clk14_a ),              // clock_a (gated) = clk mem#1
	.clock_b   ( clk4_b ),               // clock_b 
	.data_a    ( Res1 ),                 // data4_a
	.data_b    ( D4_b ),                 // data4_b
	.wren_a    ( wen34_a ),              // wen34_a
	.wren_b    ( wen4_b ),               // wen4_b
	.q_a       ( Q4_a ),                 // Q4_a
	.q_b       ( Q4_b ));                // Q4_b
  
  
// instancia divisor (clk_div) e atualiza o par (kte NclkDIV) do modulo
  wire clk2K;                          // clk2K de controle ger pulsos 
clk_div #( .NclkDIV (12_500)) ckDv1    // inst clk_div, redefine NclkDIV
  (                                    // mapear ports do módulo
  .clk    ( clk ),                     // clk daquele mod liga no clk daqui
  .reset  ( nreset),                   // reset de lá em reset daqui
  .clkOut ( clk2K )                    // clkOut de lá em clk2K daqui
  );

endmodule

/* OBS: faixas de frequências obtidas com rate code
ValIN=666: obtém 666Hz; os próximos valores de freq válidos:
(500,400,333,285,250,222,200,182,167,154,143,133,125,118,111,105)
para os próximos, arredondar para o 'int' mais próximo
(100,95,91,87,83,80,77,74,71,69,67,65,63,61,59,57,55.5,54,52.6,51,50)
(49,47.6,46.5,45.5,44.5,43.5,42.5,41.6,40.8,40,39,38.5,37.7,37,35.7,35)
ex: 34 (delay de ~29ms gera 34.48 Hz); 32 (delay ~31ms) gera 32.25 Hz
a partir desses vals as freq têm erros menoress comparadas aos int
(30.77, 29.85, 28.98, 28.16, 27.02, 25.97, 25, 24.09, 22.99, 21.98)
(21.05, 20, 19.05, 18.01, 17.09, 16, 15.03, 13.99, 12.99, 11.98, 10.99)
(10, 9.01, 8, 7.02, 6.01, 5, 4, 2.99, 2, 1 Hz)
*/

