// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68982

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
//#property indicator_separate_window
#property indicator_buffers 3

input int                inpPeriod    = 50;            // Cci Period
input ENUM_APPLIED_PRICE inpPrice     = PRICE_TYPICAL; // Cci Price
input int                inpAtrPeriod = 5;             // Atr period
input color clr2 = clrDeepPink; // Down Color
input color clr3 = clrLimeGreen; // Up Color

double trend[];

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

ColoredStream val;

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
   IndicatorName = GenerateIndicatorName("Super trend");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(5);

   int id = val.RegisterStream(0, clrDarkGray, "ST");
   id = val.RegisterStream(id, clr2, "ST");
   id = val.RegisterStream(id, clr3, "ST");
   id = val.RegisterInternal(id);

   SetIndexStyle(id, DRAW_NONE);
   SetIndexBuffer(id, trend);

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
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 2 - inpPeriod;
   for (int pos = limit; pos >= 0; --pos)
   {
      double avg = 0;
      for (int k = 0; k < inpPeriod; k++)
         avg += Close[pos + k];
      avg /= inpPeriod;

      double dev = 0;
      for (int k = 0; k < inpPeriod; k++)
         dev += MathAbs(Close[pos + k] - avg);
      dev /= inpPeriod;
      
      double atr = 0;
      for (int k = 0; k < inpAtrPeriod; k++)
         atr += MathMax(High[pos + k], Close[pos + k + 1]) - MathMin(Low[pos + k], Close[pos + k + 1]);
      atr /= inpAtrPeriod;
      
      double cci = (dev != 0) ? (Close[pos] - avg) / (0.015 * dev) : 0;
      if (val._data[pos + 1] != EMPTY_VALUE)
      {
         trend[pos] = (cci > 0) ? 1 : (cci < 0) ? -1 : trend[pos + 1];
         double value = (trend[pos] == 1) 
            ? MathMax(Low[pos] - atr, val._data[pos + 1]) 
            : MathMin(High[pos] + atr, val._data[pos + 1]);
         int colorIndex = (value > val._data[pos + 1]) 
            ? 2 
            : (value < val._data[pos + 1]) ? 1 : val.GetColorIndex(pos + 1);
         val.Set(value, pos, colorIndex);
      }
      else
      {
         trend[pos] = (cci > 0) ? 1 : (cci < 0) ? -1 : 0;
         val.Set(Close[pos], pos, 0);
      }
   } 
   return 0;
}