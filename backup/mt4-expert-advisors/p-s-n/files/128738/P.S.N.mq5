// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=68928

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.2"
#property strict

#property indicator_chart_window
#property indicator_buffers   7

enum ENUM_TF_ALL
{
   Period_Current = 0,    // Current
   Period_M1      = 1,    // M1
   Period_M5      = 2,    // M5
   Period_M15     = 3,    // M15
   Period_M30     = 4,    // M30
   Period_H1      = 5,    // H1
   Period_H4      = 6,    // H4
   Period_Daily   = 7,    // Daily
   Period_Weekly  = 8,    // Weekly
   Period_Monthly = 9,    // Monthly
   Period_Quarter = 10,   // Quarter
   Period_Year    = 11    // Year
};

enum ENUM_W1_FIRST
{
   W1Monday    = 0,       // Monday
   W1Tuesday   = 1,      // Tuesday
   W1Wednesday = 2,      // Wednesday
   W1Thursday  = 3,      // Thursday
   W1Friday    = 4       // Friday
}; 
      
// inputal inputs
input int              magicID               = 1;
input double           ValX                  = 0.25;                 
input int              iCountPeriods         = 10;
input int              iPivotLevels          = 3;
input ENUM_TF_ALL      iTimePeriod           = Period_Daily;
input int              iShiftHours           = 0;
input ENUM_W1_FIRST    iShiftDay             = 0;
input double           iHalfPeriod           = 0.5;
input bool             iEAMode               = false;
input bool             iPlotPivots           = true;
input bool             iPlotPivotFutures     = true;
input bool             iPlotPivotLabels      = true;
input bool             iPlotPivotPrices      = true;
input ENUM_LINE_STYLE  iPlotPivotStyles      = STYLE_SOLID;
input int              iPlotPivotWidths      = 1;
input color            iPlotPivotColorRes    = clrRed;
input color            iPlotPivotColorPP     = clrBlack;
input color            iPlotPivotColorKK     = clrYellow;
input color            iPlotPivotColorRange  = clrMagenta;
input color            iPlotPivotColorSup    = clrGreen;
input ENUM_LINE_STYLE  iPlotPivotMainStyles  = STYLE_SOLID;
input int              iPlotPivotMainWidths  = 2;

input bool             iPlotMidpoints        = false;
input ENUM_LINE_STYLE  iPlotMidpointStyles   = STYLE_DASH;
input int              iPlotMidpointWidths   = 1;
input color            iPlotMidpointColorM35 = clrGreen;
input color            iPlotMidpointColorM02 = clrRed;

input bool             iPlotZones            = true;
input color            iPlotBuyZoneColor     = clrLightGreen;
input color            iPlotSellZoneColor    = clrLightSalmon;

input bool             iPlotBorders          = false;
input ENUM_LINE_STYLE  iPlotBorderStyles     = STYLE_SOLID;
input int              iPlotBorderWidths     = 1;
input color            iPlotBorderColors     = clrBlack;

input bool             iPushNotifications_AllPivotsMidpoints     = false;
input bool             iPushNotifications_TouchPP                = false;
input bool             iPushNotifications_TouchR1S1              = false;
input bool             iPushNotifications_TouchR2S2              = false;
input bool             iPushNotifications_TouchR3S3              = false;
input bool             iPushNotifications_TouchM2M3              = false;
input bool             iPushNotifications_TouchM1M4              = false;
input bool             iPushNotifications_TouchM0M5              = false;
input int              iPushNotifications_TouchToleranceInDigits = 20;

// constants
#define  MAX_NUM_NOTIFICATION_QUEUE       10
#define  MAX_TIMER_EVENT_ELAPSED_IN_SECS  10

datetime AddPeriods(datetime dt, ENUM_TIMEFRAMES tf, int count)
{
   if (tf == PERIOD_CURRENT)
      return AddPeriods(dt, (ENUM_TIMEFRAMES)_Period, count);
   switch (tf)
   {
      case PERIOD_M1:
         return dt + 60 * count;
      case PERIOD_M2:
         return dt + 120 * count;
      case PERIOD_M3:
         return dt + 180 * count;
      case PERIOD_M4:
         return dt + 240 * count;
      case PERIOD_M5:
         return dt + 300 * count;
      case PERIOD_M6:
         return dt + 360 * count;
      case PERIOD_M10:
         return dt + 600 * count;
      case PERIOD_M12:
         return dt + 720 * count;
      case PERIOD_M15:
         return dt + 900 * count;
      case PERIOD_M20:
         return dt + 1200 * count;
      case PERIOD_M30:
         return dt + 1800 * count;
      case PERIOD_H1:
         return dt + 3600 * count;
      case PERIOD_H2:
         return dt + 7200 * count;
      case PERIOD_H3:
         return dt + 10800 * count;
      case PERIOD_H4:
         return dt + 14400 * count;
      case PERIOD_H6:
         return dt + 21600 * count;
      case PERIOD_H8:
         return dt + 28800 * count;
      case PERIOD_H12:
         return dt + 43200 * count;
      case PERIOD_D1:
         return dt + 86400 * count;
      case PERIOD_W1:
         return dt + 86400 * 7 * count;
      case PERIOD_MN1:
         {
            MqlDateTime date;
            if (!TimeToStruct(dt, date))
               return dt;
            int newMonths = date.mon + count;
            int addYears = (int)MathFloor((newMonths - 1) / 12);
            date.year += addYears;
            date.mon = newMonths - addYears * 12;
            return StructToTime(date);
         }
   }
   return dt;
}

// global variables
int startHTF;
datetime TimeStartHTF;
datetime TimeStopHTF;

int      iTimePeriodReal;
string   gPeriod = "";
ENUM_TIMEFRAMES gRealTimePeriod = 0;
int      gMonthsCount = 1;
int      gDaysCount   = 0;
datetime gPrevTimePivot = 0;
double   gPrevTouchPrice = 0.0;
double   gTouchToleranceDecimal = 0.0;
int      gNumNotificationQueue = 0;
string   gNotificationQueue[MAX_NUM_NOTIFICATION_QUEUE] = {NULL};

double bufferOpen[], bufferHigh[], bufferLow[], bufferKK[], bufferRange[], bufferNewPeriod[], bufferHalfPeriod[];
datetime timeLast;

//+------------------------------------------------------------------+
// init - This function will set the period string and real time. The
//    period string is used on label plots and object names. The real
//    time period is used to plot correct time lenghts on higher 
//    timeframes. 
//+------------------------------------------------------------------+

