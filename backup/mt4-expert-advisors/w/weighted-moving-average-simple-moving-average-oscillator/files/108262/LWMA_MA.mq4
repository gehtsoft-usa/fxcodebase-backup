//+------------------------------------------------------------------+
//|                                                      LWMA_MA.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF | 
//+------------------------------------------------------------------+



#property indicator_buffers 2
#property indicator_separate_window

extern int   Frame_Period = 20;
extern color Up_Color     = clrLime;
extern color Dn_Color     = clrRed;
extern int   Bars_Width   = 3;

double UP[];
double DOWN[];
double DATA[];

int init(){
   
   IndicatorShortName("LWMA_MA-Oscillator");
   IndicatorBuffers(3);
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Up_Color);
   SetIndexBuffer(0,UP);
   SetIndexLabel(0,"UP");
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Dn_Color);
   SetIndexBuffer(1,DOWN);
   SetIndexLabel(1,"DOWN");
   
   SetIndexBuffer(2,DATA); 
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for(i=limit-Frame_Period; i>=0; i--){
      
      DATA[i]= (iMA(NULL,0,Frame_Period,0,MODE_LWMA,PRICE_CLOSE,i) / iMA(NULL,0,Frame_Period,0,MODE_SMA,PRICE_CLOSE,i))-1;
      
   }
   
   for(i=limit-Frame_Period; i>=0; i--){
      
      if (DATA[i] > DATA[i+1])
         UP[i] = DATA[i];
      else
         DOWN[i] = DATA[i];

   }
   
   
   
//----
   return(0);
}
  
