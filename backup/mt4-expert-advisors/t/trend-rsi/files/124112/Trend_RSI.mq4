// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67385

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
#property indicator_buffers 5
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrOrange
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

#define _disLin 1
#define _disDot 4

enum enDisplay
{
   en_lin = _disLin,                  // Display line
   en_lid = _disLin+_disDot,          // Display lines with dots
   en_dot = _disDot                   // Display dots
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;    // Time frame
extern int             period          = 10;                // Super trend period
extern int RSIPeriod = 14; // RSI period
extern int RSILowLevel = 70; // RSI buy level
extern int RSIHighLevel = 30; // RSI sell level
extern double          multiplier      = 4.0;               // Super trend multiplier
extern enDisplay       DisplayType     = en_lin;            // Display type
extern string          soundFile       = "alert2.wav";      // Sound file
extern bool            ArrowOnFirst    = true;              // Arrow on first bars
extern int             UpArrowSize     = 2;                 // Up Arrow size
extern int             DnArrowSize     = 2;                 // Down Arrow size
extern int             UpArrowCode     = 159;               // Up Arrow code
extern int             DnArrowCode     = 159;               // Down arrow code
extern double          UpArrowGap      = 0.5;               // Up Arrow gap        
extern double          DnArrowGap      = 0.5;               // Dn Arrow gap
extern color           UpArrowColor    = clrLimeGreen;      // Up Arrow Color
extern color           DnArrowColor    = clrOrange;         // Down Arrow Color
extern bool            Interpolate     = true;              // Interpolate in multi time frame mode?
//Signaler v 1.2.1
extern bool     Popup_Alert              = true; // Popup message
extern bool     Notification_Alert       = false; // Push notification
extern bool     Email_Alert              = false; // Email
extern bool     Play_Sound               = false; // Play sound on alert
extern string   Sound_File               = ""; // Sound file
extern bool     Advanced_Alert           = false; // Advanced alert
extern string   Advanced_Key             = ""; // Advanced alert key
extern string   Comment2                 = "- You can get a advanced alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install AdvancedNotificationsLib.dll and allow use of dll in the indicator parameters window -";
extern string   Comment4                 = "- Make sure that Microsoft .NET Framework 4.6 is installed on your PC -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import

#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,period,RSIPeriod, RSILowLevel, RSIHighLevel, multiplier,DisplayType,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,_buff,_y)
double Trend[],TrendDoA[],TrendDoB[],Direction[],Up[],Dn[],arrUp[],arrDn[],count[];
string indicatorFileName;

int GetDirection(const int p)
{
   int btfPeriod = iBarShift(_Symbol, TimeFrame, Time[p]);
   double rsi0 = iRSI(_Symbol, TimeFrame, RSIPeriod, PRICE_CLOSE, btfPeriod);
   if (Trend[p] > Trend[p + 1] && rsi0 >= RSILowLevel)
      return 1;
   if (Trend[p] < Trend[p + 1] && rsi0 <= RSIHighLevel)
      return -1;
   return 0;
}

int OnInit()
{
   if (!IsDllsAllowed() && Advanced_Alert)
   {
      Print("Error: Dll calls must be allowed!");
      return INIT_FAILED;
   }
   int lstyle = DRAW_LINE;      
   if ((DisplayType&_disLin)==0) 
      lstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;     
   if ((DisplayType&_disDot)==0) 
      astyle = DRAW_NONE;
   IndicatorBuffers(9);
   SetIndexBuffer(0, Trend);    SetIndexStyle(0,lstyle);
   SetIndexBuffer(1, TrendDoA); SetIndexStyle(1,lstyle);
   SetIndexBuffer(2, TrendDoB); SetIndexStyle(2,lstyle);
   SetIndexBuffer(3, arrUp);    SetIndexStyle(3,astyle,0,UpArrowSize,UpArrowColor); SetIndexArrow(3,UpArrowCode);
   SetIndexBuffer(4, arrDn);    SetIndexStyle(4,astyle,0,DnArrowSize,DnArrowColor); SetIndexArrow(4,DnArrowCode);
   SetIndexBuffer(5, Direction);
   SetIndexBuffer(6, Up);
   SetIndexBuffer(7, Dn);
   SetIndexBuffer(8, count); 
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" SuperTrend");
   return(0);
}

