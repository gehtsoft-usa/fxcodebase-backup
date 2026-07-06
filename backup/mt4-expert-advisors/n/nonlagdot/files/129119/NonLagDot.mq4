// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69002

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
#property indicator_buffers 2

input int Length = 10; // Length
input int Filter = 0; // Filter
input int ColorBarBack = 2; // ColorBarBack
input double Deviation = 0; // Deviation
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

ColoredStream _stream;
double trend[];

int init()
{
   IndicatorName = GenerateIndicatorName("NonLagDot indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(4);

   int id = 0;
   id = _stream.RegisterStream(id, up_color, "Up", DRAW_LINE, STYLE_DOT, 1);
   id = _stream.RegisterStream(id, down_color, "Down", DRAW_LINE, STYLE_DOT, 1);
   id = _stream.RegisterInternal(id);

   SetIndexStyle(3, DRAW_NONE);
   SetIndexBuffer(3, trend);

   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

#define Pi 3.14159265358979323846

int start()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   double pipSize = point * mult;
   double Coeff = 3. * Pi;
   int Phase = Length - 1;
   int Len = Length * 4 + Phase;

   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1 - Len;
   for (int pos = limit; pos >= 0; --pos)
   {
      double Weight = 0;
      double Sum = 0;
      double t = 0;
      for (int i = 0; i < Len; ++i)
      {
         double g = 1. / (Coeff * t + 1.);
         if (t <= 0.5)
            g = 1.;
         double beta = MathCos(Pi * t);
         double alpha = g * beta;
         Sum = Sum + alpha * Close[pos + i];
         Weight = Weight + alpha;
         if (t < 1.)
            t += 1. / (Phase - 1.);
         else if (t < Len - 1.)
            t += 7. / (4. * Length - 1.);
      }
      double value = 0;
      if (Weight > 0.)
         value = (1. + Deviation / 100.) * Sum / Weight;
      if (_stream._data[pos + 1] != EMPTY_VALUE)
      {
         if (Filter > 0. && MathAbs(value - _stream._data[pos + 1]) < Filter * pipSize)
            value = _stream._data[pos + 1];
         trend[pos] = trend[pos + 1];
         if (value - _stream._data[pos + 1] > Filter * pipSize)
            trend[pos] = 1;
         if (_stream._data[pos + 1] - value > Filter * pipSize)
            trend[pos] = -1;
      }
      _stream.Set(value, pos, (trend[pos] > 0 ? 0 : 1));

      if (trend[pos] > 0 && trend[pos + ColorBarBack] < 0)
         _stream.Set(_stream._data[pos + ColorBarBack], pos + ColorBarBack, 0);
      if (trend[pos] < 0 && trend[pos + ColorBarBack] > 0)
         _stream.Set(_stream._data[pos + ColorBarBack], pos + ColorBarBack, 1);
   } 
   return 0;
}