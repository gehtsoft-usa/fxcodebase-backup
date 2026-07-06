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

extern int NumBars = 500;
double out1[];
double out2[];
double gd_88;
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
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexBuffer(0, out1);
   SetIndexArrow(0, 233);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexBuffer(1, out2);
   SetIndexArrow(1, 234);
   gd_88 = MarketInfo(Symbol(), MODE_SPREAD) * Point;
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);

   return (0);
}

int deinit() 
{
   delete _signaler;
   _signaler = NULL;
   return (0);
}

datetime _lastSignal;

int start() 
{
   double lda_60[100];
   int li_4 = 7;
   double ld_8 = 7.0;
   double ld_16 = 0.7;
   int l_index_64 = 0;
   double ld_96 = 0;
   int li_104 = 0;
   double ld_120 = 2;
   int li_24 = Bars < NumBars ? Bars : NumBars;
   bool li_32 = Close[li_24 - 2] > Close[li_24 - 1];
   double ld_36 = Close[li_24 - 2];
   for (int li_28 = li_24 - 3; li_28 >= 0; li_28--)
   {
      double ld_52 = gd_88 + High[li_28] - Low[li_28];
      if (MathAbs(gd_88 + High[li_28] - (Close[li_28 + 1])) > ld_52) 
         ld_52 = MathAbs(gd_88 + High[li_28] - (Close[li_28 + 1]));
      if (MathAbs(Low[li_28] - (Close[li_28 + 1])) > ld_52) 
         ld_52 = MathAbs(Low[li_28] - (Close[li_28 + 1]));
      if (li_28 == li_24 - 3)
      {
         for (int l_index_76 = 0; li_28 <= li_4 - 1; l_index_76++) 
         {
            lda_60[l_index_76] = ld_52;
         }
      }
      lda_60[l_index_64] = ld_52;
      double ld_68 = 0;
      double ld_80 = li_4;
      int li_108 = l_index_64;
      for (int l_index_76 = 0; l_index_76 <= li_4 - 1; l_index_76++)
      {
         ld_68 += lda_60[li_108] * ld_80;
         ld_80 -= 1.0;
         li_108--;
         if (li_108 == -1)
            li_108 = li_4 - 1;
      }
      ld_68 = 2.0 * ld_68 / (ld_8 * (ld_8 + 1.0));
      l_index_64++;
      if (l_index_64 == li_4) 
         l_index_64 = 0;
      double ld_44 = ld_16 * ld_68;
      if (li_32 && Low[li_28] < ld_36 - ld_44) 
      {
         li_32 = FALSE;
         ld_36 = gd_88 + High[li_28];
      }
      if (!li_32 && gd_88 + High[li_28] > ld_36 + ld_44) 
      {
         li_32 = TRUE;
         ld_36 = Low[li_28];
      }
      if (li_32 && Low[li_28] > ld_36) 
         ld_36 = Low[li_28];
      if (!li_32 && gd_88 + High[li_28] < ld_36) 
         ld_36 = gd_88 + High[li_28];
      double l_iatr_112 = iATR(NULL, 0, 10, li_28);
      double ld_136 = 0;
      double ld_144 = 0;
      if (li_32)
      {
         if (li_104 != 1) 
            ld_96 = Low[li_28] - l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 1) 
            ld_96 = -1.0;
         if (ld_96 > 0.0) 
         {
            ld_136 = ld_96;
            ld_144 = 0;
         }
         else 
         {
            ld_136 = 0;
            ld_144 = 0;
         }
         out1[li_28] = ld_136;
         li_104 = 1;
      }
      else
      {
         if (li_104 != 2) 
            ld_96 = gd_88 + High[li_28] + l_iatr_112 * ld_120 / 3.0;
         if (li_104 == 2) 
            ld_96 = -1.0;
         if (ld_96 > 0.0) 
         {
            ld_136 = 0;
            ld_144 = ld_96;
         }
         else 
         {
            ld_136 = 0;
            ld_144 = 0;
         }
         out2[li_28] = ld_144;
         li_104 = 2;
      }
   }
   if (out1[0] != 0)
   {
      datetime dt = iTime(_Symbol, _Period, 0);
      if (_lastSignal != dt)
      {
         _signaler.SendNotifications(_Symbol + "/" + _signaler.GetTimeframeStr() + ": Up");
         _lastSignal = dt;
      }
   }
   else if (out2[0] != 0)
   {
      datetime dt = iTime(_Symbol, _Period, 0);
      if (_lastSignal != dt)
      {
         _signaler.SendNotifications(_Symbol + "/" + _signaler.GetTimeframeStr() + ": Down");
         _lastSignal = dt;
      }
   }
   return (0);
}