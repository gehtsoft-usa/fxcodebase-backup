// Id: 
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66828

//+------------------------------------------------------------------+
//|                               Copyright � 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict

// Bar overlay template v.1.0.0

#property indicator_chart_window
#property indicator_buffers 12
extern color Up_color = Green; // Up Color
extern color Down_color = Green; // Down Color
extern color Neutral_color = Orange; // Neutral Color
extern ENUM_TIMEFRAMES TF1 = PERIOD_CURRENT; // MACD Timeframe
extern ENUM_APPLIED_PRICE Price = PRICE_CLOSE; // Price
extern int SN = 12; // Short EMA
extern int LN = 26; // Long EMA
extern int IN = 9; // Signal Line
extern ENUM_TIMEFRAMES TF2 = PERIOD_CURRENT; // Stochastic Timeframe
extern int K = 5; // K Period
extern int SD = 3; // K Slowing Period
extern bool One = true; // Use MACD Filter
extern bool Two = true; // Use Stochastic Filter

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

   void Set(const int index, const double open, const double high, const double low, const double close)
   {
      OpenStream[index] = open;
      HighStream[index] = high;
      LowStream[index] = low;
      CloseStream[index] = close;
   }
};

CandleStreams Up;
CandleStreams Down;
CandleStreams Neutral;

int init()
{
   IndicatorShortName("MACD Slow Stochastic Overlay");
   IndicatorDigits(Digits);

   int id = Up.RegisterStreams(0, Up_color);
   id = Down.RegisterStreams(id, Down_color);
   id = Neutral.RegisterStreams(id, Neutral_color);
   
   return 0;
}

int deinit()
{
   return 0;
}

int start()
{
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;

   int pos = limit;
   while (pos >= 0)
   {
      Up.Clear(pos);
      Down.Clear(pos);
      Neutral.Clear(pos);

      int P1 = iBarShift(_Symbol, TF1, Time[pos]);
      double hist_current = iMACD(_Symbol, TF1, SN, LN, IN, Price, MODE_MAIN, P1) - iMACD(_Symbol, TF1, SN, LN, IN, Price, MODE_SIGNAL, P1);
      double hist_previous = iMACD(_Symbol, TF1, SN, LN, IN, Price, MODE_MAIN, P1 - 1) - iMACD(_Symbol, TF1, SN, LN, IN, Price, MODE_SIGNAL, P1 - 1);
      int S1 = hist_current > hist_previous ? 1 : -1;
      int P2 = iBarShift(_Symbol, TF2, Time[pos]);
      double stoch_current = iStochastic(_Symbol, TF2, K, SD, 9, MODE_SMA, 0, MODE_MAIN, P2);
      double stoch_previous = iStochastic(_Symbol, TF2, K, SD, 9, MODE_SMA, 0, MODE_MAIN, P2 - 1);
      int S2 = stoch_current > stoch_previous ? 1 : -1;
      
      if (((S1 == 1 && One) || !One) && ((S2 == 1 && Two) || !Two) && (S1 != 0 || S2 != 0))
         Up.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      else if (((S1 == -1 && One) || !One) && ((S2 == -1 && Two) || !Two) && (S1!=0 || S2!=0))
         Down.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      else
         Neutral.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
   
      pos--;
   }
   return(0);
}

