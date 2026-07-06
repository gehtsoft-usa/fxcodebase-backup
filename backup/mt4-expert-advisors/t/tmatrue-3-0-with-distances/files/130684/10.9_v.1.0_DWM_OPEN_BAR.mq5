// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69307

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input string str                = "Box mode : 'full' or 'split'";
input string stra               = "full will occupy all the height depending on bid position";
input string strb               = "split will split boxes at their timeframe respective open";
input string boxMode            = "split";
input string sepa0              = "---------------------------------";
input string strc               = "RangeBox allow boxes to be defined by an ATR";
input string strd               = "High will be current open + atr";
input string stre               = "Low will be current open - atr";
input bool DWMRangeBox          = true;
input int dailyRangeATR         = 14;
input int weeklyRangeATR        = 14;
input int monthlyRangeATR       = 14;
input string sepa1              = "---------------------------------";
input string strf               = "Colors";
input color bidAboveDailyOpen   = DarkGreen;
input color bidBelowDailyOpen   = Maroon;
input color bidAboveWeeklyOpen  = DarkGreen;
input color bidBelowWeeklyOpen  = Maroon;
input color bidAboveMonthlyOpen = DarkGreen;
input color bidBelowMonthlyOpen = Maroon;
input color blankColor          = DimGray;
input string s2                 = "Size of bars";
input int barSize               = 1;
input int numBarsSpacer         = 1;
input string sepa3              = "---------------------------------";
input string strj               = "Change this to shift bars to the right";
input int shiftRightBars        = 20;
//
string   objPrefix         = "DWMBox_"; // H4 Color Bars
string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}

int atrd1, atrw1, atrmn1;
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("DWM Open bar");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   objPrefix = IndicatorObjPrefix;
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   atrd1 = iATR(_Symbol, PERIOD_D1, dailyRangeATR);
   atrw1 = iATR(_Symbol, PERIOD_W1, weeklyRangeATR);
   atrmn1 = iATR(_Symbol, PERIOD_MN1, monthlyRangeATR);

   return INIT_SUCCEEDED;//INIT_FAILED
}

void OnDeinit(const int reason)
{
   ObjectsDeleteAll(0, IndicatorObjPrefix);
   IndicatorRelease(atrd1);
   IndicatorRelease(atrw1);
   IndicatorRelease(atrmn1);
}

