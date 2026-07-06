// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=143212


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots 0

double DR[];

enum ADRType
{
   ADR,
   ATR
};
input int N = 14; // ADR poss
input ADRType Type = ADR; // Projection Type
input bool SHOW = true; // Show Projection
input bool Label = true; // Show Label
input color    Labels_Color             = clrWhite;
input double fib_level1 = 0.236; // Fib level 1
input double fib_level2 = 0.382; // Fib level 2
input double fib_level3 = 0.5; // Fib level 3
input double fib_level4 = 0.618; // Fib level 4
input int bars_limit = 1000; // Bars limit

string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(0); k >= 0; k--)
   {
      if (StringFind(ObjectName(0, k), name) == 0)
      {
         return true;
      }
   }
   return false;
}

string GenerateIndicatorPrefix(const string target)
{
   for (int i = 0; i < 1000; ++i)
   {
      string prefix = target + "_" + IntegerToString(i);
      if (!NamesCollision(prefix))
      {
         return prefix;
      }
   }
   return target;
}

double out[];

int M;
int D;

void OnInit()
{
   if (Digits() == 5)
   {
      M = 10000;
      D = 4;
   }
   else
   {
      M = 100;
      D = 2;
   }

   IndicatorObjPrefix = GenerateIndicatorPrefix("adrp");
   IndicatorSetString(INDICATOR_SHORTNAME, "ADRP");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, DR, INDICATOR_CALCULATIONS);
   ++id;
   
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(out, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      if (Type == ADR)
      {
         DR[pos] = high[pos] - low[pos];
      }
      else
      {
         double hl = MathAbs(high[pos] - low[pos]);
         double hc = MathAbs(high[pos] - close[pos - 1]);
         double lc = MathAbs(low[pos] - close[pos - 1]);

         double tr = hl;
         if (tr < hc)
            tr = hc;
         if (tr < lc)
            tr = lc;
         DR[pos] = tr;
      }
   }
   double adr = 0;
   double adr_prev = 0;
   for (int i = 0; i < N; ++i)
   {
      adr_prev += DR[rates_total - 1 - i - 1];
      adr += DR[rates_total - 1 - i];
   }
   double MAX = low[rates_total - 1] + adr;
   double MIN = high[rates_total - 1] - adr;
   if (Label)
   {
      if (Type == ADR)
      {
         if (DR[rates_total - 1] > DR[rates_total - 2])
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[rates_total - 1] < DR[rates_total - 2])
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (0)", Labels_Color);
         }

         if (adr > adr_prev)
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
         }
         else if (adr < adr_prev)
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
         }

         DrawLevels(MIN, MAX, D, time, rates_total);
      }
      else
      {
         if (DR[rates_total - 1] > DR[rates_total - 2])
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[rates_total - 1] < DR[rates_total - 2])
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", time[rates_total - 4], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[rates_total - 1] * M, 0) + " (0)", Labels_Color);
         }

         if (adr > adr_prev)
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
         }
         else if (adr < adr_prev)
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", time[rates_total - 4], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
         }

         DrawLevels(MIN, MAX, D, time, rates_total);
      }
   }
   if (SHOW)
   {
      ObjectDelete(0, IndicatorObjPrefix + "Line_1");
      ObjectCreate(0, IndicatorObjPrefix + "Line_1", OBJ_TREND, 0, time[rates_total - 1 - N], MAX, time[rates_total - 4], MAX);
      ObjectDelete(0, IndicatorObjPrefix + "Line_2");
      ObjectCreate(0, IndicatorObjPrefix + "Line_2", OBJ_TREND, 0, time[rates_total - 1 - N], MIN, time[rates_total - 4], MIN);
   }
   return rates_total;
}

void DrawLevels(double min, double max, int d, const datetime &time[], int rates_total)
{
   ObjectMakeLabel("Label_3", time[rates_total - 4], max, "ATR Projections Up " + DoubleToString(max, d), Labels_Color);
   ObjectMakeLabel("Label_4", time[rates_total - 4], min, "ATR Projections Down " + DoubleToString(min, d), Labels_Color);
   ResetLastError();
   string id = IndicatorObjPrefix + "idValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_FIBO, 0, time[rates_total - 1 - N], max, time[rates_total - 4], min))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, Labels_Color);
      ObjectSetDouble(0, id, OBJPROP_LEVELVALUE, 0, fib_level1);
      ObjectSetString(0, id, OBJPROP_LEVELTEXT, 0, DoubleToString(fib_level1, 3));
      ObjectSetDouble(0, id, OBJPROP_LEVELVALUE, 1, fib_level2);
      ObjectSetString(0, id, OBJPROP_LEVELTEXT, 1, DoubleToString(fib_level2, 3));
      ObjectSetDouble(0, id, OBJPROP_LEVELVALUE, 2, fib_level3);
      ObjectSetString(0, id, OBJPROP_LEVELTEXT, 2, DoubleToString(fib_level3, 3));
      ObjectSetDouble(0, id, OBJPROP_LEVELVALUE, 3, fib_level4);
      ObjectSetString(0, id, OBJPROP_LEVELTEXT, 3, DoubleToString(fib_level4, 3));
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE, 1, max);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 2, min);
   ObjectSetInteger(0, id, OBJPROP_TIME, 1, time[rates_total - 1 - N]);
   ObjectSetInteger(0, id, OBJPROP_TIME, 2, time[rates_total - 4]);
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
}

void ObjectMakeLabel(string nm, datetime date, double price, string LabelTexto, color labelColor, int LabelCorner = 1, int Window = 0, string Font = "Arial", int FSize = 12)
{
   ObjectDelete(0, IndicatorObjPrefix + nm);
   ObjectCreate(0, IndicatorObjPrefix + nm, OBJ_TEXT, 0, date, price);
   ObjectSetString(0, IndicatorObjPrefix + nm, OBJPROP_TEXT, LabelTexto); 
   ObjectSetInteger(0, IndicatorObjPrefix + nm, OBJPROP_BACK, false);
   ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, labelColor);
}