// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71664

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
//|SOL Address            : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                           |
//|Cardano/ADA            : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv             |  
//|Dogecoin Address       : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                     |
//|SHIB Address           : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                             |                                
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 White
#property indicator_color2 Blue
#property indicator_color3 Yellow
#include <Controls/Button.mqh>
CButton Boton;

int           average               = 3;
double        till_breakeven_rate   = 30;
double        breakeven_buffer1     = 0;
extern string SetOne                = "**********************Set_One_Settings***************";
extern double space1                = 1;
extern double expand_rate1          = 35;
extern string SetTwo                = "**********************Set_Two_Settings***************";
double        start_at_pips_profit2 = 50;
extern double space2                = 1;
extern double expand_rate2          = 50;
extern string SetThree              = "**********************Set_Three_Settings***********";
double        start_at_pips_profit3 = 100;
extern double space3                = 1;
extern double expand_rate3          = 65;

//                                                        DESCRIPTION OF SETTINGS (Please note, ALL recommendations are only for GBP/USD)
//
//   till_breakeven_rate : Determines how closely the channel will follow the price till the trade breaks even.                                   RECOMMEND 1
//                space1 : Determines the width of the channel from the beginning of a trade till profit is greater than start_at_pips_profit2.   RECOMMEND 3-5
//                         Each standard deviation is equal to 6 pips. It should be wider than space2 and space3 so the trade has
//                         room to grow when it is first opened.
//          expand_rate1 : Determines how closely the channel will follow the price after the trade has broken even.                              RECOMMEND 20-60
// start_at_pips_profit2 : Determines how many pips of profit the trade must be in before following the second group of settings.                 RECOMMEND 40-60
//                space2 : Determines the width of the channel after profit is greater than start_at_pips_profit2.                                RECOMMEND 1.5-3
//                         Each standard deviation is equal to 6 pips. It should be less than space1 but greater than space3.
//          expand_rate2 : Determines how closely the channel will follow the price after profit is greater than start_at_pips_profit2.           RECOMMEND 50-100
// start_at_pips_profit3 : Determines how many pips of profit the trade must be in before following the third group of settings.                  RECOMMEND 100+
//                space3 : Determines the width of the channel after profit is greater than start_at_pips_profit3.                                RECOMMEND 0.5-3
//                         Each standard deviation is equal to 6 pips. It should greater than space1.
//          expand_rate3 : Determines how closely the channel will follow the price after profit is greater than start_at_pips_profit3.           RECOMMEND 100+

double AverageFX[];
double Top[];
double Bottom[];

int    max, order;
double bed, tal, atr, step, deviation, bu, sl, maxlow, maxhigh, isranging, istime, cat, dif, breakeven_bufferX, spaceX, expand_rateX, profitX = 0, till_breakeven_rateX;
bool   ranging;

