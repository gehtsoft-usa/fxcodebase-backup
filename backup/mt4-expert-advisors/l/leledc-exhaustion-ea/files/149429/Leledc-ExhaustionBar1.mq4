//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73312

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_width1 0
#property indicator_color1 Lime
#property indicator_width2 0
#property indicator_color2 Red
extern int qual=6;
extern int len=30;
extern int Distance = 1;
extern int Countbars=1000;
double Up[];
double Dn[];
double point;
double bs=0;
double index=0;
double bindex=0;
double sindex=0;
double length=0;
double ret=0;

int init() {
if(Digits==3 || Digits==5) {
point=10*Point;
}
   else{                     
        point=Point;

}

   IndicatorBuffers(2);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexBuffer(0, Up);
   SetIndexArrow(0,108);
      SetIndexStyle(1, DRAW_ARROW);

      SetIndexBuffer(1, Dn);
   SetIndexArrow(1,108);

   

   return (0);
}

int deinit() {
   return (0);
}

int start() {
bool TurnedUp = false;
bool TurnedDown = false;
 double highest,lowest;

 int i,limit,limit2;
   int counted_bars = IndicatorCounted();
   if(counted_bars < 0) 
   return(-1);
 
   limit=Countbars-counted_bars;
   if (i> limit2) 
   limit2= i;    
   if (limit2 <Countbars-1)
   limit =Countbars- 1; 
  
  for( i=limit; i>=0; i--) {
  if (Close[i]>Close[i+4]){ 
bindex=bindex+1;
}
if(Close[i]<Close[i+4]){ 
sindex=sindex+1;
}
ret=0;
index=0;

 
if ((bindex>qual) && (Close[i]<Open[i])&& (High[i]>=High[iHighest(Symbol(),0,MODE_HIGH,len,i+1)])) { 
index=1;
bindex=0;
ret=-1;
}
if ((sindex>qual) && (Close[i]>Open[i])&& (Low[i]<= Low[iLowest(Symbol(),0,MODE_LOW,len,i+1)])) {
index=-1;
sindex=0;
ret=1;
}

if (ret==1 && i!=0){
Up[i]=Low[i]-Distance*point;
}

if (ret==-1 && i!=0){ 
Dn[i]=High[i]+Distance*point;

}

}
   
if (i> limit2) 
   limit2= i;


   return (0);
}



//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+


