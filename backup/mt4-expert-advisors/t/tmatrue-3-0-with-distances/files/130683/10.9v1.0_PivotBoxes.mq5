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
#property indicator_chart_window

input string s1           = "1 = Classic, 2 = Woodie, 3 = Camarilla";
input int pivotType       = 1;
input bool showDaily      = false;
input bool showWeekly     = true;
input bool showMonthly    = false;
input bool focusActiveZone= false;
input color focusRange    = Lime;
input color pivotToR1     = Green;
input color R1ToR2        = DarkGreen;
input color R2ToR3        = DarkSlateGray;
input color R3ToR4        = CLR_NONE;
input color pivotToS1     = Crimson;
input color S1ToS2        = Maroon;
input color S2ToS3        = 70;
input color S3ToS4        = CLR_NONE;
input string s2           = "Size of bars";
input int barSize         = 2;
input int numBarsSpacer   = 1;
input string s3           = "0 = solid, 1 = dash, 2 = dot, 3 = dashdot";
input int boxStyle        = 2;
input bool boxFilled      = true;
input bool boxOnChart     = false;
input int txtFontSize     = 6;
input color txtColor      = White;
input string sepa3        = "---------------------------------";
input string strj         = "Change this to shift bars to the right";
input int shiftRightBars  = 12;

string pipFactor[]  = {"JPY","XAG","SILVER","BRENT","WTI","XAU","GOLD","SP500","S&P","UK100","WS30","DE30","DJ30","NAS100","FRA40", "BCO"};
double pipFactors[] = { 100,  100,  100,     100,    100,  10,   10,    10,     10,   1,      1,     1,      1,     1,       1,       100 };
double factor;

double dailyPivot, dailyRange, dailyR1, dailyR2, dailyR3, dailyR4, dailyS1, dailyS2, dailyS3, dailyS4;
double weeklyPivot, weeklyRange, weeklyR1, weeklyR2, weeklyR3, weeklyR4, weeklyS1, weeklyS2, weeklyS3, weeklyS4;
double monthlyPivot, monthlyRange, monthlyR1, monthlyR2, monthlyR3, monthlyR4, monthlyS1, monthlyS2, monthlyS3, monthlyS4;

