//+------------------------------------------------------------------+
//|                                               SAR_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+



#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrYellow     
#property indicator_color2 clrRed     
#property indicator_color3 clrLime  

#property indicator_levelcolor clrTomato   

extern double SAR_Step    = 0.02;
extern double SAR_Maximum = 0.2;
//extern color  SAR_Color   = clrYellow;
//extern color  High_Color  = clrRed;
//extern color  Low_Color   = clrLime;
//extern int    Bars_Width  = 3;

double SAR[];
double High_Bar[];
double Low_Bar[];

int init(){
   
   IndicatorShortName("SAR_Oscillator");
   
  // SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,SAR_Color);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,SAR);
   SetIndexLabel(0,"SAR");
   //SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,High_Color);
   SetIndexBuffer(1,High_Bar);
   SetIndexLabel(1,"High Bar");
   SetIndexStyle(1,DRAW_HISTOGRAM);
  // SetIndexStyle(2,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Low_Color);
  SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Low_Bar);
   SetIndexLabel(2,"Low Bar");
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double sar;
   
   for(i=limit; i>=0; i--){

      sar = iSAR(NULL,0,SAR_Step,SAR_Maximum,i);
      
      SAR[i] = sar - Close[i];
      
      if (sar > Close[i] && sar > 0)
         High_Bar[i] = SAR[i];
      else
         High_Bar[i] = EMPTY_VALUE;
         
      if (sar < Close[i] && sar > 0)
         Low_Bar[i] = SAR[i];
      else
         Low_Bar[i] = EMPTY_VALUE;
         
   }
   
//----
   return(0);
}
  
