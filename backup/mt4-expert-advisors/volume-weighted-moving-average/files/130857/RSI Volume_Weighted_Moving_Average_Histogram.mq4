// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67144
//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Red

enum MA_Types { SMA = 1, EMA = 2, SMMA = 3, LWMA = 4 };
input MA_Types MA_Type = SMA;
input int Price_MA_Period = 50; 
input int Volume_MA_Period = 70; 

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

double hist[];

int init()
{
   double temp = iCustom(NULL, 0, "RSI Volume Weighted Moving Average", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
      Alert("Please, install the 'RSI Volume Weighted Moving Average' indicator");
      return INIT_FAILED;
   }

   IndicatorName = GenerateIndicatorName("RSI Volume Weighted Moving Average Histogram");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(1);

   SetIndexStyle(0, DRAW_HISTOGRAM);
   SetIndexBuffer(0, hist);
   SetIndexLabel(0, "Histogram");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 1;
   for (int i = limit; i >= 0; i--)
   {
      double value1 = iCustom(_Symbol, _Period, "RSI Volume Weighted Moving Average", MA_Type, Price_MA_Period, Volume_MA_Period, 0, i);
      double value2 = iCustom(_Symbol, _Period, "RSI Volume Weighted Moving Average", MA_Type, Price_MA_Period, Volume_MA_Period, 1, i);
      hist[i] = value1 - value2;
   }
   return 0;
}
