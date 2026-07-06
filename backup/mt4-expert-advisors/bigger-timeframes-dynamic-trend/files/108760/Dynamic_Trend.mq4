//+------------------------------------------------------------------+
//|                                                Dynamic_Trend.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrBlue
#property indicator_color3  clrRed

extern int    Max_Periods = 14;
extern int    Percent     = 1;

double Trend[];
double Up[];
double Dn[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Dynamic Trend");
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Trend);
   SetIndexLabel(0,"Dynamic Trend");
   
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,Up);
   SetIndexArrow(1,233);
   SetIndexLabel(1,"Up");
   
   SetIndexStyle(2,DRAW_ARROW);
   SetIndexBuffer(2,Dn);
   SetIndexArrow(2,234);
   SetIndexLabel(2,"Down");
   
   return(0);
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double max, min;
   
   double pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for(i=limit; i>=0; i--){
   
      for (j=(i+Max_Periods-1); j>=i; j--){
      
         if (j==(i+Max_Periods-1))
         
            max = min = Close[j];
         
         else{
         
            if (Close[j] > max)
               
               max = Close[j];
            
            if (Close[j] < min)
            
               min = Close[j];
         
         }
      
      }
      
      // Dynamic Trend
      
      if (Close[i] < Trend[i+1])
      
         Trend[i] = max - (Percent*pipSize);
         
      else
      
         Trend[i] = min + (Percent*pipSize);
      
      // Arrows
      if (Close[i+3] > Trend[i+2] && Close[i+2] < Trend[i+3])
      
         Up[i] = Low[i] - 10*pipSize;
         
      if (Close[i+2] < Trend[i+1] && Close[i+2] > Trend[i+3])
      
         Dn[i] = High[i] + 10*pipSize;
   
   
   }
   
   return(0);
   
  }
  
