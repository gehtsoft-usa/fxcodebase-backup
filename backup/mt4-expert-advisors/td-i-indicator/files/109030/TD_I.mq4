//+------------------------------------------------------------------+
//|                                                         TD_I.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  clrLime
#property indicator_width1  2

extern int    Shift   = 1;
extern int    Periods = 8;

double TD_I[];
double High_Diff[];
double Low_Diff[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("TD_I");
   
   IndicatorBuffers(3);
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TD_I);
   SetIndexLabel(0,"TD_I");
   
   SetIndexBuffer(1,High_Diff);
   SetIndexBuffer(2,Low_Diff);
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double High_Avg, Low_Avg;
   
   for(i=limit; i>=0; i--){
      
      High_Avg = 0;
      Low_Avg = 0;
      
      High_Diff[i] = MathMax(0,High[i]-High[i+Shift]);
      Low_Diff[i]  = MathMax(0,Low[i+Shift]-Low[i]);
      
      for (j=(i+Periods-1); j>=i; j--){
         High_Avg+=High_Diff[j];
         Low_Avg +=Low_Diff[j];
      }
      High_Avg=High_Avg/Periods;
      Low_Avg=Low_Avg/Periods;
      
      if (High_Avg!=0 || Low_Avg!=0) TD_I[i] = (High_Avg*100)/(High_Avg+Low_Avg);
      
   }
   
   return(0);
   
}
  
