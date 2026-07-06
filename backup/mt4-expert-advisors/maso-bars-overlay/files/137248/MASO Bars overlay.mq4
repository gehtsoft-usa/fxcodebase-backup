// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70367

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

#property indicator_chart_window
#property indicator_buffers 12

input color Top_color = Green; // Top Color
input color Bottom_color = Red; // Bottom Color
input color Contradictory_color = Gray; // Contradictory Color
input int First_Period = 25; // First MA Period
input ENUM_MA_METHOD First_Method = MODE_SMA; // Method of First MA
input double First_Slope = 0; // Slope, pip/minute
input int First_Bars = 1; // Bars
input int Second_Period = 50; // Second MA Period
input ENUM_MA_METHOD Second_Method = MODE_SMA; // Method of Second MA
input double Second_Slope = 0; // Slope, pip/minute
input int Second_Bars = 1; // Bars

// Candles stream v.1.3
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

   void Init()
   {
      ArrayInitialize(OpenStream, EMPTY_VALUE);
      ArrayInitialize(CloseStream, EMPTY_VALUE);
      ArrayInitialize(HighStream, EMPTY_VALUE);
      ArrayInitialize(LowStream, EMPTY_VALUE);
   }

   void Clear(const int index)
   {
      OpenStream[index] = EMPTY_VALUE;
      CloseStream[index] = EMPTY_VALUE;
      HighStream[index] = EMPTY_VALUE;
      LowStream[index] = EMPTY_VALUE;
   }

   int RegisterStreams(const int id, const color clr)
   {
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexLabel(id + 0, "Open");
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexLabel(id + 1, "Close");
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 3, LowStream);
      SetIndexLabel(id + 3, "Low");
      return id + 4;
   }

   void AddTick(const int index, const double val)
   {
      if (OpenStream[index] == EMPTY_VALUE)
      {
         Set(index, val, val, val, val);
         return;
      }
      HighStream[index] = MathMax(HighStream[index], val);
      LowStream[index] = MathMin(LowStream[index], val);
      CloseStream[index] = val;
   }

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

CandleStreams Top;
CandleStreams Bottom;
CandleStreams Contradictory;

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("masobo");
   IndicatorShortName("MASO Bars Overlay");
   IndicatorDigits(Digits);

   int id = Top.RegisterStreams(0, Top_color);
   id = Bottom.RegisterStreams(id, Bottom_color);
   id = Contradictory.RegisterStreams(id, Contradictory_color);
   
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
   int minBars = 1;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      double mas1 = iCustom(_Symbol, _Period, "MA_Slope", First_Period, First_Method, First_Slope, First_Bars, 1, pos);
      double mas2 = iCustom(_Symbol, _Period, "MA_Slope", Second_Period, Second_Method, Second_Slope, Second_Bars, 1, pos);
      Top.Clear(pos);
      Bottom.Clear(pos);
      Contradictory.Clear(pos);
      if (mas1 != EMPTY_VALUE && mas2 != EMPTY_VALUE &&  mas1 > mas2)
      {
         Top.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      }
      else if (mas1 != EMPTY_VALUE && mas2 != EMPTY_VALUE &&  mas1 > mas2)
      {
         Bottom.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      }
      else
      {
         Contradictory.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      }
   }
   return 0;
}

