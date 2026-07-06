// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70620

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

// based on Scriptong, http://advancetools.net
#property description "Displaying of the divergence based on the testimony of various indicators."
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1  clrDodgerBlue

#property indicator_level1 0.0

enum ENUM_YESNO
{
   NO,                                                                                             // No
   YES                                                                                             // Yes
};

enum ENUM_ONOFF
{
   OFF,                                                                                            // Off
   ON                                                                                              // On
};

enum ENUM_INDICATOR_TYPE
{
   RSI,                                                                                            // RSI
   MACD,                                                                                           // MACD  
   MOMENTUM,                                                                                       // Momentum
   RVI,                                                                                            // RVI
   STOCHASTIC,                                                                                     // Stochastic
   CCI,                                                                                            // CCI
   StdDev,                                                                                         // Standart deviation
   DERIVATIVE,                                                                                     // Derivative
   WILLIAM_BLAU,                                                                                   // William Blau
   CUSTOM                                                                                          // Custom
};

enum ENUM_EXTREMUM_TYPE
{
   EXTREMUM_TYPE_NONE,  
   EXTREMUM_TYPE_MIN,
   EXTREMUM_TYPE_MAX
};

enum ENUM_MARKET_APPLIED_PRICE
{
   MARKET_APPLIED_PRICE_CLOSE,                                                                     // Close/Close  
   MARKET_APPLIED_PRICE_HIGHLOW                                                                    // High/Low  
};

enum ENUM_PRICE_TYPE
{
   PRICE_TYPE_INDICATOR,
   PRICE_TYPE_MARKET  
};

enum ENUM_CUSTOM_PARAM_CNT
{
   PARAM_CNT_0,                                                                                    // 0  
   PARAM_CNT_1,                                                                                    // 1  
   PARAM_CNT_2,                                                                                    // 2  
   PARAM_CNT_3,                                                                                    // 3  
   PARAM_CNT_4,                                                                                    // 4  
   PARAM_CNT_5,                                                                                    // 5  
   PARAM_CNT_6,                                                                                    // 6  
   PARAM_CNT_7,                                                                                    // 7  
   PARAM_CNT_8,                                                                                    // 8  
   PARAM_CNT_9,                                                                                    // 9  
   PARAM_CNT_10,                                                                                   // 10  
   PARAM_CNT_11,                                                                                   // 11  
   PARAM_CNT_12,                                                                                   // 12  
   PARAM_CNT_13,                                                                                   // 13  
   PARAM_CNT_14,                                                                                   // 14  
   PARAM_CNT_15,                                                                                   // 15  
   PARAM_CNT_16,                                                                                   // 16  
   PARAM_CNT_17,                                                                                   // 17  
   PARAM_CNT_18,                                                                                   // 18  
   PARAM_CNT_19,                                                                                   // 19  
   PARAM_CNT_20                                                                                    // 20  
};


// Input parameters of indicator
input ENUM_INDICATOR_TYPE      i_indicatorType       = WILLIAM_BLAU;                               // Base indicator
input int                      i_divergenceDepth     = 20;                                         // Depth of 2nd ref. point search

input string                   i_string1             = "The base indicator parameters";            // ============================
input int                      i_barsPeriod1         = 8000;                                       // First calculate period
input int                      i_barsPeriod2         = 2;                                          // Second calculate period
input int                      i_barsPeriod3         = 1;                                          // Third calculate period
input ENUM_APPLIED_PRICE       i_indAppliedPrice     = PRICE_CLOSE;                                // Applied price of indicator
input ENUM_MA_METHOD           i_indMAMethod         = MODE_EMA;                                   // MA calculate method

input string                   i_string2             = "Price extremum parameters";            // ============================
input int                      i_findExtInterval     = 10;                                         // Price ext. to indicator ext.
input ENUM_MARKET_APPLIED_PRICE i_marketAppliedPrice = MARKET_APPLIED_PRICE_CLOSE;                 // Applied price of market

