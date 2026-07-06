//+------------------------------------------------------------------+
//|                                                    VORTEX_MA.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 2
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 1
#property indicator_color2 clrRed
#property indicator_width2 1
#property indicator_levelcolor clrYellow

extern int   Periods            = 14;
extern int   MA_Periods         = 20;
extern int   Overbought_Level   = 110;
extern int   Oversold_Level     = 90;
extern color Up_Signal          = clrLime;
extern color Dn_Signal          = clrRed;
extern bool  Positive_OB_Signal = true;
extern bool  Positive_OS_Signal = false;
extern bool  Negative_OB_Signal = false;
extern bool  Negative_OS_Signal = true;

double V_Pos[];
double V_Neg[];
double V_High[];
double V_Low[];
double MA_Up[];
double MA_Dn[];
double ATR[];
double up[];
double dn[];

int init(){
   
   IndicatorShortName("VORTEX");
   IndicatorBuffers(7);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA_Up);
   SetIndexDrawBegin(0,Periods+MA_Periods);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA_Dn);
   SetIndexDrawBegin(1,Periods+MA_Periods);
   
   SetIndexBuffer(2,V_High);
   SetIndexBuffer(3,V_Low);
   SetIndexBuffer(4,ATR);
   SetIndexBuffer(5,V_Pos);
   SetIndexBuffer(6,V_Neg);
   
   SetLevelValue(0,100);
   SetLevelValue(1,Overbought_Level);
   SetLevelValue(2,Oversold_Level);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);

}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      
      V_High[i] = MathAbs(High[i] - Low[i+1]);
      V_Low[i]  = MathAbs(Low[i] - High[i+1]);
         
   }
   
   double sum_v_high, sum_v_low, sum_atr;
   
   for(i=limit; i>=0; i--){
      
      sum_v_high = 0;
      sum_v_low  = 0;
      sum_atr    = 0;
      
      for (j=(i+Periods-1); j>=i; j--){
         
         sum_v_high += V_High[j];
         sum_v_low  += V_Low[j];
         sum_atr    += iATR(NULL,0,1,j);
      
      }
      
      V_Pos[i] = sum_v_high/sum_atr * 100;
      V_Neg[i] = sum_v_low /sum_atr * 100;
      
      MA_Up[i] = iMAOnArray(V_Pos,0,MA_Periods,0,MODE_SMA,i);
      MA_Dn[i] = iMAOnArray(V_Neg,0,MA_Periods,0,MODE_SMA,i);
         
   }
   
//----
   return(0);
}
