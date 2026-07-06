// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=32374

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_chart_window
#property indicator_buffers 15
#property indicator_plots 14

input color LabelColor = Blue;

input color PivotColor = Blue;
input int PivotStyle =  STYLE_SOLID;  

input color R1Color = Green;
input int R1Style  = STYLE_SOLID;  
input color R2Color = Green;
input int R2Style  = STYLE_SOLID; 
input color R3Color = Green;
input int R3Style  = STYLE_SOLID; 

input color S1Color = Red;
input int S1Style  = STYLE_SOLID;  
input color S2Color = Red;
input int S2Style  = STYLE_SOLID; 
input color S3Color = Red;
input int S3Style  = STYLE_SOLID; 

input bool  Show_MR_Level           = true;
input bool  Show_MS_Level           = true;

input color MR1Color = Gray;
input int MR1Style  = STYLE_SOLID;  
input color MR2Color = Gray;
input int MR2Style  = STYLE_SOLID; 
input color MR3Color = Gray;
input int MR3Style  = STYLE_SOLID; 

input color MS1Color = Gray;
input int MS1Style  = STYLE_SOLID;  
input color MS2Color = Gray;
input int MS2Style  = STYLE_SOLID; 
input color MS3Color = Gray;
input int MS3Style  = STYLE_SOLID; 
 
//---- input parameters

input bool Zero = true;
input bool One = true;
input bool Two = true;
input bool Three = true;

input ENUM_TIMEFRAMES period = PERIOD_D1; // Timeframe

enum ENUM_TYPE
{
   Pivot, // Pivot
   Camarilla, // Camarilla
   Woodie, // Woodie
   Fibonacci, // Fibonacci
   Floor, // Floor
   Fibonacci_Retracement // Fibonacci Retracement
};

input ENUM_TYPE Type = Pivot;

enum ENUM_MODE
{
   Today, // Today
   History // History
};

input ENUM_MODE Mode = Today;
input int bars_limit = 10000; // Bars limit

//---- buffers
datetime time1;
datetime time2;
string Sup1 = "S 1", Res1 = "R 1";
string Sup2="S 2", Res2="R 2", Sup3="S 3", Res3="R 3";
int fontsize = 10;
double P, S1, R1, S2, R2, S3, R3;
double  MS1, MR1, MS2, MR2, MS3, MR3;
double x,num;
double bools[];
double p_arr[];
double s1_arr[];
double s2_arr[];
double s3_arr[];
double r1_arr[];
double r2_arr[];
double r3_arr[];
double ms1_arr[];
double ms2_arr[];
double ms3_arr[];
double mr1_arr[];
double mr2_arr[];
double mr3_arr[];

string EAName = "Pivot";
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

void PlotLine(string name,double value,double line_color,double style)
{
   ObjectCreate(0, IndicatorObjPrefix + name,OBJ_TREND,0,time1,value,time2,value);
   ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_RAY, false);
   ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_BACK, true);
   ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_COLOR, line_color);
}

