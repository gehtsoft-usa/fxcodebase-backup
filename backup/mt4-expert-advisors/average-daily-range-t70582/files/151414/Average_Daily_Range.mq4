 
// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70582

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window

int NumOfDays_D = 1;

input color ADR_color_above = clrGreen;
input color ADR_color_below = clrRed;

input int TimeZoneOfData = 0;
input bool ADR_Alert_Sound = false;
input bool ADR_Line = true;
input ENUM_LINE_STYLE ADR_linestyle = STYLE_DOT;
input int ADR_Linethickness = 3;
input color ADR_Line_Colour = clrYellow;
input bool Daily_Open_Line = true;
input int Daily_Open_Line_History = 5;
input ENUM_LINE_STYLE Daily_Open_linestyle = STYLE_DOT;
input int Daily_Open_Linethickness = 1;
input color Daily_Open_Line_Colour = clrRed;
input bool display_ADR = true;
input bool Y_enabled = true;
input bool M_enabled = true;
input int NumOfDays_M = 30;
input bool M6_enabled = true;
input bool M6_Trading_weighting = false;
input int Recent_Days_Weighting = 5;
input bool Weighting_to_ADR_percentage = true;
input int NumOfDays_6M = 180;
input ENUM_TIMEFRAMES tf = PERIOD_D1; // Timeframe
input string FontName = "Courier New";
input int FontSize = 12;
input color FontColor = Orange;
input int Window = 0;
//extern int      Corner                = 1;
const ENUM_BASE_CORNER Corner = CORNER_RIGHT_UPPER;
input int HorizPos = 45;
input int VertPos = 20;
input color FontColor2 = Lime;
input int Font2Size = 12;

int DistanceLv, DistanceL, DistanceHv, DistanceH, Distance6Mv, Distance6M, DistanceMv, DistanceM, DistanceYv, DistanceY, DistanceADRv, DistanceADR;

double pnt;
int dig;
string objname = "DRPE";

string Y, M, M6, H, L, ADR;
double m, m6, h, l;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CSumDays
  {
public:
   double            m_sum;
   int               m_days;
                     CSumDays(double sum, int days)
     {
      m_sum = sum;
      m_days = days;
     }
  };
double TodayOpenBuffer[];
int sum_day, sum_m, sum_6m, sum_6m_add;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0, TodayOpenBuffer);
//ArraySetAsSeries(TodayOpenBuffer,1);
   SetIndexStyle(0, DRAW_LINE, Daily_Open_linestyle, Daily_Open_Linethickness, Daily_Open_Line_Colour);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Daily_Open_Line_Colour);
   PlotIndexSetInteger(0, PLOT_LINE_STYLE, Daily_Open_linestyle);
   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, Daily_Open_Linethickness);
   PlotIndexSetString(0, PLOT_LABEL, "Daily Open");
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   ChartSetInteger(0, CHART_FOREGROUND, true);
   pnt = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   dig = (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   if(dig == 3 || dig == 5)
     {
      pnt *= 10;
     }
   ObjectCreate(0, objname + "ADR", OBJ_LABEL, Window, 0, 0);
   ObjectCreate(0, objname + "%", OBJ_LABEL, Window, 0, 0);
   if(Y_enabled)
     {
      ObjectCreate(0, objname + "Y", OBJ_LABEL, Window, 0, 0);
      ObjectCreate(0, objname + "Y-value", OBJ_LABEL, Window, 0, 0);
     }
   if(M_enabled)
     {
      ObjectCreate(0, objname + "M", OBJ_LABEL, Window, 0, 0);
      ObjectCreate(0, objname + "M-value", OBJ_LABEL, Window, 0, 0);
     }
   if(M6_enabled)
     {
      ObjectCreate(0, objname + "6M", OBJ_LABEL, Window, 0, 0);
      ObjectCreate(0, objname + "6M-value", OBJ_LABEL, Window, 0, 0);
     }
   ObjectCreate(0, objname + "H", OBJ_LABEL, Window, 0, 0);
   ObjectCreate(0, objname + "H-value", OBJ_LABEL, Window, 0, 0);
   ObjectCreate(0, objname + "L", OBJ_LABEL, Window, 0, 0);
   ObjectCreate(0, objname + "L-value", OBJ_LABEL, Window, 0, 0);
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason)
  {
   ObjectsDeleteAll(0, objname);
  }

