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



#property indicator_buffers 5
#property indicator_chart_window

extern int   EMA_Period         = 14;
extern color EMA_High_Envelope  = clrLime;
extern color EMA_Low_Envelope   = clrRed;
extern color EMA_Close_Envelope = clrDarkGray;
extern color Top_Dot_Color      = clrDodgerBlue;
extern color Bottom_Dot_Color   = clrOrange;

double EMA_High[];
double EMA_Low[];
double EMA_Close[];
double Top_Dot[];
double Bottom_Dot[];

int init(){
   
   IndicatorShortName("EMAHLCEnvelope");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,EMA_High_Envelope);
   SetIndexBuffer(0,EMA_High);
   SetIndexLabel(0,"EMA High Envelope");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,EMA_Low_Envelope);
   SetIndexBuffer(1,EMA_Low);
   SetIndexLabel(1,"EMA Low Envelope");
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,EMA_Close_Envelope);
   SetIndexBuffer(2,EMA_Close);
   SetIndexLabel(2,"EMA Close Envelope");
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Top_Dot_Color);
   SetIndexArrow(3, 159);
   SetIndexBuffer(3,Top_Dot);
   SetIndexStyle(4,DRAW_ARROW,STYLE_SOLID,1,Bottom_Dot_Color);
   SetIndexArrow(4, 159);
   SetIndexBuffer(4,Bottom_Dot);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      EMA_High[i]=iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_HIGH,i);
      EMA_Low[i]=iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_LOW,i);
      EMA_Close[i]=iMA(NULL,0,EMA_Period,0,MODE_EMA,PRICE_CLOSE,i);
   }
   
   for(i=limit; i>=0; i--){
      if (High[i]>EMA_High[i]) Top_Dot[i]    = High[i];
      if (Low[i]<EMA_Low[i])   Bottom_Dot[i] = Low[i];
   }
   
//----
   return(0);
}
  
