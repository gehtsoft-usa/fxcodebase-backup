// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68495

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
#property indicator_buffers 6
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Red

enum KMethod
{
   Regular,
   Dynamic
};

enum DMethod
{
   DRegular,
   DDynamic,
   DAverages, // Average of K
};

extern int      K_periods      = 5; // K Periods
extern int      D_periods      = 3; // D Periods
extern int      Slowing        = 3; // Slowing
extern ENUM_MA_METHOD DS = MODE_SMA; // Smoothing type

input KMethod Type = Regular; // Stochastic Method
input DMethod DType = DRegular; // Stochastic D Method
input ENUM_MA_METHOD DAvgMethod = MODE_SMA; // Smoothing method for %D
input ENUM_MA_METHOD Method = MODE_SMA; // MA Method
input int Period = 14; // Period
input int Lb = 60; // LookBack Period
input double DZbuy = 0.1; // Buy Zone Probability
input double DZsell = 0.1; // Sell Zone Probability
input color up_color = Green; // Up color
input color down_color = Red; // Down color

double DataK[], DataD[], D_Line[], Range[], Low_[], Central[], Top[], Bottom[];

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

class ColoredStream
{
public:
   double _clr1[];
   double _clr2[];
   double _data[];

   int RegisterStream(int id, color clr1, color clr2)
   {
      SetIndexStyle(id + 0, DRAW_LINE, STYLE_SOLID, 1, clr1);
      SetIndexBuffer(id + 0, _clr1);
      SetIndexStyle(id + 1, DRAW_LINE, STYLE_SOLID, 1, clr2);
      SetIndexBuffer(id + 1, _clr2);
      SetIndexStyle(id + 2, DRAW_NONE);
      SetIndexBuffer(id + 2, _data);
      return id + 3;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      if (colorIndex == 0)
      {
         _clr1[period] = value;
         _clr2[period] = EMPTY_VALUE;
         if (_clr1[period + 1] == EMPTY_VALUE)
            _clr1[period + 1] = _clr2[period + 1];
         return;
      }
      _clr2[period] = value;
      _clr1[period] = EMPTY_VALUE;
      if (_clr2[period + 1] == EMPTY_VALUE)
         _clr2[period + 1] = _clr1[period + 1];
   }
};

ColoredStream K_Line;

int init()
{
   IndicatorName = GenerateIndicatorName("Dynamic Money Flow Index");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorBuffers(11);

   int id = 0;
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id++, Central);
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id++, Top);
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id++, Bottom);
   id = K_Line.RegisterStream(id, up_color, down_color);
   SetIndexStyle(id, DRAW_LINE);
   SetIndexBuffer(id++, D_Line);

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id++, DataK);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id++, DataD);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id++, Range);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id++, Low_);

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
      DataK[pos] = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_MAIN, pos);
	   DataD[pos] = iStochastic(_Symbol, _Period, K_periods, D_periods, Slowing, MODE_SMA, 0, MODE_SIGNAL, pos);
      
      if (pos + Lb > Bars - 1)
         continue;
      
      double min = DBL_MAX;
      double max = -DBL_MAX;
      for (int i = 0; i < Lb; ++i)
      {
         min = MathMin(min, DataK[pos + i]);
         max = MathMax(max, DataK[pos + i]);
      }
      Range[pos] = max - min;
      Low_[pos] = min;

      double ma1 = iMAOnArray(Low_, 0, Period, 0, Method, pos);
      double ma2 = iMAOnArray(Range, 0, Period, 0, Method, pos);
         
      Central[pos] = (ma2 * 0.50) + ma1;
      Top[pos] = max - Central[pos] * DZbuy;
      Bottom[pos] = min + Central[pos] * DZsell;

      double k = Type == Regular ? DataK[pos] : (4 * DataK[pos] + 3 * DataK[pos + 1] + 2 * DataK[pos + 2] + DataK[pos + 3]) / 10;
      K_Line.Set(k, pos, k > Central[pos] ? 0 : 1);
      D_Line[pos] = CalcD(pos);
   } 
   return 0;
}

double CalcD(int pos)
{
   switch (DType)
   {
      case DRegular:
         return DataD[pos];
      case DDynamic:
         return (4 * DataD[pos] + 3 * DataD[pos + 1] + 2 * DataD[pos + 2] + DataD[pos + 3]) / 10;
      case DAverages:
         return iMAOnArray(K_Line._data, 0, Period, 0, DAvgMethod, pos);
   }
   return EMPTY_VALUE;
}
