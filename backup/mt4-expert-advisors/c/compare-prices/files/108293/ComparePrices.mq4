//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+



#property indicator_buffers 2
#property indicator_chart_window

extern int   Shift      = 1;
extern color Main_Color = clrLime;
extern color Log_Color  = clrRed;

double Main[];
double Log[];

int init(){
   
   IndicatorShortName("ComparePrices");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Main_Color);
   SetIndexBuffer(0,Main);
   SetIndexLabel(0,"Main");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Log_Color);
   SetIndexBuffer(1,Log);
   SetIndexLabel(1,"Log");
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for(i=limit-1; i>=0; i--){
      
      Main[i] = Close[i];
      Log[i]  = Close[i] / (1+MathLog10(Close[i+Shift]/Close[i]));
      
   }
  
//----
   return(0);
}
  