string IndicatorName;
string IndicatorObjPrefix;
string GenerateIndicatorName(const string target)
{
   string name = target;
   return name;
}
int OnInit(void)
{
   IndicatorName = GenerateIndicatorName("P.S.N.");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   SetIndexBuffer(0, bufferOpen, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(0, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(0, PLOT_LABEL, "OP");

   SetIndexBuffer(1, bufferHigh, INDICATOR_DATA);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(1, PLOT_LABEL, "HIGH");

   SetIndexBuffer(2, bufferLow, INDICATOR_DATA);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(2, PLOT_LABEL, "LOW");

   SetIndexBuffer(3, bufferKK, INDICATOR_DATA);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(3, PLOT_LABEL, "KK");

   SetIndexBuffer(4, bufferRange, INDICATOR_DATA);
   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(4, PLOT_LABEL, "%RANGE");

   SetIndexBuffer(5, bufferNewPeriod, INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(5, PLOT_LABEL, "NEW?");

   SetIndexBuffer(6, bufferHalfPeriod, INDICATOR_DATA);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, Red);
   PlotIndexSetString(6, PLOT_LABEL, "HALF?");
   
   DoInit();
   return INIT_SUCCEEDED;//INIT_FAILED
}

void DoInit()
{
   // create random timer value between 1 and MAX defined
   MathSrand(GetTickCount()); 
   int timerVal = MathRand() % MAX_TIMER_EVENT_ELAPSED_IN_SECS;
   if (timerVal <= 0)
      timerVal = MAX_TIMER_EVENT_ELAPSED_IN_SECS;
   
   // start timer event handler
   if (EventSetTimer(timerVal) == false)
      Print("<= Error starting timer event handler => ", GetLastError());

   // calculate decimal prices according to digits
   gTouchToleranceDecimal = iPushNotifications_TouchToleranceInDigits / MathPow(10, Digits());

   // go through each timeframe and assign period string and real time period minutes
   // NOTE: real minutes are used to calculate end times and future times
   startHTF = 12;
   
   if (GlobalVariableCheck((string)+magicID+"_iTimePeriod")) 
      iTimePeriodReal = GlobalVariableGet((string)+magicID+"_iTimePeriod");
   else 
      iTimePeriodReal = iTimePeriod;
   
   switch (iTimePeriodReal)
   {
      case Period_M1:
         gPeriod = "M1";
         gRealTimePeriod = PERIOD_M1;  // 1 minute
         break;
      case Period_M5:
         gPeriod = "M5";
         gRealTimePeriod = PERIOD_M5;  // 5 minutes
         break;
      case Period_M15:
         gPeriod = "M15";
         gRealTimePeriod = PERIOD_M15; // 15 minutes
         break;
      case Period_M30:
         gPeriod = "M30";
         gRealTimePeriod = PERIOD_M30; // 30 minutes
         break;
      case Period_H1:
         gPeriod = "H1";
         gRealTimePeriod = PERIOD_H1;  // 60 minutes
         break;
      case Period_H4:
         gPeriod = "H4";
         gRealTimePeriod = PERIOD_H4;  // 240 minutes
         break;
      case Period_Daily:
         gPeriod = "D1";
         gRealTimePeriod = PERIOD_D1;  // 1440 minutes
         break;
      case Period_Weekly:
         gPeriod = "W1";
         gRealTimePeriod = PERIOD_W1;  // 8640 minutes (update to draw weekly line for 6 days only)
         break;
      case Period_Monthly:
         gPeriod = "MN1";
         gRealTimePeriod = PERIOD_MN1; // 43200 minutes (30 days)
         break;
      case Period_Quarter:
         gPeriod = "MN3";
         gRealTimePeriod = PERIOD_MN1;   
         gMonthsCount = 3;
         gDaysCount   = 90;
         while(startHTF<iBars(NULL,PERIOD_MN1)-1)
         {
            MqlDateTime _time;
            if (!TimeToStruct(iTime(NULL, PERIOD_MN1, startHTF), _time) || _time.mon == 1 || _time.mon == 4 || _time.mon == 7 || _time.mon == 10)
               break;
            ++startHTF;
         }
         startHTF-=12;
         break;
      case Period_Year:
         gPeriod = "YR1";
         gRealTimePeriod = PERIOD_MN1;
         gMonthsCount = 12;
         gDaysCount   = 365;
         while(startHTF<iBars(NULL,PERIOD_MN1)-1)
         {
            MqlDateTime _time;
            if (!TimeToStruct(iTime(NULL, PERIOD_MN1, startHTF), _time) || _time.mon == 1)
               break;
            ++startHTF;
         }
         startHTF-=12;
         break;
      default:
         gPeriod = "";
         Alert("iTimePeriod param specified is not supported.");
         break;
   }
   if (!iEAMode)
   {
      guiCreate();
      guiRefresh();
   }
}

//+------------------------------------------------------------------+
// deinit - This function will delete all objects on the chart. 
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if (!iEAMode)
   {
      DeleteAllObjects();
      ButtonsDelete();
   }
   EventKillTimer();
   if (reason == REASON_REMOVE) 
      GlobalVariableDel((string)magicID+"_iTimePeriod");
   return;
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
   if (!iEAMode) 
      guiRefresh();

   if( iTimePeriodReal==Period_Quarter || iTimePeriodReal==Period_Year ) 
   {
      startHTF = 12;
      switch (iTimePeriodReal)
      {
         case Period_Quarter:
            while(startHTF<iBars(NULL,PERIOD_MN1)-1)
            {
               MqlDateTime _time;
               if (!TimeToStruct(iTime(NULL, PERIOD_MN1, startHTF), _time) || _time.mon == 1 || _time.mon == 4 || _time.mon == 7 || _time.mon == 10)
                  break;
               ++startHTF;
            }
            startHTF-=12;
            break;
         case Period_Year:
            while(startHTF<iBars(NULL,PERIOD_MN1)-1)
            {
               MqlDateTime _time;
               if(!TimeToStruct(iTime(NULL, PERIOD_MN1, startHTF), _time) || _time.mon == 1)
                  break;
               ++startHTF;
            }
            startHTF-=12;
            break;
      }
   }
   int startBarShift = 0;
   int endBarShift = 0;
   int timeStartFuture;
   datetime timeStartObj;
   datetime timeEndObj;
   bool IsNewPeriod=false;
   bool IsHalfPeriod=false;
   // remove all objects upon entry
   if (!iEAMode) 
      DeleteAllObjects();
   // draw current and history pivots/midpoints
   if (iPlotPivots && gRealTimePeriod != PERIOD_CURRENT)
   {
      for (int shift = 0; shift < iCountPeriods; shift++)
      {
         // clear loop variables
         int error = 0;
         
         // calculate start/end times for current/previous objects
         // NOTE: check if daily period was selected and hour shift is used
         if (iTimePeriodReal == Period_Daily && iShiftHours != 0)
            error = GetShiftInfo(shift, startBarShift, endBarShift, timeStartObj, timeEndObj);
         else if (iTimePeriodReal == Period_Weekly && iShiftDay != 0)
            error = GetShiftInfoWeekly(shift, startBarShift, endBarShift, timeStartObj, timeEndObj);
         else 
         {
            if( shift>0 ) 
            {
               timeStartObj = iTime(NULL, gRealTimePeriod, shift);
               timeEndObj   = iTime(NULL, gRealTimePeriod, shift-1);
            }
            else
            {
               timeStartObj = iTime(NULL, gRealTimePeriod, shift);
               timeEndObj   = AddPeriods(iTime(NULL, gRealTimePeriod, shift), gRealTimePeriod, 1);
               if( iTimePeriodReal == Period_Monthly ) 
                  timeEndObj = AddPeriods(timeEndObj, PERIOD_D1, 1);
            }
            if( gMonthsCount>1 ) 
            {
               timeStartObj = iTime(NULL, PERIOD_MN1, (shift*gMonthsCount) +startHTF ) ;
               timeEndObj   = AddPeriods(timeStartObj, PERIOD_D1, gDaysCount);
               TimeStartHTF = timeStartObj;
               TimeStopHTF  = timeEndObj;
               if( shift==0 ) 
                  timeStartFuture = timeEndObj; 
            }             
         }
         if( shift==0 && timeStartObj>timeLast ) 
         {
            IsNewPeriod=true;
            timeLast = timeStartObj;
         }
         if( shift==0 && time[rates_total - 1]>=timeStartObj+(timeEndObj-timeStartObj)*iHalfPeriod ) 
            IsHalfPeriod=true;
         if( IsNewPeriod ) 
            bufferNewPeriod[0] = 1;
         else 
            bufferNewPeriod[0] = 0;
         if (IsHalfPeriod) 
            bufferHalfPeriod[0] = 1;
         else 
            bufferHalfPeriod[0] = 0;
         // check for valid values and draw levels
         if (error == 0)
         {
            // NOTE: increment function shift since previous bar is used to calculate current bar's pivots
            LevelsDraw(shift + 1, timeStartObj, timeEndObj, gPeriod, false);    
         }            
      }
   }
   
   // draw future pivots/midpoints
   if (iPlotPivotFutures && iTimePeriodReal != 0)
   {
      // calculate start/end times for future objects
      // NOTE: check if daily period was selected and hour shift is used
      if (iTimePeriodReal == Period_Daily && iShiftHours != 0)
      {
         // NOTE: start/end shift times for objects are used only
         GetShiftInfo(0, startBarShift, endBarShift, timeStartObj, timeEndObj);
         
         // add another day (shift) to calculate both start/end shifted times for future calculations
         timeStartObj = timeEndObj; 
         timeEndObj = AddPeriods(timeStartObj, gRealTimePeriod, 1);
      }
      else if (iTimePeriodReal == Period_Weekly && iShiftDay != 0)
      {
         // NOTE: start/end shift times for objects are used only
         GetShiftInfoWeekly(0, startBarShift, endBarShift, timeStartObj, timeEndObj);
         
         // add another day (shift) to calculate both start/end shifted times for future calculations
         timeStartObj = timeEndObj; 
         timeEndObj = AddPeriods(timeStartObj, gRealTimePeriod, 1);
      }

      else
      {
         if( gMonthsCount>1 ) 
         {
            timeStartObj = timeStartFuture;
            timeEndObj   = AddPeriods(timeStartObj, PERIOD_D1, gDaysCount);
         }
         else
         {
            timeStartObj = AddPeriods(iTime(NULL, gRealTimePeriod, 0), gRealTimePeriod, 1);
            if( iTimePeriodReal == Period_Monthly ) 
               timeStartObj = AddPeriods(timeStartObj, PERIOD_D1, 1);
            timeEndObj   = AddPeriods(iTime(NULL, gRealTimePeriod, 0), gRealTimePeriod, 2);
         }             
      }
      
      // NOTE: current bar (shift = 0) is used to calculate future pivots
      LevelsDraw(0, timeStartObj, timeEndObj, "F" + gPeriod, true);      
   }
   if (iTimePeriodReal != 0)
      SendPushNotifications();
   return rates_total;
}

//+------------------------------------------------------------------+
// LevelsDraw - This function will get the pivot levels for the
//    specified timeframe and plot them to the chart using the 
//    specified start/end times for all chart objects. 
//+------------------------------------------------------------------+
int LevelsDraw(   int      Shift,
                  datetime TimeStartObj, 
                  datetime TimeEndObj, 
                  string   PeriodStr,
                  bool     IsFuture)
{
   double pivP = 0.0;         // Pivot Levels
   double kk   = 0.0;
   double range= 0.0;
   double high = 0.0;
   double low  = 0.0;
   double mid0 = 0.0;
   double mid1 = 0.0;
   double mid2 = 0.0;
   double mid3 = 0.0;
   double mid4 = 0.0;
   double mid5 = 0.0;
   
   // get pivot points and midpoint levels
   int error = GetPivotPoints(gRealTimePeriod, Shift, pivP, kk, range, high, low);
   if (error != 0)
      return error;
   if( !iEAMode ) 
   {
      // plot zones if enabled
      if (iPlotZones)
      {
         PlotRectangle(0,(string)magicID + " _ " + PeriodStr + "BZ_"+ IntegerToString(Shift), 0, TimeStartObj, pivP, TimeEndObj, pivP+range*ValX*iPivotLevels, iPlotBuyZoneColor);    
         PlotRectangle(0,(string)magicID + " _ " + PeriodStr + "SZ_"+ IntegerToString(Shift), 0, TimeStartObj, pivP, TimeEndObj, pivP-range*ValX*iPivotLevels, iPlotSellZoneColor);
      }
      
      // plot pivots if enabled
      if (iPlotPivots)
      {                                 
         // plot trendline for pivot levels
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "OP_T"+ IntegerToString(Shift), 0, TimeStartObj, pivP, TimeEndObj, pivP, iPlotPivotColorPP, iPlotPivotMainStyles, iPlotPivotMainWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "KK_T"+ IntegerToString(Shift), 0, TimeStartObj, kk,   TimeEndObj, kk,   iPlotPivotColorKK, iPlotPivotMainStyles, iPlotPivotMainWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "HI_T"+ IntegerToString(Shift), 0, TimeStartObj, high, TimeEndObj, high, iPlotPivotColorRange, iPlotPivotMainStyles, iPlotPivotMainWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "LO_T"+ IntegerToString(Shift), 0, TimeStartObj, low,  TimeEndObj, low,  iPlotPivotColorRange, iPlotPivotMainStyles, iPlotPivotMainWidths);     
         for( int i=iPivotLevels; i>0; i-- ) {
            PlotTrend(0,(string)magicID + " _ " + PeriodStr + "U"+(string)i+"_T"+ IntegerToString(Shift), 0, TimeStartObj, pivP+range*ValX*i, TimeEndObj, pivP+range*ValX*i, iPlotPivotColorRes, iPlotPivotStyles, iPlotPivotWidths);     
            PlotTrend(0,(string)magicID + " _ " + PeriodStr + "D"+(string)i+"_T"+ IntegerToString(Shift), 0, TimeStartObj, pivP-range*ValX*i, TimeEndObj, pivP-range*ValX*i, iPlotPivotColorSup, iPlotPivotStyles, iPlotPivotWidths);     
         }
         
         if (iPlotPivotLabels)
         {
            PlotText(0,(string)magicID + " _ " + PeriodStr + "OP_L"+ IntegerToString(Shift), 0, TimeEndObj, pivP, PeriodStr + " - OP", "Arial", 8, iPlotPivotColorPP, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "KK_L"+ IntegerToString(Shift), 0, TimeEndObj, kk,   PeriodStr + " - KK", "Arial", 8, iPlotPivotColorKK, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "HI_L"+ IntegerToString(Shift), 0, TimeEndObj, high, PeriodStr + " - High", "Arial", 8, iPlotPivotColorRange, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "LO_L"+ IntegerToString(Shift), 0, TimeEndObj, low,  PeriodStr + " - Low", "Arial", 8, iPlotPivotColorRange, ANCHOR_RIGHT_UPPER);
            for (int i = iPivotLevels; i > 0; i--) 
            {
               PlotText(0,(string)magicID + " _ " + PeriodStr + "U"+(string)i+"_L"+ IntegerToString(Shift), 0, TimeEndObj, pivP+range*ValX*i, PeriodStr + " - U"+(string)i, "Arial", 8, iPlotPivotColorRes, ANCHOR_RIGHT_UPPER);
               PlotText(0,(string)magicID + " _ " + PeriodStr + "D"+(string)i+"_L"+ IntegerToString(Shift), 0, TimeEndObj, pivP-range*ValX*i, PeriodStr + " - D"+(string)i, "Arial", 8, iPlotPivotColorSup, ANCHOR_RIGHT_UPPER);
            }
         }    
         
         if (iPlotPivotPrices)
         {
            PlotText(0,(string)magicID + " _ " + PeriodStr + "OP_P"+ IntegerToString(Shift), 0, TimeStartObj, pivP, DoubleToString(pivP, Digits()), "Arial", 8, iPlotPivotColorPP, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "KK_P"+ IntegerToString(Shift), 0, TimeStartObj, kk,   DoubleToString(kk, Digits()), "Arial", 8, iPlotPivotColorKK, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "HI_P"+ IntegerToString(Shift), 0, TimeStartObj, high, DoubleToString(high, Digits()), "Arial", 8, iPlotPivotColorRange, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "LO_P"+ IntegerToString(Shift), 0, TimeStartObj, low,  DoubleToString(low, Digits()), "Arial", 8, iPlotPivotColorRange, ANCHOR_LEFT_UPPER);
            for (int i = iPivotLevels; i > 0; i--) 
            {
               PlotText(0,(string)magicID + " _ " + PeriodStr + "U"+(string)i+"_P"+ IntegerToString(Shift), 0, TimeStartObj, pivP+range*ValX*i, DoubleToString(pivP+range*ValX*i, Digits()), "Arial", 8, iPlotPivotColorRes, ANCHOR_LEFT_UPPER);
               PlotText(0,(string)magicID + " _ " + PeriodStr + "D"+(string)i+"_P"+ IntegerToString(Shift), 0, TimeStartObj, pivP-range*ValX*i, DoubleToString(pivP-range*ValX*i, Digits()), "Arial", 8, iPlotPivotColorSup, ANCHOR_LEFT_UPPER);
            }
         }
      }    
      
      // plot midpoints if enabled
      if (iPlotMidpoints)
      {
         // plot trendline for midpoint levels
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M0_T"+ IntegerToString(Shift), 0, TimeStartObj, mid0, TimeEndObj, mid0, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M1_T"+ IntegerToString(Shift), 0, TimeStartObj, mid1, TimeEndObj, mid1, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M2_T"+ IntegerToString(Shift), 0, TimeStartObj, mid2, TimeEndObj, mid2, iPlotMidpointColorM02, iPlotMidpointStyles, iPlotMidpointWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M3_T"+ IntegerToString(Shift), 0, TimeStartObj, mid3, TimeEndObj, mid3, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M4_T"+ IntegerToString(Shift), 0, TimeStartObj, mid4, TimeEndObj, mid4, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);     
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "M5_T"+ IntegerToString(Shift), 0, TimeStartObj, mid5, TimeEndObj, mid5, iPlotMidpointColorM35, iPlotMidpointStyles, iPlotMidpointWidths);

         if (iPlotPivotLabels)
         {
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M0_L"+ IntegerToString(Shift), 0, TimeEndObj, mid0, PeriodStr + " - M0", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M1_L"+ IntegerToString(Shift), 0, TimeEndObj, mid1, PeriodStr + " - M1", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M2_L"+ IntegerToString(Shift), 0, TimeEndObj, mid2, PeriodStr + " - M2", "Arial", 8, iPlotMidpointColorM02, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M3_L"+ IntegerToString(Shift), 0, TimeEndObj, mid3, PeriodStr + " - M3", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M4_L"+ IntegerToString(Shift), 0, TimeEndObj, mid4, PeriodStr + " - M4", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M5_L"+ IntegerToString(Shift), 0, TimeEndObj, mid5, PeriodStr + " - M5", "Arial", 8, iPlotMidpointColorM35, ANCHOR_RIGHT_UPPER);
         }
         
         if (iPlotPivotPrices)
         {
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M0_P"+ IntegerToString(Shift), 0, TimeStartObj, mid0, DoubleToString(mid0, Digits()), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M1_P"+ IntegerToString(Shift), 0, TimeStartObj, mid1, DoubleToString(mid1, Digits()), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M2_P"+ IntegerToString(Shift), 0, TimeStartObj, mid2, DoubleToString(mid2, Digits()), "Arial", 8, iPlotMidpointColorM02, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M3_P"+ IntegerToString(Shift), 0, TimeStartObj, mid3, DoubleToString(mid3, Digits()), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M4_P"+ IntegerToString(Shift), 0, TimeStartObj, mid4, DoubleToString(mid4, Digits()), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
            PlotText(0,(string)magicID + " _ " + PeriodStr + "M5_P"+ IntegerToString(Shift), 0, TimeStartObj, mid5, DoubleToString(mid5, Digits()), "Arial", 8, iPlotMidpointColorM35, ANCHOR_LEFT_UPPER);
         }
      }   
      
      // plot left/right borders if enabled
      if (iPlotBorders)
      {
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "BDL_"+ IntegerToString(Shift), 0, TimeStartObj, pivP+range*ValX*iPivotLevels, TimeStartObj, pivP-range*ValX*iPivotLevels, iPlotBorderColors, iPlotBorderStyles, iPlotBorderWidths);
         PlotTrend(0,(string)magicID + " _ " + PeriodStr + "BDR_"+ IntegerToString(Shift), 0, TimeEndObj, pivP+range*ValX*iPivotLevels, TimeEndObj, pivP-range*ValX*iPivotLevels, iPlotBorderColors, iPlotBorderStyles, iPlotBorderWidths);
      }
   }
   // refresh buffers
   if( Shift==1 ) {
      bufferOpen[0]  = pivP;
      bufferKK[0]    = kk;
      bufferHigh[0]  = high;
      bufferLow[0]   = low;
      bufferRange[0] = range*ValX; 
   }
   return 0;
}

