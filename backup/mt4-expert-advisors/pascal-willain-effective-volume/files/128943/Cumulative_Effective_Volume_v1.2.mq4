// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67194

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.2"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green
#property indicator_label1 "Plot"
 
input double PI = 0;  
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Calculate timeframe
input int bars = 1000; // Bars limit

double Plot[];
string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}

int init()
{
   IndicatorName = GenerateIndicatorName("Cumulative Effective Volume");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(1);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Plot);
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;

   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 2;
   for (int i = limit; i >= 0; --i)
   {
      int start = iBarShift(_Symbol, timeframe, Time[i]);
      int finish = i == 0 ? 0 : iBarShift(_Symbol, timeframe, Time[i - 1]);
      double val = Plot[i + 1] == EMPTY_VALUE ? 0 : Plot[i + 1];
      for (int pos = start; pos >= finish; --pos)
      {
         double close = iClose(_Symbol, timeframe, pos);
         double prevClose = iClose(_Symbol, timeframe, pos + 1);
         if (close != prevClose)
         {
            double highPrice = MathMax(iHigh(_Symbol, timeframe, pos), prevClose);
            double lowPrice = MathMin(iLow(_Symbol, timeframe, pos), prevClose);
            val += highPrice - lowPrice + PI != 0 
               ? ((close - prevClose + PI) / (highPrice - lowPrice + PI)) * iVolume(_Symbol, timeframe, pos)
               : 0;
         }
      }
      Plot[i] = val;
       
      i--;
   } 
   return 0;
}

 