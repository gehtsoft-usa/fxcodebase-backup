// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70331


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 2
#property indicator_label1 "UpTrend"
#property indicator_color1 clrGreen
#property indicator_label2 "DownTrend"
#property indicator_color2 clrRed


extern string     Note = "NumberOfBars = 0 means all bars";
extern int        NumberOfBars = 1000;
extern int        Periods = 12;
extern int        Smoothing = 125;

int               mult = 1;

double            currentValue = 0.0;
double            lastValue = 0.0;
double            buffer1[];
double            buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
      if ( Digits == 3 || Digits == 5 )
         mult = 10;
//---- indicators
      SetIndexBuffer(0,buffer1);
      SetIndexStyle(0,DRAW_LINE);

      SetIndexBuffer(1,buffer2);
      SetIndexStyle(1,DRAW_LINE);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   
   int limit;
   int counted_bars=IndicatorCounted();
//---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   if ( NumberOfBars == 0 ) 
      NumberOfBars = Bars-counted_bars;
   limit=NumberOfBars;

   for(int i=0; i<limit; i++)   
      {

         //  Ref(Mov(C,12,E),-1)+((C-(Ref(Mov(C,12,E),-1))) / (C/(Ref(Mov(C,12,E),-1))*125))

         currentValue =
         //  Ref(Mov(C,12,E),-1)
         iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1)
         // +
         +
         // ( (C - (Ref(Mov(C,12,E),-1)) )
         ( (Close[i] - (iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1)))
         // /
         /
         // (C/(Ref(Mov(C,12,E),-1))*125))
         (Close[i] / (iMA(NULL,0,Periods,0,MODE_EMA,PRICE_CLOSE,i+1)) * Smoothing) );

         if (currentValue <= lastValue)
         {
             buffer1[i] = currentValue;
             buffer1[i-1] = lastValue;
             // SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrGreen);
         }
         else
         {
             buffer2[i] = currentValue;
             buffer2[i-1] = lastValue;
             // SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrRed);
         }

         lastValue = currentValue;

      }
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+