//+------------------------------------------------------------------+
// GetShiftInfo - This function will calculate the start and end 
//    hourly bar and time shifts.
//+------------------------------------------------------------------+
int GetShiftInfo( int Shift,
                  int &StartBarShift,
                  int &EndBarShift,
                  datetime &StartTimeShift,
                  datetime &EndTimeShift)
{
   int error = 0;
   int ShiftedFlag = 0;
   int tempBarShift = 0;
   int DailyShift = Shift;    // in case if modified
   
   // reset params on entry
   StartBarShift = -1;
   EndBarShift = -1;
   StartTimeShift = 0;
   EndTimeShift = 0;
   
   // first, calculate hourly shift for current day overlaps
   tempBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, 0), false);
   tempBarShift += iShiftHours;
   
   // check if hourly shift is negative
   // NOTE: this may happen on iShiftHours < 0 and day open is near
   if (tempBarShift < 0)
   {
      // add a day shift for accurate pivot calculations and set shifted flag
      DailyShift++;
      ShiftedFlag = 1;
   }
   // check if hourly shift is over a day (24 hours)
   // NOTE: this may happen on iShiftHours > 0 and day close is near
   else if (tempBarShift > 24)
   {
      // subtract a day shift for accurate pivot calculations and set shifted flag
      // NOTE: shift cannot be negative
      if (DailyShift > 0)
         DailyShift--;
      ShiftedFlag = -1;
   }
   
   // get the shift for the start bar (shift in hours for the start of day)
   StartBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift), false);
   StartBarShift += iShiftHours;
   
   // check for valid start hourly bar shift (non-negative)
   if (StartBarShift >= 0)
   {
      // get shifted start time and check if valid (greater than zero)
      StartTimeShift = iTime(NULL, PERIOD_H1, StartBarShift);
      if (StartTimeShift > 0)
      {
         // check for current/future shift calculation
         if (DailyShift > 0)
         {
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            EndBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift - 1), false);
            EndBarShift += iShiftHours + 1;
         }
         else
         {            
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            // NOTE: use the current daily shift instead (= 0, same as start) and shift hours right
            EndBarShift = iBarShift(NULL, PERIOD_H1, iTime(NULL, PERIOD_D1, DailyShift), false);
            EndBarShift -= 24 - iShiftHours - 1;
         }
         
         // check for valid end hourly bar shift (non-negative)
         if (EndBarShift > 0)
         {
            // get shifted end time
            // NOTE: add another hourly bar (1 less shift) so that there won't be any gaps in the lines
            EndTimeShift = iTime(NULL, PERIOD_H1, EndBarShift - 1);
         }
         else
         {
            // use current bar for end shift and calculate end time by adding a day to the shifted start time
            // NOTE: use the latest bar's time in case of weekend gaps, then add whatever hours are left
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_H1, 0) + (MathAbs(StartBarShift - 24) * 60 * 60);
         }
         
         // check for accurate start/end calculations
         // NOTE: this may happen on initial day and if day was shifted
         if (Shift == 0 && ShiftedFlag == -1)
         {
            // update start/end params
            StartTimeShift = EndTimeShift;
            StartBarShift = iBarShift(NULL, PERIOD_H1, StartTimeShift, false);
            
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_H1, 0) + (MathAbs(StartBarShift - 24) * 60 * 60);
         }
      }
   }
   
   // check for valid params on exit
   if (StartBarShift < 0 || EndBarShift < 0 ||
       StartTimeShift <= 0 || EndTimeShift <= 0)
   {
      error = -1;
   }
   
   return error;
}

