// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69229

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
#property indicator_buffers 8
#property indicator_color1 clrRed
#property indicator_color2 clrLime
#property indicator_color3 clrRed
#property indicator_color4 clrLime
#property indicator_color5 clrRed
#property indicator_color6 clrLime
#property indicator_color7 clrRed
#property indicator_color8 clrLime
#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 6
#property indicator_width4 6
#property indicator_width5 2
#property indicator_width6 2
#property indicator_width7 4
#property indicator_width8 4

extern int PeriodWeakChannel = 24;
extern int PeriodMainChannel = 96;
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

double b1[],b2[],b3[],b4[],b5[],b6[],b7[],b8[];
int TimeFrame;
int shift1=PeriodWeakChannel/2;
int shift2=PeriodMainChannel/2;

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

Signaler* signaler;

int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");

   TimeFrame = MathMax(TimeFrame,_Period);
   IndicatorBuffers(8);
   SetIndexBuffer(0,b1); SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,164);
   SetIndexBuffer(1,b2); SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,164);
   SetIndexBuffer(2,b3); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,164);
   SetIndexBuffer(3,b4); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,164);
   SetIndexBuffer(4,b5); SetIndexLabel(4,"Upper weak channel");
   SetIndexBuffer(5,b6); SetIndexLabel(5,"Lower weak channel");
   SetIndexBuffer(6,b7); SetIndexLabel(6,"Upper Main channel");
   SetIndexBuffer(7,b8); SetIndexLabel(7,"Lower Main channel");
   IndicatorShortName(timeFrameToString(TimeFrame)+" Super-signals ("+PeriodWeakChannel+","+PeriodMainChannel+")");
   return(0);
}

void OnDeinit(const int reason)
{
   delete signaler;
}

datetime last_alert;
int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit,hhb1,llb1,hhb2,llb2;

   if(counted_bars<0) 
      return(-1);
   if(counted_bars>0) 
      counted_bars--;
   limit = Bars - counted_bars - 1;
   limit = MathMax(limit, PeriodMainChannel);

   for (i=limit;i>=0;i--)
   {
      hhb1 = Highest(NULL,0,MODE_HIGH,PeriodWeakChannel,i-shift1);
      llb1 = Lowest(NULL,0,MODE_LOW,PeriodWeakChannel,i-shift1);
      hhb2 = Highest(NULL,0,MODE_HIGH,PeriodMainChannel,i-shift2);
      llb2 = Lowest(NULL,0,MODE_LOW,PeriodMainChannel,i-shift2);

      b1[i] = EMPTY_VALUE;
      b2[i] = EMPTY_VALUE;
      b3[i] = EMPTY_VALUE;
      b4[i] = EMPTY_VALUE;
      b5[i] = High[hhb1];
      b6[i] = Low[llb1];
      b7[i] = High[hhb2];
      b8[i] = Low[llb2];

      if (i==hhb1) 
         b1[i]=High[hhb1];
      if (i==llb1) 
         b2[i]=Low[llb1];
      if (i==hhb2) 
         b3[i]=High[hhb2];
      if (i==llb2) 
         b4[i]=Low[llb2] ;
   }

   //-------------------------------------------------------------

   if (last_alert != Time[0])
   {
      if (b1[1] != EMPTY_VALUE && b3[1] != EMPTY_VALUE)
      {
         signaler.SendNotifications(" @ MAIN channel");
         last_alert = Time[0];
      }
      else if (b2[1] != EMPTY_VALUE && b4[1] != EMPTY_VALUE)
      {
         signaler.SendNotifications(" @ MAIN channel");
         last_alert = Time[0];
      }
      else if (b1[1] != EMPTY_VALUE && b3[1] == EMPTY_VALUE)
      {
         signaler.SendNotifications(" @ WEAK channel");
         last_alert = Time[0];
      }
      else if (b2[1] != EMPTY_VALUE && b4[1] == EMPTY_VALUE)
      {
         signaler.SendNotifications(" @ WEAK channel");
         last_alert = Time[0];
      }
   }
   return(0);
}

string sTfTable[] = {"M1","M2","M3","M5","M10","M15","M30","H1","H4","D1","W1","MN"};
int iTfTable[] = {1,2,3,5,10,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
      if (tf==iTfTable[i]) 
         return(sTfTable[i]);
   return("");
}
