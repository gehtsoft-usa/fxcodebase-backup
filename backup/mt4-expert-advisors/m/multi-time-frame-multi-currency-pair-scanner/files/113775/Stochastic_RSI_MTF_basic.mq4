// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64951

//+------------------------------------------------------------------+
//|                                     Stochastic_RSI_MTF_basic.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 2
#property indicator_separate_window
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
#property indicator_color1 clrLime
#property indicator_width2 1
#property indicator_style2 STYLE_DOT
#property indicator_color2 clrLime
#property indicator_levelwidth 1
#property indicator_levelcolor clrYellow
#property indicator_levelstyle STYLE_DOT

extern int      TimeFrame   = 240;
extern int      RSI_Periods = 14;
extern int      K_period    = 14;
extern int      D_period    = 3;
extern int      Slowing     = 5;
extern int      OB_Level    = 80;
extern int      OS_Level    = 20;

double SK1[];
double SK1_array[];
double SD1[];
double RSI1[];
double SKI1[];

int init(){
   
   IndicatorShortName("MTF Stochastic RSI");
   IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_SECTION);
   SetIndexBuffer(0,SK1);
   SetIndexLabel(0,"SK1");
   SetIndexStyle(1,DRAW_SECTION);
   SetIndexBuffer(1,SD1);
   SetIndexLabel(1,"SD1");
   
   SetIndexBuffer(2,SK1_array);
   SetIndexBuffer(3,RSI1);
   SetIndexBuffer(4,SKI1);
   
   SetLevelValue(0,OB_Level);
   SetLevelValue(1,OS_Level);
   SetLevelValue(2,50);
   
   return(0);
}

int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   int period, multiplier, current, next;

   double max, min;
   period     = TimeFrame;
   multiplier = TimeFrame/Period();
   for(i=floor(limit/multiplier) ; i>=0; i--){     
      
      RSI1[i]  = iRSI(NULL,period,RSI_Periods,PRICE_CLOSE,i);
      
      for (j=(i+K_period-1); j>=i; j--){
         if (j==(i+K_period-1))
            max = min = RSI1[j];
         else{
            if (RSI1[j]>max) max = RSI1[j];
            if (RSI1[j]<min) min = RSI1[j];
         }
      }
      
      if (min==max){
      
         SKI1[i] = 100;
      
      }else{
      
         SKI1[i] = (RSI1[i] - min) / (max - min) * 100;
         
      }
      
   }
   
   for(i=floor(limit/multiplier) ; i>=0; i--){
      
      current = iBarShift(NULL,0,iTime(NULL,period,i));
      if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
      
      SK1[current] = SK1_array[i] = iMAOnArray(SKI1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
      
      for (j=current; j>=next; j--){
         SK1[j]  = SK1[current];
      }
      
   }
   
   for(i=floor(limit/multiplier) ; i>=0; i--){
      
      current = iBarShift(NULL,0,iTime(NULL,period,i));
      if (i>0) next = iBarShift(NULL,0,iTime(NULL,period,i-1)); else next = 0;
      
      SD1[current] = iMAOnArray(SK1_array,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
      for (j=current; j>=next; j--){
         SD1[j]  = SD1[current];
      }
      
   }
   
//----
   return(0);
}