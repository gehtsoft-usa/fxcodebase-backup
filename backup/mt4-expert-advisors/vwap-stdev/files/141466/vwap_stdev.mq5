// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71080


//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   Dogecoin : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots 7

input ENUM_TIMEFRAMES giVWAPTf = PERIOD_W1; // Timeframe
input int       NumVWAPTf    = 2;
input string    DayStartTime = "00:00";
input color     ClrVWAP      = CadetBlue;
input color     ClrSD        = DarkSlateGray;
input int       VWAPWidth    = 2;
input int       StyleSD      = STYLE_SOLID;
input int bars_limit = 1000; // Bars limit

double BuffUpperSD3[];
double BuffUpperSD2[];
double BuffUpperSD1[];
double BuffVWAP[];
double BuffLowerSD1[];
double BuffLowerSD2[];
double BuffLowerSD3[];
double gdVWMA[];

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
   IndicatorObjPrefix = GenerateIndicatorPrefix("vwap_stdev");
   IndicatorSetString(INDICATOR_SHORTNAME, "VWAP StDev");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());

   int id = 0;
   SetIndexBuffer(id, BuffUpperSD3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, BuffUpperSD2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, BuffUpperSD1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, BuffVWAP, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrVWAP);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, VWAPWidth);
   ++id;
   SetIndexBuffer(id, BuffLowerSD1, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, BuffLowerSD2, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
   ++id;
   SetIndexBuffer(id, BuffLowerSD3, INDICATOR_DATA);
   PlotIndexSetInteger(id, PLOT_LINE_STYLE, StyleSD);
   PlotIndexSetInteger(id, PLOT_DRAW_TYPE, DRAW_LINE);
   PlotIndexSetInteger(id, PLOT_LINE_COLOR, ClrSD);
   PlotIndexSetInteger(id, PLOT_LINE_WIDTH, 1);
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
      ArrayInitialize(BuffUpperSD3, EMPTY_VALUE);
      ArrayInitialize(BuffUpperSD2, EMPTY_VALUE);
      ArrayInitialize(BuffUpperSD1, EMPTY_VALUE);
      ArrayInitialize(BuffVWAP, EMPTY_VALUE);
      ArrayInitialize(BuffLowerSD1, EMPTY_VALUE);
      ArrayInitialize(BuffLowerSD2, EMPTY_VALUE);
      ArrayInitialize(BuffLowerSD3, EMPTY_VALUE);
   }
   int iBarVWAPTf = NumVWAPTf - 1;
   datetime dtVWAPTf;
   if (giVWAPTf == PERIOD_D1)
   {      
      //--daystarttime is in future
      if (createDt(time[rates_total - 1], DayStartTime) > time[rates_total - 1]) 
      {
         iBarVWAPTf++;
         dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);
         dtVWAPTf = createDt(dtVWAPTf, DayStartTime);
      }
      else 
      {
         dtVWAPTf = createDt(dtVWAPTf, DayStartTime);
      }
   }
   else
   { 
      dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);
   }

   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   {
      if (giVWAPTf == PERIOD_D1)
      {
         dtVWAPTf = createDt(time[pos], DayStartTime);
         if (dtVWAPTf > time[pos])
         {
            dtVWAPTf -= PERIOD_D1 * 60;
         }
      }
      else
      {
         iBarVWAPTf = iBarShift(NULL, giVWAPTf, time[pos]);
         dtVWAPTf = iTime(NULL, giVWAPTf, iBarVWAPTf);
      }      
      int iStartBar = iBarShift(NULL, 0, dtVWAPTf);
      if (iTime(_Symbol, _Period, iStartBar) < dtVWAPTf)
      {
         iStartBar--;
      }
      int oldPos = rates_total - 1 - pos;
      int iNumBars = (iStartBar - oldPos) + 1;
      double dVWMA = getVWMA(iNumBars, oldPos);
                             
      if (iNumBars <= 1)
      {
         continue;
      }
      
      double dSD = getStdDev(dVWMA, iNumBars, oldPos); 
      
      BuffVWAP[pos] = dVWMA;           
      
      BuffUpperSD1[pos] = BuffVWAP[pos] + (1.0 * dSD);
      BuffUpperSD2[pos] = BuffVWAP[pos] + (2.0 * dSD);
      BuffUpperSD3[pos] = BuffVWAP[pos] + (3.0 * dSD);
      BuffLowerSD1[pos] = BuffVWAP[pos] - (1.0 * dSD);
      BuffLowerSD2[pos] = BuffVWAP[pos] - (2.0 * dSD);
      BuffLowerSD3[pos] = BuffVWAP[pos] - (3.0 * dSD);      
   }       

   return rates_total;
}
  
datetime createDt(datetime date, string time)
{
   return StringToTime(TimeToString(date, TIME_DATE) + " " + time);
}

double getVWMA(int period, int shift)
{
   double Sum    = 0;
   double Weight = 0;
   for (int i = shift; i < (shift + period); i++)
   { 
      double vol = iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, i);
      Weight += vol;
      Sum += getAppliedPrice(PRICE_TYPICAL, i) * vol;
   }
   
   return Weight > 0 ? Sum / Weight : 0; 
}

double getStdDev(double mean, int period, int shift)
{
   double sum, val, sumvol;  
   for (int i = shift; i < (shift + period); i++)
   {
      double vol = iVolume(_Symbol, (ENUM_TIMEFRAMES)_Period, i);
      sumvol += vol;
      val = getAppliedPrice(PRICE_TYPICAL, i) - mean;
      val *= val;
      sum += vol * val;
   }  
   if (sumvol > 0)
   {
      return MathSqrt(sum / sumvol);
   }
   return 0;
}
  
//--copy from market statistic 7
double getAppliedPrice(int nAppliedPrice, int nIndex)
{
   switch (nAppliedPrice)
   {
      case 0:
         return iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex);
      case 1:
         return iOpen(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex);
      case 2:
         return iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex);
      case 3:
         return iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex);
      case 4:
         return (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex)) / 2.0;
      case 5:
         return (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex) + iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex)) / 3.0;
      case 6:
         return (iHigh(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex) + iLow(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex) + 2 * iClose(_Symbol, (ENUM_TIMEFRAMES)_Period, nIndex)) / 4.0;
      default:
         return 0;
   }
}
//+------------------------------------------------------------------+