int GetShiftInfoWeekly( int Shift,
                  int &StartBarShift,
                  int &EndBarShift,
                  datetime &StartTimeShift,
                  datetime &EndTimeShift)
{
   int error = 0;
   int ShiftedFlag = 0;
   int tempBarShift = 0;
   int DailyShift = Shift;    // in case if modified
   
   // reset params on entry
   StartBarShift = -1;
   EndBarShift = -1;
   StartTimeShift = 0;
   EndTimeShift = 0;
   
   // first, calculate hourly shift for current day overlaps
   tempBarShift = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_W1, 0), false);
   tempBarShift += iShiftDay;
   
   // check if hourly shift is negative
   // NOTE: this may happen on iShiftHours < 0 and day open is near
   if (tempBarShift < 0)
   {
      // add a day shift for accurate pivot calculations and set shifted flag
      DailyShift++;
      ShiftedFlag = 1;
   }
   // check if hourly shift is over a day (24 hours)
   // NOTE: this may happen on iShiftHours > 0 and day close is near
   else if (/*iShiftHours > 0 && */tempBarShift > 24)
   {
      // subtract a day shift for accurate pivot calculations and set shifted flag
      // NOTE: shift cannot be negative
      if (DailyShift > 0)
      {
         DailyShift--;
      }
      ShiftedFlag = -1;
   }
   
   // get the shift for the start bar (shift in hours for the start of day)
   StartBarShift = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_W1, DailyShift), false);
   StartBarShift += iShiftDay-1;
   
   // check for valid start hourly bar shift (non-negative)
   if (StartBarShift >= 0)
   {
      // get shifted start time and check if valid (greater than zero)
      StartTimeShift = iTime(NULL, PERIOD_D1, StartBarShift);
      if (StartTimeShift > 0)
      {
         // check for current/future shift calculation
         if (DailyShift > 0)
         {
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            EndBarShift = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_W1, DailyShift - 1), false);
            EndBarShift += iShiftDay;
         }
         else
         {            
            // get the shift for the end bar (shift in hours for the end of day)
            // NOTE: end bar shift should be 1 hour before the end of day for accurate pivot calculations (day close = last hour close)
            // NOTE: use the current daily shift instead (= 0, same as start) and shift hours right
            EndBarShift = iBarShift(NULL, PERIOD_D1, iTime(NULL, PERIOD_W1, DailyShift), false);
            EndBarShift -= 24 - iShiftDay - 1;
         }
         
         // check for valid end hourly bar shift (non-negative)
         if (EndBarShift > 0)
         {
            // get shifted end time
            // NOTE: add another hourly bar (1 less shift) so that there won't be any gaps in the lines
            EndTimeShift = iTime(NULL, PERIOD_D1, EndBarShift - 1);
         }
         else
         {
            // use current bar for end shift and calculate end time by adding a day to the shifted start time
            // NOTE: use the latest bar's time in case of weekend gaps, then add whatever hours are left
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_D1, 0) + (MathAbs(StartBarShift - 5) * PERIOD_D1 * 60);
         }
         
         // check for accurate start/end calculations
         // NOTE: this may happen on initial day and if day was shifted
         if (Shift == 0 && ShiftedFlag == -1)
         {
            // update start/end params
            StartTimeShift = EndTimeShift;
            StartBarShift = iBarShift(NULL, PERIOD_D1, StartTimeShift, false);
            
            EndBarShift = 0;
            EndTimeShift = iTime(NULL, PERIOD_D1, 0) + (MathAbs(StartBarShift - 5) * PERIOD_D1 * 60);
         }
      }
   }
   
   // check for valid params on exit
   if (StartBarShift < 0 || EndBarShift < 0 ||
       StartTimeShift <= 0 || EndTimeShift <= 0)
   {
      error = -1;
   }
   
   return error;
}

