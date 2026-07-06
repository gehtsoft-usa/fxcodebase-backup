// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70523

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

// Based on http://www.fxtools.info
#property  indicator_chart_window
#property indicator_buffers  2
#property indicator_plots  2
#property  indicator_color1  MidnightBlue
#property  indicator_color2  FireBrick
 
input int Fib_Period = 240; 
input bool Show_StartLine = false;
input bool Show_EndLine = false;
input bool Show_Channel = false;
input int Fib_Style = 5;
input color Fib_Color = Gold;
input color StartLine_Color = RoyalBlue; 
input color EndLine_Color = FireBrick; 
input color BuyZone_Color = MidnightBlue;
input color SellZone_Color = FireBrick;
input int bars_limit = 1000; // Bars limit
 
//---- buffers
double WWBuffer1[];
double WWBuffer2[];
 
double level_array[10]={0,0.236,0.382,0.5,0.618,0.764,1,1.618,2.618,4.236};
string leveldesc_array[13]={"0","23.6%","38.2%","50%","61.8%","76.4%","100%","161.8%","261.80%","423.6%"};
int level_count;
string level_name;
string StartLine = "Start Line";
string EndLine = "End Line";
 
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


int OnInit()
{
   IndicatorObjPrefix = GenerateIndicatorPrefix("aftz");
   IndicatorSetString(INDICATOR_SHORTNAME, "AutoFib TradeZones");
   IndicatorSetInteger(INDICATOR_DIGITS, Digits());
   if (Show_Channel)
   {
      SetIndexBuffer(0, WWBuffer1, INDICATOR_DATA);
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(0, PLOT_LABEL, "High");
      SetIndexBuffer(1, WWBuffer2, INDICATOR_DATA);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetString(1, PLOT_LABEL, "Low");
   }
   
   created = false;
   return(0);
}

bool created = false;

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
   if (!created)
   {
      ObjectCreate(0, IndicatorObjPrefix + "FibLevels", OBJ_FIBO, 0, time[rates_total - 1], high[rates_total - 1], time[rates_total - 1], low[rates_total - 1]);
      ObjectCreate(0, IndicatorObjPrefix + "BuyZone", OBJ_RECTANGLE, 0,0,0,0);
      ObjectCreate(0, IndicatorObjPrefix + "SellZone", OBJ_RECTANGLE, 0,0,0,0);
      
      if (Show_StartLine)
      {
         if (ObjectFind(0, IndicatorObjPrefix + StartLine)==-1)
         {
            ObjectCreate(0, IndicatorObjPrefix + StartLine,OBJ_VLINE,0,time[rates_total - 1 - Fib_Period],close[rates_total - 1]);
            ObjectSetInteger(0, IndicatorObjPrefix + StartLine,OBJPROP_COLOR,StartLine_Color);
         }
      } 
      if (Show_EndLine)
      {
         if (ObjectFind(0, IndicatorObjPrefix + EndLine)==-1)
         {
            ObjectCreate(0, IndicatorObjPrefix + EndLine,OBJ_VLINE,0,time[rates_total - 1],close[rates_total - 1]);
            ObjectSetInteger(0, IndicatorObjPrefix + EndLine,OBJPROP_COLOR,EndLine_Color);
         }
      } 
      created = true;
   }
   int BarShift;
   if (Show_StartLine)
   {   
      datetime HLineTime=ObjectGetInteger(0, IndicatorObjPrefix + StartLine,OBJPROP_TIME, 0);

      if (HLineTime >= time[rates_total - 1])
      {
         BarShift = 0;
      }
      BarShift = iBarShift(NULL,0,HLineTime);
   }   
   else if (!Show_StartLine)
   {
      BarShift = 0;
   }
   if (ObjectFind(0, IndicatorObjPrefix + StartLine)==-1)
   {
      BarShift=0;
   }
   
 //End Line -------------------------------------------
   int BarShift2;
   if (Show_EndLine)
   {   
      datetime HLine2Time=ObjectGetInteger(0, IndicatorObjPrefix + StartLine,OBJPROP_TIME, 0);
      if (HLine2Time>=time[rates_total - 1])
      {
         BarShift2 = 0;
      }
      BarShift2=iBarShift(NULL,0,HLine2Time);
   }   
   else if (!Show_EndLine)
   {
      BarShift2=0;
   }
   if (ObjectFind(0, IndicatorObjPrefix + EndLine)==-1)
   {
      BarShift2=0;
   }
