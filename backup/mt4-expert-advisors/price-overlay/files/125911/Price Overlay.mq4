// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68378

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
#property strict

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Gray

enum Mode
{
   Line,
   Candle
};

input string Pair = "EURUSD"; // Pair
input bool AUTO = false; // Auto
input Mode MODE = Line; // Mode
input bool INVERTED = true; // Invert
input bool Normalize = true; // Normalize
input color UpBarColor = Green; // Up bar color
input color DownBarColor = Red; // Down bar color
input int BarsLimit = 1000; // Bars limit

double close[];
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
      SetIndexStyle(id + 0, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 0, OpenStream);
      SetIndexStyle(id + 1, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 1, CloseStream);
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 1, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 3, clr);
      SetIndexBuffer(id + 3, LowStream);
      return id + 4;
   }

   void Set(const int index, const double open, const double high, const double low, const double closePrice)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = closePrice;
   }
};

CandleStreams up_bars;
CandleStreams down_bars;

int init()
{
   IndicatorShortName("Price Overlay");
   IndicatorDigits(Digits);
   
   if (MODE != Candle)
   {
      SetIndexStyle(0, DRAW_LINE);
      SetIndexBuffer(0, close);
   }
   else
   {
      int id = up_bars.RegisterStreams(0, UpBarColor);
      down_bars.RegisterStreams(id, DownBarColor);
   }
   
   return 0;
}

int deinit()
{
   return 0;
}

bool Init = true;

void SetBar(const int index, const double open, const double high, const double low, const double closePrice)
{
   if (MODE == Candle)
   {
      if (open < closePrice)
         up_bars.Set(index, open, high, low, closePrice);
      else
         down_bars.Set(index, open, high, low, closePrice);
         return;
   }
   close[index] = closePrice;
}
double RATIO = 1;

int start()
{
   if (Bars <= 3) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0)
      return -1;
   int limit = Bars - 2;
   if (ExtCountedBars > 2) 
      limit = Bars - ExtCountedBars - 1;

   int pos = MathMin(BarsLimit, limit);
   while (pos >= 0)
   {
      int period = iBarShift(Pair, _Period, Time[pos]);
      double o = AUTO ? Open[pos] : iOpen(Pair, _Period, period);
      double h = AUTO ? High[pos] : iHigh(Pair, _Period, period);
      double l = AUTO ? Low[pos] : iLow(Pair, _Period, period);
      double c = AUTO ? Close[pos] : iClose(Pair, _Period, period);

      if (Normalize)
      {
         if (Init)
         {
            Init = false;
            RATIO = INVERTED ? Close[pos] / (1 / iClose(Pair, _Period, period)) : Close[pos] / iClose(Pair, _Period, period);
         }
      }

      if (INVERTED)
         SetBar(pos, (1 / o) * RATIO, (1 / h) * RATIO, (1 / l) * RATIO, (1 / c) * RATIO);
      else
         SetBar(pos, o * RATIO, h * RATIO, l * RATIO, c * RATIO);
      
      pos--;
   }
   return 0;
}

