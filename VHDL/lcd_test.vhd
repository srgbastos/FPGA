library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;
ENTITY LCD_TEST is port(    clk : IN  std_logic;
                         iRST_N : IN  std_logic;
										         SW : IN  std_logic_vector(17 downto 0);
                                switch,switch2,reset : IN  std_logic;	
                                LCD_DATA : out std_logic_vector(7 downto 0);
                                LCD_RW : out std_logic;
                                LCD_ON : out std_logic;
                                LCD_BLON : out std_logic;
                                LCD_RS : out std_logic;
                                LCD_EN : out std_logic:='0'
										         );
                      end LCD_TEST;
                      
       architecture LCD1 of LCD_TEST is
       constant LCD_INITIAL:std_logic_vector(7 downto 0):="00000000";
      
       constant LCD_LINE1:std_logic_vector(7 downto 0):= "00000100";
       constant LCD_CH_LINE:std_logic_vector(7 downto 0):=LCD_LINE1+16;
       constant LCD_LINE2:std_logic_vector(7 downto 0):=LCD_LINE1+16+1;
       constant LUT_SIZE:std_logic_vector(7 downto 0):=(LCD_LINE2+50)+1;
       signal LUT_DATA:std_logic_vector (11 downto 0):=x"000";--In hex  
       --signal secL : integer range 0 to 9:=0;
       signal secH : integer range 0 to 5 :=0;  
       signal minL : integer range 0 to 9:=0;
       signal minH : integer range 0 to 5:=0;
       signal hourL: integer range 0 to 3:=0;
       signal hourH: integer range 0 to 2:=0;
	     signal LUT_INDEX:std_logic_vector(7 downto 0):="00000000";
       signal mLCD_DONE:std_logic:='0';
       signal mLCD_ST:std_logic_vector(5 downto 0):="000000";
       signal mDLY:std_logic_vector(27 downto 0):=x"0000000";--In hex
       signal mLCD_Start:std_logic:='0';
       signal mLCD_DATA:std_logic_vector(7 downto 0):="00000000";
       signal mLCD_RS:std_logic:='0';
       signal sclk:std_logic:='0';
       signal startcount : integer range 0 to 1:=0;
       signal d1,d2,d3,d4,d5 : std_logic_vector (11 downto 0):=x"130";
       signal d6: std_logic_vector(11 downto 0):=x"130";
       
      
            
       component LCD_controller is
       port( iCLK,iRS,iRST_N,istart: in std_logic;
                                 iDATA:IN std_logic_vector(7 downto 0);
                                 oDone:out std_logic;
                                 LCD_DATA:out std_logic_vector(7 downto 0);
                                 LCD_RW:out std_logic;
                                 LCD_RS:out std_logic;
                                 LCD_EN:out std_logic
           );
       end component LCD_controller; 
       
       component CLK_DIV is
         port ( iCLK: in std_logic;
                sclk: out std_logic
               );
       end component clk_div;           
       begin	    
       U0:LCD_controller 
       port map(
                iCLK=>clk,
                iRS=>mLCD_RS,
                iRST_N=>iRST_N,
                istart=>mLCD_START,
                iDATA=>mLCD_DATA,
                oDone=>mLCD_done,
                LCD_DATA=>LCD_DATA,
                LCD_RW=>LCD_RW,
                LCD_RS=>LCD_RS,
                LCD_EN=>LCD_EN
                );
                
           U1:CLK_DIV
           port map(
             iCLK=>clk,
             sclk=>sclk
           ); 

   LCD_ON<='1';
   LCD_BLON<='0';

	
	 always: process(clk)----(sclk just add)-----(clk)
	 variable secL: integer range 0 to 9:=0;
	   begin
