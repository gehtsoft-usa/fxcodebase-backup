// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69370

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+


#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"
#property strict

//--- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 5
// MACD histogram
#property indicator_color1 Silver
#property indicator_width1 2
#property indicator_style1 STYLE_SOLID
// MACD line
#property indicator_color2 DodgerBlue
#property indicator_width2 1
#property indicator_style2 STYLE_SOLID
// Signal line
#property indicator_color3 FireBrick
#property indicator_width3 1
#property indicator_style3 STYLE_SOLID
// Momentum
#property indicator_color4 LightYellow
#property indicator_width4 1
#property indicator_style4 STYLE_DOT
// Smooth Momentum
#property indicator_color5 Gold
#property indicator_width5 1 
#property indicator_style5 STYLE_DASH
//#property strict

//--- indicator parameters
extern ENUM_TIMEFRAMES   TimeFrame            = PERIOD_CURRENT;    // Time frame to use
input int                BarsToProcess        = 1000;
input ENUM_APPLIED_PRICE AppliedPrice         = PRICE_CLOSE;
input int                PeriodFastEMA        = 12;
input int                PeriodSlowEMA        = 26;
input int                PeriodSignal         = 9;
input ENUM_MA_METHOD     SignalMA             = MODE_EMA;
input int                DeltaMomentum        = 10;
input int                PeriodMomentum       = 3;
input ENUM_MA_METHOD     MomentumMA           = MODE_SMA;
input bool               AlarmZeroCrossover   = true;
input bool               AlarmMomentumReverse = true;
input bool               Interpolate          = true;              // Interpolate true/false?

#property indicator_level1 0.0
#property indicator_levelcolor Silver
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

//--- indicator buffers
double macd[],sign[],histo[],mom[],smom[],macdL[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BarsToProcess,AppliedPrice,PeriodFastEMA,PeriodSlowEMA,PeriodSignal,SignalMA,DeltaMomentum,PeriodMomentum,MomentumMA,AlarmZeroCrossover,AlarmMomentumReverse,_buff,_ind)
//--- right input parameters flag
bool _flagParameters=false;
//---- store last bar time and the last alert direction
static int _prevSignal=0,_prevTime=0;
//---- bar number the alert to be searched by
#define SIGNAL_BAR 1

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