//
string   objPrefix         = "DWMPivot_"; // H4 Color Bars
int timeFramesDailyPivot = OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4;
int timeFramesWeeklyPivot = OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4|OBJ_PERIOD_D1;
int timeFramesMonthlyPivot = OBJ_PERIOD_M1|OBJ_PERIOD_M5|OBJ_PERIOD_M15|OBJ_PERIOD_M30|OBJ_PERIOD_H1|OBJ_PERIOD_H4|OBJ_PERIOD_D1|OBJ_PERIOD_W1;

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("PivotBoxes");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   objPrefix = IndicatorObjPrefix;
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   factor = pFactor(); 
   return INIT_SUCCEEDED;//INIT_FAILED
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
   double mHigh = ChartGetDouble(0, CHART_PRICE_MAX, 0);
   double mLow = ChartGetDouble(0, CHART_PRICE_MIN, 0);
   datetime leftBar1, leftBar2, leftBar3, rightBar1, rightBar2, rightBar3;
   datetime dailyX, weeklyX, monthlyX;
   if (boxOnChart)
   {
      leftBar1    = iTime(Symbol(),PERIOD_D1,0);
      rightBar1   = time[rates_total - 1]+(Period()*60*2);
      leftBar2    = iTime(Symbol(),PERIOD_W1,0);
      rightBar2   = time[rates_total - 1]+(Period()*60*6);
      leftBar3    = iTime(Symbol(),PERIOD_MN1,0);
      rightBar3   = time[rates_total - 1]+(Period()*60*10);
      
      dailyX      = rightBar1 + (Period()*60*2);
      weeklyX     = rightBar2 + (Period()*60*2);
      monthlyX    = rightBar3 + (Period()*60*2);
   }
   else
   { 
      leftBar1    = time[rates_total - 1]+(Period()*60*shiftRightBars);
      rightBar1   = leftBar1+(Period()*60*barSize);
      leftBar2    = rightBar1+(Period()*60*numBarsSpacer);
      if (!showDaily && showWeekly) leftBar2 = leftBar1;
      rightBar2   = leftBar2+(Period()*60*barSize);
      
      leftBar3    = rightBar2+(Period()*60*numBarsSpacer);
      if (showDaily && !showWeekly) leftBar3 = leftBar2;
      if (!showDaily && showWeekly) leftBar3 = rightBar1+(Period()*60*numBarsSpacer);
      if (!showDaily && !showWeekly) leftBar3 = leftBar1;
      rightBar3   = leftBar3+(Period()*60*barSize);
      
      dailyX      = leftBar1 + ((rightBar1-leftBar1)/2);
      weeklyX     = leftBar2 + ((rightBar2-leftBar2)/2);
      monthlyX    = leftBar3 + ((rightBar3-leftBar3)/2);
   }

   double Bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   getValues(pivotType);
   if (showDaily)
   {
      doBox(timeFramesDailyPivot, R3ToR4, dailyR4 , leftBar1, dailyR3, rightBar1, 1);
      doBox(timeFramesDailyPivot, R2ToR3, dailyR3, leftBar1, dailyR2, rightBar1, 2);
      doBox(timeFramesDailyPivot, R1ToR2, dailyR2, leftBar1, dailyR1, rightBar1, 3);
      
      doBox(timeFramesDailyPivot, pivotToR1, dailyR1, leftBar1, dailyPivot, rightBar1, 4);
   
      doBox(timeFramesDailyPivot, pivotToS1, dailyPivot, leftBar1, dailyS1, rightBar1, 5);
   
      doBox(timeFramesDailyPivot, S1ToS2, dailyS1, leftBar1, dailyS2, rightBar1, 6);
      doBox(timeFramesDailyPivot, S2ToS3, dailyS2, leftBar1, dailyS3, rightBar1, 7);
      doBox(timeFramesDailyPivot, S3ToS4, dailyS3, leftBar1, dailyS4, rightBar1, 8);
   
   
      if (pivotType==3) doLabel(timeFramesDailyPivot, "DC", txtColor, dailyPivot, dailyX, 50);
      else doLabel(timeFramesDailyPivot, "DP", txtColor, dailyPivot, dailyX, 50);
      doLabel(timeFramesDailyPivot, "DR1", txtColor, dailyR1, dailyX, 51);
      doLabel(timeFramesDailyPivot, "DR2", txtColor, dailyR2, dailyX, 52);
      doLabel(timeFramesDailyPivot, "DR3", txtColor, dailyR3, dailyX, 53);
      doLabel(timeFramesDailyPivot, "DR4", txtColor, dailyR4, dailyX, 54);
      doLabel(timeFramesDailyPivot, "DS1", txtColor, dailyS1, dailyX, 55);
      doLabel(timeFramesDailyPivot, "DS2", txtColor, dailyS2, dailyX, 56);
      doLabel(timeFramesDailyPivot, "DS3", txtColor, dailyS3, dailyX, 57);
      doLabel(timeFramesDailyPivot, "DS4", txtColor, dailyS4, dailyX, 58);
      
      if(focusActiveZone)
      {
         if (Bid>dailyR3 && Bid < dailyR4) focus(objPrefix+IntegerToString(1));
         else unfocus(objPrefix+IntegerToString(1), R3ToR4);
         if (Bid>dailyR2 && Bid < dailyR3) focus(objPrefix+IntegerToString(2));
         else unfocus(objPrefix+IntegerToString(2), R2ToR3);
         if (Bid>dailyR1 && Bid < dailyR2) focus(objPrefix+IntegerToString(3));
         else unfocus(objPrefix+IntegerToString(3), R1ToR2);
         if (Bid>dailyPivot && Bid < dailyR1) focus(objPrefix+IntegerToString(4));
         else unfocus(objPrefix+IntegerToString(4), pivotToR1);
         if (Bid>dailyS1 && Bid < dailyPivot) focus(objPrefix+IntegerToString(5));
         else unfocus(objPrefix+IntegerToString(5), pivotToS1);
         if (Bid>dailyS2 && Bid < dailyS1) focus(objPrefix+IntegerToString(6));
         else unfocus(objPrefix+IntegerToString(6), S1ToS2);
         if (Bid>dailyS3 && Bid < dailyS2) focus(objPrefix+IntegerToString(7));
         else unfocus(objPrefix+IntegerToString(7), S2ToS3);
         if (Bid>dailyS4 && Bid < dailyS3) focus(objPrefix+IntegerToString(8));
         else unfocus(objPrefix+IntegerToString(8), S3ToS4);
      }
   }
   
   if (showWeekly)
   {
      doBox(timeFramesWeeklyPivot, R3ToR4, weeklyR4 , leftBar2, weeklyR3, rightBar2, 11);
      doBox(timeFramesWeeklyPivot, R2ToR3, weeklyR3, leftBar2, weeklyR2, rightBar2, 12);
      doBox(timeFramesWeeklyPivot, R1ToR2, weeklyR2, leftBar2, weeklyR1, rightBar2, 13);
      
      doBox(timeFramesWeeklyPivot, pivotToR1, weeklyR1, leftBar2, weeklyPivot, rightBar2, 14);
   
      doBox(timeFramesWeeklyPivot, pivotToS1, weeklyPivot, leftBar2, weeklyS1, rightBar2, 15);
   
      doBox(timeFramesWeeklyPivot, S1ToS2, weeklyS1, leftBar2, weeklyS2, rightBar2, 16);
      doBox(timeFramesWeeklyPivot, S2ToS3, weeklyS2, leftBar2, weeklyS3, rightBar2, 17);
      doBox(timeFramesWeeklyPivot, S3ToS4, weeklyS3, leftBar2, weeklyS4, rightBar2, 18);
      
      if (pivotType==3) doLabel(timeFramesWeeklyPivot, "WC", txtColor, weeklyPivot, weeklyX, 60);
      else doLabel(timeFramesWeeklyPivot, "WP", txtColor, weeklyPivot, weeklyX, 60);
      doLabel(timeFramesWeeklyPivot, "WR1", txtColor, weeklyR1, weeklyX, 61);
      doLabel(timeFramesWeeklyPivot, "WR2", txtColor, weeklyR2, weeklyX, 62);
      doLabel(timeFramesWeeklyPivot, "WR3", txtColor, weeklyR3, weeklyX, 63);
      doLabel(timeFramesWeeklyPivot, "WR4", txtColor, weeklyR4, weeklyX, 64);
      doLabel(timeFramesWeeklyPivot, "WS1", txtColor, weeklyS1, weeklyX, 65);
      doLabel(timeFramesWeeklyPivot, "WS2", txtColor, weeklyS2, weeklyX, 66);
      doLabel(timeFramesWeeklyPivot, "WS3", txtColor, weeklyS3, weeklyX, 67);
      doLabel(timeFramesWeeklyPivot, "WS4", txtColor, weeklyS4, weeklyX, 68);
      
      if(focusActiveZone)
      {
         if (Bid>weeklyR3 && Bid < weeklyR4) focus(objPrefix+IntegerToString(11));
         else unfocus(objPrefix+IntegerToString(11), R3ToR4);
         if (Bid>weeklyR2 && Bid < weeklyR3) focus(objPrefix+IntegerToString(12));
         else unfocus(objPrefix+IntegerToString(12), R2ToR3);
         if (Bid>weeklyR1 && Bid < weeklyR2) focus(objPrefix+IntegerToString(13));
         else unfocus(objPrefix+IntegerToString(13), R1ToR2);
         if (Bid>weeklyPivot && Bid < weeklyR1) focus(objPrefix+IntegerToString(14));
         else unfocus(objPrefix+IntegerToString(14), pivotToR1);
         if (Bid>weeklyS1 && Bid < weeklyPivot) focus(objPrefix+IntegerToString(15));
         else unfocus(objPrefix+IntegerToString(15), pivotToS1);
         if (Bid>weeklyS2 && Bid < weeklyS1) focus(objPrefix+IntegerToString(16));
         else unfocus(objPrefix+IntegerToString(16), S1ToS2);
         if (Bid>weeklyS3 && Bid < weeklyS2) focus(objPrefix+IntegerToString(17));
         else unfocus(objPrefix+IntegerToString(17), S2ToS3);
         if (Bid>weeklyS4 && Bid < weeklyS3) focus(objPrefix+IntegerToString(18));
         else unfocus(objPrefix+IntegerToString(18), S3ToS4);
      }
   }
   
   if (showMonthly)
   {
      doBox(timeFramesMonthlyPivot, R3ToR4, monthlyR4 , leftBar3, monthlyR3, rightBar3, 21);
      doBox(timeFramesMonthlyPivot, R2ToR3, monthlyR3, leftBar3, monthlyR2, rightBar3, 22);
      doBox(timeFramesMonthlyPivot, R1ToR2, monthlyR2, leftBar3, monthlyR1, rightBar3, 23);
      
      doBox(timeFramesMonthlyPivot, pivotToR1, monthlyR1, leftBar3, monthlyPivot, rightBar3, 24);
   
      doBox(timeFramesMonthlyPivot, pivotToS1, monthlyPivot, leftBar3, monthlyS1, rightBar3, 25);
   
      doBox(timeFramesMonthlyPivot, S1ToS2, monthlyS1, leftBar3, monthlyS2, rightBar3, 26);
      doBox(timeFramesMonthlyPivot, S2ToS3, monthlyS2, leftBar3, monthlyS3, rightBar3, 27);
      doBox(timeFramesMonthlyPivot, S3ToS4, monthlyS3, leftBar3, monthlyS4, rightBar3, 28);   
      
      if (pivotType==3) doLabel(timeFramesMonthlyPivot, "MC", txtColor, monthlyPivot, monthlyX, 70);
      else doLabel(timeFramesMonthlyPivot, "MP", txtColor, monthlyPivot, monthlyX, 70);
      doLabel(timeFramesMonthlyPivot, "MR1", txtColor, monthlyR1, monthlyX, 71);
      doLabel(timeFramesMonthlyPivot, "MR2", txtColor, monthlyR2, monthlyX, 72);
      doLabel(timeFramesMonthlyPivot, "MR3", txtColor, monthlyR3, monthlyX, 73);
      doLabel(timeFramesMonthlyPivot, "MR4", txtColor, monthlyR4, monthlyX, 74);
      doLabel(timeFramesMonthlyPivot, "MS1", txtColor, monthlyS1, monthlyX, 75);
      doLabel(timeFramesMonthlyPivot, "MS2", txtColor, monthlyS2, monthlyX, 76);
      doLabel(timeFramesMonthlyPivot, "MS3", txtColor, monthlyS3, monthlyX, 77);
      doLabel(timeFramesMonthlyPivot, "MS4", txtColor, monthlyS4, monthlyX, 78);
  
      if(focusActiveZone)
      {
         if (Bid>monthlyR3 && Bid < monthlyR4) focus(objPrefix+IntegerToString(21));
         else unfocus(objPrefix+IntegerToString(21), R3ToR4);
         if (Bid>monthlyR2 && Bid < monthlyR3) focus(objPrefix+IntegerToString(22));
         else unfocus(objPrefix+IntegerToString(22), R2ToR3);
         if (Bid>monthlyR1 && Bid < monthlyR2) focus(objPrefix+IntegerToString(23));
         else unfocus(objPrefix+IntegerToString(23), R1ToR2);
         if (Bid>monthlyPivot && Bid < monthlyR1) focus(objPrefix+IntegerToString(24));
         else unfocus(objPrefix+IntegerToString(24), pivotToR1);
         if (Bid>monthlyS1 && Bid < monthlyPivot) focus(objPrefix+IntegerToString(25));
         else unfocus(objPrefix+IntegerToString(25), pivotToS1);
         if (Bid>monthlyS2 && Bid < monthlyS1) focus(objPrefix+IntegerToString(26));
         else unfocus(objPrefix+IntegerToString(26), S1ToS2);
         if (Bid>monthlyS3 && Bid < monthlyS2) focus(objPrefix+IntegerToString(27));
         else unfocus(objPrefix+IntegerToString(27), S2ToS3);
         if (Bid>monthlyS4 && Bid < monthlyS3) focus(objPrefix+IntegerToString(28));
         else unfocus(objPrefix+IntegerToString(28), S3ToS4); 
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void getValues(int pivotMode)
{
   if (pivotMode ==1)
   {
      dailyPivot  = (iHigh(Symbol(), PERIOD_D1, 1) + iLow(Symbol(), PERIOD_D1, 1) + iClose(Symbol(), PERIOD_D1, 1)) / 3;
      dailyRange  = iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1);
      
      dailyR1     = (dailyPivot * 2) - iLow(Symbol(), PERIOD_D1, 1);
      dailyR2     = dailyPivot + dailyRange;
      dailyR3     = dailyR2 + dailyRange;
      dailyR4     = dailyR3 + dailyRange;
      
      dailyS1     = (dailyPivot * 2) - iHigh(Symbol(), PERIOD_D1, 1);
      dailyS2     = dailyPivot - dailyRange;
      dailyS3     = dailyS2 - dailyRange;
      dailyS4     = dailyS3 - dailyRange;
   
      weeklyPivot  = (iHigh(Symbol(), PERIOD_W1, 1) + iLow(Symbol(), PERIOD_W1, 1) + iClose(Symbol(), PERIOD_W1, 1)) / 3;
      weeklyRange       = iHigh(Symbol(), PERIOD_W1, 1) - iLow(Symbol(), PERIOD_W1, 1);
      
      weeklyR1     = (weeklyPivot * 2) - iLow(Symbol(), PERIOD_W1, 1);
      weeklyR2     = weeklyPivot + weeklyRange;
      weeklyR3     = weeklyR2 + weeklyRange;
      weeklyR4     = weeklyR3 + weeklyRange;
      
      weeklyS1     = (weeklyPivot * 2) - iHigh(Symbol(), PERIOD_W1, 1);
      weeklyS2     = weeklyPivot - weeklyRange;
      weeklyS3     = weeklyS2 - weeklyRange;
      weeklyS4     = weeklyS3 - weeklyRange;
      
      monthlyPivot  = (iHigh(Symbol(), PERIOD_MN1, 1) + iLow(Symbol(), PERIOD_MN1, 1) + iClose(Symbol(), PERIOD_MN1, 1)) / 3;
      monthlyRange       = iHigh(Symbol(), PERIOD_MN1, 1) - iLow(Symbol(), PERIOD_MN1, 1);
      
      monthlyR1     = (monthlyPivot * 2) - iLow(Symbol(), PERIOD_MN1, 1);
      monthlyR2     = monthlyPivot + monthlyRange;
      monthlyR3     = monthlyR2 + monthlyRange;
      monthlyR4     = monthlyR3 + monthlyRange;
      
      monthlyS1     = (monthlyPivot * 2) - iHigh(Symbol(), PERIOD_MN1, 1);
      monthlyS2     = monthlyPivot - monthlyRange;
      monthlyS3     = monthlyS2 - monthlyRange;
      monthlyS4     = monthlyS3 - monthlyRange;
   }
   else if (pivotMode == 2)
   {
      dailyPivot  = (iHigh(Symbol(), PERIOD_D1, 1) + iLow(Symbol(), PERIOD_D1, 1) + iOpen(Symbol(), PERIOD_D1, 0) + iOpen(Symbol(), PERIOD_D1, 0)) / 4;
      dailyRange  = iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1);
      
      dailyR1     = (dailyPivot * 2) - iLow(Symbol(), PERIOD_D1, 1);
      dailyR2     = dailyPivot + dailyRange;
      dailyR3     = dailyR2 + dailyRange;
      dailyR4     = dailyR3 + dailyRange;
      
      dailyS1     = (dailyPivot * 2) - iHigh(Symbol(), PERIOD_D1, 1);
      dailyS2     = dailyPivot - dailyRange;
      dailyS3     = dailyS2 - dailyRange;
      dailyS4     = dailyS3 - dailyRange;
   
      weeklyPivot  = (iHigh(Symbol(), PERIOD_W1, 1) + iLow(Symbol(), PERIOD_W1, 1) + iOpen(Symbol(), PERIOD_W1, 0) + iOpen(Symbol(), PERIOD_W1, 0)) / 4;
      weeklyRange  = iHigh(Symbol(), PERIOD_W1, 1) - iLow(Symbol(), PERIOD_W1, 1);
      
      weeklyR1     = (weeklyPivot * 2) - iLow(Symbol(), PERIOD_W1, 1);
      weeklyR2     = weeklyPivot + weeklyRange;
      weeklyR3     = weeklyR2 + weeklyRange;
      weeklyR4     = weeklyR3 + weeklyRange;
      
      weeklyS1     = (weeklyPivot * 2) - iHigh(Symbol(), PERIOD_W1, 1);
      weeklyS2     = weeklyPivot - weeklyRange;
      weeklyS3     = weeklyS2 - weeklyRange;
      weeklyS4     = weeklyS3 - weeklyRange;
      
      monthlyPivot  = (iHigh(Symbol(), PERIOD_MN1, 1) + iLow(Symbol(), PERIOD_MN1, 1) + iOpen(Symbol(), PERIOD_MN1, 0) + iOpen(Symbol(), PERIOD_MN1, 0)) / 4;
      monthlyRange  = iHigh(Symbol(), PERIOD_MN1, 1) - iLow(Symbol(), PERIOD_MN1, 1);
      
      monthlyR1     = (monthlyPivot * 2) - iLow(Symbol(), PERIOD_MN1, 1);
      monthlyR2     = monthlyPivot + monthlyRange;
      monthlyR3     = monthlyR2 + monthlyRange;
      monthlyR4     = monthlyR3 + monthlyRange;
      
      monthlyS1     = (monthlyPivot * 2) - iHigh(Symbol(), PERIOD_MN1, 1);
      monthlyS2     = monthlyPivot - monthlyRange;
      monthlyS3     = monthlyS2 - monthlyRange;
      monthlyS4     = monthlyS3 - monthlyRange;
   }
   else if (pivotMode == 3)
   {
      dailyPivot  = iClose(Symbol(), PERIOD_D1, 1);
      dailyRange  = iHigh(Symbol(), PERIOD_D1, 1) - iLow(Symbol(), PERIOD_D1, 1);
      
      dailyR4     = iClose(Symbol(), PERIOD_D1, 1) + (dailyRange * 0.55);
      dailyR3     = iClose(Symbol(), PERIOD_D1, 1) + (dailyRange * 0.275);
      dailyR2     = iClose(Symbol(), PERIOD_D1, 1) + (dailyRange * 0.183);
      dailyR1     = iClose(Symbol(), PERIOD_D1, 1) + (dailyRange * 0.091);
      
      dailyS4     = iClose(Symbol(), PERIOD_D1, 1) - (dailyRange * 0.55);
      dailyS3     = iClose(Symbol(), PERIOD_D1, 1) - (dailyRange * 0.275);
      dailyS2     = iClose(Symbol(), PERIOD_D1, 1) - (dailyRange * 0.183);
      dailyS1     = iClose(Symbol(), PERIOD_D1, 1) - (dailyRange * 0.091);
   
      weeklyPivot  = iClose(Symbol(), PERIOD_W1, 1);
      weeklyRange  = iHigh(Symbol(), PERIOD_W1, 1) - iLow(Symbol(), PERIOD_W1, 1);
      
      weeklyR4     = iClose(Symbol(), PERIOD_W1, 1) + (weeklyRange * 0.55);
      weeklyR3     = iClose(Symbol(), PERIOD_W1, 1) + (weeklyRange * 0.275);
      weeklyR2     = iClose(Symbol(), PERIOD_W1, 1) + (weeklyRange * 0.183);
      weeklyR1     = iClose(Symbol(), PERIOD_W1, 1) + (weeklyRange * 0.091);
      
      weeklyS4     = iClose(Symbol(), PERIOD_W1, 1) - (weeklyRange * 0.55);
      weeklyS3     = iClose(Symbol(), PERIOD_W1, 1) - (weeklyRange * 0.275);
      weeklyS2     = iClose(Symbol(), PERIOD_W1, 1) - (weeklyRange * 0.183);
      weeklyS1     = iClose(Symbol(), PERIOD_W1, 1) - (weeklyRange * 0.091);
      
      monthlyPivot  = iClose(Symbol(), PERIOD_MN1, 1);
      monthlyRange  = iHigh(Symbol(), PERIOD_MN1, 1) - iLow(Symbol(), PERIOD_MN1, 1);
      
      monthlyR4     = iClose(Symbol(), PERIOD_MN1, 1) + (monthlyRange * 0.55);
      monthlyR3     = iClose(Symbol(), PERIOD_MN1, 1) + (monthlyRange * 0.275);
      monthlyR2     = iClose(Symbol(), PERIOD_MN1, 1) + (monthlyRange * 0.183);
      monthlyR1     = iClose(Symbol(), PERIOD_MN1, 1) + (monthlyRange * 0.091);
      
      monthlyS4     = iClose(Symbol(), PERIOD_MN1, 1) - (monthlyRange * 0.55);
      monthlyS3     = iClose(Symbol(), PERIOD_MN1, 1) - (monthlyRange * 0.275);
      monthlyS2     = iClose(Symbol(), PERIOD_MN1, 1) - (monthlyRange * 0.183);
      monthlyS1     = iClose(Symbol(), PERIOD_MN1, 1) - (monthlyRange * 0.091);
   
   }

}

