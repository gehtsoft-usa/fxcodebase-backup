// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=65344

//+------------------------------------------------------------------+
//|                                               Stochastic_RSI.mq4 |
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

extern int      TimeFrame   = 0;
extern int      RSI_Periods = 14;
extern int      K_period    = 5;
extern int      D_period    = 3;
extern int      Slowing     = 3;

double SK1[];
double SK1_array[];
double SD1[];
double RSI1[];
double SKI1[];

int init(){
   
   IndicatorShortName("Stochastic RSI");
   IndicatorBuffers(5);
   SetIndexStyle(0,DRAW_NONE);
   SetIndexBuffer(0,SK1);
   SetIndexStyle(1,DRAW_NONE);
   SetIndexBuffer(1,SD1);
   for (int k=0; k<2; k++){
      SetIndexDrawBegin(k,K_period+1);
   }
   SetIndexBuffer(2,SK1_array);
   SetIndexBuffer(3,RSI1);
   SetIndexBuffer(4,SKI1);
   
   return(0);
}

int start(){
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   int period;
   double max, min;
   limit = 100;
   period     = TimeFrame;
   for(i=limit; i>=0; i--){     
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
   for(i=limit; i>=0; i--){
      SK1[i] = iMAOnArray(SKI1,WHOLE_ARRAY,Slowing,0,MODE_SMA,i);
   }
   for(i=limit; i>=0; i--){
      SD1[i] = iMAOnArray(SK1,WHOLE_ARRAY,D_period,0,MODE_SMA,i);
   }
   return(0);
}
