// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69453

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
#property indicator_buffers 8

double dosc[], smoothprice[], Color[], rma[];

input int decay = 250; // Decay
input int detection = 1; // Detection
input int smooth = 2; // Smooth
input int rma_smooth = 12; // RMA Smooth

input color Top_color = Green; // Top Color
input color Bottom_color = Red; // Bottom Color

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

CandleStreams Top;
CandleStreams Bottom;

int init()
{
   IndicatorShortName("Renko Stop");
   IndicatorDigits(Digits);
   IndicatorBuffers(12);

   int id = Top.RegisterStreams(0, Top_color);
   id = Bottom.RegisterStreams(id, Bottom_color);

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, dosc);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, smoothprice);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, Color);
   ++id;

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, rma);
   ++id;
   
   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   double decayValue = decay * pipSize;

   int counted_bars = IndicatorCounted();
   int minBars = detection;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int pos = limit; pos >= 0; pos--)
   {
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, detection, pos);
      double ll = iLow(_Symbol, _Period, lowestIndex);
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, detection, pos);
      double hh = iHigh(_Symbol, _Period, highestIndex);

      double rprice = MathFloor(Close[pos] / decayValue) * decayValue;
	   double predosc = dosc[pos + 1];
      if (predosc == EMPTY_VALUE)
         dosc[pos] = rprice;
      else if (hh > predosc + decayValue && hh + decayValue < predosc + decayValue)
         dosc[pos] = predosc + decayValue;
      else if (hh > predosc + decayValue && hh + decayValue > predosc + decayValue)
         dosc[pos] = rprice;
      else if (ll < predosc - decayValue && ll - decayValue > predosc - decayValue)
         dosc[pos] = predosc - decayValue;
      else if (ll < predosc - decayValue && ll - decayValue < predosc - decayValue)
         dosc[pos] = rprice;
      else
         dosc[pos] = predosc;

      smoothprice[pos] = iMA(_Symbol, _Period, smooth, 0, MODE_SMA, PRICE_CLOSE, pos);
      if (pos >= Bars - 1 - minBars - rma_smooth)
      {
         continue;
      }
	   rma[pos] = iMAOnArray(dosc, 0, rma_smooth, 0, MODE_SMA, pos);
      if (rma[pos + 1] == EMPTY_VALUE)
      {
         continue;
      }

      Color[pos] = Color[pos + 1];
      if ((smoothprice[pos] > rma[pos] && smoothprice[pos + 1] <= rma[pos + 1]) || (smoothprice[pos] < rma[pos] && smoothprice[pos + 1] >= rma[pos + 1]))
      {
         if (Close[pos] > rma[pos])
            Color[pos] = 1;
         else if (Close[pos] < rma[pos])
            Color[pos] = -1;
      }
      double high = MathMax(smoothprice[pos], rma[pos]);
      double low = MathMin(smoothprice[pos], rma[pos]);

      Top.Clear(pos);
      Bottom.Clear(pos);
      if (Color[pos] == 1)
         Top.Set(pos, high, high, low, low);
      else
         Bottom.Set(pos, high, high, low, low);
   }
   return 0;
}