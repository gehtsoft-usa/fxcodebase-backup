// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68705

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

input string Indi1 = ""; // == MACD ==
input bool One = true; // Use MACD Filter
input int SN = 12; // Short EMA
input int LN = 26; // Long EMA
input int IN = 9; // Signal Line

input string Indi2 = ""; // == RSI ==
input bool Two = true; // Use RSI Filter
input int RP = 14; // Period

input string Indi3 = ""; // == Stochastic ==
input bool Three = true; // Use Stochastic Filter
input int K = 5; // Number of periods for %K
input int SD = 3; // %D slowing periods
input int D = 3; // Number of periods for %D

input string Indi4 = ""; // == ADX ==
input bool Fifth = true; // Use ADX Filter
input int Period = 14; // Period
input double Alpha1 = 0.25; // Alpha1
input double Alpha2 = 0.33; // Alpha2
input double Level = 20; // Level

input string Indi5 = ""; // == CCI ==
input bool Four = true; // Use CCI Filter
input int CCIPeriod = 14; // Period

input string Indi6 = ""; // == SAR ==
input bool Sixth = true; // Use PSAR Filter
input double Step = 0.02; // Step
input double Max = 0.2; // Max

input color Up_color = Green; // Up Color
input color Dn_color = Red; // Down Color
input color No_color = Gray; // Neutral Color

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

CandleStreams Up;
CandleStreams Down;
CandleStreams Neutral;

int init()
{
   IndicatorShortName("MACD RSI Stochastic Overlay");
   IndicatorDigits(Digits);

   int id = Up.RegisterStreams(0, Up_color);
   id = Down.RegisterStreams(id, Dn_color);
   id = Neutral.RegisterStreams(id, No_color);
   
   return 0;
}

int deinit()
{
   return 0;
}

int GetSignalOne(int pos)
{
   if (!One)
      return 0;

   double macd = iMACD(_Symbol, _Period, SN, LN, IN, PRICE_CLOSE, MODE_MAIN, pos);
   double signal = iMACD(_Symbol, _Period, SN, LN, IN, PRICE_CLOSE, MODE_SIGNAL, pos);
   if (macd > signal)
      return 1;
   if (macd < signal)
      return -1;
      
   return 0;
}

int GetSignalTwo(int pos)
{
   if (!Two)
      return 0;

   double rsiValue = iRSI(_Symbol, _Period, RP, PRICE_CLOSE, pos);
   if (rsiValue > 50)
      return 1;
   if (rsiValue < 50)
      return -1;

	return 0;
}

int GetSignalThree(int pos)
{
   if (!Three)
      return 0;
   double k = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_MAIN, pos);
   double d = iStochastic(_Symbol, _Period, K, D, SD, MODE_SMA, 0, MODE_SIGNAL, pos);
   if (k > d)
      return 1;
   if (k < d)
      return -1;
      
   return 0;
}

int GetSignalFour(int pos)
{
   if (!Four)
      return 0;

   double cciValue = iCCI(_Symbol, _Period, CCIPeriod, PRICE_CLOSE, pos);
   if (cciValue > 0)
      return 1;
   if (cciValue < 0)
      return -1;
   return 0;
}

int GetSignalFifth(int pos)
{
   if (!Fifth)
      return 0;

   double adxValue = iADX(_Symbol, _Period, Period, PRICE_CLOSE, MODE_MAIN, pos);
   double plus = iADX(_Symbol, _Period, Period, PRICE_CLOSE, MODE_PLUSDI, pos);
   double minus = iADX(_Symbol, _Period, Period, PRICE_CLOSE, MODE_MINUSDI, pos);
   if (adxValue > Level)
   {
      if (plus > Level && plus > minus)
         return 1;
      if (minus > Level && plus < minus)
         return -1;
   }
   return 0;
}

int GetSignalSixth(int pos)
{
   if (!Sixth)
      return 0;
   double sarValue = iSAR(_Symbol, _Period, Step, Max, pos);
   double close = Close[pos];
   if (sarValue < close)
      return 1;
   if (sarValue > close)
      return -1;
   return 0;
}

bool IsUp(int pos)
{
   return GetSignalOne(pos) != -1
      && GetSignalTwo(pos) != -1
      && GetSignalThree(pos) != -1
      && GetSignalFour(pos) != -1
      && GetSignalFifth(pos) != -1
      && GetSignalSixth(pos) != -1;
}

bool IsDown(int pos)
{
   return GetSignalOne(pos) != 1
      && GetSignalTwo(pos) != 1
      && GetSignalThree(pos) != 1
      && GetSignalFour(pos) != 1
      && GetSignalFifth(pos) != 1
      && GetSignalSixth(pos) != 1;
}

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

   int pos = limit;
   while (pos >= 0)
   {
      Up.Clear(pos);
      Down.Clear(pos);
      Neutral.Clear(pos);
      if (IsUp(pos))
         Up.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      else if (IsDown(pos))
         Down.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
      else
         Neutral.Set(pos, Open[pos], High[pos], Low[pos], Close[pos]);
   
      pos--;
   }
   return 0;
}

