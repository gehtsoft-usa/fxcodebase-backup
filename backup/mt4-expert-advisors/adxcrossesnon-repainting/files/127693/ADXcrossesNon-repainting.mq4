// More information about this indicator can be found at:
// http://fxcodebase.com/

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
#property version   "1.0"
#property strict

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red
//---- input parameters
extern int ADXcrossesPeriod = 14;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
//----
double b4plusdi, b4minusdi, nowplusdi, nowminusdi;
int    nShift;   

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = true; // Popup message
extern bool     notification_alert       = false; // Push notification
extern bool     email_alert              = false; // Email
extern bool     play_sound               = false; // Play sound on alert
extern string   sound_file               = ""; // Sound file
extern bool     start_program            = false; // Start external program
extern string   program_path             = ""; // Path to the external program executable
extern bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
extern string   advanced_key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
extern string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
   datetime _lastDatetime;
   string _prefix;
public:
   Signaler(const string symbol, ENUM_TIMEFRAMES timeframe)
   {
      _symbol = symbol;
      _timeframe = timeframe;
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
         case PERIOD_M5: return "M5";
         case PERIOD_D1: return "D1";
         case PERIOD_H1: return "H1";
         case PERIOD_H4: return "H4";
         case PERIOD_M15: return "M15";
         case PERIOD_M30: return "M30";
         case PERIOD_MN1: return "MN1";
         case PERIOD_W1: return "W1";
      }
      return "M1";
   }

   void SendNotifications(const string subject, string message = NULL, string symbol = NULL, string timeframe = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;
      if (symbol == NULL)
         symbol = _symbol;
      if (timeframe == NULL)
         timeframe = GetTimeframeStr();

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
         AdvancedAlert(advanced_key, message, symbol, timeframe);
   }
};

Signaler* _signaler;

int init() 
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
//---- indicators
   SetIndexStyle(0, DRAW_ARROW, 0, 3);
   SetIndexArrow(0, 233);
   SetIndexBuffer(0, ExtMapBuffer1);
//----
   SetIndexStyle(1, DRAW_ARROW, 0, 3);
   SetIndexArrow(1, 234);
   SetIndexBuffer(1, ExtMapBuffer2);
//---- name for DataWindow and indicator subwindow label
   IndicatorShortName("ADXcrosses(" + IntegerToString(ADXcrossesPeriod) + ")");
   SetIndexLabel(0, "ADXcrUp");
   SetIndexLabel(1, "ADXcrDn"); 
//----
   switch(Period())
   {
      case     1: nShift = 1;   break;    
      case     5: nShift = 3;   break; 
      case    15: nShift = 5;   break; 
      case    30: nShift = 10;  break; 
      case    60: nShift = 15;  break; 
      case   240: nShift = 20;  break; 
      case  1440: nShift = 80;  break; 
      case 10080: nShift = 100; break; 
      case 43200: nShift = 200; break;               
   }
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
//----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
   delete _signaler;
   _signaler = NULL;
//----
    return(0);
}
datetime _lastSignal;
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int limit;
   int counted_bars = IndicatorCounted();
//---- check for possible errors
   if(counted_bars < 0) 
      return(-1);
//---- last counted bar will be recounted
   if(counted_bars > 0) 
      counted_bars--;
   limit = Bars - counted_bars;
//----
   for(int i = 0; i < limit; i++)
   {
      b4plusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i + 1);
      nowplusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_PLUSDI, i);
      b4minusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i + 1);
      nowminusdi = iADX(NULL, 0, ADXcrossesPeriod, PRICE_CLOSE, MODE_MINUSDI, i);  
      //----
      if(b4plusdi < b4minusdi && nowplusdi > nowminusdi)
         ExtMapBuffer1[i] = Low[i] - nShift*Point;
      //----
      if(b4plusdi > b4minusdi && nowplusdi < nowminusdi)
         ExtMapBuffer2[i] = High[i] + nShift*Point;
   }
   if (ExtMapBuffer1[0] != EMPTY_VALUE)
   {
      datetime dt = iTime(_Symbol, _Period, 0);
      if (_lastSignal != dt)
      {
         _signaler.SendNotifications(_Symbol + "/" + _signaler.GetTimeframeStr() + ": Up");
         _lastSignal = dt;
      }
   }
   else if (ExtMapBuffer2[0] != EMPTY_VALUE)
   {
      datetime dt = iTime(_Symbol, _Period, 0);
      if (_lastSignal != dt)
      {
         _signaler.SendNotifications(_Symbol + "/" + _signaler.GetTimeframeStr() + ": Down");
         _lastSignal = dt;
      }
   }
//----
   return(0);
}
//+------------------------------------------------------------------+