void OnDeinit(const int reason) { }

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int &spread[])
{
   int i,counted_bars = prev_calculated;
   if(counted_bars < 0) 
      return(-1);
   if(counted_bars > 0) 
      counted_bars--;
   int limit = fmin(rates_total - counted_bars, rates_total - 2); 
   count[0] = limit;
   if (TimeFrame!=_Period)
   {
      limit = (int)MathMax(limit,MathMin(rates_total-1,_mtfCall(6,0)*TimeFrame/_Period));
      if (Direction[limit] == -1) CleanPoint(limit,TrendDoA,TrendDoB);
      for (i=limit;i>=0 && !_StopFlag; i--)
      {
         int y = iBarShift(NULL,TimeFrame,Time[i]);
         int x = y;
         if (ArrowOnFirst)
         {
            if (i<Bars-1) 
               x = iBarShift(NULL,TimeFrame,Time[i+1]);
         }
         else  
         {  
            if (i>0)
               x = iBarShift(NULL,TimeFrame,Time[i-1]);
            else 
               x = -1;  
         }
         Trend[i]     = _mtfCall(0,y);
         Direction[i] = _mtfCall(5,y);
         Up[i]        = _mtfCall(6,y);
         Dn[i]        = _mtfCall(7,y);
         TrendDoA[i]  = EMPTY_VALUE;
         TrendDoB[i]  = EMPTY_VALUE;
         arrUp[i]     = EMPTY_VALUE;
         arrDn[i]     = EMPTY_VALUE;
         if (x!=y)
         {
            arrUp[i]  = _mtfCall(3,y);
            arrDn[i]  = _mtfCall(4,y);
         }

         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) 
            continue;
         
         #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
         int n,k; datetime ttime = iTime(NULL,TimeFrame,y);
         for(n = 1; (i+n)<rates_total && time[i+n] >= ttime; n++) 
            continue;	
         for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
         {
            _interpolate(Trend);  
            _interpolate(Up);  
            _interpolate(Dn);     
         }                     
      }
      for(i=limit; i>=0; i--) 
      {
         if (Direction[i] == -1) 
            PlotPoint(i,TrendDoA,TrendDoB,Trend); 
      }
      return(rates_total);
   }               
         
   if (Direction[limit] == -1) 
      CleanPoint(limit,TrendDoA,TrendDoB);
   for(i = limit; i >= 0; i--)
   {
      double atr    = iATR(NULL,0,period,i);
      double cprice =  close[i];
      double mprice = (high[i]+low[i])/2;
      Up[i]  = mprice+multiplier*atr;
      Dn[i]  = mprice-multiplier*atr;
      
      Direction[i] = (i<rates_total-1) ? (cprice > Up[i+1]) ? 1 : (cprice < Dn[i+1]) ? -1 : Direction[i+1] : 0;
      TrendDoA[i]  = EMPTY_VALUE;
      TrendDoB[i]  = EMPTY_VALUE;
      arrUp[i]     = EMPTY_VALUE;
      arrDn[i]     = EMPTY_VALUE;
      if (Direction[i] ==  1) 
      { 
         Dn[i] = fmax(Dn[i],Dn[i+1]); 
         Trend[i] = Dn[i]; 
      }
      if (Direction[i] == -1) 
      { 
         Up[i] = fmin(Up[i],Up[i+1]); 
         Trend[i] = Up[i]; 
         PlotPoint(i,TrendDoA,TrendDoB,Trend); 
      }
      int dir = GetDirection(i);
      if (i < rates_total - 2 && dir != 0 && dir != GetDirection(i + 1))
      {
         if (dir == 1) 
            arrUp[i] = fmin(Trend[i],Low[i] )-iATR(NULL,0,15,i)*UpArrowGap;
         else
            arrDn[i] = fmax(Trend[i],High[i])+iATR(NULL,0,15,i)*DnArrowGap;
         if (i == 0)
            SendNotifications(dir);
      }
   }
   return(rates_total);
}

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>Bars-2) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
      second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
         first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>Bars-3) 
      return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
      {
         first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE;
      }
      else
      {
         second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE;
      }
   else
   { 
      first[i]  = from[i];                          
      second[i] = EMPTY_VALUE; 
   }
}

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
      if (tf==iTfTable[i]) 
         return(sTfTable[i]);
   return("");
}

string GetTimeframe()
{
   switch (_Period)
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

datetime _lastDatetime;
#define ENTER_BUY_SIGNAL 1
#define ENTER_SELL_SIGNAL -1

void SendNotifications(const int direction)
{
   if (direction == 0 || IsTesting())
      return;

   datetime currentTime = iTime(_Symbol, _Period, 0);
   if (_lastDatetime == currentTime)
      return;

   _lastDatetime = currentTime;
   string tf = GetTimeframe();
   string alert_Subject;
   string alert_Body;
   switch (direction)
   {
      case ENTER_BUY_SIGNAL:
         alert_Subject = "Up signal on " + _Symbol + "/" + tf;
         alert_Body = "Up signal on " + _Symbol + "/" + tf;
         break;
      case ENTER_SELL_SIGNAL:
         alert_Subject = "Down signal on " + _Symbol + "/" + tf;
         alert_Body = "Down signal on " + _Symbol + "/" + tf;
         break;
   }
   SendNotifications(alert_Subject, alert_Body, _Symbol, tf);
}

void SendNotifications(const string subject, const string message, const string symbol, const string timeframe)
{
   if (Popup_Alert)
      Alert(message);
   if (Email_Alert)
      SendMail(subject, message);
   if (Play_Sound)
      PlaySound(Sound_File);
   if (Notification_Alert)
      SendNotification(message);
   if (Advanced_Alert && Advanced_Key != "")
      AdvancedAlert(Advanced_Key, message, symbol, timeframe);
}
