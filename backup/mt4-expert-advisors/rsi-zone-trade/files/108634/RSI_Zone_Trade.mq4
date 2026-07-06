//+------------------------------------------------------------------+
//|                                               RSI_Zone_Trade.mq4 |
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

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };

extern int      RSI_Period       = 14;
extern int      RSI_MA_Period    = 14;
extern e_method MA_Method        = SMA;
extern string   Comment0         = "- Inverse RSI/MA-of-RSI Crossing -";
extern bool     Inverse_Crossing = true;

double Up_High[];
double Up_Low[];
double Up_Open[];
double Up_Close[];
double Dn_High[];
double Dn_Low[];
double Dn_Open[];
double Dn_Close[];

double RSI[];
double MA[];

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

int init(){
 
   IndicatorShortName("RSI Zone Trade");
   
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

   return(0);
   
}

int start(){   

   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
 
   PrepareBuffers();

   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      RSI[i] = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
      MA[i]  = iMAOnArray(RSI,0,RSI_MA_Period,0,ENUM_MA_METHOD(MA_Method),i);
      
      bias=ColorCandle(RSI[i], MA[i]);
   
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

void PrepareBuffers(){
   
   int Size = Bars;
   
   if (ArraySize(RSI) < Size){
       
       ArraySetAsSeries(RSI, false);
       ArrayResize(RSI, Size); 
       ArraySetAsSeries(RSI, true);
       
       ArraySetAsSeries(MA, false);
       ArrayResize(MA, Size); 
       ArraySetAsSeries(MA, true);
   
   }

}

int ColorCandle(double rsi_value, double ma_value){
 
 if (rsi_value > 50 && ((Inverse_Crossing==false && rsi_value > ma_value) || (Inverse_Crossing && rsi_value < ma_value)))
   
   return (Bullish);
 
 else if (rsi_value < 50 && ((Inverse_Crossing==false && rsi_value < ma_value) || (Inverse_Crossing && rsi_value > ma_value)))
   
   return (Bearish);
 
 else
   
   return (Neutral);

}