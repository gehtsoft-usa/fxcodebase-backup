// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70869

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
//+------------------------------------------------------------------+
//| ASCTrend1i.mq4 
//| Ramdass - Conversion only
//| Updates:
//|  2013-04-15, v1.1, X
//|    - Bug fix. Check array bounds in loops
//|    - Bug fix. Set correct nr of counted bars on first run
//|  2012-10-23, X, Performance enhancements. About 500x improvement.
//|    - Removed redundant code and variables
//|    - Cleaned up and modified code for improved performance
//|    - Update only the new bars instead of the full buffer.
//|    - Commented code
//|    - Option to use full buffer size.
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Magenta
#property indicator_color2 Yellow
#property  indicator_width1  1 
#property  indicator_width2  1

#define RANGE_FACTOR 4.6
#define ALT_PERIOD 4
#define HIGH_LEVEL 67
#define LOW_LEVEL 33

//---- input parameters
extern int Risk=6;       // Risk level. WPR_Period=3+Risk*2 or WPR_Period=ALT_PERIOD for a large move 
extern int BarCount=0;   // 0 for full chart buffer
//Signaler v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start inputal program
input string   program_path             = ""; // Path to the inputal program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, "", "");
   }
};

//---- buffers
double dn_sig[];
double up_sig[];
double signal[];
Signaler* mainSignaler;

string TimeframeToString(ENUM_TIMEFRAMES tf)
{
   switch (tf)
   {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_D1: return "D1";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_MN1: return "MN1";
      case PERIOD_W1: return "W1";
   }
   return "";
}
datetime last_signal;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  //Init buffers
   mainSignaler = new Signaler();
   mainSignaler.SetMessagePrefix(_Symbol + "/" + TimeframeToString((ENUM_TIMEFRAMES)_Period) + ": ");
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_ARROW);
   SetIndexArrow(0,234); 
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexArrow(1,233); 
   SetIndexStyle(2,DRAW_NONE);
   
   SetIndexBuffer(0,dn_sig);
   SetIndexBuffer(1,up_sig);
   SetIndexBuffer(2,signal);
      
   SetIndexLabel(0, "Down");
   SetIndexLabel(1, "Up");
   SetIndexLabel(2, "Signal");

   SetIndexDrawBegin(0,3+Risk*2+1); 
   SetIndexDrawBegin(1,3+Risk*2+1);
      
   // Set max bars to draw
   if (BarCount<1 || BarCount>Bars) 
      BarCount=Bars-12;

  return(0);
}

void OnDeinit(const int reason)
{
   delete mainSignaler;
}

//+------------------------------------------------------------------+
//| ASCTrend1sig                                                     |
//+------------------------------------------------------------------+
int start() {
  int i,shift,counted_bars, min_bars, wpr_period;
  double wpr_value, avg_range, high_level,low_level;
  
  // Set levels 
  high_level=HIGH_LEVEL+Risk;
  low_level=LOW_LEVEL-Risk;
   
  // Check for enough bars
  min_bars=3+Risk*2+1;
  if(Bars<=min_bars) 
    return(0);
    
  // Get new bars
  counted_bars=IndicatorCounted();
  if(counted_bars<0) 
    return (-1); 
  if(counted_bars>0) 
    counted_bars--;
  shift=Bars-counted_bars;
  if (BarCount>0 && shift>BarCount)
    shift=BarCount;
  if (shift>Bars-min_bars)
    shift=Bars-min_bars;  
     
  while(shift>=0) { 
    // Calc Avg range for 10 bars
    i=shift;
    avg_range=0.0;
    for (i=shift; i<shift+10; i++) {
      if (i>=Bars) break;
      avg_range=avg_range+MathAbs(High[i]-Low[i]);
    }
    avg_range=avg_range/10.0;
 
    // Set period for WPR calculation.
    wpr_period=3+Risk*2;
    
    // Use alternative period if there has been a large move.
    i=shift;
    while (i<shift+6) {
      if (i>=Bars-3) break;
      if (MathAbs(Close[i+3]-Close[i])>=avg_range*RANGE_FACTOR) {
        wpr_period=ALT_PERIOD;
        break;
      }
      i++;
    }      
	 
    // Calc WPR 
    wpr_value=100-MathAbs(iWPR(NULL,0,wpr_period,shift)); 
    
    // Set current signal
    if (wpr_value>=high_level) 
      signal[shift] = 1;
    else if (wpr_value<=low_level) 
      signal[shift] = -1;  
    else if (wpr_value>low_level && signal[shift+1]==1) 
      signal[shift] = 1;
    else if (wpr_value<high_level && signal[shift+1]==-1) 
      signal[shift] = -1;      
    else
      signal[shift]=0;
      
    // Draw arrows
    dn_sig[shift]=0;
    up_sig[shift]=0;
    if (signal[shift]==-1 && signal[shift+1]==1)
      dn_sig[shift]=High[shift]+avg_range*0.5;
    if (signal[shift]==1 && signal[shift+1]==-1)
      up_sig[shift]=Low[shift]-avg_range*0.5;
    
    shift--;
   }
   if (last_signal != Time[0])
   {
      if (signal[0] == 1 && signal[1] != 1)
      {
         mainSignaler.SendNotifications("Buy");
      }
      else if (signal[0] == -1 && signal[1] != -1)
      {
         mainSignaler.SendNotifications("Sell");
      }
   }

   return(0);
}
//+------------------------------------------------------------------+