//+--------------------------------------------------------------------------------+
//|           Funzione di iterazione indicatore personalizato                      |
//+--------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // grandezza delle timeseries input
                const int prev_calculated, // numero di barre gestite alla precedente chiamata
                const datetime &time[],    // array Time
                const double &open[],      // array Open
                const double &high[],      // array High
                const double &low[],       // array Low
                const double &close[],     // array Close
                const long &tick_volume[], // array Tick Volume
                const long &volume[],      // array Real Volume
                const int &spread[])       // array Spread
  {
   int counted_bars = prev_calculated;
   if(counted_bars > 0)
      counted_bars--;
   else
      counted_bars = 1;
   DailyOpen(rates_total - counted_bars, rates_total - counted_bars, open, time);
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
//
   double sum_day_val[1];
   sum_day_val[0] = iATR(_Symbol, tf, NumOfDays_D, 1);
   double sum_m_val[1];
   sum_m_val[0] = iATR(_Symbol, tf, NumOfDays_M, 1);
   double sum_6m_val[1];
   sum_6m_val[0] = iATR(_Symbol, tf, NumOfDays_6M, 1);
   double sum_6m_add_val[1];
   sum_6m_add_val[0] = iATR(_Symbol, tf, Recent_Days_Weighting, 1);
//
   double hi = iHigh(NULL, tf, 0);
   double lo = iLow(NULL, tf, 0);
   if(pnt > 0)
     {
      if(Y_enabled)
         Y = DoubleToString(sum_day_val[0] / pnt, 0);
      m = sum_m_val[0] / pnt;
      M = DoubleToString(sum_m_val[0] / pnt, 0);
      m6 = sum_6m_val[0];
      h = (hi - bid) / pnt;
      H = DoubleToString((hi - bid) / pnt, 0);
      l = (bid - lo) / pnt;
      L = DoubleToString((bid - lo) / pnt, 0);
      if(m6 == 0)
         return rates_total;
      double ADR_val;
      if(Weighting_to_ADR_percentage)
        {
         double WADR = ((iHigh(NULL, tf, 0) - iLow(NULL, tf, 0)) + (iHigh(NULL, tf, 1) - iLow(NULL, tf, 1)) + (iHigh(NULL, tf, 2) - iLow(NULL, tf, 2)) +
                        (iHigh(NULL, tf, 3) - iLow(NULL, tf, 3)) + (iHigh(NULL, tf, 4) - iLow(NULL, tf, 4))) /
                       5;
         double val = (m6 + WADR) / 2 / pnt;
         ADR_val = (h + l) / val * 100;
         ADR = DoubleToString(ADR_val, 0);
        }
      else
        {
         ADR_val = (h + l) / (m6 / pnt) * 100;
         ADR = DoubleToString(ADR_val, 0);
        }
      if(M6_Trading_weighting)
        {
         m6 = (m6 + sum_6m_add_val[0]) / 2;
        }
      if(ADR_Line)
        {
         ObjectCreate(0, objname + "ADR high line", OBJ_TREND, 0, 0, hi - m6);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_TIME, 0, iTime(_Symbol, tf, 0) + TimeZoneOfData * 3600);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_TIME, 1, iTime(_Symbol, PERIOD_CURRENT, 0));
         ObjectSetDouble(0, objname + "ADR high line", OBJPROP_PRICE, 0, hi - m6);
         ObjectSetDouble(0, objname + "ADR high line", OBJPROP_PRICE, 1, hi - m6);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_COLOR, ADR_Line_Colour);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_STYLE, ADR_linestyle);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_WIDTH, ADR_Linethickness);
         ObjectSetInteger(0, objname + "ADR high line", OBJPROP_RAY, false);
         ObjectCreate(0, objname + "ADR low line", OBJ_TREND, 0, 0, lo + m6);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_TIME, 0, iTime(_Symbol, tf, 0) + TimeZoneOfData * 3600);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_TIME, 1, iTime(_Symbol, PERIOD_CURRENT, 0));
         ObjectSetDouble(0, objname + "ADR low line", OBJPROP_PRICE, 0, lo + m6);
         ObjectSetDouble(0, objname + "ADR low line", OBJPROP_PRICE, 1, lo + m6);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_COLOR, ADR_Line_Colour);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_STYLE, ADR_linestyle);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_WIDTH, ADR_Linethickness);
         ObjectSetInteger(0, objname + "ADR low line", OBJPROP_RAY, false);
        }
      m6 = m6 / pnt;
      M6 = DoubleToString(m6, 0);
      uint h2;
      TextSetFont(FontName, -10 * FontSize);
      TextGetSize(L + " ", DistanceL, h2);
      TextGetSize(H + " ", DistanceH, h2);
      TextGetSize(M6 + " ", Distance6M, h2);
      TextGetSize(M + " ", DistanceM, h2);
      TextGetSize(Y + " ", DistanceY, h2);
      TextGetSize(ADR + "% ", DistanceADR, h2);
      TextSetFont(FontName, -10 * Font2Size);
      TextGetSize("H:", DistanceHv, h2);
      TextGetSize("L:", DistanceLv, h2);
      TextGetSize("6M:", Distance6Mv, h2);
      TextGetSize("M:", DistanceMv, h2);
      TextGetSize("Y:", DistanceYv, h2);
      TextGetSize("ADR", DistanceADRv, h2);
      //ADR
      if(display_ADR)
        {
         ObjectSetInteger(0, objname + "ADR", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "ADR", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + M_enabled * (DistanceMv + DistanceM) + Y_enabled * (DistanceYv + DistanceY) + DistanceADRv + DistanceADR);
         ObjectSetInteger(0, objname + "ADR", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "ADR", OBJPROP_TEXT, "ADR");
         ObjectSetString(0, objname + "ADR", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "ADR", OBJPROP_FONTSIZE, FontSize);
         ObjectSetInteger(0, objname + "ADR", OBJPROP_COLOR, FontColor);
         ObjectSetInteger(0, objname + "%", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "%", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + M_enabled * (DistanceMv + DistanceM) + Y_enabled * (DistanceYv + DistanceY) + DistanceADR);
         ObjectSetInteger(0, objname + "%", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "%", OBJPROP_TEXT, ADR + "%");
         ObjectSetString(0, objname + "%", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "%", OBJPROP_FONTSIZE, Font2Size);
         static bool oneTime = true;
         if(ADR_val < 100)
           {
            ObjectSetInteger(0, objname + "%", OBJPROP_COLOR, ADR_color_below);
            oneTime = true;
           }
         else
           {
            if(ADR_Alert_Sound && oneTime)
              {
               Alert(_Symbol + " ADX >= 100%");
               oneTime = false;
              }
            ObjectSetInteger(0, objname + "%", OBJPROP_COLOR, ADR_color_above);
           }
        }
      if(Y_enabled)
        {
         ObjectSetInteger(0, objname + "Y", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "Y", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + M_enabled * (DistanceMv + DistanceM) + DistanceYv + DistanceY);
         ObjectSetInteger(0, objname + "Y", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "Y", OBJPROP_TEXT, "Y:");
         ObjectSetString(0, objname + "Y", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "Y", OBJPROP_FONTSIZE, FontSize);
         ObjectSetInteger(0, objname + "Y", OBJPROP_COLOR, FontColor);
         ObjectSetInteger(0, objname + "Y-value", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "Y-value", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + M_enabled * (DistanceMv + DistanceM) + DistanceY);
         ObjectSetInteger(0, objname + "Y-value", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "Y-value", OBJPROP_TEXT, Y);
         ObjectSetString(0, objname + "Y-value", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "Y-value", OBJPROP_FONTSIZE, Font2Size);
         ObjectSetInteger(0, objname + "Y-value", OBJPROP_COLOR, FontColor2);
        }
      if(M_enabled)
        {
         ObjectSetInteger(0, objname + "M", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "M", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + DistanceMv + DistanceM);
         ObjectSetInteger(0, objname + "M", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "M", OBJPROP_TEXT, "M:");
         ObjectSetString(0, objname + "M", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "M", OBJPROP_FONTSIZE, FontSize);
         ObjectSetInteger(0, objname + "M", OBJPROP_COLOR, FontColor);
         ObjectSetInteger(0, objname + "M-value", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "M-value", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + M6_enabled * (Distance6Mv + Distance6M) + DistanceM);
         ObjectSetInteger(0, objname + "M-value", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "M-value", OBJPROP_TEXT, M);
         ObjectSetString(0, objname + "M-value", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "M-value", OBJPROP_FONTSIZE, Font2Size);
         ObjectSetInteger(0, objname + "M-value", OBJPROP_COLOR, FontColor2);
        }
      if(M6_enabled)
        {
         ObjectSetInteger(0, objname + "6M", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "6M", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + Distance6Mv + Distance6M);
         ObjectSetInteger(0, objname + "6M", OBJPROP_YDISTANCE, VertPos);
         ObjectSetString(0, objname + "6M", OBJPROP_TEXT, "6M:");
         ObjectSetString(0, objname + "6M", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "6M", OBJPROP_FONTSIZE, FontSize);
         ObjectSetInteger(0, objname + "6M", OBJPROP_COLOR, FontColor);
         ObjectSetInteger(0, objname + "6M-value", OBJPROP_CORNER, Corner);
         ObjectSetInteger(0, objname + "6M-value", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceHv + DistanceH + Distance6M);
         ObjectSetInteger(0, objname + "6M-value", OBJPROP_YDISTANCE, VertPos);
         //ObjectSetString(0,objname+"6M-value",M6,Font2Size,FontName,FontColor2);
         ObjectSetString(0, objname + "6M-value", OBJPROP_TEXT, M6);
         ObjectSetString(0, objname + "6M-value", OBJPROP_FONT, FontName);
         ObjectSetInteger(0, objname + "6M-value", OBJPROP_FONTSIZE, Font2Size);
         ObjectSetInteger(0, objname + "6M-value", OBJPROP_COLOR, FontColor2);
        }
      ObjectSetInteger(0, objname + "H", OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, objname + "H", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceH + DistanceHv);
      ObjectSetInteger(0, objname + "H", OBJPROP_YDISTANCE, VertPos);
      ObjectSetString(0, objname + "H", OBJPROP_TEXT, "H:");
      ObjectSetString(0, objname + "H", OBJPROP_FONT, FontName);
      ObjectSetInteger(0, objname + "H", OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, objname + "H", OBJPROP_COLOR, FontColor);
      ObjectSetInteger(0, objname + "H-value", OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, objname + "H-value", OBJPROP_XDISTANCE, HorizPos + DistanceLv + DistanceH);
      ObjectSetInteger(0, objname + "H-value", OBJPROP_YDISTANCE, VertPos);
      ObjectSetString(0, objname + "H-value", OBJPROP_TEXT, H);
      ObjectSetString(0, objname + "H-value", OBJPROP_FONT, FontName);
      ObjectSetInteger(0, objname + "H-value", OBJPROP_FONTSIZE, Font2Size);
      ObjectSetInteger(0, objname + "H-value", OBJPROP_COLOR, FontColor2);
      ObjectSetInteger(0, objname + "L", OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, objname + "L", OBJPROP_XDISTANCE, HorizPos + DistanceLv);
      ObjectSetInteger(0, objname + "L", OBJPROP_YDISTANCE, VertPos);
      ObjectSetString(0, objname + "L", OBJPROP_TEXT, "L:");
      ObjectSetString(0, objname + "L", OBJPROP_FONT, FontName);
      ObjectSetInteger(0, objname + "L", OBJPROP_FONTSIZE, FontSize);
      ObjectSetInteger(0, objname + "L", OBJPROP_COLOR, FontColor);
      ObjectSetInteger(0, objname + "L-value", OBJPROP_CORNER, Corner);
      ObjectSetInteger(0, objname + "L-value", OBJPROP_XDISTANCE, HorizPos);
      ObjectSetInteger(0, objname + "L-value", OBJPROP_YDISTANCE, VertPos);
      ObjectSetString(0, objname + "L-value", OBJPROP_TEXT, L);
      ObjectSetString(0, objname + "L-value", OBJPROP_FONT, FontName);
      ObjectSetInteger(0, objname + "L-value", OBJPROP_FONTSIZE, Font2Size);
      ObjectSetInteger(0, objname + "L-value", OBJPROP_COLOR, FontColor2);
     }
   return (rates_total);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*int TimeDayOfWeek(datetime date)
{
   MqlDateTime tm;
   TimeToStruct(date, tm);
   return (tm.day_of_week);
}*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void range(int days, CSumDays &sumdays)
  {
   sumdays.m_days = 0;
   sumdays.m_sum = 0;
   for(int i = 1; i < Bars(_Symbol, PERIOD_CURRENT) - 1; i++)
     {
      double hi = iHigh(NULL, tf, i);
      double lo = iLow(NULL, tf, i);
      datetime dt = iTime(NULL, tf, i);
      if(TimeDayOfWeek(dt) > 0 && TimeDayOfWeek(dt) < 6)
        {
         sumdays.m_sum += hi - lo;
         sumdays.m_days = sumdays.m_days + 1;
         if(sumdays.m_days >= days)
            break;
        }
     }
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int DailyOpen(int offset, int lastbar, const double &open[], const datetime &time[])
  {
   int shift;
   int dayC = 0;
   int tzdiffsec = TimeZoneOfData * 3600;
   double barsper30 = 1.0 * PeriodSeconds(PERIOD_M30) / PeriodSeconds(Period());
   bool ShowDailyOpenLevel = true;
   offset = MathMin(offset, iBarShift(Symbol(),Period(),iTime(Symbol(),PERIOD_D1,Daily_Open_Line_History-1)));
   Print(offset + " " + lastbar);
   for(shift = offset; shift >= 0; shift--)
     {
      if(Daily_Open_Line)
        {
         TodayOpenBuffer[shift] = 0;
         if(ShowDailyOpenLevel)
           {
            if(iBarShift(Symbol(), PERIOD_D1, (time[shift] - tzdiffsec)) != iBarShift(Symbol(), PERIOD_D1, (time[shift + 1] - tzdiffsec))) // day change
              {
               TodayOpenBuffer[shift] = open[shift];
               TodayOpenBuffer[shift + 1] = EMPTY_VALUE; // avoid stairs in the line
               dayC++;
              }
            else 
              {
               TodayOpenBuffer[shift] = TodayOpenBuffer[shift + 1];
              }
            
           }
        }
      else
        {
         TodayOpenBuffer[shift] = 0;
        }
        
     }
   return (0);
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+
