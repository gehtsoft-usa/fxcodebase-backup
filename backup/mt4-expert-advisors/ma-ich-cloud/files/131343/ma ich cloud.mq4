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
#property indicator_buffers 10
#property indicator_color1 Blue
#property indicator_color2 Green

input ENUM_MA_METHOD ma_method = MODE_SMA; // Smoothing method
input int ma_period = 14; // Smoothing period
input int  Tenkan_Sen_Period                = 7; // Tenkan Sen Period
input int  Kijun_Sen_Period                 = 21; // Kijun Sen Period
input int  Senkou_Span_B_Period             = 48; // Senkou Span B Period
input color up_color = Green; // Up color
input color down_color = Red; // Down color

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
// Candles stream v.1.2
class CandleStreams
{
public:
   double OpenStream[];
   double CloseStream[];
   double HighStream[];
   double LowStream[];

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

double ma[], ich[];
CandleStreams* up;
CandleStreams* down;
int init()
{
   IndicatorName = GenerateIndicatorName("MA ICH Cloud");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(10);
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, ma);
   SetIndexLabel(0, "MA");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, ich);
   SetIndexLabel(1, "ICH");

   up = new CandleStreams();
   down = new CandleStreams();
   int id = up.RegisterStreams(2, up_color);
   id = down.RegisterStreams(id, down_color);

   return 0;
}

int deinit()
{
   delete up;
   up = NULL;
   delete down;
   down = NULL;
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = MathMax(Kijun_Sen_Period, MathMin(Bars - 1 - 0, Bars - counted_bars - 1));
   for (int i = limit; i >= Kijun_Sen_Period; i--)
   {
      up.Clear(i);
      down.Clear(i);
      double maValue = iMA(_Symbol, _Period, ma_period, 0, ma_method, PRICE_CLOSE, i);
      ma[i] = maValue;
      double ichValue = iIchimoku(_Symbol, _Period, Tenkan_Sen_Period, Kijun_Sen_Period, Senkou_Span_B_Period, MODE_CHIKOUSPAN, i);
      ich[i] = ichValue;
      double ll = MathMin(maValue, ichValue);
      double hh = MathMax(maValue, ichValue);
      if (maValue > ichValue)
      {
         up.Set(i, ll, hh, ll, hh);
      }
      else
      {
         down.Set(i, ll, hh, ll, hh);
      }
   }
   return 0;
}
