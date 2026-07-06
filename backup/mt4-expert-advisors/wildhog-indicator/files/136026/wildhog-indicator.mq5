// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70184

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

#property strict

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots 5
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_color4  LimeGreen
#property indicator_color5  Magenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

input int    Length                    = 8;
input double Overbought_Level          = 60.0;
input double Oversold_Level            = 40.0;
input int    DivergearrowSize          = 1; 
input double DivergencearrowsUpperGap  = 4;
input double DivergencearrowsLowerGap  = 4;
input bool   drawDivergences           = true;
input bool   ShowClassicalDivergence   = true;
input bool   ShowHiddenDivergence      = true;
input bool   drawIndicatorTrendLines   = true;
input bool   drawPriceTrendLines       = true;
input color  divergenceBullishColor    = DeepSkyBlue;
input color  divergenceBearishColor    = DeepPink;
input string drawLinesIdentificator    = "whdiverge1";
input bool   divergenceAlert           = true;
input bool   divergenceAlertsMessage   = true;
input bool   divergenceAlertsSound     = true;
input bool   divergenceAlertsEmail     = false;
input bool   divergenceAlertsNotify    = false;
input string divergenceAlertsSoundName = "alert1.wav";

double Wildhog[];
double whda[];
double whdb[];
double bullishDivergence[];
double bearishDivergence[];
double slope[];

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

void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("whi");
   IndicatorSetString(INDICATOR_SHORTNAME, "Wildhog");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, Wildhog, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   ++id;
   SetIndexBuffer(id, whda, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   ++id;
   SetIndexBuffer(id, whdb, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   ++id;
   SetIndexBuffer(id, bullishDivergence, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_ARROW, 233);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   ++id;
   SetIndexBuffer(id, bearishDivergence, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_ARROW, 234);
   PlotIndexSetInteger(id, PLOT_ARROW_SHIFT, 5);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_ARROW);
   ++id;
   SetIndexBuffer(id, slope, INDICATOR_DATA);
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
      ArrayInitialize(Wildhog, 0);
      ArrayInitialize(whda, EMPTY_VALUE);
      ArrayInitialize(whdb, EMPTY_VALUE);
      ArrayInitialize(slope, EMPTY_VALUE);
   }
   int first = MathMax(Length, 3);
   for (int pos = MathMax(first, prev_calculated - 1); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      int lowestIndex = iLowest(_Symbol, _Period, MODE_LOW, Length, oldPos);
      double Min = iLow(_Symbol, _Period, lowestIndex);
      int highestIndex = iHighest(_Symbol, _Period, MODE_HIGH, Length, oldPos);
      double Max = iHigh(_Symbol, _Period, highestIndex);
      Wildhog[pos] = Max != Min ? 100 * (close[pos] - Min) / (3 * (Max - Min)) + Wildhog[pos - 1] / 1.5 : 0;
      whda[pos] = EMPTY_VALUE;
      whdb[pos] = EMPTY_VALUE;  
      slope[pos] = slope[pos - 1];
      if (Wildhog[pos] > Wildhog[pos - 1])
         slope[pos] = 1;
      if (Wildhog[pos] < Wildhog[pos - 1])
         slope[pos] =-1;
      if (slope[pos] == -1)
         PlotPoint(pos, whda, whdb, Wildhog); 
      if (drawDivergences)
      {
         CatchBullishDivergence(oldPos, rates_total);
         CatchBearishDivergence(oldPos, rates_total);
      }             
   }
   return rates_total;
}

void CleanPoint(int i, double& first[], double& second[])
{
   if (second[i] != EMPTY_VALUE && second[i - 1] != EMPTY_VALUE)
      second[i - 1] = EMPTY_VALUE;
   else if (first[i] != EMPTY_VALUE && first[i - 1] != EMPTY_VALUE && first[i - 2] == EMPTY_VALUE)
      first[i - 1] = EMPTY_VALUE;
}

void PlotPoint(int i, double& first[], double& second[], double& from[])
{
   if (first[i - 1] == EMPTY_VALUE)
   {
      if (first[i - 2] == EMPTY_VALUE) 
      {
         first[i] = from[i];
         first[i - 1] = from[i - 1];
         second[i] = EMPTY_VALUE;
      }
      else 
      {
         second[i] = from[i];
         second[i - 1] = from[i - 1];
         first[i] = EMPTY_VALUE;
      }
   }
   else
   {
      first[i] = from[i];
      second[i] = EMPTY_VALUE;
   }
}