if(switch2 = '1' and switch2'event) then---------initial switch2
startcount<= startcount + 1;            
end if;

if (startcount = 1) then             
if (sclk = '1' and sclk'event)then  

  
  
  if(sw(2)='1') then
  hourH<=2;
  d6<=x"132";
  hourL<=3;
  d5<=x"133";
  
elsif(sw(1)='1') then
minH<=5;
d4<=x"135";
minL<=9;
d3<=x"139";


elsif(sw(0)='1') then
secH<=5;
d2<=x"135";
secL:=9;
d1<=x"139";


 
 end if;
--end if;
--end if;

------------------23 59 59 -----------------------

if (hourH=2) and (hourL=3) and (minH=5) and (minL=9) and (secH=5) and (secL=9) then
hourH<=0;
d6<=x"130";
hourL<=0;
d5<=x"130";
minH<=0;
d4<=x"130";
minL<=0;
d3<=x"130";
secH<=0;
d2<=x"130";
secL:=0;
d1<=x"130";


------------------x3 59 59-------------------------

elsif (hourL=3) and (minH=5) and (minL=9) and (secH=5) and (secL=9) then
hourL<=0;
d5<=x"130";
minH<=0;
d4<=x"130";
minL<=0;
d3<=x"130";
secH<=0;
d2<=x"130";
secL:=0;
d1<=x"130";

if (hourH<2) then
hourH<=hourH+1;
d6<=d6+1;
else 
d6<=x"130";
hourH<=0;
end if;

 
 -----------------xx 59 59--------------------------
 
 elsif (minH=5) and (minL=9) and (secH=5) and (secL=9) then
minH<=0;
d4<=x"130";
minL<=0;
d3<=x"130";
secH<=0;
d2<=x"130";
secL:=0;
d1<=x"130";


if(hourL<3) then
hourL<=hourL+1;
d5<=d5+1;
else
d5<=x"130";
hourL<=0;
end if;
 
 --------------------xx x9 59----------------------
elsif (minL=9) and (secH=5) and (secL=9) then
minL<=0;
d3<=x"130";
secH<=0;
d2<=x"130";
secL:=0;
d1<=x"130";

if(minH<5) then
minH<=minH+1;
d4<=d4+1;
else 
d4<=x"130";
minH<=0;
end if;



--------------------xx xx 59----------------------

elsif(secL=9) and (secH=5) then
secL:=0;
d1<=x"130";
secH<=0;
d2<=x"130";

if(minL<9) then
minL<=minL+1;
d3<=d3+1;
else
  d3<=x"130";
  minL<=0;
end if;

------------------xx xx x9-----------------------

elsif (secL=9) then 
  secL:=0;
  d1<=x"130";
  
  if(secH<5)then
  secH<=secH+1;
  d2<=d2+1;
else
  d2<=x"130";
  secH<=0;
  end if;
--end if;

else
    secL := secL + 1 ;
   d1 <= d1 + 1 ;	

end if;----------------------
end if;-----------------------
end if;

 
--------------LINE1----------------   
if (reset='0') then----------------not press button--------------initialiy is reset='0'
      LUT_INDEX<="00000000";
      mLCD_ST<="000000";
      mDLY<=x"0000000";
      mLCD_DATA<="00000000";
		  mLCD_START<='0';
      mLCD_RS<='0';	
	    
	    secL:=0;
	    secH<=0;
	    
	    minL<=0;
	    minH<=0;
	    hourL<=0;
	    hourH<=0;
	    startcount <= 0;
	    d1 <= x"130";
	    d2 <= x"130";
	    d3 <= x"130";
	    d4 <= x"130";
	    d5 <= x"130";		
	    d6<=x"130";
   elsif (rising_edge(clk))
   then
if (LUT_INDEX<LUT_SIZE)
    then
    case mLCD_ST is     
    when"000000"=>
  mLCD_DATA<=LUT_DATA(7 downto 0);
                  mLCD_RS<=LUT_DATA(8);----------8 meann MSB which is 0
                  mLCD_START<='1';
                  mLCD_ST<="000001";                 
    when"000001"=>done:if(mLCD_DONE='1')----------------?????
                     then
                   mLCD_START<='0';
                   mLCD_ST<="000010";
                 end if done;              
    when"000010"=>	     
            if(switch= '1')
            then
            if(LUT_DATA=x"080")------line 1 first location"00"
            then 
             delay3:if(mDLY<x"1DEEE10")-----------------------?   2FAF079   (1DEEE10)
                        then 
                          mDLY<=mDLY+1;
                        else
                        mDLY<=x"0000000";
                        mLCD_ST<="000011";
                      end if delay3;
            else
            delay4:if(mDLY<x"3FFFE")------------------------5.2 ms    3FFFE
                        then 
                         mDLY<=mDLY+1;
                        else
                       mDLY<=x"0000000";
                        mLCD_ST<="000011";
                      end if delay4;
               end if;
        elsif(clk = '1')
            then
            if(LUT_DATA=x"080")
            then 
             delay5:if(mDLY<x"1DEEE10")----------------------------?    2FAF079  longer delay   (1DEEE10)
                        then 
                          mDLY<=mDLY+1;
                        else
                        mDLY<=x"0000000";
                        mLCD_ST<="000011";
                      end if delay5;
            else
            delay6:if(mDLY<x"3FFFE")---------------------------5.2ms   3FFFE
                        then 
                         mDLY<=mDLY+1;
                        else
                       mDLY<=x"0000000";
                        mLCD_ST<="000011";
                      end if delay6;
							 end if;		
               end if;			 
  when"000011"=>LUT_INDEX<=LUT_INDEX+1;
                mLCD_ST<="000000";
  when others =>mLCD_ST<="000000";
  end case;
  else
  if(sclk ='1' or switch = '1')
  then
  LUT_INDEX<=LCD_INITIAL;
end if;
end if;
end if;
end process always;






----READING OF LCD COMMAND----
check:process(LUT_INDEX)
      begin

   case LUT_INDEX is  
   when LCD_INITIAL+0=>LUT_DATA<=(x"030");
   when LCD_INITIAL+1=>LUT_DATA<=(x"00C");         
   --when LCD_INITIAL+2=>LUT_DATA<=(x"001");          
   when LCD_INITIAL+2=>LUT_DATA<=(x"006");           
   when LCD_INITIAL+3=>LUT_DATA<=(x"080");
   
   

   
   when LCD_LINE1 +1=>LUT_DATA<=(x"120");
   when LCD_LINE1 +2=>LUT_DATA<=(x"120");
   when LCD_LINE1 +3=>LUT_DATA<=(x"120");
   when LCD_LINE1 +4=>LUT_DATA<=(d6);
   when LCD_LINE1 +5=>LUT_DATA<=(d5);
   when LCD_LINE1 +6=>LUT_DATA<=(x"13a");
   when LCD_LINE1 +7=>LUT_DATA<=(d4);
   when LCD_LINE1 +8=>LUT_DATA<=(d3);
   when LCD_LINE1 +9=>LUT_DATA<=(x"13a");
   when LCD_LINE1 +10=>LUT_DATA<=(d2);
   when LCD_LINE1 +11=>LUT_DATA<=(d1);  
    when others=>LUT_DATA<=(x"000");

    end case;	

  end process check; 
   end LCD1;

