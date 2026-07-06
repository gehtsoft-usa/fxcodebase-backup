//+------------------------------------------------------------------+
//|                                          Stochastics_Overlay.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
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

#property description "Colored bars depending on Stochastic Oscillator.\n\nAvailable modes:\n\n1) Compare Stochastic Main and Signal Lines\n2) Stochastic above or below 50 Line\n3) Compare Current Stochastic value with Previous Stochastic value\n4) Stochastic Above Overbought or Below Oversold"

enum e_method{ Stochastic_Signal=1, Stochastic_50_Line=2, Stochastic_Compare=3, OBOS_Levels=4 };

extern e_method Method     = Stochastic_50_Line;
extern int      K_period   = 8;
extern int      D_period   = 3;
extern int      Slowing    = 3;
extern int      Oversold   = 20;
extern int      Overbought = 80;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

double Stochastic[];
double Signal[];

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

int init(){
 
   IndicatorShortName("Stochastics Overlay ");
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
   
   SetIndexBuffer(8,Stochastic);
   SetIndexBuffer(9,Signal);

   return(0);
   
}

int start(){   

   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;

   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      Stochastic[i] = iStochastic(NULL,0,K_period,D_period,Slowing,MODE_SMA,0,MODE_MAIN,i);
      Signal[i]     = iStochastic(NULL,0,K_period,D_period,Slowing,MODE_SMA,0,MODE_SIGNAL,i);
      
      bias=ColorCandle(Stochastic[i], Signal[i], Stochastic[i+1]);
   
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

int ColorCandle(double stochastic_value, double signal_value, double previous_stochastic){
 
   if (Method==1){
   
      if (stochastic_value >= signal_value)
         return(Bullish);
      else
         return (Bearish);
         
   }
   else if (Method==2){
      
      if (stochastic_value >= 50)
         return(Bullish);
      else
         return (Bearish);
      
   }
   else if (Method==3){
   
      if (stochastic_value >= previous_stochastic)
         return(Bullish);
      else
         return (Bearish);
   
   }
   else{
   
      if (stochastic_value >= Overbought)
         return(Bullish);
      else if (stochastic_value <= Oversold)
         return (Bearish);
      else
         return (Neutral);
   
   }

}