input string                   i_string3             = "Custom indicator";            // ============================
input string                   i_customName          = "Sentiment_Line";                           // The name of indicator
input int                      i_customBuffer        = 0;                                          // Index of data buffer
input ENUM_CUSTOM_PARAM_CNT    i_customParamCnt      = PARAM_CNT_3;                                // Amount of ind. parameters
input double                   i_customParam1        = 13.0;                                       // Value of the 1st parameter
input double                   i_customParam2        = 1.0;                                        // Value of the 2nd parameter
input double                   i_customParam3        = 0.0;                                        // Value of the 3rd parameter
input double                   i_customParam4        = 0.0;                                        // Value of the 4th parameter
input double                   i_customParam5        = 0.0;                                        // Value of the 5th parameter
input double                   i_customParam6        = 0.0;                                        // Value of the 6th parameter
input double                   i_customParam7        = 0.0;                                        // Value of the 7th parameter
input double                   i_customParam8        = 0.0;                                        // Value of the 8th parameter
input double                   i_customParam9        = 0.0;                                        // Value of the 9th parameter
input double                   i_customParam10       = 0.0;                                        // Value of the 10th parameter
input double                   i_customParam11       = 0.0;                                        // Value of the 11th parameter
input double                   i_customParam12       = 0.0;                                        // Value of the 12th parameter
input double                   i_customParam13       = 0.0;                                        // Value of the 13th parameter
input double                   i_customParam14       = 0.0;                                        // Value of the 14th parameter
input double                   i_customParam15       = 0.0;                                        // Value of the 15th parameter
input double                   i_customParam16       = 0.0;                                        // Value of the 16th parameter
input double                   i_customParam17       = 0.0;                                        // Value of the 17th parameter
input double                   i_customParam18       = 0.0;                                        // Value of the 18th parameter
input double                   i_customParam19       = 0.0;                                        // Value of the 19th parameter
input double                   i_customParam20       = 0.0;                                        // Value of the 20th parameter

input string                   i_string4             = "Filters";                        // ============================
input ENUM_ONOFF               i_useCoincidenceCharts = OFF;                                       // The coincidence of charts
input ENUM_ONOFF               i_excludeOverlaps     = OFF;                                        // Exclude overlaps of lines

input string                   i_string5             = "Parameters of displaying";                    // ============================
input ENUM_YESNO               i_isAlert             = YES;                                        // Alert on divergence?
input ENUM_YESNO               i_isPush              = YES;                                        // Notification on divergence?
input string                   i_string4_1           = "Divergence class A";// ============================
input ENUM_YESNO               i_showClassA          = YES;                                        // Show
input color                    i_bullsDivAColor      = clrBlue;                                    // Color of bulls divergence line
input color                    i_bearsDivAColor      = clrRed;                                     // Color of bears divergence line
input string                   i_string4_2           = "Divergence class B";// ============================
input ENUM_YESNO               i_showClassB          = NO;                                         // Show
input color                    i_bullsDivBColor      = clrDodgerBlue;                              // Color of bulls divergence line
input color                    i_bearsDivBColor      = clrMaroon;                                  // Color of bears divergence line
input string                   i_string4_3           = "Divergence class C";// ============================
input ENUM_YESNO               i_showClassC          = NO;                                         // Show
input color                    i_bullsDivCColor      = clrDeepSkyBlue;                             // Color of bulls divergence line
input color                    i_bearsDivCColor      = clrPurple;                                  // Color of bears divergence line
input string                   i_string4_4           = "Hidden divergence";  // ============================
input ENUM_YESNO               i_showHidden          = NO;                                         // Show
input color                    i_bullsDivHColor      = clrYellowGreen;                             // Color of bulls divergence line
input color                    i_bearsDivHColor      = clrIndigo;                                  // Color of bears divergence line
input int                      i_indBarsCount        = 10000;                                      // The number of bars to display

// The indicator's buffers
double            g_indValues[];
double            g_tempBuffer[];

// Other global variables of indicator
bool              g_activate;                                                                      // Sign of successful initialization of indicator
    
int               g_indSubWindow;                                                                  // Subwindow index of indicator

datetime          g_lastDivergenceTime;                                                            // Time of bar of right
                                                                                                  
string            g_indName,                                                                       // The unique name of the indicator for easy location indicator subwindow
                  g_tfName;                                                                        // Name of current TF
      
#define PREFIX                                  "DIVVIEW_"                                         // Prefix the name of the graphic objects which displayed by indicator

#define TITLE_CLASS_A                           "Class A"
#define TITLE_CLASS_B                           "Class B"
#define TITLE_CLASS_C                           "Class C"
#define TITLE_CLASS_H                           "Hidden divergence"
    
    
string IndicatorObjPrefix;

