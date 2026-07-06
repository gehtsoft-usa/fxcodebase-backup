// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70512

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
#property version   "1.0"

#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots 4
#property  indicator_color1  Green
#property  indicator_color2  Red
#property  indicator_color3  Gold
#property  indicator_color4  Aqua
#property  indicator_minimum 0.0
//----
input int  Sensetive = 150;
input int  DeadZonePip = 30;
input int  ExplosionPower = 15;
input int  TrendPower = 15;
input int bars_limit = 1000; // Bars limit
double   ind_buffer1[];
double   ind_buffer2[];
double   ind_buffer3[];
double   ind_buffer4[];
int LastTime1 = 1;
int LastTime2 = 1;
int LastTime3 = 1;
int LastTime4 = 1;
int Status = 0, PrevStatus = -1;
double bask, bbid;

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

int macd, bb;
void OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("wae");
   IndicatorSetString(INDICATOR_SHORTNAME, "W.A Explosion: [S(" + Sensetive + 
                      ") - DZ(" + DeadZonePip + ") - EP(" + ExplosionPower + 
                      ") - TP(" + TrendPower + ")]");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   macd = iMACD(_Symbol, _Period, 20, 40, 9, PRICE_CLOSE);
   bb = iBands(_Symbol, _Period, 20, 0, 2, PRICE_CLOSE);
   int id = 0;
   SetIndexBuffer(id, ind_buffer1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, ind_buffer2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, ind_buffer3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_SOLID);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, ind_buffer4, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, STYLE_DOT);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
}

void OnDeinit(const int reason)
{
   IndicatorRelease(macd);
   IndicatorRelease(bb);
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
   double Trend1, Trend2, Explo1, Explo2, Dead;
   double pwrt, pwre;
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(ind_buffer1, EMPTY_VALUE);
      ArrayInitialize(ind_buffer2, EMPTY_VALUE);
      ArrayInitialize(ind_buffer3, EMPTY_VALUE);
      ArrayInitialize(ind_buffer4, EMPTY_VALUE);
   }
   int first = 4;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      int oldPos = rates_total - pos - 1;
      double buffer[4];
      if (CopyBuffer(macd, 0, oldPos, 4, buffer) != 4)
      {
         continue;
      }
      Trend1 = (buffer[0] - buffer[1]) * Sensetive;
      Trend2 = (buffer[2] - buffer[3]) * Sensetive;
      double bbup[1];
      if (CopyBuffer(bb, UPPER_BAND, oldPos, 1, bbup) != 1)
      {
         continue;
      }
      double bbdn[1];
      if (CopyBuffer(bb, LOWER_BAND, oldPos, 1, bbdn) != 1)
      {
         continue;
      }
      if(Trend1 >= 0)
         ind_buffer1[pos] = Trend1;
      if(Trend1 < 0)
         ind_buffer2[pos] = (-1 * Trend1);
      ind_buffer3[pos] = (bbup[0] - bbdn[0]);
      ind_buffer4[pos] = Point() * DeadZonePip;
      // if (i == 0)
      // {
      //    if(Trend1 > 0 && Trend1 > Explo1 && Trend1 > Dead && 
      //       Explo1 > Dead && Explo1 > Explo2 && Trend1 > Trend2 && 
      //       LastTime1 < AlertCount && AlertLong == true && Ask != bask)
      //    {
      //       pwrt = 100*(Trend1 - Trend2) / Trend1;
      //       pwre = 100*(Explo1 - Explo2) / Explo1;
      //       bask = Ask;
      //       if(pwre >= ExplosionPower && pwrt >= TrendPower)
      //       {
      //          if(AlertWindow == true)
      //          {
      //             Alert(LastTime1, "- ", Symbol(), " - BUY ", " (", 
      //                   DoubleToStr(bask, Digits) , ") Trend PWR " , 
      //                   DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
      //          }
      //          else
      //          {
      //             Print(LastTime1, "- ", Symbol(), " - BUY ", " (", 
      //                   DoubleToStr(bask, Digits), ") Trend PWR ", 
      //                   DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
      //          }
      //          LastTime1++;
      //       }
      //       Status = 1;
      //    }
      //    if(Trend1 < 0 && MathAbs(Trend1) > Explo1 && MathAbs(Trend1) > Dead && 
      //       Explo1 > Dead && Explo1 > Explo2 && MathAbs(Trend1) > MathAbs(Trend2) && 
      //       LastTime2 < AlertCount && AlertShort == true && Bid != bbid)
      //    {
      //       pwrt = 100*(MathAbs(Trend1) - MathAbs(Trend2)) / MathAbs(Trend1);
      //       pwre = 100*(Explo1 - Explo2) / Explo1;
      //       bbid = Bid;
      //       if(pwre >= ExplosionPower && pwrt >= TrendPower)
      //       {
      //          if(AlertWindow == true)
      //          {
      //             Alert(LastTime2, "- ", Symbol(), " - SELL ", " (", 
      //                   DoubleToStr(bbid, Digits), ") Trend PWR ", 
      //                   DoubleToStr(pwrt,0), " - Exp PWR ", DoubleToStr(pwre, 0));
      //          }
      //          else
      //          {
      //             Print(LastTime2, "- ", Symbol(), " - SELL ", " (", 
      //                   DoubleToStr(bbid, Digits), ") Trend PWR " , 
      //                   DoubleToStr(pwrt, 0), " - Exp PWR ", DoubleToStr(pwre, 0));
      //          }
      //          LastTime2++;
      //       }
      //       Status = 2;
      //    }
      //    if(Trend1 > 0 && Trend1 < Explo1 && Trend1 < Trend2 && Trend2 > Explo2 && 
      //       Trend1 > Dead && Explo1 > Dead && LastTime3 <= AlertCount && 
      //       AlertExitLong == true && Bid != bbid)
      //    {
      //       bbid = Bid;
      //       if(AlertWindow == true)
      //       {
      //          Alert(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
      //                DoubleToStr(bbid, Digits));
      //       }
      //       else
      //       {
      //          Print(LastTime3, "- ", Symbol(), " - Exit BUY ", " ", 
      //                DoubleToStr(bbid, Digits));
      //       }
      //       Status = 3;
      //       LastTime3++;
      //    }
      //    if(Trend1 < 0 && MathAbs(Trend1) < Explo1 && 
      //       MathAbs(Trend1) < MathAbs(Trend2) && MathAbs(Trend2) > Explo2 && 
      //       Trend1 > Dead && Explo1 > Dead && LastTime4 <= AlertCount && 
      //       AlertExitShort == true && Ask != bask)
      //    {
      //       bask = Ask;
      //       if(AlertWindow == true)
      //       {
      //          Alert(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
      //                DoubleToStr(bask, Digits));
      //       }
      //       else
      //       {
      //          Print(LastTime4, "- ", Symbol(), " - Exit SELL ", " ", 
      //                DoubleToStr(bask, Digits));
      //       }
      //       Status = 4;
      //       LastTime4++;
      //    }
      //    PrevStatus = Status;
      // }
      if(Status != PrevStatus)
      {
         LastTime1 = 1;
         LastTime2 = 1;
         LastTime3 = 1;
         LastTime4 = 1;
      }
   }
   return rates_total;
}