string IndicatorName;
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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("Pivot");
   IndicatorSetString(INDICATOR_SHORTNAME, "Pivot");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   EAName = IndicatorObjPrefix;

   int id = 0;
   if (Mode == History)
   {
      SetIndexBuffer(id, p_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, PivotColor);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, PivotStyle);
      PlotIndexSetString(id, PLOT_LABEL, "P");
      ++id;
      SetIndexBuffer(id, s1_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, S1Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, S1Style);
      PlotIndexSetString(id, PLOT_LABEL, "S1");
      ++id;
      SetIndexBuffer(id, s2_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, S2Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, S2Style);
      PlotIndexSetString(id, PLOT_LABEL, "S2");
      ++id;
      SetIndexBuffer(id, s3_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, S3Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, S3Style);
      PlotIndexSetString(id, PLOT_LABEL, "S3");
      ++id;
      SetIndexBuffer(id, r1_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, R1Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, R1Style);
      PlotIndexSetString(id, PLOT_LABEL, "R1");
      ++id;
      SetIndexBuffer(id, r2_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, R2Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, R2Style);
      PlotIndexSetString(id, PLOT_LABEL, "R2");
      ++id;
      SetIndexBuffer(id, r3_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, R3Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, R3Style);
      PlotIndexSetString(id, PLOT_LABEL, "R3");
      ++id;
      SetIndexBuffer(id, ms1_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MS1Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MS1Style);
      PlotIndexSetString(id, PLOT_LABEL, "MS1");
      ++id;
      SetIndexBuffer(id, ms2_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MS2Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MS2Style);
      PlotIndexSetString(id, PLOT_LABEL, "MS2");
      ++id;
      SetIndexBuffer(id, ms3_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MS3Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MS3Style);
      PlotIndexSetString(id, PLOT_LABEL, "MS3");
      ++id;
      SetIndexBuffer(id, mr1_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MR1Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MR1Style);
      PlotIndexSetString(id, PLOT_LABEL, "MR1");
      ++id;
      SetIndexBuffer(id, mr2_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MR2Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MR2Style);
      PlotIndexSetString(id, PLOT_LABEL, "MR2");
      ++id;
      SetIndexBuffer(id, mr3_arr, INDICATOR_DATA);
      PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetInteger(id, PLOT_LINE_COLOR, MR3Color);
      PlotIndexSetInteger(id, PLOT_LINE_STYLE, MR3Style);
      PlotIndexSetString(id, PLOT_LABEL, "MR3");
      ++id;
   }
   SetIndexBuffer(id, bools, INDICATOR_CALCULATIONS);
}

void CalcPivot(const int i, double &p, 
   double &s1, double &s2, double &s3,
   double &r1, double &r2, double &r3)
{
   double high  = iHigh(NULL,period,i+1);
   double low   = iLow(NULL,period,i+1);
   double open  = iOpen(NULL,period,i+1);
   double close = iClose(NULL,period,i+1);
   switch (Type)
   {
      case Pivot:
         p = (high + low + close ) / 3;
         r1 = (2 * p) - low;
         s1 = (2 * p) - high;
         r2 = p + (high - low);
         s2 = p - (high - low);
         r3 = p + (high - low) * 2;
         s3 = p - (high - low) * 2;
         break;
      case Camarilla:
         p = close;
         r1 = p + (high - low) * 1.1 / 12;
         s1 = p - (high - low) * 1.1 / 12;
         r2 = p + (high - low) * 1.1 / 6;
         s2 = p - (high - low) * 1.1 / 6;
         r3 = p + (high - low) * 1.1 / 4;
         s3 = p - (high - low) * 1.1 / 4;
         break;
      case Woodie:
         p = open;
         r1 = p * 2 - low;
         s1 = p * 2 - high;
         r2 = p + (high - low);
         s2 = p - (high - low);
         r3 = high + 2 * (p - low);
         s3 = low - 2 * (high - p);
         break;
      case Fibonacci:
         p = (high + low + close ) / 3;
         r1 = p+ 0.382 * (high - low);
         s1 =  p- 0.382 * (high - low);
         r2 =  p+ 0.618 *(high - low);
         s2 = p - 0.618 *(high - low);
         r3 = p+ (high - low);
         s3 =  p- (high - low);
         break;
      case Floor:
         p = (high + low + close ) / 3; 
         r1 = p*2+ low;
         s1 =  high;
         r2 =  p+(high - low);
         s2 = p -(high - low);
         r3 = high+ (p - low)*2;
         s3 =  low - (high - p)*2;
         break;
      case Fibonacci_Retracement:
         p = (high + low)/2;
         r1 = low + (high - low) * 0.618;
         s1 = low + (high - low) * 0.382;
         r2 = low+(high - low) * 0.764;
         s2 = low+(high - low) * 0.236;
         r3 = low+(high - low) * 1;
         s3 = low+(high - low) * 0;
         break;
   }
}

