//+------------------------------------------------------------------+
//|                                              EMAHLC_Envelope.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+



#property indicator_buffers 2
#property indicator_separate_window

extern int   EMA_Period  = 14;
extern color High_Color  = clrDeepSkyBlue;
extern color Low_Color   = clrRed;

double High_Bar[];
double Low_Bar[];

int init(){
   
   IndicatorShortName("EMAHLCEnvelope-Oscillator");
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2,High_Color);
   SetIndexBuffer(0,High_Bar);
   SetIndexLabel(0,"High Bar");
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2,Low_Color);
   SetIndexBuffer(1,Low_Bar);
   SetIndexLabel(1,"Low Bar");
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double top_dot, bottom_dot, high_env, low_env;
   
   for(i=limit; i>=0; i--){
      
      high_env   = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_HIGH,i);
      low_env    = iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_LOW,i);
      top_dot    = High[i];
      bottom_dot = Low[i];
      
      if (top_dot > high_env && top_dot > 0)
         High_Bar[i] = top_dot - high_env;
      else
         High_Bar[i] = EMPTY_VALUE;
         
      if (bottom_dot < low_env && bottom_dot > 0)
         Low_Bar[i] = bottom_dot - low_env;
      else
         Low_Bar[i] = EMPTY_VALUE;
         
   }
   
//----
   return(0);
}
  
