// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68782

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

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Gray
#property indicator_color5 Gray

input int ssd_K = 10; // Number of periods for %K
input int ssd_SD = 5; // %D slowing periods
input int ssd_D = 5; // Number of periods for %D
input int Level_Stochastic_UP = 70; // Level Stochastic UP
input int Level_Stochastic_DN = 30; // Level Stochastic DN
input double Dev = 10; // Dev
input ENUM_MA_METHOD method = MODE_SMA; // MA method
input int XLength = 12; // X Length

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

double SK[], SD[], Avg[], up[], dn[];

int init()
{
   IndicatorName = GenerateIndicatorName("Stochastic on Chart");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, SK);
   SetIndexLabel(0, "K");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SD);
   SetIndexLabel(1, "D");
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Avg);
   SetIndexLabel(2, "Avg");
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, up);
   SetIndexLabel(3, "Up");
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, dn);
   SetIndexLabel(4, "Dn");

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      Avg[pos] = iMA(_Symbol, _Period, XLength, 0, method, PRICE_CLOSE, pos);
      double sk = iStochastic(_Symbol, _Period, ssd_K, ssd_D, ssd_SD, MODE_SMA, 0, MODE_MAIN, pos);
      double sd = iStochastic(_Symbol, _Period, ssd_K, ssd_D, ssd_SD, MODE_SMA, 0, MODE_SIGNAL, pos);
      SK[pos] = Avg[pos] + Dev * (sk - 50) * pipSize;
      SD[pos] = Avg[pos] + Dev * (sd - 50) * pipSize;
      up[pos] = Avg[pos] + (Level_Stochastic_UP - 50) * pipSize * Dev;
      dn[pos] = Avg[pos] + (Level_Stochastic_DN - 50) * pipSize * Dev;
   } 
   return 0;
}