//+------------------------------------------------------------------+
// GetPivotPoints - This function will calculate the pivot points and
//    midpoint levels for the timeframe and shift specified. This 
//    function also checks if there is a GMT offset on the daily time
//    frame and adjust the pivot calculations accordingly.
//+------------------------------------------------------------------+
int GetPivotPoints(  ENUM_TIMEFRAMES TimeFrame,
                     int Shift,
                     double &PP,
                     double &KK,
                     double &RA,
                     double &barHigh,
                     double &barLow)
{
   double barOpen = 0.0;
   double barClose = 0.0;
   barHigh = 0.0;
   barLow = 0.0;
   double range = 0.0;
   int startBarShift = 0;
   int endBarShift = 0;
   datetime startTimeShift = 0;
   datetime endTimeShift = 0;
   
   // clear output params on entry
   PP = 0.0;
   KK = 0.0;
   RA = 0.0;
   
   // calculate daily bar start/end hourly shift for shifted hours
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // get start/end bar shift info
      // NOTE: time shift is not used in this function
      GetShiftInfo(Shift, startBarShift, endBarShift, startTimeShift, endTimeShift);
   }
   if (TimeFrame == PERIOD_W1 && iShiftDay != 0)
   {
      // get start/end bar shift info
      // NOTE: time shift is not used in this function
      GetShiftInfoWeekly(Shift, startBarShift, endBarShift, startTimeShift, endTimeShift);
   }  
   // get bar open price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
      barOpen = Shift > 0 ?iOpen(_Symbol, PERIOD_H1, endBarShift - 1) : iOpen(_Symbol, TimeFrame, Shift);
   else if (TimeFrame == PERIOD_W1 && iShiftDay != 0)
      barOpen = Shift > 0 ?iOpen(_Symbol, PERIOD_D1, endBarShift - 1) :iOpen(_Symbol, TimeFrame, Shift);
   else
      barOpen = iOpen(_Symbol, TimeFrame, MathMax(Shift - 1, 0));
   if (barOpen == 0)
   {
      // print error to log and exit function
      int error = GetLastError();
      Print("<= Error getting current bar open => ", error);
      return error;
   }
   
   // get bar close price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
      barClose = iClose(_Symbol, PERIOD_H1, endBarShift);
   else if (TimeFrame == PERIOD_W1 && iShiftDay != 0)
      barClose = iClose(_Symbol, PERIOD_D1, endBarShift);
   else
      barClose = iClose(_Symbol, TimeFrame, Shift);
   if (barClose == 0)
   {
      // print error to log and exit function
      int error = GetLastError();
      Print("<= Error getting current bar close => ", error);
      return error;
   } 
   
   // get bar high price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // NOTE: iHighest function has an inclusive count
      barHigh = iHigh(_Symbol, PERIOD_H1, iHighest(_Symbol, PERIOD_H1, MODE_HIGH, startBarShift - endBarShift + 1, endBarShift));
   }
   else if (TimeFrame == PERIOD_W1 && iShiftDay != 0)
   {
      // NOTE: iHighest function has an inclusive count
      barHigh = iHigh(_Symbol, PERIOD_D1, iHighest(_Symbol, PERIOD_D1, MODE_HIGH, startBarShift - endBarShift + 1, endBarShift));
   }
   else
   {
      barHigh = iHigh(_Symbol, TimeFrame, Shift);
   }
   if (barHigh == 0)
   {
      // print error to log and exit function
      int error = GetLastError();
      Print("<= Error getting current bar high => ", error);
      return error;
   }
   
   // get bar low price and check for error
   // NOTE: check for daily period and shift hours enabled
   if (TimeFrame == PERIOD_D1 && iShiftHours != 0)
   {
      // NOTE: iLowest function has an inclusive count
      barLow = iLow(_Symbol, PERIOD_H1, iLowest(_Symbol, PERIOD_H1, MODE_LOW, startBarShift - endBarShift + 1, endBarShift));
   }
   else if (TimeFrame == PERIOD_W1 && iShiftDay != 0)
   {
      // NOTE: iLowest function has an inclusive count
      barLow = iLow(_Symbol, PERIOD_D1, iLowest(_Symbol, PERIOD_D1, MODE_LOW, startBarShift - endBarShift + 1, endBarShift));
   }
   else
   {
      barLow = iLow(_Symbol, TimeFrame, Shift);
   }
   if (barLow == 0)
   {
      // print error to log and exit function
      int error = GetLastError();
      Print("<= Error getting current bar low => ", error);
      return error;
   }
   // Quarter (3MN) and Yearly (YR) calculations
   if(TimeFrame == PERIOD_MN1 && gMonthsCount>1 ) 
   {
      int startHTFshift = iBarShift(NULL,TimeFrame,TimeStartHTF);
      int stopHTFshift  = iBarShift(NULL,TimeFrame,TimeStopHTF);
      barOpen  =iOpen(_Symbol,TimeFrame,startHTFshift);
      barClose = iClose(_Symbol,TimeFrame,0);
      barHigh = 0.0;
      barLow  = EMPTY_VALUE;
      for(int ii=startHTFshift; ii>=startHTFshift-gMonthsCount+1;ii--)
      {
         barHigh  = MathMax(barHigh,iHigh(_Symbol,TimeFrame,ii+gMonthsCount));
         barLow   = MathMin(barLow,iLow(_Symbol,TimeFrame,ii+gMonthsCount));
      }
      if (Shift == 0)
      {
         barHigh = 0.0;
         barLow = EMPTY_VALUE;
         int m = 0;
         if (iTimePeriodReal == Period_Year)
            m = Month();
         if (iTimePeriodReal == Period_Quarter)
            m = cc3MN();
         for (int ii = 0; ii <= m - 1; ii++)
         {
            barHigh = MathMax(barHigh,iHigh(_Symbol,TimeFrame,ii));
            barLow = MathMin(barLow,iLow(_Symbol,TimeFrame,ii));
         }
      }
   } 
   
   // calculate OP, KK and Range
   if( Shift>0 ) PP =barOpen;
      else PP = barClose;
   
   RA = barHigh - barLow;
   KK = barHigh - RA*0.5;
     
   return 0;
}

