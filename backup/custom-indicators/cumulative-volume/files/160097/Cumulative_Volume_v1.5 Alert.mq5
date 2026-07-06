// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=17&t=42392&start=40

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3

#property indicator_label1  "Cumulative"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMagenta
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Positive"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Negative"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

input string session_start = "000000"; // Session Start
input bool Combined=true;
input bool Relative=false;
input ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT; // Timeframe
input int maxBars = 1000; // Maximum number of bars to calculate
input int highLevel = 20; // High level for alerts and arrows
input int lowLevel = -20;  // Low level for alerts and arrows
input bool showArrows = true; // Show arrows
input color arrUpColor = clrBlue;
input color arrDoColor = clrRed;
input int arrUpCode = 233;
input int arrDoCode = 234;
input int arrWidth = 2;
input int Distance = 20; // Arrow distance from Hi/Lo
enum alert
   {
    Off = 0, // Off
    Current = 1, // At current bar
    Previous = 2 // At previous closed bar
   };
input alert  notificationsOn       = Current;                // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

double Positive[], Negative[], Cumulative[];
double APos[], ANeg[];

void drawArrow(int dir, int bar)
   {
    string prefix = "CV_";
    if(MQLInfoInteger(MQL_TESTER)) prefix = "CVT_";
    
    // Calculate price position for arrows
    double priceHigh = iHigh(_Symbol, _Period, bar);
    double priceLow = iLow(_Symbol, _Period, bar);
    double arrowDistance = Distance * _Point * 10; // Increase distance multiplier
    
    if(dir == 11)
       {
         ObjectDelete(0, prefix + "arrU" + (string)bar);
       }
    if(dir == -11)
       {
         ObjectDelete(0, prefix + "arrD" + (string)bar);
       }
    if(dir == -1)
       {
         string name = prefix + "arrD" + (string)bar;
         ObjectDelete(0, name);
         if(ObjectCreate(0, name, OBJ_ARROW, 0, iTime(_Symbol, _Period, bar), priceHigh + arrowDistance))
            {
             ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_BOTTOM);
             ObjectSetInteger(0, name, OBJPROP_COLOR, arrDoColor);
             ObjectSetInteger(0, name, OBJPROP_WIDTH, arrWidth);
             ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrDoCode);
             ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
             ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
             ObjectSetInteger(0, name, OBJPROP_BACK, false);
            }
       }
    if(dir == 1)
       {
         string name = prefix + "arrU" + (string)bar;
         ObjectDelete(0, name);
         if(ObjectCreate(0, name, OBJ_ARROW, 0, iTime(_Symbol, _Period, bar), priceLow - arrowDistance))
            {
             ObjectSetInteger(0, name, OBJPROP_ANCHOR, ANCHOR_TOP);
             ObjectSetInteger(0, name, OBJPROP_COLOR, arrUpColor);
             ObjectSetInteger(0, name, OBJPROP_WIDTH, arrWidth);
             ObjectSetInteger(0, name, OBJPROP_ARROWCODE, arrUpCode);
             ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
             ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
             ObjectSetInteger(0, name, OBJPROP_BACK, false);
            }
       }
   }

int ParseTime(const string time, string &error)
{
   string items[];
   StringSplit(time, StringGetCharacter(":", 0), items);
   int hours;
   int minutes;
   int seconds;
   if (ArraySize(items) > 1)
   {
      if (ArraySize(items) != 3)
      {
         error = "Bad format for " + time;
         return -1;
      }
      //hh:mm:ss
      seconds = (int)StringToInteger(items[2]);
      minutes = (int)StringToInteger(items[1]);
      hours = (int)StringToInteger(items[0]);
   }
   else
   {
      //hhmmss
      int time_parsed = (int)StringToInteger(time);
      seconds = time_parsed % 100;
      
      time_parsed /= 100;
      minutes = time_parsed % 100;
      time_parsed /= 100;
      hours = time_parsed % 100;
   }
   if (hours > 24)
   {
      error = "Incorrect number of hours in " + time;
      return -1;
   }
   if (minutes > 59)
   {
      error = "Incorrect number of minutes in " + time;
      return -1;
   }
   if (seconds > 59)
   {
      error = "Incorrect number of seconds in " + time;
      return -1;
   }
   if (hours == 24 && (minutes != 0 || seconds != 0))
   {
      error = "Incorrect date";
      return -1;
   }
   return (hours * 60 + minutes) * 60 + seconds;
}

