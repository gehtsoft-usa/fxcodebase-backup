// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68583

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
#property indicator_buffers 4

input double Percentage = 1.0; // Risk Percentage
input double Multiplier = 1.5; // ATR Multiplier
input double pMultiplier = 2.0; // Profit Multiplier
input int Period = 14; // ATR Period
input int NumDots = 5; // Num Dots
input bool LAST_CANDLE = false; // Put on the current candle

input color DOTclr = Red; // Stop Dot colour
input color pDOTclr = Blue; // Profit Dot colour
input int FontSize = 8; // Font Size
input color LblColour = Gray; // Colour for pattern labels

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

double DOTh[], DOTl[], DOThp[], DOTlp[];
double pipSize;

int init()
{
   IndicatorName = GenerateIndicatorName("ATR Stop Dots");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   SetIndexStyle(0, DRAW_ARROW, 0, 2, DOTclr);
   SetIndexBuffer(0, DOTh);
   SetIndexLabel(0, "DOTh");
   SetIndexArrow(0, 4);

   SetIndexStyle(1, DRAW_ARROW, 0, 2, DOTclr);
   SetIndexBuffer(1, DOTl);
   SetIndexLabel(1, "DOTl");
   SetIndexArrow(1, 4);

   SetIndexStyle(2, DRAW_ARROW, 0, 2, pDOTclr);
   SetIndexBuffer(2, DOThp);
   SetIndexLabel(2, "DOThp");
   SetIndexArrow(2, 4);

   SetIndexStyle(3, DRAW_ARROW, 0, 2, pDOTclr);
   SetIndexBuffer(3, DOTlp);
   SetIndexLabel(3, "DOTlp");
   SetIndexArrow(3, 4);

   double point = MarketInfo(_Symbol, MODE_POINT);
   int digits = (int)MarketInfo(_Symbol, MODE_DIGITS);
   int mult = digits == 3 || digits == 5 ? 10 : 1;
   pipSize = point * mult;

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
   for (int pos = LAST_CANDLE ? 0 : 1; pos <= NumDots + 1; ++pos)
   {
      double atrValue = iATR(_Symbol, _Period, Period, pos) * Multiplier;
      
      double unitCost = MarketInfo(_Symbol, MODE_TICKVALUE);
      double tickSize = MarketInfo(_Symbol, MODE_TICKSIZE);
      double BalPct = (AccountBalance() * Percentage) / 100.0;
      double PipPct = BalPct / unitCost;
      double base_value = PipPct * tickSize;
      if (atrValue < base_value)
         base_value = atrValue;

      DOTh[pos] = Close[pos] + base_value;
      DOTl[pos] = Close[pos] - base_value;

      DOThp[pos] = Close[pos] + (base_value * pMultiplier);
      DOTlp[pos] = Close[pos] - (base_value * pMultiplier);

      double display_value = MathFloor(base_value / tickSize);
      double lotsize = MathFloor(PipPct / display_value);

      string lotsId = IndicatorObjPrefix + "lotsValue" + IntegerToString(pos);
      ObjectCreate(0, lotsId, OBJ_TEXT, 0, 0, 0);
      ObjectSetInteger(0, lotsId, OBJPROP_TIME1, Time[pos]);
      ObjectSetDouble(0, lotsId, OBJPROP_PRICE1, High[pos] + base_value + 10 * pipSize);
      string text = "Lot: " + DoubleToString(lotsize, 2);
      ObjectSetString(0, lotsId, OBJPROP_TEXT, text);
      ObjectSetString(0, lotsId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, lotsId, OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, lotsId, OBJPROP_COLOR, LblColour);

      string valId = IndicatorObjPrefix + "idValue" + IntegerToString(pos);
      ObjectCreate(0, valId, OBJ_TEXT, 0, 0, 0);
      ObjectSetInteger(0, lotsId, OBJPROP_TIME1, Time[pos]);
      ObjectSetDouble(0, lotsId, OBJPROP_PRICE1, Low[pos] - base_value + 10 * pipSize);
      text = DoubleToString(display_value);
      ObjectSetString(0, valId, OBJPROP_TEXT, text);
      ObjectSetString(0, valId, OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, valId, OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, valId, OBJPROP_COLOR, LblColour);
   } 
   return 0;
}