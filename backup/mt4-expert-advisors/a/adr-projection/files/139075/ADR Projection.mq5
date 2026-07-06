// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66195
#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"

string IndicatorName = "ADR Projection";

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#property indicator_color1 Green

double DR[];

enum ADRType
{
   ADR,
   ATR
};

input int N_up = 14;         // ADR Up poss
input int N_down = 14;         // ADR Down poss
input ADRType Type = ADR; // Projection Type
input bool SHOW = true;   // Show Projection
input bool Label = true;  // Show Label
input color Labels_Color = clrWhite;
int M;
int D;

int OnInit()
{
   if (_Digits == 5)
   {
      M = 10000;
      D = 4;
   }
   else
   {
      M = 100;
      D = 2;
   }
   ArraySetAsSeries(DR, true);
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   //    PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
   SetIndexBuffer(0, DR, INDICATOR_DATA);

   return (0);
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(ChartID());
}

double CalcAdr(int period, int pos, double& high[], double& low[])
{
   double Sum = 0.;
   for (int i = 0; i < period; i++)
   {
      Sum += DR[pos + i];
   }
   return Sum / period;
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time2[],
                const double &open2[],
                const double &high2[],
                const double &low2[],
                const double &close2[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   datetime time[];
   double open[], high[], low[], close[];

   ArraySetAsSeries(time, true);
   CopyTime(_Symbol, _Period, 0, rates_total, time);

   ArraySetAsSeries(open, true);
   CopyOpen(_Symbol, _Period, 0, rates_total, open);

   ArraySetAsSeries(high, true);
   CopyHigh(_Symbol, _Period, 0, rates_total, high);

   ArraySetAsSeries(low, true);
   CopyLow(_Symbol, _Period, 0, rates_total, low);

   ArraySetAsSeries(close, true);
   CopyClose(_Symbol, _Period, 0, rates_total, close);
   if (Bars(_Symbol, _Period) <= 1)
      return (0);
   int ExtCountedBars = prev_calculated;
   if (ExtCountedBars < 0)
      return (-1);
   int limit = Bars(_Symbol, _Period) - 5;
   if (ExtCountedBars > 2)
      limit = Bars(_Symbol, _Period) - ExtCountedBars - 1;
   int pos = limit;
   while (pos >= 0)
   {
      if (Type == ADR)
         DR[pos] = high[pos] - low[pos];
      else
         DR[pos] = TrueRange(pos, time, open, high, low, close);
      pos--;
   }
   int i;
   double adr_max = CalcAdr(N_up, 0, high, low);
   double adr_min = CalcAdr(N_down, 0, high, low);
   double adr_prev_max = CalcAdr(N_up, 1, high, low);;
   double adr_prev_min = CalcAdr(N_down, 1, high, low);;
   double MAX = low[0] + adr_max;
   double MIN = high[0] - adr_min;
   if (Label)
   {
      if (Type == ADR)
      {
         if (DR[0] > DR[1])
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "DR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[0] < DR[1])
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "DR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "DR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
         }

         if (adr_max > adr_prev_max)
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ADR " + DoubleToString(adr_max * M, 0) + " (+)", Labels_Color);
         }
         else if (adr_max < adr_prev_max)
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ADR " + DoubleToString(adr_max * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ADR " + DoubleToString(adr_max * M, 0) + " (0)", Labels_Color);
         }

         ObjectMakeLabel("Label_3", time[3], MAX,
                         "ADR Projections Up " + DoubleToString(MAX, D), Labels_Color);
         ObjectMakeLabel("Label_4", time[3], MIN,
                         "ADR Projections Down " + DoubleToString(MIN, D), Labels_Color);
      }
      else
      {
         if (DR[0] > DR[1])
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "TR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
         }
         else if (DR[0] < DR[1])
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "TR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_1", time[3], MAX + 2 * (MAX - MIN) / 5,
                            "TR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
         }

         if (adr_max > adr_prev_max)
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ATR " + DoubleToString(adr_max * M, 0) + " (+)", Labels_Color);
         }
         else if (adr_max < adr_prev_max)
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ATR " + DoubleToString(adr_max * M, 0) + " (-)", Labels_Color);
         }
         else
         {
            ObjectMakeLabel("Label_2", time[3], MAX + (MAX - MIN) / 5,
                            "ATR " + DoubleToString(adr_max * M, 0) + " (0)", Labels_Color);
         }

         ObjectMakeLabel("Label_3", time[3], MAX,
                         "ATR Projections Up " + DoubleToString(MAX, D), Labels_Color);
         ObjectMakeLabel("Label_4", time[3], MIN,
                         "ATR Projections Down " + DoubleToString(MIN, D), Labels_Color);
      }
   }
   if (SHOW)
   {
      ObjectDelete(ChartID(), "Line_1");
      ObjectCreate(ChartID(), "Line_1", OBJ_TREND, 0, time[N_up], MAX, time[3], MAX);
      ObjectDelete(ChartID(), "Line_2");
      ObjectCreate(ChartID(), "Line_2", OBJ_TREND, 0, time[N_down], MIN, time[3], MIN);
   }
   return (0);
}

double TrueRange(const int p,
                 const datetime &time[],
                 const double &open[],
                 const double &high[],
                 const double &low[],
                 const double &close[])

{
   double hl = MathAbs(high[p] - low[p]);
   double hc = MathAbs(high[p] - close[p + 1]);
   double lc = MathAbs(low[p] - close[p + 1]);

   double tr = hl;
   if (tr < hc)
      tr = hc;
   if (tr < lc)
      tr = lc;
   return tr;
}

void ObjectMakeLabel(string nm, datetime date, double price, string LabelTexto, color labelColor, int LabelCorner = 1, int Window = 0, string Font = "Arial", int FSize = 12)
{
   ObjectDelete(ChartID(), nm);
   ObjectCreate(ChartID(), nm, OBJ_TEXT, 0, date, price);
   ObjectSetString(0, nm, OBJPROP_TEXT, LabelTexto);
   ObjectSetInteger(ChartID(), nm, OBJPROP_BACK, false);
   ObjectSetString(0, nm, OBJPROP_LEVELTEXT, LabelTexto);
   ObjectSetString(0, nm, OBJPROP_FONT, Font);
   ObjectSetInteger(0, nm, OBJPROP_FONTSIZE, FSize);
   ObjectSetInteger(0, nm, OBJPROP_COLOR, labelColor);
}