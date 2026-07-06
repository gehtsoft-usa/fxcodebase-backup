// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67352

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

#property indicator_buffers 12

extern ENUM_TIMEFRAMES TF = PERIOD_M1; // Timeframe
extern int BandsPeriod = 20; // Bands period
extern int BandsShift = 0; // Bands shift
extern double BandsDeviations = 2.0; // Bands deviations
extern color UpColor = Red; // Top color
extern color CenterColor = Green; // Avarage color
extern color DownColor = Yellow; // Bottom color

// Candles stream v.1.1.0
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
      SetIndexStyle(id + 2, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
      SetIndexBuffer(id + 2, HighStream);
      SetIndexLabel(id + 2, "High");
      SetIndexStyle(id + 3, DRAW_HISTOGRAM, STYLE_SOLID, 5, clr);
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

CandleStreams Up;
CandleStreams Center;
CandleStreams Down;

int init()
{
   IndicatorShortName("LTF Bars BB");
   IndicatorDigits(Digits);
   int index = Up.RegisterStreams(0, UpColor);
   index = Center.RegisterStreams(index, CenterColor);
   index = Down.RegisterStreams(index, DownColor);

   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int pos = Bars - 2;
   if (ExtCountedBars > 2) 
      pos = Bars - ExtCountedBars - 1;
   while (pos >= 0)
   {
      Up.Clear(pos);
      Center.Clear(pos);
      Down.Clear(pos);
      int periodFrom = iBarShift(NULL, TF, Time[pos], true);
      if (periodFrom != -1)
      {
         int periodTo = pos > 0 ? iBarShift(NULL, TF, Time[pos - 1], true) : 0;
   
         for (int i = periodFrom; i >= periodTo; --i)
         {
            double up = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_UPPER, i);
            double down = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_LOWER, i);
            double center = iBands(NULL, TF, BandsPeriod, BandsDeviations, BandsShift, PRICE_CLOSE, MODE_MAIN, i);
            Up.AddTick(pos, up);
            Down.AddTick(pos, down);
            Center.AddTick(pos, center);
         }
      }
      pos--;
   } 
   return(0);
}