int Month()
{
   MqlDateTime dt;
   TimeCurrent(dt);
   return dt.mon;
}

int cc3MN() 
{
   switch(Month())
   {
      case 1  : return(1); break;
      case 2  : return(2); break;
      case 3  : return(3); break;
      case 4  : return(1); break;
      case 5  : return(2); break;        
      case 6  : return(3); break;        
      case 7  : return(1); break;        
      case 8  : return(2); break;        
      case 9  : return(3); break;        
      case 10 : return(1); break;        
      case 11 : return(2); break;        
      case 12 : return(3); break;        
        break;
      default:
        break;
   }
   return(0);
}
//+------------------------------------------------------------------+
// DeleteAllObjects - This function will delete all objects from the
//    chart for all history counts and future counts. 
//+------------------------------------------------------------------+
void DeleteAllObjects()
{
   for (int k=ObjectsTotal(0); k>=0; k--)
   {
      if( StringFind(ObjectName(0, k),(string)magicID + " _ " + gPeriod)>-1 )
         ObjectDelete(0, ObjectName(0, k));
      if( StringFind(ObjectName(0, k),(string)magicID + " _ " + "F" + gPeriod)>-1 )
         ObjectDelete(0, ObjectName(0, k));
   }
   return;
}

void ButtonsDelete()
{
   for( int k=ObjectsTotal(0); k>=0; k-- ) {
      if( StringFind(ObjectName(0, k),(string)magicID + "_BT_") >-1 ) 
         ObjectDelete(0, ObjectName(0, k));
   }
   return;
}

//+------------------------------------------------------------------+
// PlotTrend - This function will plot a pivot level to the chart. 
//+------------------------------------------------------------------+
bool PlotTrend(const long              Chart_ID = 0,
               string                  Name = "trendline",
               const int               Subwindow = 0,
               datetime                Time1 = 0,
               double                  Price1 = 0,
               datetime                Time2 = 0,
               double                  Price2 = 0,             
               const color             Clr = clrBlack,
               const int               Style = STYLE_SOLID,
               const int               Width = 2,
               const bool              Back = true,
               const bool              Selection = false,
               const bool              Ray = false,
               const bool              Hidden = true,
               const string            Tooltip = "\n")
{
   if (ObjectFind(Chart_ID, Name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(Chart_ID, Name, OBJ_TREND, Subwindow, Time1, Price1, Time2, Price2))
      {
         Print(__FUNCTION__, ": failed to create trendline = "+Name+" error:", GetLastError());
         return(false);
      }
   }
   ObjectSetDouble(Chart_ID, Name, OBJPROP_PRICE, 0, Price1);
   ObjectSetDouble(Chart_ID, Name, OBJPROP_PRICE, 1, Price2);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_TIME, 0, Time1);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_TIME, 1, Time2);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_STYLE, Style);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_WIDTH, Width);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_BACK, Back);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTED, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_RAY, Ray);
   ObjectSetString(Chart_ID, Name, OBJPROP_TOOLTIP, Tooltip);
   return(true);
}

