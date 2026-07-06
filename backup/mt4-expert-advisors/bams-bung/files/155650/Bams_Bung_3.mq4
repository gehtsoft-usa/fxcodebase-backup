//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=74948

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 CLR_NONE            // Dots instead of lines (leave at 0 to stay lines)
#property indicator_color2 CLR_NONE            // Dots instead of lines (leave at 0 to stay lines)
#property indicator_color3 Aquamarine          // Arrow size indicating new up trend
#property indicator_color4 Bisque              // Arrow size indicating new down trend
#property indicator_color5 DeepSkyBlue         // Up trend line thickness
#property indicator_color6 LightSalmon         // Down trend line thickness


#property indicator_width5 2
#property indicator_width6 2




extern int    Length = 14;    // Bollinger Bands Period
extern int    Deviation = 2;  // Deviation was 2
extern double MoneyRisk = 0.02; // Offset Factor
int    Signal = 1;            // Display signals mode: 1-Signals & Stops; 0-only Stops; 2-only Signals;
int    Line = 1;              // Display line mode: 0-no,1-yes
extern int    Nbars = 10000;
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

//---- indicator buffers
double UpTrendBuffer[];
double DownTrendBuffer[];
double UpTrendSignal[];
double DownTrendSignal[];
double UpTrendLine[];
double DownTrendLine[];
bool SoundON = true;
bool TurnedUp = true;
bool TurnedDown = true;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexBuffer(0, UpTrendBuffer);
   SetIndexBuffer(1, DownTrendBuffer);
   SetIndexBuffer(2, UpTrendSignal);
   SetIndexBuffer(3, DownTrendSignal);
   SetIndexBuffer(4, UpTrendLine);
   SetIndexBuffer(5, DownTrendLine);
   SetIndexStyle(0, DRAW_ARROW, 0, 0);
   SetIndexStyle(1, DRAW_ARROW, 0, 0);
   SetIndexStyle(2, DRAW_ARROW, 0, 5);
   SetIndexStyle(3, DRAW_ARROW, 0, 5);
   SetIndexStyle(4, DRAW_LINE, 0, 5);
   SetIndexStyle(5, DRAW_LINE, 0, 5);
   SetIndexArrow(0, 159);
   SetIndexArrow(1, 159);
   SetIndexArrow(2, 171);
   SetIndexArrow(3, 171);
   IndicatorDigits(MarketInfo(Symbol(), MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name = "Bams Bung 2(" + Length + "," + Deviation + ")";
   IndicatorShortName(short_name);
   SetIndexLabel(0, "UpTrend Stop");
   SetIndexLabel(1, "DownTrend Stop");
   SetIndexLabel(2, "UpTrend Signal");
   SetIndexLabel(3, "DownTrend Signal");
   SetIndexLabel(4, "UpTrend Line");
   SetIndexLabel(5, "DownTrend Line");
//----
   SetIndexDrawBegin(0, Length);
   SetIndexDrawBegin(1, Length);
   SetIndexDrawBegin(2, Length);
   SetIndexDrawBegin(3, Length);
   SetIndexDrawBegin(4, Length);
   SetIndexDrawBegin(5, Length);
//----
   return(0);
  }

//+------------------------------------------------------------------+
//|    i-Custom bams-bung 2, now Bams Bung 2                         |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, trend;
   double smax[15000], smin[15000], bsmax[15000], bsmin[15000];
   for(shift = Nbars; shift >= 0; shift--)
     {
      UpTrendBuffer[shift] = 0;
      DownTrendBuffer[shift] = 0;
      UpTrendSignal[shift] = 0;
      DownTrendSignal[shift] = 0;
      UpTrendLine[shift] = EMPTY_VALUE;
      DownTrendLine[shift] = EMPTY_VALUE;
     }
   for(shift = Nbars - Length - 1; shift >= 0; shift--)
     {
      smax[shift] = iBands(NULL, 0, Length, Deviation, 0, PRICE_CLOSE, MODE_UPPER, shift);
      smin[shift] = iBands(NULL, 0, Length, Deviation, 0, PRICE_CLOSE, MODE_LOWER, shift);
      if(Close[shift] > smax[shift + 1])
         trend = 1;
      if(Close[shift] < smin[shift + 1])
         trend = -1;
      if(trend > 0 && smin[shift] < smin[shift + 1])
         smin[shift] = smin[shift + 1];
      if(trend < 0 && smax[shift] > smax[shift + 1])
         smax[shift] = smax[shift + 1];
      bsmax[shift] = smax[shift] + 0.5 * (MoneyRisk - 1) * (smax[shift] - smin[shift]);
      bsmin[shift] = smin[shift] - 0.5 * (MoneyRisk - 1) * (smax[shift] - smin[shift]);
      if(trend > 0 && bsmin[shift] < bsmin[shift + 1])
         bsmin[shift] = bsmin[shift + 1];
      if(trend < 0 && bsmax[shift] > bsmax[shift + 1])
         bsmax[shift] = bsmax[shift + 1];
      if(trend > 0)
        {
         if(Signal > 0 && UpTrendBuffer[shift + 1] == -1.0)
           {
            UpTrendSignal[shift] = bsmin[shift];
            UpTrendBuffer[shift] = bsmin[shift];
            if(Line > 0)
               UpTrendLine[shift] = bsmin[shift];
            if(SoundON == true && shift == 0 && !TurnedUp)
              {
               Alert("Bams Bung 2 --> ", Symbol(), "@TF", Period());
               TurnedUp = true;
               TurnedDown = false;
              }
           }
         else
           {
            UpTrendBuffer[shift] = bsmin[shift];
            if(Line > 0)
               UpTrendLine[shift] = bsmin[shift];
            UpTrendSignal[shift] = -1;
           }
         if(Signal == 2)
            UpTrendBuffer[shift] = 0;
         DownTrendSignal[shift] = -1;
         DownTrendBuffer[shift] = -1.0;
         DownTrendLine[shift] = EMPTY_VALUE;
        }
      if(trend < 0)
        {
         if(Signal > 0 && DownTrendBuffer[shift + 1] == -1.0)
           {
            DownTrendSignal[shift] = bsmax[shift];
            DownTrendBuffer[shift] = bsmax[shift];
            if(Line > 0)
               DownTrendLine[shift] = bsmax[shift];
            if(SoundON == true && shift == 0 && !TurnedDown)
              {
               Alert("Bams Bung 2 --> ", Symbol(), "@TF", Period());
               TurnedDown = true;
               TurnedUp = false;
              }
           }
         else
           {
            DownTrendBuffer[shift] = bsmax[shift];
            if(Line > 0)
               DownTrendLine[shift] = bsmax[shift];
            DownTrendSignal[shift] = -1;
           }
         if(Signal == 2)
            DownTrendBuffer[shift] = 0;
         UpTrendSignal[shift] = -1;
         UpTrendBuffer[shift] = -1.0;
         UpTrendLine[shift] = EMPTY_VALUE;
        }
     }
     if(notificationsOn > 0)
     {
      checkAlert();
     }
   return(0);
  }

//+------------------------------------------------------------------+

bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(IsValue(UpTrendLine[0]))
        {
         Notify(1);
         alerted = true;
        }
      if(IsValue(DownTrendLine[0]))
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(IsValue(UpTrendLine[1]))
        {
         Notify(11);
        }
      if(IsValue(DownTrendLine[1]))
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsValue(double val)
  {
   return val > 0 && val != EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Bams Bung: ";
   switch(type)
     {
      case 1:
         text += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Turned UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Turned DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 