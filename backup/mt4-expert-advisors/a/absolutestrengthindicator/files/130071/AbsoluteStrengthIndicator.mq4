// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69191

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
#property indicator_buffers 4
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Yellow
#property indicator_color4 Blue

enum Method
{
   RSI,
   Stoch,
   ADX
};

input Method method = RSI; // Method
input ENUM_MA_METHOD Method1 = MODE_SMA; // Smoothing method
input int Length = 10; // Period for Evaluation
input int Signal = 5; // Period for Signal
input int Smoothing = 5; // Period for Smoothing
input double OverBought = 0; // OverBought
input double OverSold = 0; // OverSold
input bool ShowBulls = true; // Show Bulls
input bool ShowBears = true; // Show Bears

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

double Bulls[], SignalBulls[], Bears[], SignalBears[], BullsTemp[], BearsTemp[], BearsAVG[], BullsAVG[];

int init()
{
   IndicatorName = GenerateIndicatorName("Absolute Strength Indicator");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(8);

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, Bulls);
   SetIndexLabel(0, "Bulls");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SignalBulls);
   SetIndexLabel(1, "Signal Bulls");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Bears);
   SetIndexLabel(2, "Bears");

   SetIndexStyle(3, DRAW_LINE);
   SetIndexBuffer(3, SignalBears);
   SetIndexLabel(3, "Signal Bears");

   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(4, BullsTemp);

   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(5, BearsTemp);

   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(6, BullsAVG);

   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(7, BearsAVG);
   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars - 2;
   for (int i = limit; i >= 0; i--)
   {
      double ma0 = iMA(_Symbol, _Period, 2, 0, MODE_SMA, PRICE_CLOSE, i);
      double ma1 = iMA(_Symbol, _Period, 2, 0, MODE_SMA, PRICE_CLOSE, i + 1);
      if (method == RSI)
      {
         BullsTemp[i] = 0.5 * (MathAbs(ma0 - ma1) + (ma0 - ma1));
         BearsTemp[i] = 0.5 * (MathAbs(ma0 - ma1) - (ma0 - ma1));
      }
      else if (method == Stoch)
      {
         int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Length, i);
         double min = iLow(_Symbol, _Period, lowestIndex);
         int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Length, i);
         double max = iHigh(_Symbol, _Period, highestIndex);
         BullsTemp[i] = ma0 - min;
         BearsTemp[i] = max - ma0;
      }
      else if (method == ADX)
      {
         BullsTemp[i] = 0.5 * (MathAbs(High[i] - High[i + 1]) + (High[i] - High[i + 1]));
         BearsTemp[i] = 0.5 * (MathAbs(Low[i + 1] - Low[i]) + (Low[i + 1] - Low[i]));
      }
      if (i > Bars - 2 - Length)
      {
         continue;
      }
      BullsAVG[i] = iMAOnArray(BullsTemp, 0, Length, 0, Method1, i);
      BearsAVG[i] = iMAOnArray(BearsTemp, 0, Length, 0, Method1, i);
      if (i <= Bars - 2 - Length - Smoothing)
      {
         Bulls[i] = iMAOnArray(BullsAVG, 0, Smoothing, 0, Method1, i);
         Bears[i] = iMAOnArray(BearsAVG, 0, Smoothing, 0, Method1, i);
      }
      if (OverBought > 0 && OverSold > 0)
      {
         SignalBulls[i] = OverBought / 100 * (Bulls[i] + Bears[i]);
         SignalBears[i] = OverSold / 100 * (Bulls[i] + Bears[i]);
      }
      else
      {
         if (i > Bars - 2 - Length - Signal)
         {
            continue;
         }
         SignalBulls[i] = iMAOnArray(BullsAVG, 0, Signal, 0, Method1, i);
         SignalBears[i] = iMAOnArray(BearsAVG, 0, Signal, 0, Method1, i);
      }
   }
   return 0;
}
