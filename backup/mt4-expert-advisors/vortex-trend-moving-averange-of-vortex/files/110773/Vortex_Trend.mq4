//+------------------------------------------------------------------+
//|                                                 Vortex_Trend.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+


#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 3
#property indicator_color2 clrRed
#property indicator_width2 3
#property indicator_color3 clrDarkGray
#property indicator_width3 3

extern int  Vortex_Periods   = 14;
extern int  MA_Periods       = 20;
extern int  Overbought_Level = 110;
extern int  Oversold_Level   = 90;
extern bool Use_Averaging    = true;
extern int  Limit_Bars       = 1000;

double V_Pos[];
double V_Neg[];
double V_High[];
double V_Low[];
double MA_Up[];
double MA_Dn[];
double ATR[];

double Up[];
double Down[];
double Neutral[];

int init(){
   
   IndicatorShortName("Vortex Trend");
   IndicatorBuffers(10);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"Up");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Down);
   SetIndexLabel(1,"Down");
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Neutral);
   SetIndexLabel(2,"Neutral");
   
   SetIndexBuffer(3,V_Pos);
   SetIndexBuffer(4,V_Neg);
   SetIndexBuffer(5,V_High);
   SetIndexBuffer(6,V_Low);
   
   SetIndexBuffer(7,MA_Up);
   SetIndexBuffer(8,MA_Dn);
   SetIndexBuffer(9,ATR);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars>0) limit = Limit_Bars;
   
   for(i=limit; i>=0; i--){
      
      V_High[i] = MathAbs(High[i] - Low[i+1]);
      V_Low[i]  = MathAbs(Low[i] - High[i+1]);
         
   }
   
   double sum_v_high, sum_v_low, sum_atr;
   
   for(i=limit; i>=0; i--){
      
      sum_v_high = 0;
      sum_v_low  = 0;
      sum_atr    = 0;
      
      for (j=(i+Vortex_Periods-1); j>=i; j--){
         
         sum_v_high += V_High[j];
         sum_v_low  += V_Low[j];
         sum_atr    += iATR(NULL,0,1,j);
      
      }
      
      V_Pos[i] = sum_v_high/sum_atr * 100;
      V_Neg[i] = sum_v_low /sum_atr * 100;
      
      MA_Up[i] = iMAOnArray(V_Pos,0,MA_Periods,0,MODE_SMA,i);
      MA_Dn[i] = iMAOnArray(V_Neg,0,MA_Periods,0,MODE_SMA,i);
      
      if (Use_Averaging){
      
         if (MA_Up[i] > Overbought_Level && MA_Dn[i] < Oversold_Level){
            Up[i]      = 100;
            Down[i]    = 0;
            Neutral[i] = 0;
         }else if (MA_Dn[i] > Overbought_Level && MA_Up[i] < Oversold_Level){
            Up[i]      = 0;
            Down[i]    = 100;
            Neutral[i] = 0;
         }else{
            Up[i]      = 0;
            Down[i]    = 0;
            Neutral[i] = 100;
         }
         
      }else{
      
         if (V_Pos[i] > Overbought_Level && V_Neg[i] < Oversold_Level){
            Up[i]      = 100;
            Down[i]    = 0;
            Neutral[i] = 0;
         }else if (V_Neg[i] > Overbought_Level && V_Pos[i] < Oversold_Level){
            Up[i]      = 0;
            Down[i]    = 100;
            Neutral[i] = 0;
         }else{
            Up[i]      = 0;
            Down[i]    = 0;
            Neutral[i] = 100;
         }
      
      }
      
   }
   
//----
   return(0);
}
  
