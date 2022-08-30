// ------------------ modulo interface SpikeDriver --------------------------//
//
// apenas faz a interface com o módulo SpikeDriver_SPI
// autor João Ranhel                 data: 2019_03_06
//
//
//---------------------------------------------------------------------------//
module ut_SpikeDriver_SPI
  (
  input clk50, nreset,                 // clk e reset do sistema
  input lsck, lmosi, lnss,             // input do SPI
  output lmiso,                        // saída SPI
  output [SZPFIRED-1:0] FOut           // saída Parallel Firing OUt
  );

  parameter SZPFIRED = 32;             // tam do vetor saída paralela FiredOut

// instancia o módulo SpikeDriver_SPI
SpikeDriver_SPI                        // este modulo 256 nrds
  U1
  (
  .clk       ( clk50 ), 
  .nreset    ( nreset ),
  .lsck      ( lsck ), 
  .lmosi     ( lmosi ), 
  .lnss      ( lnss ),
  .lmiso     ( lmiso ),
  .FiredOut  ( Fout )
  );

endmodule