//+------------------------------------------------------------------+
// PlotRectangle - This function will plot a take profit zone to the chart. 
//+------------------------------------------------------------------+
bool PlotRectangle(  const long        Chart_ID = 0,
                     string            Name = "rectangle", 
                     const int         Subwindow = 0,
                     datetime          Time1 = 0,
                     double            Price1 = 1,
                     datetime          Time2 = 0, 
                     double            Price2 = 0, 
                     const color       Clr = clrGray,
                     const bool        Back = true,
                     const bool        Selection = false,
                     const bool        Hidden = true,
                     const string      Tooltip = "\n")
{
   if (ObjectFind(Chart_ID, Name) < 0)
   {
      if(!ObjectCreate(Chart_ID, Name, OBJ_RECTANGLE, Subwindow, Time1, Price1, Time2, Price2))
      {
         Print(__FUNCTION__, ": failed to create rectangle = ", GetLastError());
         return(false);
      }
   }
   ObjectSetDouble(Chart_ID, Name, OBJPROP_PRICE, 0, Price1);
   ObjectSetDouble(Chart_ID, Name, OBJPROP_PRICE, 1, Price2);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_TIME, 0, Time1);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_TIME, 1, Time2);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_BACK, Back);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetString(Chart_ID, Name, OBJPROP_TOOLTIP, Tooltip);
   return(true);
}

//+------------------------------------------------------------------+
// PlotText - This function will plot a text box to the chart. Used to
//    plot pivot labels and prices. 
//+------------------------------------------------------------------+
bool PlotText(       const long        Chart_ID = 0,
                     string            Name = "text", 
                     const int         Subwindow = 0,
                     datetime          Time1 = 0, 
                     double            Price1 = 0, 
                     const string      Text = "text",
                     const string      Font = "Arial",
                     const int         Font_size = 10,
                     const color       Clr = clrGray,
                     const int         Anchor = ANCHOR_RIGHT_UPPER,
                     const bool        Back = true,
                     const bool        Selection = false,
                     const bool        Hidden = true,
                     const string      Tooltip = "\n")
{
   if (ObjectFind(Chart_ID, Name) < 0)
   {
      ResetLastError();
      if(!ObjectCreate(Chart_ID, Name, OBJ_TEXT, Subwindow, Time1, Price1))
      {
         Print(__FUNCTION__,": failed to create text = ",GetLastError());
         return(false);
      }
   }
   ObjectSetDouble(Chart_ID, Name, OBJPROP_PRICE, 0, Price1);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_TIME, 0, Time1);
   ObjectSetString(Chart_ID, Name, OBJPROP_TEXT, Text);
   ObjectSetString(Chart_ID, Name, OBJPROP_FONT, Font);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_FONTSIZE, Font_size);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_COLOR, Clr);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_ANCHOR, Anchor);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTABLE, Selection);
   ObjectSetInteger(Chart_ID, Name, OBJPROP_SELECTED, Selection);
   ObjectSetString(Chart_ID, Name, OBJPROP_TOOLTIP, Tooltip);
   return(true);
} 

