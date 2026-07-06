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
#property indicator_color1 clrMagenta
#property indicator_color2 Green
#property  indicator_width1  2
#property  indicator_width2  2
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
input alert  notificationsOn       = 1;                      // Notifications
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
   if(IsTesting()) prefix = "CVT_";
   
   // Calculate price position for arrows
   double priceHigh = iHigh(Symbol(), Period(), bar);
   double priceLow = iLow(Symbol(), Period(), bar);
   double arrowDistance = Distance * Point() * 10; // Increase distance multiplier
   
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
      if(ObjectCreate(0, name, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), priceHigh + arrowDistance))
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
      if(ObjectCreate(0, name, OBJ_ARROW, 0, iTime(Symbol(), Period(), bar), priceLow - arrowDistance))
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
   StringSplit(time, ':', items);
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

int init()
{
   IndicatorShortName("Cumulative Volume");
   IndicatorDigits(Digits);
   if (Combined)
   {
      SetIndexStyle(2,DRAW_LINE);
      SetIndexBuffer(0,Cumulative);
      SetIndexStyle(1,DRAW_NONE);
      SetIndexBuffer(1,Positive);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,Negative);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,APos);
      SetIndexStyle(4,DRAW_NONE);
      SetIndexBuffer(4,ANeg);
   }
   else
   {
      SetIndexStyle(0,DRAW_HISTOGRAM);
      SetIndexBuffer(0,Positive);
      SetIndexStyle(1,DRAW_HISTOGRAM);
      SetIndexBuffer(1,Negative);
      SetIndexStyle(2,DRAW_NONE);
      SetIndexBuffer(2,APos);
      SetIndexStyle(3,DRAW_NONE);
      SetIndexBuffer(3,ANeg);
   }
   string error;
   startTime = ParseTime(session_start, error);
   if (startTime < 0)
   {
      Print(error);
      return INIT_FAILED;
   }
   return(0);
}

int deinit()
{
   string prefix = "CV_";
   if(IsTesting()) prefix = "CVT_";
   
   ObjectsDeleteAll(0, prefix + "arrD");
   ObjectsDeleteAll(0, prefix + "arrU");
   return(0);
}

int start()
{
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars<0 && Bars < 10) 
      return(-1);
   int limit=MathMin(maxBars, Bars-2);
   if(ExtCountedBars>2) 
      limit=Bars-ExtCountedBars-1;
   
    if(IsTesting() && ExtCountedBars == 0)
     {
      ObjectsDeleteAll(0, "CVT_");
     }
   
   for (int pos = limit; pos >= 0; --pos)
   {
      if (_Period == timeframe || timeframe == PERIOD_CURRENT)
      {
         if (Close[pos] > Close[pos + 1])
         {
            APos[pos] = (double)Volume[pos] / 100;
            ANeg[pos] = 0;
         }
         else
         {
            APos[pos] = 0;
            ANeg[pos] = (double)Volume[pos] / 100;
         }
         datetime sessionStart = (Time[pos] / 86400) * 86400 + startTime;
         if (sessionStart > Time[pos])
         {
            sessionStart -= 86400;
         }
         int index = iBarShift(_Symbol, (ENUM_TIMEFRAMES)_Period, sessionStart);
         if (index < 0)
         {
            continue;
         }
         int smoothingPeriod = index - pos + 1;
         double p = iMAOnArray(APos, 0, smoothingPeriod, 0, MODE_SMA, pos) * smoothingPeriod;
         double n = iMAOnArray(ANeg, 0, smoothingPeriod, 0, MODE_SMA, pos) * smoothingPeriod;
         if (pos > Bars - 1 - smoothingPeriod)
            continue;
         double SVolume = 0.;
         for (int i = 0; i < smoothingPeriod; i++)
         {
            SVolume = SVolume + Volume[pos + i];
         }
         SVolume = SVolume / 100;
         if (Combined)
         {
            if (Relative)
               Cumulative[pos] = (p - n) * 1000 / SVolume;
            else
               Cumulative[pos] = p - n;
         }
         else
         {
            if (Relative)
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
         int index = iBarShift(_Symbol, timeframe, Time[pos]);
         if (index < 0)
            continue;
         if (Combined)
            Cumulative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.5+alert", session_start, Combined, Relative, 0, index);
         else
         {
            Positive[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.5+alert", session_start, Combined, Relative, 0, index);
            Negative[pos] = iCustom(_Symbol, timeframe, "Cumulative_Volume_v1.5+alert", session_start, Combined, Relative,1, index);
         }
      }
   }
   if(showArrows)
     {
      for(int i = MathMin(maxBars, Bars - 1); i >= 0; i--)
        {
         if(i < Bars - 2 && Combined)
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
       if(IsTesting())
        {
         ChartRedraw(0);
        }
     }
   
   if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(0);
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