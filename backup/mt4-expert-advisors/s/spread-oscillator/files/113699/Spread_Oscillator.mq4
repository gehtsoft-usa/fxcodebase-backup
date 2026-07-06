// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64942

//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1

extern string Pair1        = "EURUSD";
extern string Pair2        = "GBPUSD";
extern int    Short_Period = 5;
extern int    Long_Period  = 15;

double SO[];
double Ratio[];
double Short_MA[];
double Long_MA[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Spread Oscillator");
   
   IndicatorBuffers(4);
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,SO);
   
   SetIndexBuffer(1,Ratio);
   SetIndexBuffer(2,Short_MA);
   SetIndexBuffer(3,Long_MA);
   
   SetLevelValue(0,0);
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   if (iClose(Pair1,0,0) > iClose(Pair2,0,0) ){
      string PairA = Pair1;
      string PairB = Pair2;
   }else{
      PairA = Pair2;
      PairB = Pair1;
   }
   
   for(i=limit; i>=0; i--){
      
      Ratio[i] = (iClose(PairA,0,i)/iClose(PairB,0,i))*100;
      
   }
   
   for(i=limit; i>=0; i--){
   
      Short_MA[i] = iMAOnArray(Ratio,WHOLE_ARRAY,Short_Period,0,MODE_EMA,i);
      Long_MA[i]  = iMAOnArray(Ratio,WHOLE_ARRAY,Long_Period,0,MODE_EMA,i);
   
   }
   
   for(i=limit; i>=0; i--){
   
      if (iClose(Pair1,0,0) > iClose(Pair2,0,0) ){
         SO[i] = Long_MA[i] - Short_MA[i];
      }else{
         SO[i] = Short_MA[i] - Long_MA[i];
      }
   
   }
   
   return(0);
   
}
  