//+------------------------------------------------------------------+
// OnTimer - This timer event handler will resend push notifications
//    in case of a frequency violation. According to MT4, no more than
//    2 notifications per second or 10 notifications per minute. This
//    function will try sending again on every second elapsed.
//    In the event that the queue gets maxed out this function will
//    flush all queued notifications.
//+------------------------------------------------------------------+
void OnTimer()
{
   int error = 0;
   int i = 0;
   
   // check if notification queue is not empty
   if (gNumNotificationQueue > 0 && gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
   {
      // loop through all queued notifications and try to send them
      for (i = 0; i < gNumNotificationQueue; i++)
      {
         // check if string queue is not empty
         if (StringLen(gNotificationQueue[i]) > 0)
         {
            // send notification and check for error
            if (SendNotification(gNotificationQueue[i]) == false)
            {
               // print error to log and exit (possibly too frequent)
               error = GetLastError();
               Print("<= Error sending notification => ", error);
               return;
            }
            else
            {
               // notification was sent successfully... clear string buffer and exit
               // NOTE: will send the next notification on the next timer elapsed
               gNotificationQueue[i] = "";
               return;
            }
         }
      }  // end of notification queue (for loop)
      
      // check if sending all notifications was a success and reset queue num
      if (error == 0)
      {
         gNumNotificationQueue = 0;
      }
   }  // end of notification buffer check (if statement)
   else if (gNumNotificationQueue >= MAX_NUM_NOTIFICATION_QUEUE)
   {
      // queue buffer is maxed out and terminal cannot keep up... flush buffer to start over
      for (i = 0; i < gNumNotificationQueue; i++)
      {
         gNotificationQueue[i] = "";
      }
      gNumNotificationQueue = 0;
   }
   
   return;
}

//+------------------------------------------------------------------+
// SendPushNotifications - This function will calculate the current
//    period's pivot points and send them as push notifications to the
//    terminal.
//+------------------------------------------------------------------+
int SendPushNotifications(void)
{
   int error = 0;
   double pivP = 0.0;
   double kk   = 0.0;
   double range= 0.0;
   double high = 0.0;
   double low  = 0.0;
   double res1 = 0.0;
   double res2 = 0.0;
   double res3 = 0.0;
   double sup1 = 0.0;
   double sup2 = 0.0;
   double sup3 = 0.0;
   double mid0 = 0.0;
   double mid1 = 0.0;
   double mid2 = 0.0;
   double mid3 = 0.0;
   double mid4 = 0.0;
   double mid5 = 0.0;
   string msg = "";
   string pivMsg = "";
   string midMsg = "";
   int startBarShift = 0;
   int endBarShift = 0;
   datetime currBarTime = 0;
   datetime endTimeShift = 0;
   double currBarPrice = 0.0;
   
   if (iTimePeriodReal == Period_Daily && iShiftHours != 0)
   {   
      // NOTE: only the start time shift is used in this function
      error = GetShiftInfo(0, startBarShift, endBarShift, currBarTime, endTimeShift);
   }
   else
   {
      if (gRealTimePeriod <= PERIOD_MN1) 
      {
         // get the current bar time and check for error for existing timeframes
         currBarTime = iTime(NULL, gRealTimePeriod, 0);
         if (currBarTime == 0)
         {
            // print error to log and exit function
            error = GetLastError();
            Print("<= Error getting current bar time => ", error);
            return error;
         }
      }
   }
   
   currBarPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   if (currBarPrice == 0)
   {
      // print error to log and exit function
      error = GetLastError();
      Print("<= Error getting current bid price => ", error);
      return error;
   }
   
   // get pivot points and midpoint levels for current period (shift = 1)
   error = GetPivotPoints(gRealTimePeriod, 1, pivP, kk, range, high, low);
   if (error != 0)
      return error;
   
   // create pivots message if enabled
   if (iPlotPivots)
   {
      pivMsg = ", " + gPeriod + " - R3: " + DoubleToString(res3, Digits()) +
               ", " + gPeriod + " - R2: " + DoubleToString(res2, Digits()) +
               ", " + gPeriod + " - R1: " + DoubleToString(res1, Digits()) +
               ", " + gPeriod + " - PP: " + DoubleToString(pivP, Digits()) + 
               ", " + gPeriod + " - KK: " + DoubleToString(kk, Digits()) +
               ", " + gPeriod + " - S1: " + DoubleToString(sup1, Digits()) +
               ", " + gPeriod + " - S2: " + DoubleToString(sup2, Digits()) +
               ", " + gPeriod + " - S3: " + DoubleToString(sup3, Digits());
   }
   
   // create midpoints message if enabled
   if (iPlotMidpoints)
   {     
      midMsg = ", " + gPeriod + " - M5: " + DoubleToString(mid5, Digits()) +
         ", " + gPeriod + " - M4: " + DoubleToString(mid4, Digits()) +
         ", " + gPeriod + " - M3: " + DoubleToString(mid3, Digits()) +
         ", " + gPeriod + " - M2: " + DoubleToString(mid2, Digits()) +
         ", " + gPeriod + " - M1: " + DoubleToString(mid1, Digits()) +
         ", " + gPeriod + " - M0: " + DoubleToString(mid0, Digits());
   }
   
   // check for push notifications enabled
   if (iPushNotifications_AllPivotsMidpoints == true &&
         (gPrevTimePivot == 0 || gPrevTimePivot != currBarTime))   // initial program start or a new time period has begun
   {
	   // update prev time global to current period so we wont enter here again
      gPrevTimePivot = currBarTime;
      
      // add push notification to queue and print msg to log
      Print(Symbol() + pivMsg + midMsg);
      if (gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
      {
         gNotificationQueue[gNumNotificationQueue] = Symbol() + pivMsg + midMsg;
         gNumNotificationQueue++;
      }
   }
   
   // check/send pivot point touches
   SendPushNotifications_Touch(iPushNotifications_TouchPP, "PP", pivP, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchPP, "KK", kk, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR1S1, "R1", res1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR1S1, "S1", sup1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR2S2, "R2", res2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR2S2, "S2", sup2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR3S3, "R3", res3, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchR3S3, "S3", sup3, currBarPrice);
   
   // check/send midpoint touches
   SendPushNotifications_Touch(iPushNotifications_TouchM2M3, "M2", mid2, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM2M3, "M3", mid3, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM1M4, "M1", mid1, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM1M4, "M4", mid4, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM0M5, "M0", mid0, currBarPrice);
   SendPushNotifications_Touch(iPushNotifications_TouchM0M5, "M5", mid5, currBarPrice);

   return error;
}

//+------------------------------------------------------------------+
// SendPushNotifications_Touch - This function will check if the touch
//    feature is enabled and calculate if the current price is near
//    the target price in order to send a price alert as a push 
//    notification to the terminal. The function will also check if 
//    the notification has already been sent to avoid multiple sends.
//
// Returns: 0 = not sent; 1 = was sent.
//+------------------------------------------------------------------+
int SendPushNotifications_Touch( bool FeatureEnabled,
                                 string LevelStr,
                                 double TargetPrice,
                                 double CurrBarPrice)
{
   int sent = 0;
   string msg = "";
   
   // check if previous touch price has been initialized
   // NOTE: happens during initial program load or system reset
   if (gPrevTouchPrice < 0.0000001)
   {
      gPrevTouchPrice = CurrBarPrice;
   }
   
   // check if feature is enabled and at target price
   if (FeatureEnabled == true &&
       MathAbs(TargetPrice - gPrevTouchPrice) > 0.0000001 &&                 // price has not already touched before (double compare)
         (MathAbs(TargetPrice - CurrBarPrice) <= gTouchToleranceDecimal ||   // current price is close to target price -or-
          (gPrevTouchPrice < TargetPrice && TargetPrice < CurrBarPrice) ||   // target price is between last touch and current price (gaps)
          (gPrevTouchPrice > TargetPrice && TargetPrice > CurrBarPrice)))
   {
      // update prev touch price global to target price so we wont enter here again
      gPrevTouchPrice = TargetPrice;
      
      // add push notification to queue and print msg to log
      msg = Symbol() + ", Price touched " + gPeriod + LevelStr + " at " + DoubleToString(TargetPrice, Digits());
      Print(msg);
      if (gNumNotificationQueue < MAX_NUM_NOTIFICATION_QUEUE)
      {
         gNotificationQueue[gNumNotificationQueue] = msg;
         gNumNotificationQueue++;
      }
      
      // set notification sent return variable
      sent = 1;
   }
   
   return sent;
}

string TF[] = { "M1","M5","M15","M30","H1","H4","D1","W1","MN1","MN3","YR1" };

void guiRefresh() {
   for( int i=10; i>=0; i-- ) {
      if ( gPeriod==TF[i] ) ObjectSetInteger(0,(string)magicID + "_BT_" + TF[i],OBJPROP_STATE,true);
         else ObjectSetInteger(0,(string)magicID + "_BT_" + TF[i],OBJPROP_STATE,false);
   }
}

void guiCreate() {
   for( int i=10; i>=0; i-- ) {
      ButtonCreate((string)magicID + "_BT_" + TF[10-i],50+(30*i),20,30,20,TF[10-i]); 
   }
}

//+------------------------------------------------------------------+
//|                Chart events and button's actions                 |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam
                 )
{
   if(id==CHARTEVENT_OBJECT_CLICK )
   {
      if(StringFind(sparam,"_BT_",0)>-1)  
      {
         string tf = StringSubstr(sparam,5,3);
         if( tf == "M1" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_M1);
         if( tf == "M5" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_M5);
         if( tf == "M15" ) GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_M15);
         if( tf == "M30" ) GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_M30);
         if( tf == "H1" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_H1);
         if( tf == "H4" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_H4);
         if( tf == "D1" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_Daily);
         if( tf == "W1" )  GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_Weekly);
         if( tf == "MN1" ) GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_Monthly);
         if( tf == "MN3" ) GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_Quarter);
         if( tf == "YR1" ) GlobalVariableSet((string)+magicID+"_iTimePeriod",Period_Year);
         OnDeinit(REASON_PARAMETERS);
         DoInit();
         guiRefresh();
      }
   }     
}

bool ButtonCreate      ( const string            name="Button",            // button name
                         const int               x=10,                     // X coordinate
                         const int               y=10,                     // Y coordinate
                         const int               width=20,                 // button width
                         const int               height=20,                // button height
                         const string            text="",                  // text
                         const string            tooltip="\n",             // tooltip
                         const int               font_size=8,              // font size
                         const string            font="Arial",             // font
                         const color             clr=clrBlack,             // text color
                         const color             back_clr=clrLightGray     // background color
                         )
{
//--- reset the error value
   ResetLastError();
   if(ObjectFind(0,name)>-1)  
      return(false); 

//--- create a text label
   if(!ObjectCreate(0,name,OBJ_BUTTON,0,0,0))
   {
      Print(__FUNCTION__,
            ": failed to create button! Error code = ",GetLastError());
      return(false);
   }
   ObjectCreate(0,name,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(0,name,OBJPROP_CORNER, CORNER_RIGHT_UPPER);
   ObjectSetString(0,name,OBJPROP_FONT,font);
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetString(0,name,OBJPROP_TEXT,text);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_STATE,false);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,10);
   ObjectSetString(0,name,OBJPROP_TOOLTIP,tooltip);
   return(true);
} 