bool hideIndicator = false;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   max = 50;

   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(0, AverageFX);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, Top);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, Bottom);

   SetIndexDrawBegin(0, max);
   SetIndexDrawBegin(1, max);
   SetIndexDrawBegin(2, max);

   if (Digits == 5 || Digits == 3)
   {
      dif = Point * 10;
   } else
      dif = Point;

   //---
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   Boton.Create(0, "Boton", 0, 5, 100, 100, 125);  //
   Boton.Text("Easy Forex Pips");
   Boton.Color(clrLightGray);
   Boton.ColorBackground(clrBlack);
   Boton.ColorBorder(C'28, 40, 51');
   Boton.FontSize(9);
   Boton.Font("Calibri");

   return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
{
   if (hideIndicator)
   {
      return 0;
   }

   int    i, k, x, counted_bars = IndicatorCounted(), limit;
   double buffer, sum, newres, BandsDeviation, distance, sub, expandingx = till_breakeven_rate, mh;
   bool   condition1 = false;

   if (Bars <= max)
   {
      return (0);
   }
   if (counted_bars < 1)
      for (i = 1; i <= max; i++)
      {
         AverageFX[Bars - i] = EMPTY_VALUE;
         Top[Bars - i]       = EMPTY_VALUE;
         Bottom[Bars - i]    = EMPTY_VALUE;
      }

   if (counted_bars > 0)
   {
      limit++;
      counted_bars--;
   }
   limit = Bars - counted_bars - 1;

   for (i = 0; i < limit; i++)
      AverageFX[i] = iMA(NULL, 0, average, 0, MODE_EMA, PRICE_CLOSE, i);

   i = Bars - max + 1;
   if (counted_bars > max - 1) i = Bars - counted_bars - 1;
   while (i >= 0)
   {
      if (order == 0)
      {
         profitX = 1;
      }
      if (profitX < start_at_pips_profit2)
      {
         cat               = 1;
         breakeven_bufferX = breakeven_buffer1 * dif;
         spaceX            = space1 * dif;
         expand_rateX      = expand_rate1 * dif;
      }
      if (profitX >= start_at_pips_profit2 && profitX <= start_at_pips_profit3)
      {
         cat               = 2;
         breakeven_bufferX = breakeven_buffer1 * dif;
         spaceX            = space2 * dif;
         expand_rateX      = expand_rate2 * dif;
      }
      if (profitX > start_at_pips_profit3)
      {
         cat               = 3;
         breakeven_bufferX = breakeven_buffer1 * dif;
         spaceX            = space3 * dif;
         expand_rateX      = expand_rate3 * dif;
      }

      buffer               = 6 * spaceX;
      till_breakeven_rateX = till_breakeven_rate * dif;

      if ((order == 1) && (step < (bu + breakeven_bufferX)))
      {
         expandingx = till_breakeven_rateX;
      }
      if ((order == 1) && (step > (bu + breakeven_bufferX)))
      {
         expandingx = expand_rateX;
      }
      if ((order == 2) && (step > (sl - breakeven_bufferX)))
      {
         expandingx = till_breakeven_rateX;
      }
      if ((order == 2) && (step < (sl - breakeven_bufferX)))
      {
         expandingx = expand_rateX;
      }

      if (order == 0)
      {
         step = AverageFX[i] - till_breakeven_rateX;
      }
      if (order == 1)
      {  // Buy
         if ((AverageFX[i] > step) && MathAbs(AverageFX[i] - step) > expandingx)
         {
            step = AverageFX[i] - expandingx;
         }
      }
      if (order == 2)
      {  // Sell
         if ((AverageFX[i] < step) && MathAbs(AverageFX[i] - step) > expandingx)
         {
            step = AverageFX[i] + expandingx;
         }
      }

      if (order == 1)
      {
         Top[i]    = step;
         Bottom[i] = step - buffer;
      }
      if (order == 2)
      {
         Top[i]    = step + buffer;
         Bottom[i] = step;
      }

      if (AverageFX[i] > Top[i])
      {
         order = 1;
         if (bu == 0)
         {
            bu      = AverageFX[i];
            sl      = 0;
            profitX = 0;
         }
      }
      if (AverageFX[i] < Bottom[i])
      {
         order = 2;
         if (sl == 0)
         {
            sl      = AverageFX[i];
            bu      = 0;
            profitX = 0;
         }
      }

      if (order == 1)
      {
         if (NormalizeDouble(MathAbs(AverageFX[i] - bu) * 10000, 0) > profitX)
         {
            profitX = NormalizeDouble(MathAbs(AverageFX[i] - bu) * 10000, 0);
         }
      }
      if (order == 2)
      {
         if (NormalizeDouble(MathAbs(AverageFX[i] - sl) * 10000, 0) > profitX)
         {
            profitX = NormalizeDouble(MathAbs(AverageFX[i] - sl) * 10000, 0);
         }
      }

      i--;
   }

   return (rates_total);
}

void OnChartEvent(const int     id,
                  const long&   lparam,
                  const double& dparam,
                  const string& sparam)
{
   if (id == CHARTEVENT_OBJECT_CLICK && sparam == "Boton")
   {
      HideIndicator();
   }

   //DETECTAR QUE LE MOUSE ESTÁ UBICADO SOBRE EL BOTON:
   long izq   = ObjectGetInteger(0, "Boton", OBJPROP_XDISTANCE);
   long der   = izq + ObjectGetInteger(0, "Boton", OBJPROP_XSIZE);
   long top   = ObjectGetInteger(0, "Boton", OBJPROP_YDISTANCE);
   long botom = top + ObjectGetInteger(0, "Boton", OBJPROP_YSIZE);

   if (lparam > izq && lparam < der && dparam > top && dparam < botom)
   {
      Boton.Color(clrRed);
      Boton.ColorBackground(clrPink);
   } else
   {
      Boton.Color(clrLightGray);
      Boton.ColorBackground(clrBlack);
   }
}

//+------------------------------------------------------------------+
bool HideIndicator()
{
   hideIndicator = !hideIndicator;

   if (hideIndicator)
   {
      SetIndexStyle(1, DRAW_NONE);
      SetIndexStyle(2, DRAW_NONE);
   } else
   {
      SetIndexStyle(1, DRAW_LINE);
      SetIndexStyle(2, DRAW_LINE);
   }

   return hideIndicator;
}