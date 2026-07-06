//+------------------------------------------------------------------+
//|                                 Elder_Impulse_System_Overlay.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                    Paypal: https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                       Developed by : Mario Jemic |                    
//|                                            mario.jemic@gmail.com |
//|                     BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 8

#property indicator_color1 clrLime
#property indicator_color2 clrLime
#property indicator_color3 clrLime
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_color6 clrRed
#property indicator_color7 clrRed
#property indicator_color8 clrRed
#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3

#property description "Colored bars depending on Elder Impulse System:\n\nGreen when Current EMA > Previous EMA\n\nAnd Current MACD Histo > Previous MACD Histo\n\nThe opposite for Red color"

extern int  EMA_period             = 13;
extern int  MACD_Fast_EMA          = 12;
extern int  MACD_Slow_EMA          = 26;
extern int  MACD_Signal_EMA        = 9;
extern bool MACD_Signal_Difference = true;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

double EMA[];
double MACD[];

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

int init(){
 
   IndicatorShortName("Elder Impulse System Overlay ");
   IndicatorBuffers(10);
   
   SetIndexBuffer(0,Up_High);
   SetIndexBuffer(1,Up_Low);
   SetIndexBuffer(2,Up_Open);
   SetIndexBuffer(3,Up_Close);
   SetIndexBuffer(4,Dn_High);
   SetIndexBuffer(5,Dn_Low);
   SetIndexBuffer(6,Dn_Open);
   SetIndexBuffer(7,Dn_Close);
   
   for (int i=0; i<8; i++){
      SetIndexStyle(i,DRAW_HISTOGRAM);
   }
   
   SetIndexBuffer(8,EMA);
   SetIndexBuffer(9,MACD);

   return(0);
   
}

int start(){   

   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;

   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      EMA[i]  = iMA(NULL,0,EMA_period,0,MODE_EMA,PRICE_CLOSE,i);
      if (MACD_Signal_Difference)
         MACD[i] = iMACD(NULL,0,MACD_Fast_EMA,MACD_Slow_EMA,MACD_Signal_EMA,PRICE_CLOSE,MODE_MAIN,i) - iMACD(NULL,0,MACD_Fast_EMA,MACD_Slow_EMA,MACD_Signal_EMA,PRICE_CLOSE,MODE_SIGNAL,i);
      else
         MACD[i] = iMACD(NULL,0,MACD_Fast_EMA,MACD_Slow_EMA,MACD_Signal_EMA,PRICE_CLOSE,MODE_MAIN,i);
      
      bias=ColorCandle(EMA[i], EMA[i+1], MACD[i], MACD[i+1]);
   
      if(bias>0){
         
         Up_High[i]  = iHigh(NULL,0,i);
         Up_Low[i]   = iLow(NULL,0,i);  
         Up_Open[i]  = iOpen(NULL,0,i);
         Up_Close[i] = iClose(NULL,0,i);  
      
      }
      else if(bias<0){
         
         Dn_High[i]  = iHigh(NULL,0,i);
         Dn_Low[i]   = iLow(NULL,0,i);  
         Dn_Open[i]  = iOpen(NULL,0,i);
         Dn_Close[i] = iClose(NULL,0,i);
      
      }

   }
 
   return(0);

}

void ResetBuffers(int shift){
 Up_High[shift]  = EMPTY_VALUE;
 Up_Low[shift]   = EMPTY_VALUE;
 Up_Open[shift]  = EMPTY_VALUE;
 Up_Close[shift] = EMPTY_VALUE;
 Dn_High[shift]  = EMPTY_VALUE;
 Dn_Low[shift]   = EMPTY_VALUE;
 Dn_Open[shift]  = EMPTY_VALUE;
 Dn_Close[shift] = EMPTY_VALUE;
 return;
}

int ColorCandle(double current_ema, double previous_ema, double current_macd, double previous_macd ){
 
   if (current_ema > previous_ema && current_macd > previous_macd)
      return(Bullish);
   else if (current_ema < previous_ema && current_macd < previous_macd)
      return (Bearish);
   else
      return (Neutral);

}