void CatchBullishDivergence(int shift, int rates_total)
{
   shift++;
   bullishDivergence[rates_total - 1 - shift] = EMPTY_VALUE;
   if (!IsIndicatorLow(shift, rates_total))
      return;  
      
   int currentLow = shift;
   int lastLow = GetIndicatorLastLow(shift + 1, rates_total);
   if (lastLow == -1)
   {
      return;
   }

   if (Wildhog[rates_total - 1 - currentLow] > Wildhog[rates_total - 1 - lastLow] && iLow(_Symbol, 0, currentLow) < iLow(_Symbol, 0, lastLow))
   {
      if (ShowClassicalDivergence)
      {
         bullishDivergence[rates_total - 1 - currentLow] = Wildhog[rates_total - 1 - currentLow] - DivergencearrowsLowerGap;
         if (drawPriceTrendLines)
            DrawPriceTrendLine("l", iTime(_Symbol, 0, currentLow), iTime(_Symbol, 0, lastLow), iLow(_Symbol, _Period, currentLow), iLow(_Symbol, _Period, lastLow),            divergenceBullishColor,STYLE_SOLID);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("l", iTime(_Symbol, 0, currentLow), iTime(_Symbol, 0, lastLow), Wildhog[rates_total - 1 - currentLow],Wildhog[rates_total - 1 - lastLow],divergenceBullishColor,STYLE_SOLID);
         if (divergenceAlert)
            DisplayAlert("Classical bullish divergence",currentLow);  
      }
   }
        
   if (Wildhog[rates_total - 1 - currentLow] < Wildhog[rates_total - 1 - lastLow] && iLow(_Symbol, _Period, currentLow) > iLow(_Symbol, _Period, lastLow))
   {
      if (ShowHiddenDivergence)
      {
         bullishDivergence[rates_total - 1 - currentLow] = Wildhog[rates_total - 1 - currentLow] - DivergencearrowsLowerGap;
         if (drawPriceTrendLines)
            DrawPriceTrendLine("l", iTime(_Symbol, 0, currentLow), iTime(_Symbol, 0, lastLow), iLow(_Symbol, _Period, currentLow), iLow(_Symbol, _Period, lastLow),            divergenceBullishColor,STYLE_DOT);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("l", iTime(_Symbol, 0, currentLow), iTime(_Symbol, 0, lastLow), Wildhog[rates_total - 1 - currentLow],Wildhog[rates_total - 1 - lastLow],divergenceBullishColor,STYLE_DOT);
         if (divergenceAlert)
            DisplayAlert("Hidden bullish divergence",currentLow); 
      }
   }
}

void CatchBearishDivergence(int shift, int rates_total)
{
   shift++; 
   bearishDivergence[rates_total - 1 - shift] = EMPTY_VALUE;
   if(IsIndicatorPeak(shift, rates_total) == false) 
      return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift + 1, rates_total);
   if (lastPeak == -1)
   {
      return;
   }
      
   if (Wildhog[rates_total - 1 - currentPeak] < Wildhog[rates_total - 1 - lastPeak] && iHigh(_Symbol, _Period, currentPeak) > iHigh(_Symbol, _Period, lastPeak))
   {
      if (ShowClassicalDivergence)
      {
         bearishDivergence[rates_total - 1 - currentPeak] = Wildhog[rates_total - 1 - currentPeak] + DivergencearrowsUpperGap;
         if (drawPriceTrendLines)
            DrawPriceTrendLine("h", iTime(_Symbol, 0, currentPeak), iTime(_Symbol, 0, lastPeak), iHigh(_Symbol, _Period, currentPeak), iHigh(_Symbol, _Period, lastPeak),          divergenceBearishColor,STYLE_SOLID);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("h", iTime(_Symbol, 0, currentPeak), iTime(_Symbol, 0, lastPeak), Wildhog[rates_total - 1 - currentPeak],Wildhog[rates_total - 1 - lastPeak],divergenceBearishColor,STYLE_SOLID);
         if (divergenceAlert)
            DisplayAlert("Classical bearish divergence",currentPeak);
      } 
   }

   if (Wildhog[rates_total - 1 - currentPeak] > Wildhog[rates_total - 1 - lastPeak] && iHigh(_Symbol, _Period, currentPeak) < iHigh(_Symbol, _Period, lastPeak))
   {
      if (ShowHiddenDivergence)
      {
         bearishDivergence[rates_total - 1 - currentPeak] = Wildhog[rates_total - 1 - currentPeak] + DivergencearrowsUpperGap;
         if (drawPriceTrendLines)
            DrawPriceTrendLine("h", iTime(_Symbol, 0, currentPeak), iTime(_Symbol, 0, lastPeak), iHigh(_Symbol, _Period, currentPeak), iHigh(_Symbol, _Period, lastPeak),          divergenceBearishColor,STYLE_DOT);
         if (drawIndicatorTrendLines)
            DrawIndicatorTrendLine("h", iTime(_Symbol, 0, currentPeak),iTime(_Symbol, 0, lastPeak) ,Wildhog[rates_total - 1 - currentPeak],Wildhog[rates_total - 1 - lastPeak],divergenceBearishColor,STYLE_DOT);
         if (divergenceAlert)
            DisplayAlert("Hidden bearish divergence",currentPeak);
      }
   }   
}

