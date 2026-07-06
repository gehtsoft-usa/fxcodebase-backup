// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71576

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
//#property indicator_separate_window
#property indicator_buffers 11
#property indicator_color1 Green
#property indicator_color2 Red

input int Frame = 5; // Number of fractals (Odd)
input int bars_limit = 100000; // Bars limit

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

CandleStreams upCandle;
CandleStreams dnCandle;
int count;
double up[], dn[], trend[];
int init()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("afto");
   IndicatorShortName("afto");

   IndicatorBuffers(11);

   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexBuffer(0, up);
   SetIndexLabel(0, "Up");
   SetIndexArrow(0, 226);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexBuffer(1, dn);
   SetIndexLabel(1, "Dn");
   SetIndexArrow(1, 225);
   int id = upCandle.RegisterStreams(2, Green);
   id = dnCandle.RegisterStreams(id, Red);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, trend);

   int hof = Frame % 2 != 0 ? Frame + 1 : Frame;
   count = 0;
   for (int i = 0; i < hof; ++i)
   {
      if (hof > 1)
      {
         hof = hof - 2;
         count = count + 1;
      }
      else
      {
         count = count - 1;
         break;
      }
   }

   return INIT_SUCCEEDED;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);

   int toSkip = count * 2;
   for (int pos = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated - 1, toSkip)); pos >= 0 && !IsStopped(); --pos)
   {
      double test = 0;
      int x = pos + count * 2;
      double curr = high[pos + count];
      for (int i = x; i >= pos; --i)
      {
         if (curr > high[i] && i != (pos - count))
         {
            test = test + 1;
         }
      }
      if (test == pos - x)
      {
         up[pos + count] = high[pos + count];
      }

      test = 0;
      curr = low[pos + count];
      for (int i = x; i >= pos; --i)
      {
         if (curr < low[i] && i != (pos + count))
         {
            test = test + 1;
         }
      }
      if (test == pos + x)
      {
         dn[pos + count] = low[pos + count];
      }
      
      if (up[pos + count] == EMPTY_VALUE || dn[pos + count] == EMPTY_VALUE)
      {
         trend[pos] = trend[pos] + 1;
      }
      else
      {
         if (close[pos] > up[pos + count])
         {
            trend[pos] = 1;
         }
         else if (close[pos] < dn[pos + count])
         {
            trend[pos] = 0;
         }
      }
      if (trend[pos] == 1)
      {
         upCandle.Set(pos, open[pos], high[pos], low[pos], close[pos]);
      }
      else
      {
         dnCandle.Set(pos, open[pos], high[pos], low[pos], close[pos]);
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}