bool NamesCollision(const string name)
{
   for (int k = ObjectsTotal(); k >= 0; k--)
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

//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator initialization function                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("dd");
   g_activate = false;                                                                            
  
   if (!IsTuningParametersCorrect())                                                              
      return INIT_FAILED;                                
      
   if (!BuffersBind())                            
      return (INIT_FAILED);                                
        
   g_tfName = GetCurrentTFName();
   g_indSubWindow = -1;
   g_lastDivergenceTime = 0;            
   g_activate = true;                                                                              
   return INIT_SUCCEEDED;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the correctness of input parameters                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsTuningParametersCorrect()
{
   string name = WindowExpertName();
  
   if (i_divergenceDepth < 1)
   {
      Alert(name, ": depth search for the second reference point should be 1 or more bars. The indicator is turned off.");
      return false;
   }

   if (i_barsPeriod1 < 1)
   {
      Alert(name, ": the first amount of bars for calculate the indicator values is less then 1. The indicator is turned off.");
      return false;
   }

   if (i_barsPeriod2 < 1)
   {
      Alert(name, ": the second amount of bars for calculate the indicator values is less then 1. The indicator is turned off.");
      return false;
   }

   if (i_barsPeriod3 < 1)
   {
      Alert(name, ": the third amount of bars for calculate the indicator values is less then 1. The indicator is turned off.");
      return false;
   }

   if (i_findExtInterval < 1)
   {
      Alert(name, ": the interval of search of price extremum must be greater than zero bars. The indicator is turned off.");
      return false;
   }

   return (true);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Defining the current TF name                                                                                                                                                                      |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetCurrentTFName()
{
   switch(_Period)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D1";
      case PERIOD_W1: return "W1";
      case PERIOD_MN1: return "MN1";
   }
  
   return "U/D";
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Binding the indicator buffers with arrays                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool BuffersBind()
{
   if (i_indicatorType == WILLIAM_BLAU)
      IndicatorBuffers(2);
   string name = WindowExpertName();

   if (!SetIndexBuffer(0, g_indValues))
   {
      Alert(name, ": error of binding of the arrays and the indicator buffers. Error N" + IntegerToString(GetLastError()));
      return false;
   }
  
   if (i_indicatorType == WILLIAM_BLAU)
      if (!SetIndexBuffer(1, g_tempBuffer))
      {
         Alert(name, ": error of binding of the arrays and the indicator buffers. Error N" + IntegerToString(GetLastError()));
         return false;
      }

   SetIndexStyle(0, DRAW_LINE);
   if (i_indicatorType == WILLIAM_BLAU)
      SetIndexStyle(1, DRAW_NONE);
      
   g_indName = "DivViewer at " + GetBaseIndicatorName() + IntegerToString(GetTickCount());
   IndicatorShortName(g_indName);
  
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Defining the name of the base indicator                                                                                                                                                           |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetBaseIndicatorName()
{
   if (i_indicatorType == CUSTOM)
      return i_customName + " (" + DoubleToString(i_customParam1, 1) + ", " + DoubleToString(i_customParam2, 1) + ", " + DoubleToString(i_customParam3, 1) + ") ";
      
   return EnumToString(i_indicatorType) + " (" + IntegerToString(i_barsPeriod1) + ", " + IntegerToString(i_barsPeriod2) + ", " + IntegerToString(i_barsPeriod3) + ") ";
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator deinitialization function                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   DeleteAllObjects();
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Deleting of all graphical objects                                                                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void DeleteAllObjects()
{
   string prefix = PREFIX + IntegerToString(g_indSubWindow);
   int strLen = StringLen(prefix);
   for (int i = ObjectsTotal() - 1; i >= 0; i--)    
      if (StringSubstr(ObjectName(i), 0, strLen) == prefix)
         ObjectDelete(ObjectName(i));
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Displaying the trend line                                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowTrendLine(int subWindow, datetime time1, double price1, datetime time2, double price2, string toolTip, color clr)
{
   string name = PREFIX +  IntegerToString(g_indSubWindow) + IntegerToString(subWindow) + IntegerToString(time1) + IntegerToString(time2);
  
   if (ObjectFind(0, name) < 0)
   {
      ObjectCreate(0, name, OBJ_TREND, subWindow, time1, price1, time2, price2);
      ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, name, OBJPROP_BACK, false);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);
      ObjectSetInteger(0, name, OBJPROP_RAY, false);
      ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);
      ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
      ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
      return;
   }
  
   ObjectMove(0, name, 0, time1, price1);
   ObjectMove(0, name, 1, time2, price2);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetString(0, name, OBJPROP_TOOLTIP, toolTip);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determination of bar index which needed to recalculate                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetRecalcIndex(int& total, const int ratesTotal, const int prevCalculated)
{
   total = ratesTotal - 1;                                                                        
                                                  
   if (i_indBarsCount > 0 && i_indBarsCount < total)
      total = MathMin(i_indBarsCount, total);                      
                                                  
   if (prevCalculated < ratesTotal - 1)                    
   {      
      InitializeBuffers();
      return (total);
   }
  
   return (MathMin(ratesTotal - prevCalculated, total));                            
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Initialize of all indicator buffers                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void InitializeBuffers()
{
   ArrayInitialize(g_indValues, EMPTY_VALUE);
   ArrayInitialize(g_tempBuffer, EMPTY_VALUE);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculate the price value at the specified bar                                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetPrice(int barIndex)
{
   barIndex = (int) MathMin(Bars - 1, barIndex);

   switch (i_indAppliedPrice)
   {
      case PRICE_CLOSE:    return(Close[barIndex]);                  
      case PRICE_OPEN:     return(Open[barIndex]);                  
      case PRICE_HIGH:     return(High[barIndex]);                  
      case PRICE_LOW:      return(Low[barIndex]);                    
      case PRICE_MEDIAN:   return((High[barIndex] + Low[barIndex]) / 2);
      case PRICE_TYPICAL:  return((High[barIndex] + Low[barIndex] + Close[barIndex]) / 3);
      case PRICE_WEIGHTED: return((High[barIndex] + Low[barIndex] + 2 * Close[barIndex]) / 4);            
   }
  
   return 0.0;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculate the value of the custom indicator at the specified bar                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetCustomIndicatorValue(int barIndex)
{
   switch(i_customParamCnt)
   {
      case PARAM_CNT_0:    return iCustom(NULL, 0, i_customName, i_customBuffer, barIndex);
      case PARAM_CNT_1:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customBuffer, barIndex);
      case PARAM_CNT_2:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customBuffer, barIndex);
      case PARAM_CNT_3:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customBuffer, barIndex);
      case PARAM_CNT_4:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customBuffer, barIndex);
      case PARAM_CNT_5:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customBuffer, barIndex);
      case PARAM_CNT_6:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customBuffer, barIndex);
      case PARAM_CNT_7:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7,
                                          i_customBuffer, barIndex);
      case PARAM_CNT_8:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customBuffer, barIndex);
      case PARAM_CNT_9:    return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customBuffer, barIndex);
      case PARAM_CNT_10:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customBuffer, barIndex);
      case PARAM_CNT_11:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customBuffer, barIndex);
      case PARAM_CNT_12:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customBuffer, barIndex);
      case PARAM_CNT_13:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customBuffer, barIndex);
      case PARAM_CNT_14:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customBuffer, barIndex);
      case PARAM_CNT_15:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customBuffer, barIndex);
      case PARAM_CNT_16:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customParam16,
                                          i_customBuffer, barIndex);
      case PARAM_CNT_17:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customParam16, i_customParam17,
                                          i_customBuffer, barIndex);
      case PARAM_CNT_18:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customParam16, i_customParam17,
                                          i_customParam18, i_customBuffer, barIndex);
      case PARAM_CNT_19:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customParam16, i_customParam17,
                                          i_customParam18, i_customParam19, i_customBuffer, barIndex);
      case PARAM_CNT_20:   return iCustom(NULL, 0, i_customName, i_customParam1, i_customParam2, i_customParam3, i_customParam4, i_customParam5, i_customParam6, i_customParam7, i_customParam8,
                                          i_customParam9, i_customParam10, i_customParam11, i_customParam12, i_customParam13, i_customParam14, i_customParam15, i_customParam16, i_customParam17,
                                          i_customParam18, i_customParam19, i_customParam20, i_customBuffer, barIndex);
   }
  
   return 0.0;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculate the value of base indicator at the specified bar                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetBaseIndicatorValue(int barIndex)
{
   switch (i_indicatorType)
   {
      case RSI:         return iRSI(NULL, 0, i_barsPeriod1, i_indAppliedPrice, barIndex);
      case MACD:        return iMACD(NULL, 0, i_barsPeriod1, i_barsPeriod2, 1, i_indAppliedPrice, MODE_MAIN, barIndex);
      case MOMENTUM:    return iMomentum(NULL, 0, i_barsPeriod1, i_indAppliedPrice, barIndex);
      case RVI:         return iRVI(NULL, 0, i_barsPeriod1, MODE_MAIN, barIndex);
      case STOCHASTIC:  return iStochastic(NULL, 0, i_barsPeriod1, i_barsPeriod2, i_barsPeriod3, i_indMAMethod, 1, MODE_MAIN, barIndex);
      case CCI:         return iCCI(NULL, 0, i_barsPeriod1, i_indAppliedPrice, barIndex);
      case StdDev:      return iStdDev(NULL, 0, i_barsPeriod1, 0, i_indMAMethod, i_indAppliedPrice, barIndex);
      case DERIVATIVE:  return 100.0 * (GetPrice(barIndex) - GetPrice(barIndex + i_barsPeriod1)) / i_barsPeriod1;
      case CUSTOM:      return GetCustomIndicatorValue(barIndex);
   }
  
   return 0.0;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Receive the price of specified bar index                                                                                                                                                          |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetMarketPrice(int barIndex, ENUM_EXTREMUM_TYPE extremumType)
{
   if (barIndex < 0 || barIndex >= Bars)
      return 0.0;

   if (i_marketAppliedPrice == MARKET_APPLIED_PRICE_CLOSE)
      return Close[barIndex];
      
   if (extremumType == EXTREMUM_TYPE_MAX)
      return High[barIndex];
  
   return Low[barIndex];
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determining of the extremum type at the spesified element of speciefied array                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ENUM_EXTREMUM_TYPE GetBufferExtremum(int barIndex, int total, const double &buffer[])
{
   if (barIndex + 2 >= total || barIndex < 0)
   {
      Print("Possible error! ", __FUNCTION__, ", barIndex = ", barIndex, ", total bars = ", total);
      return EXTREMUM_TYPE_NONE;
   }

   double valueRight = buffer[barIndex];
   double valueCenter = buffer[barIndex + 1];
   double valueLeft = buffer[barIndex + 2];
  
   if (valueCenter < valueRight && valueCenter < valueLeft)
      return EXTREMUM_TYPE_MIN;
      
   if (valueCenter > valueRight && valueCenter > valueLeft)
      return EXTREMUM_TYPE_MAX;
      
   return EXTREMUM_TYPE_NONE;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determining whether an extremum of price at a specified bar                                                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
ENUM_EXTREMUM_TYPE GetMarketExtremum(int barIndex, int total, ENUM_EXTREMUM_TYPE desiredExtremum)
{
   if (i_marketAppliedPrice == MARKET_APPLIED_PRICE_HIGHLOW)
   {
      if (desiredExtremum != EXTREMUM_TYPE_MIN && GetBufferExtremum(barIndex, total, High) == EXTREMUM_TYPE_MAX)
         return EXTREMUM_TYPE_MAX;
        
      if (desiredExtremum != EXTREMUM_TYPE_MAX && GetBufferExtremum(barIndex, total, Low) == EXTREMUM_TYPE_MIN)
         return EXTREMUM_TYPE_MIN;
        
      return EXTREMUM_TYPE_NONE;
   }

   return GetBufferExtremum(barIndex, total, Close);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculating the coefficients K and B of the equation straight line through specified points                                                                                                       |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetBAndKKoefs(int x1, double y1, int x2, double y2, double &kKoef)
{
   if (x2 == x1)
      return EMPTY_VALUE;
      
   kKoef = (y2 - y1) / (x2 - x1);
   return y1 - kKoef * x1;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Calculating the price by values of base indicator or by market price                                                                                                                              |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
double GetIndOrMarketPrice(ENUM_EXTREMUM_TYPE extremumType, ENUM_PRICE_TYPE priceType, int barIndex)
{
   if (priceType == PRICE_TYPE_INDICATOR)
      return g_indValues[barIndex];
      
   return GetMarketPrice(barIndex, extremumType);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Is break the divergence line?                                                                                                                                                                     |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsDivLineBreak(ENUM_EXTREMUM_TYPE extremumType, ENUM_PRICE_TYPE priceType, int leftBarIndex, int rightBarIndex)
{
   double kKoef;
   double bKoef = GetBAndKKoefs(rightBarIndex, GetIndOrMarketPrice(extremumType, priceType, rightBarIndex), leftBarIndex, GetIndOrMarketPrice(extremumType, priceType, leftBarIndex), kKoef);
   if (bKoef == EMPTY_VALUE)
      return true;
  
   for (int i = leftBarIndex - 1; i > rightBarIndex; i--)
   {
      double lineValue = kKoef * i + bKoef;
      double basePrice = GetIndOrMarketPrice(extremumType, priceType, i);

      if (extremumType == EXTREMUM_TYPE_MAX && lineValue < basePrice)
         return true;

      if (extremumType == EXTREMUM_TYPE_MIN && lineValue > basePrice)
         return true;
   }
  
   return false;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| The class definition of divergence                                                                                                                                                                |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
string GetDivergenceType(double indRightValue, double indLeftValue, double priceRightValue, double priceLeftValue, ENUM_EXTREMUM_TYPE extType)
{
   if (extType == EXTREMUM_TYPE_MIN)
   {
      if (indRightValue > indLeftValue && priceRightValue < priceLeftValue)
         return TITLE_CLASS_A;
      if (indRightValue > indLeftValue && MathAbs(priceRightValue - priceLeftValue) < _Point / 10)
         return TITLE_CLASS_B;
      if (MathAbs(indRightValue - indLeftValue) < _Point / 100 && priceRightValue < priceLeftValue)
         return TITLE_CLASS_C;

      return TITLE_CLASS_H;
   }
  
   if (indRightValue < indLeftValue && priceRightValue > priceLeftValue)
      return TITLE_CLASS_A;
   if (indRightValue < indLeftValue && MathAbs(priceRightValue - priceLeftValue) < _Point / 10)
      return TITLE_CLASS_B;
   if (MathAbs(indRightValue - indLeftValue) < _Point / 100 && priceRightValue > priceLeftValue)
      return TITLE_CLASS_C;

   return TITLE_CLASS_H;  
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| The class definition of divergence, the need for its display and color of display                                                                                                                 |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsShowDivergence(double indRightValue, double indLeftValue, double priceRightValue, double priceLeftValue, ENUM_EXTREMUM_TYPE extType, string& divClass, color& clr, int& code)
{
   divClass = GetDivergenceType(indRightValue, indLeftValue, priceRightValue, priceLeftValue, extType);
   if ((i_showClassA == NO && divClass == TITLE_CLASS_A) ||
       (i_showClassB == NO && divClass == TITLE_CLASS_B) ||
       (i_showClassC == NO && divClass == TITLE_CLASS_C) ||
       (i_showHidden == NO && divClass == TITLE_CLASS_H))
      return false;
      
   if (divClass == TITLE_CLASS_A)
      clr = (extType == EXTREMUM_TYPE_MIN) ? i_bullsDivAColor : i_bearsDivAColor;
      
   if (divClass == TITLE_CLASS_B)
      clr = (extType == EXTREMUM_TYPE_MIN) ? i_bullsDivBColor : i_bearsDivBColor;

   if (divClass == TITLE_CLASS_C)
      clr = (extType == EXTREMUM_TYPE_MIN) ? i_bullsDivCColor : i_bearsDivCColor;

   if (divClass == TITLE_CLASS_H)
      clr = (extType == EXTREMUM_TYPE_MIN) ? i_bullsDivHColor : i_bearsDivHColor;

   code = (extType == EXTREMUM_TYPE_MIN) ? 218 : 217;

   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Sound and Push-notifications of divergence                                                                                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void SignalOnDivergence(string text)
{
   static datetime lastSignal = 0;
   if (lastSignal >= Time[0])
      return;
      
   lastSignal = Time[0];
  
   if (i_isAlert)
      Alert(_Symbol, ", ", g_tfName, ": ", text);
      
   if (i_isPush)
      SendNotification(_Symbol + ", " + g_tfName + ": " + text);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Checking the coincidence of charts of price and base indicator                                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsChartsCoincidence(int leftBarIndex, int rightBarIndex, ENUM_EXTREMUM_TYPE extremumType)
{
   double prevPriceValue = GetMarketPrice(leftBarIndex + 1, extremumType);
   double prevIndValue = g_indValues[leftBarIndex + 1];
   rightBarIndex--;
   for (int i = leftBarIndex; i >= rightBarIndex; i--)
   {
      double curPriceValue = GetMarketPrice(i, extremumType);
      double curIndValue = g_indValues[i];
      if ((curPriceValue > prevPriceValue && curIndValue <= prevIndValue) ||
          (curPriceValue < prevPriceValue && curIndValue >= prevIndValue) ||
          (curPriceValue == prevPriceValue && curIndValue != prevIndValue))
         return false;
        
      prevPriceValue = curPriceValue;
      prevIndValue = curIndValue;
   }
  
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Determining the divergence existence and its showing                                                                                                                                              |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool DefineAndShowDivergence(ENUM_EXTREMUM_TYPE extremumType, int rightBarIndex, int leftBarIndex, int priceRightBarIndex, int priceLeftBarIndex)
{
   double indRightValue = g_indValues[rightBarIndex];
   double indLeftValue = g_indValues[leftBarIndex];
   double priceRightValue = GetMarketPrice(priceRightBarIndex, extremumType);
   double priceLeftValue = GetMarketPrice(priceLeftBarIndex, extremumType);
  
   // Checking the divergence existence
   if ((indRightValue > indLeftValue && priceRightValue > priceLeftValue) ||
       (indRightValue < indLeftValue && priceRightValue < priceLeftValue))
      return false;

   // Checking for exit of one of the indicator values beyond the line of divergence
   if (IsDivLineBreak(extremumType, PRICE_TYPE_INDICATOR, leftBarIndex, rightBarIndex))
      return false;

   // Checking for exit of one of the market prices beyond the line of divergence
   if (IsDivLineBreak(extremumType, PRICE_TYPE_MARKET, priceLeftBarIndex, priceRightBarIndex))
      return false;
      
   // The class definition of divergence, the need for its display and color of display
   string divClass = "";
   color clr = clrNONE;
   int code;
   if (!IsShowDivergence(indRightValue, indLeftValue, priceRightValue, priceLeftValue, extremumType, divClass, clr, code))
      return false;

   // Checking the coincidence of charts of price and base indicator
   if (i_useCoincidenceCharts == ON)
      if (!IsChartsCoincidence((int)MathMax(leftBarIndex, priceLeftBarIndex), (int)MathMin(rightBarIndex, priceRightBarIndex), extremumType))
      return false;

   // Checking the overlaps of current divergence line with last divergence line
   if (i_excludeOverlaps == ON)
      if (iTime(NULL, 0, (int)MathMax(leftBarIndex, priceLeftBarIndex)) <= g_lastDivergenceTime)
         return false;

   // The divergence is detected - display it
   string divType = (extremumType == EXTREMUM_TYPE_MIN) ? "Bullish " : "Bearish ";
   if (rightBarIndex == 2 || priceRightBarIndex == 2)
      SignalOnDivergence(divType + divClass);
  
   ShowTrendLine(g_indSubWindow, Time[rightBarIndex], indRightValue, Time[leftBarIndex], indLeftValue, divType + divClass, clr);
   ShowTrendLine(0, Time[priceRightBarIndex], priceRightValue, Time[priceLeftBarIndex], priceLeftValue, divType + divClass, clr);

   ResetLastError();
   string id = IndicatorObjPrefix + TimeToString(Time[rightBarIndex]);
   if (ObjectFind(0, id) == -1)
   {
      if (!ObjectCreate(0, id, OBJ_TEXT, 0, Time[priceLeftBarIndex], priceLeftValue))
      {
         Print(__FUNCTION__, ". Error: ", GetLastError());
         return true;
      }
      ObjectSetString(0, id, OBJPROP_FONT, "Wingdings");
      ObjectSetInteger(0, id, OBJPROP_FONTSIZE, 12);
      ObjectSetInteger(0, id, OBJPROP_COLOR, clr);
      ObjectSetInteger(0, id, OBJPROP_ANCHOR, ANCHOR_LEFT_UPPER);
   }
   ObjectSetInteger(0, id, OBJPROP_TIME, Time[priceLeftBarIndex]);
   ObjectSetDouble(0, id, OBJPROP_PRICE1, priceLeftValue);
   ObjectSetString(0, id, OBJPROP_TEXT, CharToStr(code));
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Finding the indicator extremum at the specified interval from said bar                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetIndicatorExtremumAtInterval(int barIndex, int total, ENUM_EXTREMUM_TYPE extType)
{
   int limit = (int)MathMin(barIndex + i_findExtInterval, total);
   for (int i = barIndex; i < limit; i++)
      if (GetBufferExtremum(i, total, g_indValues) == extType)
         return i;
        
   return -1;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Finding the market extremum at the specified interval from said bar                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int GetMarketExtremumAtInterval(int barIndex, int total, ENUM_EXTREMUM_TYPE extType)
{
   int limit = (int)MathMin(barIndex + i_findExtInterval, total);
   for (int i = barIndex; i < limit; i++)
   {
      if (i_marketAppliedPrice == MARKET_APPLIED_PRICE_HIGHLOW)
      {
         if (extType == EXTREMUM_TYPE_MAX)
            if (GetBufferExtremum(i, total, High) == extType)
               return i;
            
         if (extType == EXTREMUM_TYPE_MIN)
            if (GetBufferExtremum(i, total, Low) == extType)
               return i;
      }
      else
         if (GetBufferExtremum(i, total, Close) == extType)
            return i;
   }
        
   return -1;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Finding the pair of corresponding extremums of base indicator and market price                                                                                                                    |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool IsPairExtremums(int barIndex, int total, ENUM_EXTREMUM_TYPE neededExtType, int &indExtBarIndex, int &priceExtBarIndex)
{
   // Is the indicator extremum exists?
   indExtBarIndex = barIndex;
   priceExtBarIndex = barIndex;
   ENUM_EXTREMUM_TYPE divExtType = GetBufferExtremum(barIndex, total, g_indValues);
   if (divExtType == EXTREMUM_TYPE_NONE || (neededExtType != EXTREMUM_TYPE_NONE && divExtType != neededExtType))
   {
      // Is the market extremum?
      divExtType = GetMarketExtremum(barIndex, total, neededExtType);
      if (divExtType == EXTREMUM_TYPE_NONE)
         return false;
      
      // Market price extremum was found. Finding the extremum of indicator
      indExtBarIndex = GetIndicatorExtremumAtInterval(barIndex, total, divExtType);
      if (indExtBarIndex < 0)
         return false;
   }
   // Indicator extremum was found. Finding the extremum of market price
   else
   {
      priceExtBarIndex = GetMarketExtremumAtInterval(barIndex, total, divExtType);
      if (priceExtBarIndex < 0)
         return false;
   }
  
   return true;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Search the left extremums of price and indicator                                                                                                                                                  |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool SearchLeftReferencePoint(int total, int rightIndExtBarIndex, int rightPriceExtBarIndex, ENUM_EXTREMUM_TYPE divExtType)
{
   bool result = false;
   int startBarIndex = (int)MathMax(rightIndExtBarIndex, rightPriceExtBarIndex) + 1;
   int lastBar = (int)MathMin(startBarIndex + i_divergenceDepth, total);
   int leftPriceExtBarIndex = -1, leftIndExtBarIndex = -1;

   for (int i = startBarIndex; i < lastBar; i++)
   {
      if (!IsPairExtremums(i, total, divExtType, leftIndExtBarIndex, leftPriceExtBarIndex))
         continue;

      if (DefineAndShowDivergence(divExtType, rightIndExtBarIndex + 1, leftIndExtBarIndex + 1, rightPriceExtBarIndex + 1, leftPriceExtBarIndex + 1))
         result = true;
   }
  
   return result;
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| First searched indicator extremum, and behind it (if extremum of indicator was found) - the price extremum                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ProcessByIndicatorExtremum(int barIndex, int total)
{
   // Is the indicator extremum exists?
   ENUM_EXTREMUM_TYPE divExtType = GetBufferExtremum(barIndex, total, g_indValues);
   if (divExtType == EXTREMUM_TYPE_NONE)
      return false;

   // Indicator extremum was found. Finding the extremum of market price
   int priceExtBarIndex = GetMarketExtremumAtInterval(barIndex, total, divExtType);
   if (priceExtBarIndex < 0)
      return false;
  
   return SearchLeftReferencePoint(total, barIndex, priceExtBarIndex, divExtType);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| First searched the price extremum, and behind it (if extremum of price was found) - the indicator extremum                                                                                        |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
bool ProcessByMarketExtremum(int barIndex, int total, ENUM_EXTREMUM_TYPE desiredExtremum)
{
   // Is the market extremum?
   ENUM_EXTREMUM_TYPE divExtType = GetMarketExtremum(barIndex, total, desiredExtremum);
   if (divExtType == EXTREMUM_TYPE_NONE)
      return false;
  
   // Market price extremum was found. Finding the extremum of indicator
   int indExtBarIndex = GetIndicatorExtremumAtInterval(barIndex, total, divExtType);
   if (indExtBarIndex < 0)
      return false;
  
   return SearchLeftReferencePoint(total, indExtBarIndex, barIndex, divExtType);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Process the specified bar                                                                                                                                                                         |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ProcessBar(int barIndex, int total)
{
   bool result = false;

   if (ProcessByIndicatorExtremum(barIndex, total))
      result = true;

   if (i_marketAppliedPrice == MARKET_APPLIED_PRICE_CLOSE)
   {
      if (ProcessByMarketExtremum(barIndex, total, EXTREMUM_TYPE_NONE))
         result = true;
   }
   else
      if (ProcessByMarketExtremum(barIndex, total, EXTREMUM_TYPE_MAX) ||
          ProcessByMarketExtremum(barIndex, total, EXTREMUM_TYPE_MIN))
         result = true;
        
   if (result)
      g_lastDivergenceTime = iTime(NULL, 0, barIndex + 1);
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Recalculate the values of William Blau                                                                                                                                                            |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void CalculateDataByWilliamBlau(int limit, int total)
{
   for (int i = limit; i > 0; i--)
      g_tempBuffer[i] = iMA(NULL, 0, i_barsPeriod2, 0, MODE_EMA, i_indAppliedPrice, i) - iMA(NULL, 0, i_barsPeriod1, 0, MODE_EMA, i_indAppliedPrice, i);
      
   for (int i = limit; i > 0; i--)
   {
      g_indValues[i] = iMAOnArray(g_tempBuffer, 0, i_barsPeriod3, 0, MODE_EMA, i);
      if (i + i_divergenceDepth + i_findExtInterval + 2 >= total)
         continue;

      ProcessBar(i, total);
   }
  
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Displaying of indicators values                                                                                                                                                                   |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
void ShowIndicatorData(int limit, int total)
{
   if (i_indicatorType == WILLIAM_BLAU)
   {
      CalculateDataByWilliamBlau(limit, total);
      return;
   }

   for (int i = limit; i > 0; i--)
   {
      g_indValues[i] = GetBaseIndicatorValue(i);
      if (i + i_divergenceDepth + i_findExtInterval + 2 >= total)
         continue;
        
      ProcessBar(i, total);
   }
}
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
//| Custom indicator iteration function                                                                                                                                                               |
//+---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (!g_activate)                                                                                
      return rates_total;                                
    
   g_indSubWindow = WindowFind(g_indName);
   if (g_indSubWindow < 0)
      return 0;
      
   int total;  
   int limit = GetRecalcIndex(total, rates_total, prev_calculated);                                

   ShowIndicatorData(limit, total);                                                                
   WindowRedraw();
  
   return rates_total;
}