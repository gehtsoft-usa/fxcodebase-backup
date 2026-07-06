// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69051

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
#property indicator_buffers 7

input int len = 36; // len
input ENUM_TIMEFRAMES timeframe = PERIOD_D1; // Timeframe
input color clr1 = Navy; // Color 1
input color clr2 = Blue; // Color 2
input color clr3 = Orange; // Color 3
input color clr4 = Red; // Color 4
input color clr5 = Maroon; // Color 5
input color clr6 = Gray; // Color 6;
input double level1 = 1.28;
input double level2 = 2.1;
input double level3 = 2.5;
input double level4 = 3.09;
input double level5 = 4.1;

// Colored stream v2.1

#ifndef ColoredStream_IMP
#define ColoredStream_IMP

class ColoredStreamData
{
public:
   double Stream[];
};

class ColoredStream
{
public:
   ColoredStreamData _streams[];
   double _data[];

   int RegisterInternal(int id)
   {
      SetIndexBuffer(id + 0, _data);
      return id + 1;
   }

   int RegisterStream(int id, color clr, string label = "", int lineType = DRAW_LINE, ENUM_LINE_STYLE lineStyle = STYLE_SOLID, int width = 1)
   {
      int size = ArraySize(_streams);
      ArrayResize(_streams, size + 1);
      SetIndexStyle(id + 0, lineType, lineStyle, width, clr);
      SetIndexBuffer(id + 0, _streams[size].Stream);
      if (label != "")
         SetIndexLabel(id + 0, label);
      return id + 1;
   }

   int GetColorIndex(int period)
   {
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (_streams[i].Stream[period] != EMPTY_VALUE)
            return i;
      }
      return -1;
   }

   void Set(double value, int period, int colorIndex)
   {
      _data[period] = value;
      for (int i = 0; i < ArraySize(_streams); ++i)
      {
         if (colorIndex == i)
         {
            _streams[i].Stream[period] = value;
            if (_streams[i].Stream[period + 1] == EMPTY_VALUE)
               _streams[i].Stream[period + 1] = _data[period + 1];   
         }
         else
            _streams[i].Stream[period] = EMPTY_VALUE;
      }
   }
};

#endif

ColoredStream nRes;
double nRes3[], vwapsum[], volumesum[], v2sum[];

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
   IndicatorName = GenerateIndicatorName("Percent difference between price and vwap");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(11);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, nRes3);
   SetIndexLabel(0, "Avreage");
   int id = 1;
   id = nRes.RegisterStream(id, clr1);
   id = nRes.RegisterStream(id, clr2);
   id = nRes.RegisterStream(id, clr3);
   id = nRes.RegisterStream(id, clr4);
   id = nRes.RegisterStream(id, clr5);
   id = nRes.RegisterStream(id, clr6);
   id = nRes.RegisterInternal(id);
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, vwapsum);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, volumesum);
   ++id;
   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, v2sum);
   ++id;

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
      bool newSession = limit == Bars - 2 
         || iBarShift(_Symbol, timeframe, Time[pos + 1]) != iBarShift(_Symbol, timeframe, Time[pos]);

      double hl2 = (High[pos] + Low[pos]) / 2;
      if (newSession)
      {
         vwapsum[pos] = hl2 * Volume[pos];
         volumesum[pos] = Volume[pos];
         v2sum[pos] = Volume[pos] * hl2 * hl2;
      }
      else
      {
         vwapsum[pos] = vwapsum[pos + 1] + hl2 * Volume[pos];
         volumesum[pos] = volumesum[pos + 1] + Volume[pos];
         v2sum[pos] = v2sum[pos + 1] + Volume[pos] * hl2 * hl2;
      }

      double xSMA = vwapsum[pos] / volumesum[pos];
      double value = MathAbs(Close[pos] - xSMA) * 100 / Close[pos];
      int colorIndex = 5;
      if (value > level1 && value < level2)
         colorIndex = 0;
      else if (value > level2 && value < level3)
         colorIndex = 1;
      else if (value > level3 && value < level4)
         colorIndex = 2;
      else if (value > level4 && value < level5)
         colorIndex = 3;
      else if (value > level5)
         colorIndex = 4;
      nRes.Set(value, pos, colorIndex);
      nRes3[pos] = iMAOnArray(nRes._data, 0, len, 0, MODE_SMA, pos);
   } 
   return 0;
}