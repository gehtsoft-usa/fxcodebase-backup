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
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots 2

#property indicator_color1 clrRed
#property indicator_width1 1
#property indicator_type1 DRAW_ARROW

#property indicator_color2 clrBlue
#property indicator_width2 1
#property indicator_type2 DRAW_ARROW

input int FilterCandle=12;
double bufferUp[];
double bufferDown[];
input string AlertsSection = ""; // == Alerts ==
input bool     Popup_Alert              = true; // Popup message
input bool     Notification_Alert       = false; // Push notification
input bool     Email_Alert              = false; // Email
input bool     Play_Sound               = false; // Play sound on alert
input string   Sound_File               = ""; // Sound file
#ifdef ADVANCED_ALERTS
input bool     Advanced_Alert           = false; // Advanced alert
input string   Advanced_Key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib using ProfitRobots installer -";
#endif

#ifdef ADVANCED_ALERTS
// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#endif

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   string _prefix;
   bool _popupAlert;
   bool _emailAlert;
   bool _playSound;
   string _soundFile;
   bool _notificationAlert;
   bool _advancedAlert;
   string _advancedKey;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
      _popupAlert = false;
      _emailAlert = false;
      _playSound = false;
      _notificationAlert = false;
      _advancedAlert = false;
   }

   void SetPopupAlert(bool isEnabled) { _popupAlert = isEnabled; }
   void SetEmailAlert(bool isEnabled) { _emailAlert = isEnabled; }
   void SetPlaySound(bool isEnabled, string fileName) 
   { 
      _playSound = isEnabled;
      _soundFile = fileName;
   }
   void SetNotificationAlert(bool isEnabled) { _notificationAlert = isEnabled; }
   void SetAdvancedAlert(bool isEnabled, string key)
   {
      _advancedAlert = isEnabled;
      _advancedKey = key;
   }

   void SendNotifications(string message, string subject = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (subject == NULL)
         subject = message;

      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

      if (_popupAlert)
         Alert(message);
      if (_emailAlert)
         SendMail(subject, message);
      if (_playSound)
         PlaySound(_soundFile);
      if (_notificationAlert)
         SendNotification(message);
#ifdef ADVANCED_ALERTS
      if (_advancedAlert && _advancedKey != "")
         AdvancedAlert(_advancedKey, message, symbol, timeframe);
#endif
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   string GetSymbol()
   {
      return _symbol;
   }

   ENUM_TIMEFRAMES GetTimeframe()
   {
      return _timeframe;
   }

   string GetTimeframeStr()
   {
      switch (_timeframe)
      {
         case PERIOD_M1: return "M1";
         case PERIOD_M2: return "M2";
         case PERIOD_M3: return "M3";
         case PERIOD_M4: return "M4";
         case PERIOD_M5: return "M5";
         case PERIOD_M6: return "M6";
         case PERIOD_M10: return "M10";
         case PERIOD_M12: return "M12";
         case PERIOD_M15: return "M15";
         case PERIOD_M20: return "M20";
         case PERIOD_M30: return "M30";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H2: return "H2";
         case PERIOD_H3: return "H3";
         case PERIOD_H4: return "H4";
         case PERIOD_H6: return "H6";
         case PERIOD_H8: return "H8";
         case PERIOD_H12: return "H12";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }
};
Signaler* mainSignaler;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   mainSignaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   mainSignaler.SetPopupAlert(Popup_Alert);
   mainSignaler.SetEmailAlert(Email_Alert);
   mainSignaler.SetPlaySound(Play_Sound, Sound_File);
   mainSignaler.SetNotificationAlert(Notification_Alert);
   #ifdef ADVANCED_ALERTS
   mainSignaler.SetAdvancedAlert(Advanced_Alert, Advanced_Key);
   #endif
   mainSignaler.SetMessagePrefix(_Symbol + "/" + mainSignaler.GetTimeframeStr() + ": ");
   //--- indicator buffers mapping
   SetIndexBuffer(0,bufferUp,INDICATOR_DATA);
   SetIndexBuffer(1,bufferDown,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);

   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);

   ArraySetAsSeries(bufferDown,true);
   ArraySetAsSeries(bufferUp,true);
   //---
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
   mainSignaler = NULL;
}
datetime last_signal;
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
//---
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
   int limit;
   if(prev_calculated>0)
      limit=rates_total-prev_calculated -1;
   else
      limit=rates_total -1;

   for(int i=limit; i>=0; i--)
   {
      bufferUp[i]=0;
      bufferDown[i]=0;

      if(i+FilterCandle+2<rates_total)
      {
         if(isUp(i+1))
         {
            bufferUp[i+2]=low[i+2];
         }

         if(isDown(i+1))
         {
            bufferDown[i+2]=high[i+2];
         }
      }
   }

   if (time[rates_total - 1] != last_signal)
   {
      if (bufferUp[2] != 0 && bufferUp[2] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("Up");
         last_signal = time[rates_total - 1];
      }
      if (bufferDown[2] != 0 && bufferDown[2] != EMPTY_VALUE)
      {
         mainSignaler.SendNotifications("Down");
         last_signal = time[rates_total - 1];
      }
   }

//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+

bool isUp(int index)
{
   bool flag=true;
   int preIndex=index+1;
   if(
      iLow(Symbol(),0,index)>iLow(Symbol(),0,preIndex)
      && iHigh(Symbol(),0,index)>iHigh(Symbol(),0,preIndex)
      && iClose(Symbol(),0,index)>iClose(Symbol(),0,preIndex)
      )
   {
      int startIndex=preIndex+1;
      int endIndex=preIndex+FilterCandle-1;
      for(int i=startIndex; i<=endIndex; i++)
      {
         if(iLow(Symbol(),0,i)<iLow(Symbol(),0,preIndex))
         {
            flag=false;
            break;
         }
      }
   }
   else
   {
      flag=false;
   }

   return flag;
}
//+------------------------------------------------------------------+

bool isDown(int index)
{
   bool flag=true;
   int preIndex=index+1;
   if(
      iLow(Symbol(),0,index)<iLow(Symbol(),0,preIndex)
      && iHigh(Symbol(),0,index)<iHigh(Symbol(),0,preIndex)
      && iClose(Symbol(),0,index)<iClose(Symbol(),0,preIndex)
      )
   {
      int start=preIndex+1;
      int end=preIndex+FilterCandle-1;
      for(int i=start; i<=end; i++)
      {
         if(iHigh(Symbol(),0,i)>iHigh(Symbol(),0,preIndex))
         {
            flag=false;
            break;
         }
      }
   }
   else
   {
      flag=false;
   }

   return flag;
}
//+------------------------------------------------------------------+
