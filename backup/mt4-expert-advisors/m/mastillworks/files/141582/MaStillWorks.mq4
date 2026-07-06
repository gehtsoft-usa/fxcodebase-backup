// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71106


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
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
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

//based on Forex Avatar www.pipswanted.com"

#define major   1
#define minor   0
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_width1  1
#property indicator_width2  1

extern int __period = 14;
extern int MaxBars = 500;

double sell[];
double buy[];

void init() 
{
  SetIndexBuffer(0, sell);
  SetIndexBuffer(1, buy);
  SetIndexEmptyValue(0, 0);
  SetIndexEmptyValue(1, 0);
  SetIndexStyle(0, DRAW_ARROW);
  SetIndexArrow(0, 234);
  SetIndexStyle(1, DRAW_ARROW);
  SetIndexArrow(1, 233);  
}

void start() 
{
  int counted = IndicatorCounted();
  if (counted < 0) return (-1);
  if (counted > 0) counted--;
  
  int limit = MathMin(Bars-counted, MaxBars);

  double dy = 0;
  for (int i=1; i <= 20; i++) {
    dy += 0.3*(High[i]-Low[i])/20;
  }
  
  for (i=0+__period; i <= limit+__period; i++) 
  {
    sell[i] = 0;
    buy[i] = 0;
  
    if (MovingAverage(i) == 1) sell[i] = High[i]+dy; 
    if (MovingAverage(i) == -1) buy[i] = Low[i]-dy;
  }
}

int MovingAverage(int i)
{
   double ma[3];
   int period = __period;
   ma[0] = iMA(NULL,0,period,0,MODE_EMA,PRICE_MEDIAN,i);
   ma[1] = iMA(NULL,0,period,0,MODE_EMA,PRICE_MEDIAN,i+1);
   ma[2] = iMA(NULL,0,period,0,MODE_EMA,PRICE_MEDIAN,i+2);

   int candles = 6; 
   double min = Low[iLowest(NULL,0,MODE_LOW,candles,i+2)];
   double max = High[iHighest(NULL,0,MODE_HIGH,candles,i+2)];
   
   bool horizontal = false;
   if(ma[0] < max && ma[0] > min)
   {
      horizontal = true;
   }
   
   if(ma[1] < ma[0] && horizontal == false)
   {
      return(1);
      Print(" ");
   }
   else if(ma[1] > ma[0] && horizontal == false)
   {
      return(-1);
   }
   else
   {
      return(0);
   }
}