void doBox(int timeframes, color mColor, double high, datetime left, double low, datetime right, int i)
{
   bool created = ObjectCreate(0, objPrefix+IntegerToString(i),OBJ_RECTANGLE, 0, left, high, right, low);
   ObjectSetInteger(0, objPrefix+IntegerToString(i),OBJPROP_TIME, 0, left);
   ObjectSetDouble(0, objPrefix+IntegerToString(i),OBJPROP_PRICE, 0, high);
   ObjectSetInteger(0, objPrefix+IntegerToString(i),OBJPROP_TIME, 1, right);
   ObjectSetDouble(0, objPrefix+IntegerToString(i),OBJPROP_PRICE, 1, low);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_BACK, true);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_COLOR, mColor);  
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_BACK, boxFilled);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_STYLE, boxStyle);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_WIDTH, 1);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_TIMEFRAMES, timeframes);
   
   if (mColor == CLR_NONE)
   {
      ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_COLOR, CLR_NONE);
      ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_BACK, false);
      ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_STYLE, STYLE_DOT);
      //return;
   }
}
void ObjectSetText(string id, string text, int fontSize, string font, color clr)
{
   ObjectSetString(0, id, OBJPROP_TEXT, text);
   ObjectSetString(0, id, OBJPROP_FONT, font);
   ObjectSetInteger(0, id, OBJPROP_FONTSIZE, fontSize);
   ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
}
void doLabel(int timeframes, string mTxt, color mColor, double top, datetime left, int i)
{
   bool created;
   created = ObjectCreate(0, objPrefix+IntegerToString(i), OBJ_TEXT, 0, left, top);
   ObjectSetInteger(0, objPrefix+IntegerToString(i),OBJPROP_TIME, left);
   ObjectSetDouble(0, objPrefix+IntegerToString(i),OBJPROP_PRICE, top);
   ObjectSetText(objPrefix+IntegerToString(i), mTxt, txtFontSize, "Arial", mColor);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, objPrefix+IntegerToString(i), OBJPROP_TIMEFRAMES, timeframes);
}
void focus(string box)
{
   ObjectSetInteger(0, box, OBJPROP_STYLE, 0);
   ObjectSetInteger(0, box, OBJPROP_COLOR, focusRange);
   ObjectSetInteger(0, box, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, box, OBJPROP_WIDTH, 2);
}
void unfocus(string box, color initialColor)
{
   ObjectSetInteger(0, box, OBJPROP_STYLE, boxStyle);
   ObjectSetInteger(0, box, OBJPROP_COLOR, initialColor);
   ObjectSetInteger(0, box, OBJPROP_HIDDEN, true);
   ObjectSetInteger(0, box, OBJPROP_WIDTH, 1);
}
double pFactor()
{
   for ( int i = ArraySize(pipFactor)-1; i >=0; i-- ) 
      if (StringFind(Symbol(),pipFactor[i],0) != -1) 
         return (pipFactors[i]);
   return(10000);
}