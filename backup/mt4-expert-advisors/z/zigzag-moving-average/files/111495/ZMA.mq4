// Id: 17822
//+------------------------------------------------------------------+
//|                                                          ZMA.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_buffers 2
#property indicator_chart_window
#property indicator_width1 1
#property indicator_color1 clrLime
#property indicator_width2 1
#property indicator_color2 clrRed

extern int Depth      = 12;
input  int Deviation  = 5;
extern int Backstep   = 3;
extern int Limit_Bars = 800;

double MA_Top[];
double MA_Bottom[];

int init(){
   
       double temp = iCustom(NULL, 0, "ZigZag", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ZigZag' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("ZMA");
   
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,159);
   SetIndexBuffer(0,MA_Top);
   SetIndexDrawBegin(0,Depth);
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,159);
   SetIndexBuffer(1,MA_Bottom);
   SetIndexDrawBegin(1,Depth);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars>0) limit = Limit_Bars;
   
   double ZZ, Last_ZZ, MA = 0;
   int    Candles = 0;
   
   for(i=limit; i>=0; i--){
      
      ZZ = iCustom(NULL,0,"ZigZag",Depth,Deviation,Backstep,0,i);
      
      if (ZZ > 0){
      
         if (ZZ > Last_ZZ){
         
            MA_Top[i] = Close[i];
            Last_ZZ = High[i];
         
         }
         else{
         
            MA_Bottom[i] = Close[i];   
            Last_ZZ = Low[i];
         
         }
         
         Candles = 1;
      
      }
      else{
      
         MA = 0;
         Candles++;
         for (j=i; j<(i+Candles); j++){
            MA+=Close[j];
         }
         MA = MA/Candles;
         
         if (MA < Last_ZZ) MA_Top[i] = MA; else MA_Bottom[i] = MA;
      
      }
   
   }
   
//----
   return(0);
}
  
