// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70919


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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green

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
int M;
int D;

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
   if (Digits == 5)
   {
      M = 10000;
      D = 4;
   }
   else
   {
      M = 100;
      D = 2;
   }
    IndicatorName = GenerateIndicatorName(IndicatorName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   IndicatorDigits(Digits);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, DR);
   
   return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1);
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      if (Type == ADR)
         DR[pos] = High[pos] - Low[pos];
      else
         DR[pos] = TrueRange(pos);
      pos--;
   }
   double adr = iMAOnArray(DR, 0, N, 0, MODE_SMA, 0);
   double adr_prev = iMAOnArray(DR, 0, N, 0, MODE_SMA, 1);
   double MAX = Low[0] + adr;
   double MIN = High[0] - adr;
   if (Label)
   {
      if (Type == ADR)
      {
         if (DR[0] > DR[1])
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[0] < DR[1])
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
               "DR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
         }

         if (adr > adr_prev)
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
         }
         else if (adr < adr_prev)
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ADR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
         }

         DrawLevels(MIN, MAX, D);
      }
      else
      {
         if (DR[0] > DR[1])
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[0] < DR[1])
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
               "TR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
         }

         if (adr > adr_prev)
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
         }
         else if (adr < adr_prev)
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
               "ATR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
         }

         DrawLevels(MIN, MAX, D);
      }
   }
   if (SHOW)
   {
      ObjectDelete(IndicatorObjPrefix + "Line_1");
      ObjectCreate(IndicatorObjPrefix + "Line_1", OBJ_TREND, 0, Time[N], MAX, Time[3], MAX);
      ObjectDelete(IndicatorObjPrefix + "Line_2");
      ObjectCreate(IndicatorObjPrefix + "Line_2", OBJ_TREND, 0, Time[N], MIN, Time[3], MIN);
   }
   return(0);
}

void DrawLevels(double min, double max, int d)
{
   ObjectMakeLabel("Label_3", Time[3], max, "ATR Projections Up " + DoubleToString(max, d), Labels_Color);
   ObjectMakeLabel("Label_4", Time[3], min, "ATR Projections Down " + DoubleToString(min, d), Labels_Color);
   ResetLastError();
   string id = IndicatorObjPrefix + "idValue";
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_FIBO, 0, Time[N], max, Time[3], min))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return ;
      }
      ObjectSetInteger(0, id, OBJPROP_COLOR, Labels_Color);
      ObjectSet(id, OBJPROP_FIRSTLEVEL + 1, fib_level1);
      ObjectSetFiboDescription(id, OBJPROP_FIRSTLEVEL + 1, DoubleToString(fib_level1, 3));
      ObjectSet(id, OBJPROP_FIRSTLEVEL + 2, fib_level2);
      ObjectSetFiboDescription(id, OBJPROP_FIRSTLEVEL + 2, DoubleToString(fib_level2, 3));
      ObjectSet(id, OBJPROP_FIRSTLEVEL + 3, fib_level3);
      ObjectSetFiboDescription(id, OBJPROP_FIRSTLEVEL + 3, DoubleToString(fib_level3, 3));
      ObjectSet(id, OBJPROP_FIRSTLEVEL + 4, fib_level4);
      ObjectSetFiboDescription(id, OBJPROP_FIRSTLEVEL + 4, DoubleToString(fib_level4, 3));
   }
   ObjectSetDouble(0, id, OBJPROP_PRICE1, max);
   ObjectSetDouble(0, id, OBJPROP_PRICE2, min);
   ObjectSetInteger(0, id, OBJPROP_TIME1, Time[N]);
   ObjectSetInteger(0, id, OBJPROP_TIME2, Time[3]);
}

double TrueRange(const int p)
{
   double hl = MathAbs(High[p] - Low[p]);
   double hc = MathAbs(High[p] - Close[p + 1]);
   double lc = MathAbs(Low[p] - Close[p + 1]);

   double tr = hl;
   if (tr < hc)
      tr = hc;
   if (tr < lc)
      tr = lc;
   return tr;
}

void ObjectMakeLabel(string nm, datetime date, double price, string LabelTexto, color labelColor, int LabelCorner = 1, int Window = 0, string Font = "Arial", int FSize = 12)
{
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix + nm, OBJ_TEXT, 0, date, price);
   ObjectSetString(0, IndicatorObjPrefix + nm, OBJPROP_TEXT, LabelTexto); 
   ObjectSet(IndicatorObjPrefix + nm, OBJPROP_BACK, false);
   ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, labelColor);
}