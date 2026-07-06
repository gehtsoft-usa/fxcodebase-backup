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
 
#define major   1
#define minor   0
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 DodgerBlue
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 Yellow
#property indicator_style2 STYLE_DOT
#property indicator_level1 50
#property indicator_levelcolor Aqua
#property indicator_levelstyle STYLE_DOT
//----
extern string NOTESETTINGS=" --- INDICATOR SETTINGS ---";
extern int SF=5;
extern string NOTEALERTS=" --- Alerts ---";
extern int AlertLevel=50;
extern bool MsgAlerts=true;
extern bool SoundAlerts=true;
extern string SoundAlertFile="alert.wav";
extern bool eMailAlerts=false;

//Signaler v 1.7
// More templates and snippets on https://github.com/sibvic/mq4-templates
extern string   AlertsSection            = ""; // == Alerts ==
extern bool     popup_alert              = false; // Popup message
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

//----
int RSI_Period=14;
int Wilders_Period;
int StartBar, LastAlertBar;
datetime LastAlertTime;
double TrLevelSlow[];
double AtrRsi[];
double MaAtrRsi[];
double Rsi[];
double RsiMa[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   if (!IsDllsAllowed() && advanced_alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   Wilders_Period=RSI_Period * 2 - 1;
   if (Wilders_Period < SF)
      StartBar=SF;
   else
      StartBar=Wilders_Period;
//----
   IndicatorBuffers(6);
   SetIndexBuffer(0, RsiMa);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2);
   SetIndexLabel(0, "Value 1");
   SetIndexDrawBegin(0, StartBar);
   SetIndexStyle(1, DRAW_LINE, STYLE_DOT);
   SetIndexBuffer(1, TrLevelSlow);
   SetIndexLabel(1, "Value 2");
   SetIndexDrawBegin(1, StartBar);
   SetIndexBuffer(2, AtrRsi);
   SetIndexBuffer(3, MaAtrRsi);
   SetIndexBuffer(4, Rsi);
   IndicatorShortName(StringConcatenate("QQE(", SF, ")"));
//----
   LastAlertBar=Bars-1;
   return(0);
  }
  
void deinit()
{
   delete _signaler;
   _signaler = NULL;
}
datetime _dt;
int start()
  {
   int counted, i;
   double rsi0, rsi1, dar, tr, dv;
//----
   if(Bars<=StartBar)
      return(0);
//----      
   counted=IndicatorCounted();
   if(counted < 1)
      for(i=Bars - StartBar; i < Bars; i++)
        {
         TrLevelSlow[i]=0.0;
         AtrRsi[i]=0.0;
         MaAtrRsi[i]=0.0;
         Rsi[i]=0.0;
         RsiMa[i]=0.0;
        }
   counted=Bars - counted - 1;

   for(i=counted; i>=0; i--)
   {
      Rsi[i]=iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, i);
      RsiMa[i]=iMAOnArray(Rsi, 0, SF, 0, MODE_EMA, i);
      if (i != Bars - 1)
      {
         AtrRsi[i]=MathAbs(RsiMa[i + 1] - RsiMa[i]);
         MaAtrRsi[i]=iMAOnArray(AtrRsi, 0, Wilders_Period, 0, MODE_EMA, i);
      }
   }

   i=counted + 1;
   tr=TrLevelSlow[i];
   rsi1=iMAOnArray(Rsi, 0, SF, 0, MODE_EMA, i);
   while(i > 0)
     {
      i--;
      rsi0=iMAOnArray(Rsi, 0, SF, 0, MODE_EMA, i);
      dar=iMAOnArray(MaAtrRsi, 0, Wilders_Period, 0, MODE_EMA, i) * 4.236;
      dv=tr;
      if (rsi0 < tr)
        {
         tr=rsi0 + dar;
         if (rsi1 < dv)
            if (tr > dv)
               tr=dv;
        }
      else if (rsi0 > tr)
           {
            tr=rsi0 - dar;
            if (rsi1 > dv)
               if (tr < dv)
                  tr=dv;
           }
      TrLevelSlow[i]=tr;
      rsi1=rsi0;
   }
   i = 1;
   if (_dt == Time[i])
      return 0;
   if ((RsiMa[i+1]<AlertLevel && RsiMa[i]>AlertLevel) ||(RsiMa[i+1]>AlertLevel && RsiMa[i]<AlertLevel) )
   {
      string base=Symbol()+ ", TF: " + TF2Str(Period());
      string Subj=base + ", " + AlertLevel + " level Cross Up";
      if (RsiMa[i+1]>AlertLevel && RsiMa[i]<AlertLevel) 
         Subj=base + " " +  AlertLevel + " level Cross Down";
      string Msg=Subj + " @ " + TimeToStr(TimeLocal(),TIME_SECONDS);
      _signaler.SendNotifications(Subj, Msg);
      _dt = Time[i];
   }
//----
   return(0);
}

string TF2Str(int period)
  {
   switch(period)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M5: return("M5");
      case PERIOD_M15: return("M15");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H4: return("H4");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN");
     }
   return(Period());
  }
//+------------------------------------------------------------------+