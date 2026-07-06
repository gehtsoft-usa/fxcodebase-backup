//+------------------------------------------------------------------+
//|                                          Donchian_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrRed
#property indicator_width2  2

extern int    Periods   = 20;

double Up[];
double Dn[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Donchian Oscillator");
      
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexBuffer(0,Up);
   SetIndexArrow(0,159);
   SetIndexLabel(0,"Up");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,Dn);
   SetIndexArrow(1,159);
   SetIndexLabel(1,"Dn");
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double Max_High, Min_Low;
   
   for(i=limit; i>=0; i--){
      
      Max_High = 0;
      Min_Low = 0;
      
      for (j=(i+Periods-1); j>i; j--){
         
         if (j==(i+Periods-1)){
            
            Max_High = High[j];
            Min_Low  = Low[j];
         
         }else{
         
            if (High[j] > Max_High) Max_High = High[j];
            if (Low[j]  < Min_Low)  Min_Low  = Low[j];
         
         }
      
      }
      
      if (Close[i] > Max_High) Up[i] = 1;
      if (Close[i] < Min_Low)  Dn[i] = -1;
      
   }
   
   return(0);
   
}
  