void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
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
      ArrayInitialize(bools, EMPTY_VALUE);
      ArrayInitialize(p_arr, EMPTY_VALUE);
      ArrayInitialize(s1_arr, EMPTY_VALUE);
      ArrayInitialize(s2_arr, EMPTY_VALUE);
      ArrayInitialize(s3_arr, EMPTY_VALUE);
      ArrayInitialize(r1_arr, EMPTY_VALUE);
      ArrayInitialize(r2_arr, EMPTY_VALUE);
      ArrayInitialize(r3_arr, EMPTY_VALUE);
      ArrayInitialize(ms1_arr, EMPTY_VALUE);
      ArrayInitialize(ms2_arr, EMPTY_VALUE);
      ArrayInitialize(ms3_arr, EMPTY_VALUE);
      ArrayInitialize(mr1_arr, EMPTY_VALUE);
      ArrayInitialize(mr2_arr, EMPTY_VALUE);
      ArrayInitialize(mr3_arr, EMPTY_VALUE);
   }
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      if (Zero)
      {
         ObjectCreate(0, EAName + "Pivot", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Pivot", "                 Pivot Point", fontsize, "Arial", LabelColor);
      }
      if (One)
      {
         ObjectCreate(0, EAName + "Sup1", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup1", "      S 1", fontsize, "Arial", LabelColor);
         ObjectCreate(0, EAName + "Res1", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res1", "      R 1", fontsize, "Arial", LabelColor);
         
         if (Show_MS_Level)
         {
            ObjectCreate(0, EAName + "MSup1", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup1", "      MS 1", fontsize, "Arial", LabelColor);
         }
         
         if(Show_MR_Level)
         {
            ObjectCreate(0, EAName + "MRes1", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes1", "      MR 1", fontsize, "Arial", LabelColor);
         }
      }
      if (Two)
      { 
         ObjectCreate(0, EAName + "Sup2", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup2", "      S 2", fontsize, "Arial", LabelColor);
         ObjectCreate(0, EAName + "Res2", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res2", "      R 2", fontsize, "Arial", LabelColor);
         if(Show_MR_Level)
         {
            ObjectCreate(0, EAName + "MSup2", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup2", "      MS 2", fontsize, "Arial", LabelColor);
         }
         if(Show_MR_Level)
         {
            ObjectCreate(0, EAName + "MRes2", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes2", "      MR 2", fontsize, "Arial", LabelColor);
         }
      }
      if (Three)
      {
         ObjectCreate(0, EAName + "Sup3", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Sup3", "      S 3", fontsize, "Arial", LabelColor);
         ObjectCreate(0, EAName + "Res3", OBJ_TEXT, 0, 0, 0);
         ObjectSetText(EAName + "Res3", "      R 3", fontsize, "Arial", LabelColor);
         if(Show_MR_Level)
         {
            ObjectCreate(0, EAName + "MSup3", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MSup3", "      MS 3", fontsize, "Arial", LabelColor);
         }
         if(Show_MR_Level)
         {
            ObjectCreate(0, EAName + "MRes3", OBJ_TEXT, 0, 0, 0);
            ObjectSetText(EAName + "MRes3", "      MR 3", fontsize, "Arial", LabelColor);
         }
      }
      if (Mode == History)
      {
         DrawHistory(oldPos);
      }
   }
   if (Mode == Today)
   {
      time1 = iTime(NULL,period, 0);  
      time2 = time1 + (time1 - iTime(NULL,period, 1));
      DrawToday(0);
   }
   return rates_total;
}
      
void DrawHistory(const int i)
{
   double p;
   double s1;
   double s2;
   double s3;
   double r1;
   double r2;
   double r3;
   int btf_i = iBarShift(NULL, period, iTime(NULL, _Period, i));
   CalcPivot(btf_i, p, s1, s2, s3, r1, r2, r3);
   if (Zero)
   {
      p_arr[i] = p;
   }
   if (One)
   {
      s1_arr[i] = s1;
      r1_arr[i] = r1;
   }
   if (Two)
   {
      s2_arr[i] = s2;
      r2_arr[i] = r2;
   }
   if (Three)
   {
      s3_arr[i] = s3;
      r3_arr[i] = r3;
   }
   if (Show_MR_Level)
   {
      mr1_arr[i] = p + (r1 - p) / 2;
      mr2_arr[i] = r1+(r2-r1)/2;
      mr3_arr[i] = r2+(r3-r2)/2;
   }
   if (Show_MS_Level)
   {
      ms1_arr[i] = p-(p-s1)/2;
      ms2_arr[i] = s1-(s1-s2)/2;
      ms3_arr[i] = s2-(s2-s3)/2;
   }
}

void DrawToday(const int i)
{
   double p;
   double s1;
   double s2;
   double s3;
   double r1;
   double r2;
   double r3;
   CalcPivot(i, p, s1, s2, s3, r1, r2, r3);

   MR1=p+(r2-p)/2;
   MR2=r1+(r2-r1)/2;
   MR3=r2+(r3-r2)/2;
   
   MS1=p-(p-s1)/2;
   MS2=s1-(s1-s2)/2;
   MS3=s2-(s2-s3)/2;
   ObjectMove(0, EAName + "Pivot", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), p);
   ObjectMove(0, EAName + "Sup1", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), s1);
   ObjectMove(0, EAName + "Res1", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), r1);
   ObjectMove(0, EAName + "Sup2", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), s2);
   ObjectMove(0, EAName + "Res2", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), r2);
   ObjectMove(0, EAName + "Sup3", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), s3);
   ObjectMove(0, EAName + "Res3", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), r3);    

   if(Show_MR_Level)
   {
      ObjectMove(0, EAName + "MSup1", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MS1);
      ObjectMove(0, EAName + "MSup2", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MS2);
      ObjectMove(0, EAName + "MSup3", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MS3);
   }
   
   if(Show_MS_Level)
   {
      ObjectMove(0, EAName + "MRes1", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MR1);   
      ObjectMove(0, EAName + "MRes2", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MR2);
      ObjectMove(0, EAName + "MRes3", 0, iTime(_Symbol, (ENUM_TIMEFRAMES)_Period, i), MR3);    
   }
   
   if (Zero)
   {
      PlotLine(EAName + "PP["+i+"]",p,PivotColor,PivotStyle);
   }
   if (One)
   {
      PlotLine(EAName + "R1["+i+"]",r1,R1Color,R1Style);
      PlotLine(EAName + "S1["+i+"]",s1,S1Color,S1Style);
      if(Show_MR_Level)
      {
         PlotLine(EAName + "MR1["+i+"]",MR1,MR1Color,MR1Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS1["+i+"]",MS1,MS1Color,MS1Style);
      }
   }
   if (Two)
   {
      PlotLine(EAName + "R2["+i+"]",r2,R2Color,R2Style);
      PlotLine(EAName + "S2["+i+"]",s2,S2Color,S2Style);
      
      if(Show_MR_Level)
      {
         PlotLine(EAName + "MR2["+i+"]",MR2,MR2Color,MR2Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS2["+i+"]",MS2,MS2Color,MS2Style);
      }
   }

   if (Three)
   {
      PlotLine(EAName + "R3["+i+"]",r3,R3Color,R3Style);
      PlotLine(EAName + "S3["+i+"]",s3,S3Color,S3Style);
      if(Show_MR_Level)
      {  
         PlotLine(EAName + "MR3["+i+"]",MR3,MR3Color,MR3Style);
      }
      if(Show_MS_Level)
      {
         PlotLine(EAName + "MS3["+i+"]",MS3,MS3Color,MS3Style);
      }
   }
   bools[i] = 1;
}
//+------------------------------------------------------------------+