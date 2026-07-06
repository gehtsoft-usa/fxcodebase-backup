//+------------------------------------------------------------------+
//|                                    RSI_Zone_Trade_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                    Paypal: https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                       Developed by : Mario Jemic |                    
//|                                            mario.jemic@gmail.com |
//|                     BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1 clrDodgerBlue
#property indicator_color2 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_width1 1
#property indicator_width2 2
#property indicator_levelcolor clrYellow

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };

extern int      RSI_Period       = 14;
extern int      RSI_MA_Period    = 14;
extern e_method MA_Method        = SMA;

double RSI[];
double MA[];

int init(){
 
   IndicatorShortName("RSI Zone Trade Oscillator");
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RSI);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA);
   
   SetLevelValue(0,50);

   return(0);
   
}

int start(){   

   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
 
   PrepareBuffers();

   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
   
      RSI[i] = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
      MA[i]  = iMAOnArray(RSI,0,RSI_MA_Period,0,ENUM_MA_METHOD(MA_Method),i);

   }
 
   return(0);

}

void ResetBuffers(int shift){
 RSI[shift]  = EMPTY_VALUE;
 MA[shift]   = EMPTY_VALUE;
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
