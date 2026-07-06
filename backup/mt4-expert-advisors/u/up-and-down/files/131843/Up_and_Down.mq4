// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69435

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
#property strict

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_style1 STYLE_SOLID
#property indicator_color1 Yellow

#property indicator_level1 0
#property indicator_minimum -3
#property indicator_maximum 3
#define PREFIX "xxx"

input string symbol = "EURUSD"; // Symbol
extern int    period          = 18;
extern bool   Arrow           = true;
extern int    ArrowSize       = 1;
extern int    SIGNAL_BAR      = 1;
extern color  clArrowBuy      = Blue;
extern color  clArrowSell     = Red; 

//Signaler v 1.7
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
   string _symbol;
   ENUM_TIMEFRAMES _timeframe;
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

double      ExtBuffer0[];
Signaler* signaler;
// -------------------------------------------------------------------------------------------------------------
int init()
{
   signaler = new Signaler(symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(symbol + "/" + signaler.GetTimeframeStr() + ": ");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtBuffer0);
   IndicatorShortName("Up and Down");
   return(0);
}
// -------------------------------------------------------------------------------------------------------------
int deinit()                            
{          
   delete signaler;
   signaler = NULL;                                 
   for (int i = ObjectsTotal()-1; i >= 0; i--)   
   if (StringSubstr(ObjectName(i), 0, StringLen(PREFIX)) == PREFIX)
      ObjectDelete(ObjectName(i));
   return(0);  
}
// -------------------------------------------------------------------------------------------------------------
int start()
{
   double Value=0,Value1=0,Value2=0,Fish=0,Fish1=0,Fish2=0;
   double price;
   double MinL=0;
   double MaxH=0;

   int counted_bars = IndicatorCounted();
   int minBars = 2;
   int limit = MathMin(Bars - 1 - minBars, Bars - counted_bars - 1);
   for (int i = limit; i >= 0; i--)
   {
      int index = iBarShift(symbol, _Period, Time[i]);
      MaxH = iHigh(symbol, 0, iHighest(symbol, 0, MODE_CLOSE, period, index));
      MinL = iLow(symbol, 0, iLowest(symbol, 0, MODE_CLOSE, period, index));
      price = (iOpen(symbol, 0, index) + iClose(symbol, 0, index)) / 2;                                             

      if (MaxH-MinL == 0)
      {
         Value = 0.33*2*(0-0.5) + 0.67*Value1;
      }
      else
      {
         Value = 0.33*2*((price-MaxH)/(MinL-MaxH)-0.5) + 0.67*Value1;
      }

      Value = MathMin(MathMax(Value, -0.999), 0.999);
      if (1 - Value == 0)
      {
         ExtBuffer0[i]=0.5+0.5*Fish1;
      }
      else
      {
         ExtBuffer0[i]=0.5*MathLog((1+Value)/(1-Value))+0.5*Fish1;
      }

      Value1=Value;
      Fish1=ExtBuffer0[i];

      if (Arrow)
      {
         if (ExtBuffer0[i + SIGNAL_BAR + 1] > 0.0 && ExtBuffer0[i + SIGNAL_BAR] < 0.0)
         {
            manageArr(i + 1, clArrowBuy, 233, false);
         }
         if (ExtBuffer0[i + SIGNAL_BAR + 1] < 0.0 && ExtBuffer0[i + SIGNAL_BAR] > 0.0)
         {
            manageArr(i + 1, clArrowSell, 234, true);
         }
      }
   }
   return(0);
}
// -------------------------------------------------------------------------------------------------------------
void manageArr(int j, color clr, int theCode, bool up)   
{
   string objName = PREFIX + Time[j];
   double gap  = 3.0*iATR(NULL,0,20,j)/4.0;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[j],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,theCode);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
   if ( up )
   {
      ObjectSet(objName,OBJPROP_PRICE1,Open[j]+gap);
      if (j == 1)
      {
         signaler.SendNotifications("Up");
      }
   }
   else  
   {
      ObjectSet(objName,OBJPROP_PRICE1,Close[j] -gap);
      if (j == 1)
      {
         signaler.SendNotifications("Down");
      }
   }
}
// -------------------------------------------------------------------------------------------------------------

