// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68494

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
#property indicator_buffers 5
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Red

enum MFIMethod
{
   Regular,
   Dynamic
};

input int N = 14; // Periods
input MFIMethod Type = Regular; // MFI Method
input ENUM_MA_METHOD Method = MODE_SMA; // MA Method
input int Period = 14; // Period
input int Lb = 60; // LookBack Period
input double DZbuy = 0.1; // Buy Zone Probability
input double DZsell = 0.1; // Sell Zone Probability

double POS[], NEG[], Data[], Range[], Low_[], MFI_up[], MFI_down[], Central[], Top[], Bottom[];

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
   IndicatorName = GenerateIndicatorName("Dynamic Money Flow Index");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(10);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Central);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Top);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Bottom);
   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, MFI_up);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexBuffer(4, MFI_down);

   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(8, POS);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(9, NEG);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, Data);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, Range);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, Low_);

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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 2;
   for (int pos = limit; pos >= 0; --pos)
   {
      double typical_0 = (High[pos] + Low[pos] + Close[pos]) / 3.0;
      double typical_1 = (High[pos + 1] + Low[pos + 1] + Close[pos + 1]) / 3.0;
      if (typical_0 > typical_1)
         POS[pos] = typical_0 * Volume[pos];
      else if (typical_0 < typical_1)
         NEG[pos] = typical_0 * Volume[pos];

      if (pos + N > Bars - 1)
         continue;
      
      double a = 0;
      double b = 0;
      for (int i = 0; i < N; ++i)
      {
         a += POS[pos + i];
         b += NEG[pos + i];
      }
      if (b != 0)
         Data[pos] = 100 - (100 / (1 + a / b));
      else
         Data[pos] = 100;
         
      if (pos + Lb > Bars - 1)
         continue;

      double min = DBL_MAX;
      double max = -DBL_MAX;
      for (int i = 0; i < Lb; ++i)
      {
         min = MathMin(min, Data[pos + i]);
         max = MathMax(max, Data[pos + i]);
      }
      Range[pos] = max - min;
      Low_[pos] = min;

      double ma1 = iMAOnArray(Low_, 0, Period, 0, Method, pos);
      double ma2 = iMAOnArray(Range, 0, Period, 0, Method, pos);

      Central[pos] = (ma2 * 0.50) + ma1;
      Top[pos] = max - Central[pos] * DZbuy;
      Bottom[pos] = min + Central[pos] * DZsell;

      double mfi = Type == Regular ? Data[pos] : (4 * Data[pos] + 3 * Data[pos + 1] + 2 * Data[pos + 2] + Data[pos + 3]) / 10;

      if (mfi > Central[pos])
      {
         MFI_up[pos] = mfi;
         MFI_down[pos] = EMPTY_VALUE;
         if (MFI_up[pos + 1] == EMPTY_VALUE)
            MFI_up[pos + 1] = MFI_down[pos + 1];
      }
      else
      {
         MFI_down[pos] = mfi;
         MFI_up[pos] = EMPTY_VALUE;
         if (MFI_down[pos + 1] == EMPTY_VALUE)
            MFI_down[pos + 1] = MFI_up[pos + 1];
      }
   } 
   return 0;
}

