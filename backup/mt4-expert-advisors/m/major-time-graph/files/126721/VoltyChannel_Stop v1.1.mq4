// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property version   "1.1"
#property strict

// Trading arrows template v.1.1

//1. Implement int GetDirection(
//2. place your parameters here

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_label1 "BUY"
#property indicator_label2 "SELL"
#property indicator_label3 "EXIT BUY"
#property indicator_label4 "EXIT SELL"
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_label5 "Up"
#property indicator_label6 "Down"

double buy[], sell[], exit_buy[], exit_sell[], UpBuffer[], DnBuffer[], SMax[], SMin[], Trend[];

string IndicatorName;
string IndicatorObjPrefix;

input ENUM_TIMEFRAMES btf = PERIOD_CURRENT; // Timeframe
input int MA_N = 1; // Moving Average Period
input ENUM_MA_METHOD MA_M = MODE_EMA; // Moving Average Method
input int ATR_N = 10; // ATR period
input double VF = 4; // Volatility's Factor or Multiplier
input int OF = 0; // Offset factor
input bool HiLoE = false; // Use High/Low envelope
input bool HiLoB = true; // Hi/Lo Break

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
   IndicatorName = GenerateIndicatorName("Volty Channel Stop");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   IndicatorBuffers(9);
   SetIndexStyle(0, DRAW_ARROW, 0, 2);
   SetIndexArrow(0, 217);
   SetIndexBuffer(0, buy);
   SetIndexStyle(1, DRAW_ARROW, 0, 2);
   SetIndexArrow(1, 218);
   SetIndexBuffer(1, sell);
   SetIndexStyle(2, DRAW_ARROW, 0, 2);
   SetIndexArrow(2, 217);
   SetIndexBuffer(2, exit_buy);
   SetIndexStyle(3, DRAW_ARROW, 0, 2);
   SetIndexArrow(3, 218);
   SetIndexBuffer(3, exit_sell);
   SetIndexBuffer(4, UpBuffer);
   SetIndexBuffer(5, DnBuffer);
   SetIndexBuffer(6, SMax);
   SetIndexBuffer(7, SMin);
   SetIndexBuffer(8, Trend);

   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1
#define EXIT_BUY_SIGNAL 2
#define EXIT_SELL_SIGNAL -2

int GetDirection(const int period)
{
   if (Trend[period] == 1 && 1 != Trend[period + 1])
      return ENTER_BUY_SIGNAL;
   if (Trend[period] == -1 && -1 != Trend[period + 1])
      return ENTER_SELL_SIGNAL;
   return 0;
}

string FileName = "VoltyChannel_Stop v1.1";

int BTFStart()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   for (int pos = limit; pos >= 0; --pos)
   {
      int btfIndex = iBarShift(_Symbol, btf, Time[pos]);
      buy[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 0, btfIndex);
      sell[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 1, btfIndex);
      exit_sell[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 2, btfIndex);
      exit_buy[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 3, btfIndex);
      UpBuffer[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 4, btfIndex);
      DnBuffer[pos] = iCustom(_Symbol, btf, FileName, btf, MA_N, MA_M, ATR_N, VF, OF, HiLoE, HiLoB, 5, btfIndex);
   }

   return 0;
}

int CurrentTimeframeStart()
{
   if (Bars <= 1) 
      return 0;
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) 
      return -1;
   int limit = ExtCountedBars > 1 ? Bars - ExtCountedBars - 1 : Bars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      
      double price = iMA(_Symbol, _Period, MA_N, 0, MA_M, PRICE_CLOSE, pos);
      double atr = iATR(_Symbol, _Period, ATR_N, pos);
      SMax[pos] = price + VF * atr;
      SMin[pos] = price - VF * atr;
      if (pos == Bars - 1)
      {
         --pos;
         continue;
      }
      Trend[pos] = Trend[pos + 1];
      if (HiLoB)
      {
         if (High[pos] > SMax[pos + 1])
            Trend[pos] = 1;
         if (Low[pos] < SMin[pos + 1])
            Trend[pos] = -1;
      }
      else
      {
         if (price > SMax[pos + 1])
            Trend[pos] = 1;
         if (price < SMin[pos + 1])
            Trend[pos] = -1;
      }

      if (Trend[pos] > 0)
      {
         if (SMin[pos] < SMin[pos + 1])
            SMin[pos] = SMin[pos + 1];
         UpBuffer[pos] = SMin[pos] - (OF - 1) * atr;
         if (UpBuffer[pos] < UpBuffer[pos + 1] && UpBuffer[pos + 1] != EMPTY_VALUE)
            UpBuffer[pos] = UpBuffer[pos + 1];
      }
      else if (Trend[pos] < 0)
      {
         if (SMax[pos] > SMax[pos + 1])
            SMax[pos] = SMax[pos + 1];
         DnBuffer[pos] = SMax[pos] + (OF - 1) * atr;
         if (DnBuffer[pos] > DnBuffer[pos + 1] && DnBuffer[pos + 1] != EMPTY_VALUE)
            DnBuffer[pos] = DnBuffer[pos + 1];
      }
      int direction = GetDirection(pos);
      switch (direction)
      {
         case ENTER_BUY_SIGNAL:
            buy[pos] = Low[pos];
            sell[pos] = EMPTY_VALUE;
            exit_sell[pos] = EMPTY_VALUE;
            exit_buy[pos] = EMPTY_VALUE;
            break;
         case ENTER_SELL_SIGNAL:
            buy[pos] = EMPTY_VALUE;
            sell[pos] = High[pos];
            exit_sell[pos] = EMPTY_VALUE;
            exit_buy[pos] = EMPTY_VALUE;
            break;
         case EXIT_BUY_SIGNAL:
            buy[pos] = EMPTY_VALUE;
            sell[pos] = EMPTY_VALUE;
            exit_sell[pos] = EMPTY_VALUE;
            exit_buy[pos] = Low[pos];
            break;
         case EXIT_SELL_SIGNAL:
            buy[pos] = EMPTY_VALUE;
            sell[pos] = EMPTY_VALUE;
            exit_sell[pos] = High[pos];
            exit_buy[pos] = EMPTY_VALUE;
            break;
      }
      pos--;
   } 
   return 0;
}

int start()
{
   if (btf != PERIOD_CURRENT && btf != _Period)
      return BTFStart();

   return CurrentTimeframeStart();
}