bool IsIndicatorPeak(int shift, int rates_total)
{
   return Wildhog[rates_total - 1 - shift] >= Wildhog[rates_total - 1 - shift - 1] && Wildhog[rates_total - 1 - shift] > Wildhog[rates_total - 1 - shift - 2] && Wildhog[rates_total - 1 - shift] > Wildhog[rates_total - 1 - shift + 1];
}

bool IsIndicatorLow(int shift, int rates_total)
{
   return Wildhog[rates_total - 1 - shift] <= Wildhog[rates_total - 1 - shift - 1] && Wildhog[rates_total - 1 - shift] < Wildhog[rates_total - 1 - shift - 2] && Wildhog[rates_total - 1 - shift] < Wildhog[rates_total - 1 - shift + 1];
}

int GetIndicatorLastPeak(int shift, int rates_total)
{
   for(int i = shift + 5; i < rates_total - 2; i++)
   {
      if(Wildhog[rates_total - 1 - i] >= Wildhog[rates_total - 1 - i - 1] && Wildhog[rates_total - 1 - i] > Wildhog[rates_total - 1 - i - 2] && Wildhog[rates_total - 1 - i] >= Wildhog[rates_total - 1 - i + 1] && Wildhog[rates_total - 1 - i] > Wildhog[rates_total - 1 - i + 2])
         return(i);
   }
   return(-1);
}

int GetIndicatorLastLow(int shift, int rates_total)
{
   for (int i = shift + 5; i < rates_total - 2; i++)
   {
      if (Wildhog[rates_total - 1 - i] <= Wildhog[rates_total - 1 - i - 1] && Wildhog[rates_total - 1 - i] < Wildhog[rates_total - 1 - i - 2] && Wildhog[rates_total - 1 - i] <= Wildhog[rates_total - 1 - i + 1] && Wildhog[rates_total - 1 - i] < Wildhog[rates_total - 1 - i + 2])
         return(i);
   }
      
   return(-1);
}

void DisplayAlert(string doWhat, int shift)
{
   string dmessage;
   static datetime lastAlertTime;
   if(shift <= 2 && iTime(_Symbol, 0, 0) != lastAlertTime)
   {
      dmessage =  _Symbol + " at " + TimeToString(TimeLocal(),TIME_SECONDS) + " Wildhog " + doWhat;
      if (divergenceAlertsMessage) Alert(dmessage);
      if (divergenceAlertsNotify)  SendNotification(dmessage);
      if (divergenceAlertsEmail)   SendMail(_Symbol + " Wildhog ", dmessage);
      if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
      lastAlertTime = iTime(_Symbol, 0, 0);
   }
}

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string id = IndicatorObjPrefix + first + "os" + TimeToString(t1, 0);
   if (ObjectFind(0, id) == -1)
   {
      if (ObjectCreate(0, id, OBJ_TREND, 0, t1, p1, t2, p2))
      {
         ObjectSetInteger(0, id, OBJPROP_COLOR, lineColor);
         ObjectSetInteger(0, id, OBJPROP_STYLE, style);
         ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, 0);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, 0);
      }
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, id, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 1, p2);
}

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = ChartWindowFind();
   if (indicatorWindow < 0)
      return;

   string id = IndicatorObjPrefix + first + TimeToString(t1, 0);
   if (ObjectFind(0, id) == -1)
   {
      if (ObjectCreate(0, id, OBJ_TREND, indicatorWindow, t1, p1, t2, p2))
      {
         ObjectSetInteger(0, id, OBJPROP_COLOR, lineColor);
         ObjectSetInteger(0, id, OBJPROP_STYLE, style);
         ObjectSetInteger(0, id, OBJPROP_RAY_LEFT, 0);
         ObjectSetInteger(0, id, OBJPROP_RAY_RIGHT, 0);
      }
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, 0, t1);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 0, p1);
   ObjectSetInteger(0, id, OBJPROP_TIME, 1, t2);
   ObjectSetDouble(0, id, OBJPROP_PRICE, 1, p2);
}