int OnCalculate(const int rates_total,       // size of input time series
                const int prev_calculated,   // number of handled bars at the previous call
                const datetime& time[],      // Time array
                const double& open[],        // Open array
                const double& high[],        // High array
                const double& low[],         // Low array
                const double& close[],       // Close array
                const long& tick_volume[],   // Tick Volume array
                const long& volume[],        // Real Volume array
                const int& spread[]          // Spread array
)
{
   double highdaily, lowdaily, highweekly, lowweekly, highmonthly, lowmonthly;
   
   datetime leftdaily     = time[rates_total - 1] + (Period() * 60 * shiftRightBars);
   datetime rightdaily    = leftdaily+(Period() * 60 * barSize);
   datetime leftweekly    = rightdaily+(Period() * 60 * numBarsSpacer);
   datetime rightweekly   = leftweekly+(Period() * 60 * barSize);
   datetime leftmonthly   = rightweekly+(Period() * 60 * numBarsSpacer);
   datetime rightmonthly  = leftmonthly+(Period() * 60 * barSize);
   
   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if (DWMRangeBox)
   {
      double d1ATR[1];
      if (CopyBuffer(atrd1, 0, 0, 1, d1ATR) != 1)
      {
         return 0;
      }
      double w1ATR[1];
      if (CopyBuffer(atrw1, 0, 0, 1, w1ATR) != 1)
      {
         return 0;
      }
      double mn1ATR[1];
      if (CopyBuffer(atrmn1, 0, 0, 1, mn1ATR) != 1)
      {
         return 0;
      }
      highdaily    = iOpen(Symbol(), PERIOD_D1, 0) + d1ATR[0];
      lowdaily     = iOpen(Symbol(), PERIOD_D1, 0) - d1ATR[0];
      highweekly   = iOpen(Symbol(), PERIOD_W1, 0) + w1ATR[0];
      lowweekly    = iOpen(Symbol(), PERIOD_W1, 0) - w1ATR[0];
      highmonthly  = iOpen(Symbol(), PERIOD_MN1, 0) + mn1ATR[0];
      lowmonthly   = iOpen(Symbol(), PERIOD_MN1, 0) - mn1ATR[0];
   }
   else
   {
      highdaily    = ChartGetDouble(0, CHART_PRICE_MAX, 0);
      lowdaily     = ChartGetDouble(0, CHART_PRICE_MIN, 0);
      highweekly   = highdaily;
      lowweekly    = lowdaily;
      highmonthly  = highdaily;
      lowmonthly   = lowdaily; 
   }
   
   // daily
   if (boxMode == "full")
   {
      if (Bid >= iOpen(Symbol(), PERIOD_D1, 0))
      {
         doBox(bidAboveDailyOpen, highdaily, leftdaily, lowdaily, rightdaily, 1);
      }
      else if (Bid < iOpen(Symbol(), PERIOD_D1, 0))
      {
         doBox(bidBelowDailyOpen, highdaily, leftdaily, lowdaily, rightdaily, 1);
      }
      else // just in case...
      {
         doBox(CLR_NONE, highdaily, leftdaily, lowdaily, rightdaily, 1);
      } 
      
      if (Bid >= iOpen(Symbol(), PERIOD_W1, 0))
      {
         doBox(bidAboveWeeklyOpen, highweekly, leftweekly, lowweekly, rightweekly ,3);
      }
      else if (Bid < iOpen(Symbol(), PERIOD_W1, 0))
      {
         doBox(bidBelowWeeklyOpen, highweekly, leftweekly, lowweekly, rightweekly, 3);
      }
      else // just in case...
      {
         doBox(CLR_NONE, highweekly, leftweekly, lowweekly, rightweekly, 3);
      }  
      
      if (Bid >= iOpen(Symbol(), PERIOD_MN1, 0))
      {
         doBox(bidAboveMonthlyOpen, highmonthly, leftmonthly, lowmonthly, rightmonthly, 5);
      }
      else if (Bid < iOpen(Symbol(), PERIOD_MN1, 0))
      {
         doBox(bidBelowMonthlyOpen, highmonthly, leftmonthly, lowmonthly, rightmonthly, 5);
      }
      else // just in case...
      {
         doBox(CLR_NONE, highmonthly, leftmonthly, lowmonthly, rightmonthly, 5);
      } 
         
   }
   else if(boxMode == "split")
   {
      doBox(bidAboveDailyOpen, highdaily, leftdaily, iOpen(Symbol(), PERIOD_D1, 0), rightdaily, 1);
      doBox(bidBelowDailyOpen, iOpen(Symbol(), PERIOD_D1, 0), leftdaily, lowdaily, rightdaily, 2);
      doBox(bidAboveWeeklyOpen, highweekly, leftweekly, iOpen(Symbol(), PERIOD_W1, 0), rightweekly, 3);
      doBox(bidBelowWeeklyOpen, iOpen(Symbol(), PERIOD_W1, 0), leftweekly, lowweekly, rightweekly, 4);
      doBox(bidAboveMonthlyOpen, highmonthly, leftmonthly, iOpen(Symbol(), PERIOD_MN1, 0), rightmonthly, 5);
      doBox(bidBelowMonthlyOpen, iOpen(Symbol(), PERIOD_MN1, 0), leftmonthly, lowmonthly, rightmonthly, 6);
   }

   return rates_total;
}

void doBox(color mColor, double high, datetime left, double low, datetime right, int i)
{
   bool created = ObjectCreate(0, objPrefix+i,OBJ_RECTANGLE, 0, left, high, right, low);
   if (!created)
   {
      ObjectSetInteger(0, objPrefix+i,OBJPROP_TIME, 0, left);
      ObjectSetDouble(0, objPrefix+i,OBJPROP_PRICE, 0, high);
      ObjectSetInteger(0, objPrefix+i,OBJPROP_TIME, 1, right);
      ObjectSetDouble(0, objPrefix+i,OBJPROP_PRICE, 1, low);
   }
   ObjectSetInteger(0, objPrefix+i, OBJPROP_COLOR, mColor);  
   ObjectSetInteger(0, objPrefix+i, OBJPROP_BACK, true);
   ObjectSetInteger(0, objPrefix+i, OBJPROP_STYLE, STYLE_SOLID);
   
   if (mColor == CLR_NONE)
   {
      ObjectSetInteger(0, objPrefix+i, OBJPROP_COLOR, blankColor);
      ObjectSetInteger(0, objPrefix+i, OBJPROP_BACK, true);
      ObjectSetInteger(0, objPrefix+i, OBJPROP_STYLE, STYLE_DOT);
   }
}
