//+------------------------------------------------------------------+
//|                                               CandleMidPoint.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 1
#property indicator_chart_window

enum e_method{ Candle=1, Body=2 };
enum e_arrow{
 Dot1=159,
 Dot2=108,
 Square1=167,
 Square2=110,
 Diamond1=119,
 Arrow1=216,
 Arrow2=232
};

input e_method Method          = Body;
input e_arrow  Arrow_Code      = Dot2;
extern color   Mid_Point_Color = clrYellow;

double MidPoint[];

int init(){
   
   IndicatorShortName("CandleMidPoint");
   
   SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,0,Mid_Point_Color);
   SetIndexArrow(0,Arrow_Code);
   SetIndexBuffer(0,MidPoint);
   SetIndexLabel(0,"Mid Point");
   
   return(0);
}

int deinit(){
   ObjectsDeleteAll();
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      if (Method==2)
         MidPoint[i] = (Open[i]+Close[i])/2;
      else
         MidPoint[i] = (High[i]+Low[i])/2;
   }
   
//----
   return(0);
}