int startTime;

int OnInit()
{
   IndicatorSetString(INDICATOR_SHORTNAME, "Cumulative Volume");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   
   if (Combined)
   {
      SetIndexBuffer(0, Cumulative, INDICATOR_DATA);
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
      
      SetIndexBuffer(1, Positive, INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
      
      SetIndexBuffer(2, Negative, INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
      
      SetIndexBuffer(3, APos, INDICATOR_CALCULATIONS);
      SetIndexBuffer(4, ANeg, INDICATOR_CALCULATIONS);
   }
   else
   {
      SetIndexBuffer(0, Positive, INDICATOR_DATA);
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      
      SetIndexBuffer(1, Negative, INDICATOR_DATA);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
      
      SetIndexBuffer(2, Cumulative, INDICATOR_CALCULATIONS);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
      
      SetIndexBuffer(3, APos, INDICATOR_CALCULATIONS);
      SetIndexBuffer(4, ANeg, INDICATOR_CALCULATIONS);
   }
   
   // Set array series direction (true = from present to past)
   ArraySetAsSeries(Cumulative, true);
   ArraySetAsSeries(Positive, true);
   ArraySetAsSeries(Negative, true);
   ArraySetAsSeries(APos, true);
   ArraySetAsSeries(ANeg, true);
   
   string error;
   startTime = ParseTime(session_start, error);
   if (startTime < 0)
   {
      Print(error);
      return(INIT_FAILED);
   }
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   string prefix = "CV_";
   if(MQLInfoInteger(MQL_TESTER)) prefix = "CVT_";
   
   // Delete all objects with prefix
   int total = ObjectsTotal(0);
   for(int i = total - 1; i >= 0; i--)
   {
      string name = ObjectName(0, i);
      if(StringFind(name, prefix + "arrD") == 0 || StringFind(name, prefix + "arrU") == 0)
      {
         ObjectDelete(0, name);
      }
   }
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
   // Set arrays as series (from present to past)
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   
   if (rates_total < 10) 
     return(0);
     
   int limit = MathMin(maxBars, rates_total - 2);
   if(prev_calculated > 2) 
     limit = rates_total - prev_calculated;
   
   if(MQLInfoInteger(MQL_TESTER) && prev_calculated == 0)
   {
     ObjectsDeleteAll(0, "CVT_");
   }
   
   for (int pos = limit; pos >= 0; --pos)
   {
     if (_Period == timeframe || timeframe == PERIOD_CURRENT)
     {
       if (close[pos] > close[pos + 1])
       {
         APos[pos] = (double)tick_volume[pos] / 100;
         ANeg[pos] = 0;
       }
       else
       {
         APos[pos] = 0;
         ANeg[pos] = (double)tick_volume[pos] / 100;
       }
       
       datetime sessionStart = (time[pos] / 86400) * 86400 + startTime;
       if (sessionStart > time[pos])
       {
         sessionStart -= 86400;
       }
       
       int index = iBarShift(_Symbol, _Period, sessionStart, true);
       if (index < 0)
       {
         continue;
       }
       
       int smoothingPeriod = index - pos + 1;
       if (smoothingPeriod <= 0 || pos + smoothingPeriod > rates_total)
         continue;
         
       double p = 0, n = 0;
       for(int j = 0; j < smoothingPeriod; j++)
       {
         p += APos[pos + j];
         n += ANeg[pos + j];
       }
       
       double SVolume = 0.;
       for (int i = 0; i < smoothingPeriod; i++)
       {
         SVolume = SVolume + tick_volume[pos + i];
       }
       SVolume = SVolume / 100;
       
       if (Combined)
       {
         if (Relative && SVolume != 0)
            Cumulative[pos] = (p - n) * 1000 / SVolume;
         else
            Cumulative[pos] = p - n;
       }
       else
       {
         if (Relative && SVolume != 0)
         {
            Positive[pos] = p * 1000 / SVolume;
            Negative[pos] = -n * 1000 / SVolume;
         }
         else
         {
            Positive[pos] = p;
            Negative[pos] = -n;
         }
       }
     }
   else
   {
     static int handle = INVALID_HANDLE;
     static datetime lastInitTime = 0;
     
     // Recreate handle if it's invalid or if significant time has passed
     if(handle == INVALID_HANDLE || TimeCurrent() - lastInitTime > 60)
     {
       if(handle != INVALID_HANDLE)
       {
         IndicatorRelease(handle);
         handle = INVALID_HANDLE;
       }
       
       handle = iCustom(_Symbol, timeframe, "fxcodebase\\259\\Cumulative_Volume_v1.5+alert", 
                   session_start,     // Session Start
                   Combined,          // Combined
                   Relative,          // Relative
                   PERIOD_CURRENT,    // Timeframe (should be PERIOD_CURRENT for recursive call)
                   maxBars,           // Maximum number of bars
                   highLevel,         // High level
                   lowLevel,          // Low level
                   showArrows,        // Show arrows
                   arrUpColor,        // Arrow up color
                   arrDoColor,        // Arrow down color
                   arrUpCode,         // Arrow up code
                   arrDoCode,         // Arrow down code
                   arrWidth,          // Arrow width
                   Distance,          // Arrow distance
                   notificationsOn,   // Notifications
                   desktop_notifications, // Desktop notifications
                   email_notifications,   // Email notifications
                   push_notifications,    // Push notifications
                   sound_notifications,   // Sound notifications
                   sound_file);           // Sound file
       
       if(handle == INVALID_HANDLE)
       {
         Print("Failed to create indicator handle");
         continue;
       }
       lastInitTime = TimeCurrent();
     }
     
     int index = iBarShift(_Symbol, timeframe, time[pos], true);
     if (index < 0)
       continue;
       
     // Ensure we have enough data before copying
     int calculated = BarsCalculated(handle);
     if(calculated <= 0)
       continue;
       
     if (Combined)
     {
       double value[1];
       if(CopyBuffer(handle, 0, index, 1, value) > 0)
         Cumulative[pos] = value[0];
       else
         Cumulative[pos] = EMPTY_VALUE;
     }
     else
     {
       double value1[1], value2[1];
       if(CopyBuffer(handle, 0, index, 1, value1) > 0)
         Positive[pos] = value1[0];
       else
         Positive[pos] = EMPTY_VALUE;
         
       if(CopyBuffer(handle, 1, index, 1, value2) > 0)
         Negative[pos] = value2[0];
       else
         Negative[pos] = EMPTY_VALUE;
     }
   }
   }
   
   if(showArrows)
   {
     for(int i = MathMin(maxBars, rates_total - 1); i >= 0; i--)
     {
       if(i < rates_total - 2 && Combined)
       {
         if(Cumulative[i] != EMPTY_VALUE && Cumulative[i+1] != EMPTY_VALUE)
         {
            if(Cumulative[i+1] < highLevel && Cumulative[i] >= highLevel)
              drawArrow(1, i);
            else
              drawArrow(11, i);
              
            if(Cumulative[i+1] > lowLevel && Cumulative[i] <= lowLevel)
              drawArrow(-1, i);
            else
              drawArrow(-11, i);
         }
       }
     }
      
      
      
   }
    ChartRedraw(0);
   if(notificationsOn > 0)
   {
     checkAlert();
   }
   
   return(rates_total);
}

bool alerted;
void checkAlert()
   {
    bool nb = IsNewBar();
    if(nb)
         alerted = false;
    if(notificationsOn == 1 && !alerted)
       {
         if(Cumulative[1] < highLevel && Cumulative[0] > highLevel)
            {
             Notify(1);
             alerted = true;
            }
         if(Cumulative[1] > lowLevel && Cumulative[0] < lowLevel)
            {
             Notify(2);
             alerted = true;
            }
       }
    if(notificationsOn == 2 && nb)
       {
       if(Cumulative[2] < highLevel && Cumulative[1] > highLevel)
            {
             Notify(11);
            }
         if(Cumulative[2] > lowLevel && Cumulative[1] < lowLevel)
            {
             Notify(22);
            }
       }
   }

  bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

  void Notify(int type)
  {
   string text = "RSI custom: ";
   switch(type)
     {
      case 1:
         text += " Breaks UP level before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Breaks DOWN level before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Broken UP level after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Broken DOWN level after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

 string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
 // More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=17&t=42392&start=40

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+