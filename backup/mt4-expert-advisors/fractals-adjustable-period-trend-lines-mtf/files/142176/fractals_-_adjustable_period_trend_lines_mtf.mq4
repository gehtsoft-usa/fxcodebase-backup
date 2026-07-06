// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71211


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


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrPaleVioletRed
#property indicator_width1 2
#property indicator_width2 2
#property strict

input ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT;   // Time frame
input int cci_period = 14;                          // CCI Period
input int FractalPeriod = 25;                       // Fractal period
input double UpperArrowDisplacement = 0.2;          // Upper fractal displacement
input double LowerArrowDisplacement = 0.2;          // Lower fractal displacement
input color UpperCompletedColor = clrDeepSkyBlue;   // Upper trend line completed color
input color UpperUnCompletedColor = clrAqua;        // Upper trend line uncompleted color
input color LowerCompletedColor = clrPaleVioletRed; // Lower trend line completed color
input color LowerUnCompletedColor = clrHotPink;     // Lower trend line uncompleted color
input int CompletedWidth = 2;                       // Completed trend line width
input int UnCompletedWidth = 1;                     // Uncompleted trend line width
input string UniqueID = "FractalTrendLines1";       // Trend line unique ID.
input int bars_limit = 1000; // Bars limit

double UpperBuffer[], LowerBuffer[], count[];
string indicatorFileName;
#define _mtfCall(_buff, _ind) iCustom(NULL, TimeFrame, indicatorFileName, PERIOD_CURRENT, cci_period, FractalPeriod, UpperArrowDisplacement, LowerArrowDisplacement, UpperCompletedColor, UpperUnCompletedColor, LowerCompletedColor, LowerUnCompletedColor, CompletedWidth, UnCompletedWidth, UniqueID, _buff, _ind)

int init()
{
   IndicatorBuffers(3);
   SetIndexBuffer(0, UpperBuffer);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 159);
   SetIndexBuffer(1, LowerBuffer);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 159);
   SetIndexBuffer(2, count);

   indicatorFileName = WindowExpertName();

   return (0);
}
int deinit()
{
   ObjectDelete(UniqueID + "up1");
   ObjectDelete(UniqueID + "up2");
   ObjectDelete(UniqueID + "dn1");
   ObjectDelete(UniqueID + "dn2");
   return (0);
}

int start()
{
   int half = FractalPeriod / 2;
   int i, counted_bars = IndicatorCounted();
   if (counted_bars < 0)
      return (-1);
   if (counted_bars > 0)
      counted_bars--;
   int limit = fmin(fmax(Bars - counted_bars, FractalPeriod), Bars - 1);
   if (TimeFrame != _Period && TimeFrame != PERIOD_CURRENT)
   {
      limit = (int)fmax(limit, fmin(Bars - 1, _mtfCall(2, 0) * TimeFrame / _Period));
      for (i = limit; i >= 0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL, TimeFrame, Time[i]);
         int x = iBarShift(NULL, TimeFrame, Time[i - 1]);
         if (x != y)
         {
            UpperBuffer[i] = _mtfCall(0, y);
            LowerBuffer[i] = _mtfCall(1, y);
         }
         else
         {
            UpperBuffer[i] = EMPTY_VALUE;
            LowerBuffer[i] = EMPTY_VALUE;
         }
      }
      return (0);
   }

   int toSkip = half;
   for (i = MathMin(bars_limit, Bars - 1 - MathMax(IndicatorCounted(), toSkip)); i >= half && !IsStopped(); --i)
   {
      if (i < Bars - 1)
      {
         int k;
         bool found = true;
         double compareTo = iCCI(_Symbol, _Period, cci_period, PRICE_HIGH, i);
         for (k = 1; k <= half; k++)
         {
            if ((i + k) < Bars && iCCI(_Symbol, _Period, cci_period, PRICE_HIGH, i + k) > compareTo)
            {
               found = false;
               break;
            }
            if ((i - k) >= 0 && iCCI(_Symbol, _Period, cci_period, PRICE_HIGH, i - k) >= compareTo)
            {
               found = false;
               break;
            }
         }
         if (found)
            UpperBuffer[i] = iCCI(_Symbol, _Period, cci_period, PRICE_HIGH, i) + iATR(NULL, 0, 20, i) * UpperArrowDisplacement;
         else
            UpperBuffer[i] = EMPTY_VALUE;

         found = true;
         compareTo = iCCI(_Symbol, _Period, cci_period, PRICE_LOW, i);
         for (k = 1; k <= half; k++)
         {
            if ((i + k) < Bars && iCCI(_Symbol, _Period, cci_period, PRICE_LOW, i + k) < compareTo)
            {
               found = false;
               break;
            }
            if ((i - k) >= 0 && iCCI(_Symbol, _Period, cci_period, PRICE_LOW, i - k) <= compareTo)
            {
               found = false;
               break;
            }
         }
         if (found)
            LowerBuffer[i] = iCCI(_Symbol, _Period, cci_period, PRICE_LOW, i) - iATR(NULL, 0, 20, i) * LowerArrowDisplacement;
         else
            LowerBuffer[i] = EMPTY_VALUE;
      }
   }

   int lastUp[3];
   int lastDn[3];
   int dnInd = -1;
   int upInd = -1;
   for (i = 0; i < Bars; i++)
   {
      if (upInd < 2 && UpperBuffer[i] != EMPTY_VALUE)
      {
         upInd++;
         lastUp[upInd] = i;
      }
      if (dnInd < 2 && LowerBuffer[i] != EMPTY_VALUE)
      {
         dnInd++;
         lastDn[dnInd] = i;
      }
      if (upInd == 2 && dnInd == 2)
         break;
   }
   createLine("up1", High[lastUp[1]], Time[lastUp[1]], High[lastUp[0]], Time[lastUp[0]], UpperUnCompletedColor, UnCompletedWidth);
   createLine("up2", High[lastUp[2]], Time[lastUp[2]], High[lastUp[1]], Time[lastUp[1]], UpperCompletedColor, CompletedWidth);
   createLine("dn1", Low[lastDn[1]], Time[lastDn[1]], Low[lastDn[0]], Time[lastDn[0]], LowerUnCompletedColor, UnCompletedWidth);
   createLine("dn2", Low[lastDn[2]], Time[lastDn[2]], Low[lastDn[1]], Time[lastDn[1]], LowerCompletedColor, CompletedWidth);
   return (0);
}

//
//
//
//
//

void createLine(string add, double price1, datetime time1, double price2, datetime time2, color theColor, int width)
{
   string name = UniqueID + add;
   ObjectDelete(name);
   ObjectCreate(name, OBJ_TREND, 0, time1, price1, time2, price2);
   ObjectSet(name, OBJPROP_COLOR, theColor);
   ObjectSet(name, OBJPROP_WIDTH, width);
}

//+-------------------------------------------------------------------
//|
//+-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

string timeFrameToString(int tf)
{
   for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
      if (tf == iTfTable[i])
         return (sTfTable[i]);
   return ("");
}