//----------------------------------------------------------
 
   double SellZoneHigh,BuyZoneLow;
   if (Show_StartLine)
   {
      SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,BarShift-BarShift2,BarShift2+1));
      BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,BarShift-BarShift2,BarShift2+1));
   }
   if (!Show_StartLine)
   {
      SellZoneHigh = iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,Fib_Period,1));
      BuyZoneLow = iLow(NULL,0,iLowest(NULL,0,MODE_LOW,Fib_Period,1));
   } 
   double PriceRange = SellZoneHigh - BuyZoneLow; 
   double BuyZoneHigh = BuyZoneLow + (0.236*PriceRange);
   double SellZoneLow = SellZoneHigh - (0.236*PriceRange);
   datetime StartZoneTime = time[rates_total - 1 - Fib_Period];
   datetime EndZoneTime = time[rates_total - 1] + time[rates_total - 1];
   
   level_count=ArraySize(level_array);
   
   int first = 0;
   for (int pos = MathMax(rates_total - 1 - bars_limit, MathMax(first, prev_calculated - 1)); pos < rates_total; ++pos)
   { 
      if (Show_Channel)
      {
         WWBuffer1[pos] = getPeriodHigh(Fib_Period, rates_total - 1 - pos);
         WWBuffer2[pos] = getPeriodLow(Fib_Period, rates_total - 1 - pos);
      }
      
      if (Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_TIME, 0, time[rates_total - 1 - BarShift]);
         ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_TIME, 1, time[rates_total - 1 - BarShift2]);
      }
      if (!Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_TIME, 0, StartZoneTime);
      }
      ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_TIME, 1, time[rates_total - 1]);
      if (open[rates_total - 1 - Fib_Period] < open[rates_total - 1]) // Up
      { 
         if (Show_StartLine)
         {
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 0, SellZoneHigh);
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 1, BuyZoneLow);
         }
         if (!Show_StartLine)
         {
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 0, getPeriodHigh(Fib_Period, rates_total - 1 - pos));
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 1, getPeriodLow(Fib_Period, rates_total - 1 - pos));
         } 
      } 
      else 
      {
         if (Show_StartLine)
         {
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 0, BuyZoneLow);
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 1, SellZoneHigh);
         }
         if (!Show_StartLine)
         {
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 0, getPeriodLow(Fib_Period, rates_total - 1 - pos));
            ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_PRICE, 1, getPeriodHigh(Fib_Period, rates_total - 1 - pos));
         }
      }
      ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_LEVELCOLOR, Fib_Color);
      ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_STYLE, Fib_Style);
      ObjectSetInteger(0, IndicatorObjPrefix + "FibLevels", OBJPROP_LEVELS, level_count);
      for(int j=0; j<level_count; j++)
      {
         ObjectSetDouble(0, IndicatorObjPrefix + "FibLevels", OBJPROP_LEVELVALUE, j, level_array[j]);
      }
   
      if (Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "BuyZone", OBJPROP_TIME, 1, time[rates_total - 1 - BarShift]);
         ObjectSetInteger(0, IndicatorObjPrefix + "BuyZone", OBJPROP_TIME, 0, time[rates_total - 1 - BarShift2]);
      }
      if (!Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "BuyZone", OBJPROP_TIME, 1, StartZoneTime);
      }
      ObjectSetInteger(0, IndicatorObjPrefix + "BuyZone", OBJPROP_TIME, 0, EndZoneTime);
      ObjectSetDouble(0, IndicatorObjPrefix + "BuyZone", OBJPROP_PRICE, 0, BuyZoneLow);
      ObjectSetDouble(0, IndicatorObjPrefix + "BuyZone", OBJPROP_PRICE, 1, BuyZoneHigh);
      ObjectSetInteger(0, IndicatorObjPrefix + "BuyZone", OBJPROP_COLOR, BuyZone_Color);
      
      if (Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "SellZone", OBJPROP_TIME, 1, time[rates_total - 1 - BarShift]);
         ObjectSetInteger(0, IndicatorObjPrefix + "SellZone", OBJPROP_TIME, 0, time[rates_total - 1 - BarShift2]);
      }
      if (!Show_StartLine)
      {
         ObjectSetInteger(0, IndicatorObjPrefix + "SellZone", OBJPROP_TIME, 1, StartZoneTime);
      }
      ObjectSetInteger(0, IndicatorObjPrefix + "SellZone", OBJPROP_TIME, 0, EndZoneTime);
      ObjectSetDouble(0, IndicatorObjPrefix + "SellZone", OBJPROP_PRICE, 0, SellZoneLow);
      ObjectSetDouble(0, IndicatorObjPrefix + "SellZone", OBJPROP_PRICE, 1, SellZoneHigh);
      ObjectSetInteger(0, IndicatorObjPrefix + "SellZone", OBJPROP_COLOR, SellZone_Color);
   }
   return(0);
}
 
double getPeriodHigh(int period, int pos) 
{
   int i;
   double buffer = 0;
   for (i=pos;i<=pos+period;i++) 
   {
      if (iHigh(_Symbol, _Period, i) > buffer) 
      {
         buffer = iHigh(_Symbol, _Period, i);
      }
      else 
      {
         if (iOpen(_Symbol, _Period, i) > iClose(_Symbol, _Period, i)) // Down
         { 
            if (iOpen(_Symbol, _Period, i) > buffer) 
            {
               buffer = iOpen(_Symbol, _Period, i);
            }
         } 
      }
   }
   return (buffer);
}
double getPeriodLow(int period, int pos) 
{
   int i;
   double buffer = 100000;
   for (i=pos;i<=pos+period;i++) 
   {
      if (iClose(_Symbol, _Period, i) < buffer) 
      {
         buffer = iClose(_Symbol, _Period, i);
      }
      else 
      {
         if (iOpen(_Symbol, _Period, i) > iClose(_Symbol, _Period, i)) // Down
         {
            if (iClose(_Symbol, _Period, i) < buffer) 
            {
               buffer = iClose(_Symbol, _Period, i);
            }
         } 
         else 
         {
            if (iOpen(_Symbol, _Period, i) < buffer) 
            {
               buffer = iOpen(_Symbol, _Period, i);
            }
         }
      }
   }
   return (buffer);
}