Signaler* signaler;
int OnInit()
{
   signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   signaler.SetMessagePrefix(_Symbol + "/" + signaler.GetTimeframeStr() + ": ");
   IndicatorDigits(Digits+1);
   IndicatorBuffers(7);
   SetIndexBuffer(0,histo); SetIndexStyle(0,DRAW_HISTOGRAM);        SetIndexLabel(0,"MACD histogram");
   SetIndexBuffer(1,macd);  SetIndexStyle(1,DRAW_LINE);             SetIndexLabel(1,"MACD");      
   SetIndexBuffer(2,sign);  SetIndexStyle(2,DRAW_LINE);             SetIndexLabel(2,"Signal");
   SetIndexBuffer(3,mom);   SetIndexStyle(3,DRAW_LINE,STYLE_DOT);   SetIndexLabel(3,"Momentum");
   SetIndexBuffer(4,smom);  SetIndexStyle(4,DRAW_LINE,STYLE_SOLID); SetIndexLabel(4,"Smooth Momentum");
   SetIndexBuffer(5,macdL);
   SetIndexBuffer(6,count);

   if(PeriodFastEMA<=1 || PeriodSlowEMA<=1 || PeriodSignal<=1 || PeriodFastEMA>=PeriodSlowEMA || PeriodMomentum<=0) 
   {
      Print("Wrong input parameters");
      _flagParameters=false;
      return(INIT_PARAMETERS_INCORRECT);
   }
   else
   {
      _flagParameters=true;
   }
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   
   IndicatorShortName(timeFrameToString(TimeFrame)+" MACD("+IntegerToString(PeriodFastEMA)+","+IntegerToString(PeriodSlowEMA)+","+IntegerToString(PeriodSignal)+")");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   delete signaler;
   signaler = NULL;
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
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
   int i,limitDisplay,limit=fmin(rates_total-prev_calculated+1,rates_total-2); 
   if (BarsToProcess==0)
      limitDisplay = limit;
   else  
      limitDisplay = fmin(limit,fmin(rates_total,BarsToProcess));  count[0]=limit;
      
   if (TimeFrame!=_Period)
   {
      limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
      for (i=limit;i>=0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL,TimeFrame,Time[i]);
         histo[i] = _mtfCall(0,y);
         macd[i]  = _mtfCall(1,y);
         sign[i]  = _mtfCall(2,y); 
         mom[i]   = _mtfCall(3,y); 
         smom[i]  = _mtfCall(4,y); 
         macdL[i] = _mtfCall(5,y); 
         
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) 
            continue;
         #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
         int n,k; datetime btime = iTime(NULL,TimeFrame,y);
         for(n = 1; (i+n)<rates_total && Time[i+n] >= btime; n++) 
            continue;	
         for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++)
         {
            _interpolate(macd);
            _interpolate(sign);
            _interpolate(mom);
            _interpolate(smom);
            _interpolate(macdL); 
            if (histo[i]!= EMPTY_VALUE) 
               histo[i+k] = macdL[i+k];
         }
      }          
      return(rates_total);
   } 
              
   for(i=limit; i>=0; i--)
   {
      macd[i] = iMA(NULL, 0, PeriodFastEMA, 0, MODE_EMA, AppliedPrice, i) - iMA(NULL, 0, PeriodSlowEMA, 0, MODE_EMA, AppliedPrice, i);
      sign[i] = iMAOnArray(macd, 0, PeriodSignal, 0, SignalMA, i);
      histo[i] = macd[i] - sign[i];
      macdL[i] = histo[i];
      if (i < Bars - 1 - DeltaMomentum) 
      {
         mom[i] = macd[i] - macd[i + DeltaMomentum];
      }
      smom[i] = iMAOnArray(mom, 0, PeriodMomentum, 0, MomentumMA, i);
   }

//---- Alarms
//---- avoid analyze the same bar multiple times
   if(SIGNAL_BAR>0 && Time[0]<=_prevTime)
      return(rates_total);
//---- mark that this bar was checked
   _prevTime=(int)Time[0];

   double currentPrice=NormalizeDouble((open[SIGNAL_BAR]+close[SIGNAL_BAR])/2,_Digits);
//---- preceding alert was SELL or this is the first launch (PrevSignal=0)
   if(_prevSignal<=0)
   {
      if(AlarmZeroCrossover && 
         macd[SIGNAL_BAR]-sign[SIGNAL_BAR]>0 && 
         sign[SIGNAL_BAR+1]-macd[SIGNAL_BAR+1]>=0)
      {
         _prevSignal=1;
         signaler.SendNotifications("[BUY] MACD " + DoubleToString(currentPrice, _Digits));
      }
      if(AlarmMomentumReverse && 
         smom[SIGNAL_BAR]-smom[SIGNAL_BAR+1]>0 && 
         smom[SIGNAL_BAR+2]-smom[SIGNAL_BAR+1]>0)
      {
         _prevSignal=1;
         signaler.SendNotifications("[BUY] MACD Momentum " + DoubleToString(currentPrice, _Digits));
      }
   }
//---- preceding alert was BUY or this is the first launch (PrevSignal=0)
   if(_prevSignal>=0)
   {
      if(AlarmZeroCrossover && 
         sign[SIGNAL_BAR]-macd[SIGNAL_BAR]>0 && 
         macd[SIGNAL_BAR+1]-sign[SIGNAL_BAR+1]>=0)
      {
         _prevSignal=-1;
         signaler.SendNotifications("[SELL] MACD " + DoubleToString(currentPrice, _Digits));
      }
      if(AlarmMomentumReverse && 
         smom[SIGNAL_BAR+1]-smom[SIGNAL_BAR]>0 && 
         smom[SIGNAL_BAR+1]-smom[SIGNAL_BAR+2]>0)
      {
         _prevSignal=-1;
         signaler.SendNotifications("[SELL] MACD Momentum " + DoubleToString(currentPrice, _Digits));
      }
   }
   return(rates_total);
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
