// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67194

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
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_label1 "Large"

#property indicator_color2 Red
#property indicator_label2 "Small"

input double PI = 0; 
input int Period = 14;  
input bool Cumulative = true;
input int BarsLimit = 1000; // Bars limit
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Lower Timeframe

double out1[], out2[];
double src1[], src2[];

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
   IndicatorName = GenerateIndicatorName("Large Effective Ratio");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, out1);
   SetIndexLabel(0, "LER Long");
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, out2);
   SetIndexLabel(1, "LER Short");

   SetIndexStyle(2, DRAW_NONE);
   SetIndexBuffer(2, src1);
   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, src2);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      double valueLong = iCustom(_Symbol, _Period, "Effective Volume Split Version 1 LTF", PI, Period, Cumulative, BarsLimit, tf, 0, pos);
      double valueShort = iCustom(_Symbol, _Period, "Effective Volume Split Version 1 LTF", PI, Period, Cumulative, BarsLimit, tf, 1, pos);
      if (valueLong == EMPTY_VALUE || valueShort == EMPTY_VALUE)
         continue;
      src1[pos] = valueLong / Volume[pos];
      src2[pos] = valueShort / Volume[pos];
      if (src1[pos + 250] != EMPTY_VALUE)
      {
         out1[pos] = iMAOnArray(src1, 0, 250, 0, MODE_SMA, pos);
         out2[pos] = iMAOnArray(src2, 0, 250, 0, MODE_SMA, pos);
      }
   } 
   return 0;
}