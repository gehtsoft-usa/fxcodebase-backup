// Id: 22043
// Id:  
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64665

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property description "Color Candles based on TSI behavior"
#property strict

#property indicator_buffers 26
#property indicator_chart_window

/* Candles */
#property indicator_color1 clrDeepPink
#property indicator_color2 clrDeepPink
#property indicator_color3 clrDeepPink
#property indicator_color4 clrDeepPink
#property indicator_color5 clrMagenta
#property indicator_color6 clrMagenta
#property indicator_color7 clrMagenta
#property indicator_color8 clrMagenta
#property indicator_color9 clrLime
#property indicator_color10 clrLime
#property indicator_color11 clrLime
#property indicator_color12 clrLime
#property indicator_color13 clrGreen
#property indicator_color14 clrGreen
#property indicator_color15 clrGreen
#property indicator_color16 clrGreen
#property indicator_color17 clrMaroon
#property indicator_color18 clrMaroon
#property indicator_color19 clrMaroon
#property indicator_color20 clrMaroon
#property indicator_color21 clrRed
#property indicator_color22 clrRed
#property indicator_color23 clrRed
#property indicator_color24 clrRed

#property indicator_width1 1
#property indicator_width2 1
#property indicator_width3 3
#property indicator_width4 3
#property indicator_width5 1
#property indicator_width6 1
#property indicator_width7 3
#property indicator_width8 3
#property indicator_width9 1
#property indicator_width10 1
#property indicator_width11 3
#property indicator_width12 3
#property indicator_width13 1
#property indicator_width14 1
#property indicator_width15 3
#property indicator_width16 3
#property indicator_width17 1
#property indicator_width18 1
#property indicator_width19 3
#property indicator_width20 3
#property indicator_width21 1
#property indicator_width22 1
#property indicator_width23 3
#property indicator_width24 3

extern int    TSI_Smooth1  = 7;
extern int    TSI_Smooth2  = 14;
extern double OB_Level     = 50.0;
extern double OS_Level     = -50.0;
extern int    Limit_Bars   = 1000;
extern bool     Sound_Alert              = true; // Sound alert
extern bool     Notification_Alert       = false; // Notification alert
extern bool     Email_Alert              = false; // Email alert
extern bool     Play_Sound               = false; // Play sound on alert
extern bool     Telegram_Alert           = false; // External alert
extern string   Telegram_Key             = ""; // External alert key
extern string   Comment2                 = "- You can get a external alert key by starting a dialog with @profit_robots_bot Telegram bot -";
extern string   Comment3                 = "- Also, you need to install TelegramNotificationsLib.dll and allow use of dll in the indicator parameters window -";

// TelegramNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "TelegramNotificationsLib.dll"
void AlertTelegram(string key, string text, string instrument, string timeframe);
#import

double TSI[];

double OBOS_Up_High[], OBOS_Up_Low[], OBOS_Up_Open[], OBOS_Up_Close[];
double OBOS_Dn_High[], OBOS_Dn_Low[], OBOS_Dn_Open[], OBOS_Dn_Close[];
double Up_Up_High[], Up_Up_Low[], Up_Up_Open[], Up_Up_Close[];
double Up_Dn_High[], Up_Dn_Low[], Up_Dn_Open[], Up_Dn_Close[];
double Dn_Up_High[], Dn_Up_Low[], Dn_Up_Open[], Dn_Up_Close[];
double Dn_Dn_High[], Dn_Dn_Low[], Dn_Dn_Open[], Dn_Dn_Close[];
double colorDirection[];

#define OBOS_Positive 1
#define OBOS_Negative 2
#define Up_Positive   3
#define Up_Negative   4
#define Dn_Positive   5
#define Dn_Negative   6

string indicatorName;

int init(){
        double temp = iCustom(NULL, 0, "TSI", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TSI' indicator");
       return INIT_FAILED;
   }
   indicatorName = "TSI Overlay";
    IndicatorShortName(indicatorName);
    IndicatorBuffers(26);
   
   SetIndexBuffer(0,OBOS_Up_High);
   SetIndexBuffer(1,OBOS_Up_Low);
   SetIndexBuffer(2,OBOS_Up_Open);
   SetIndexBuffer(3,OBOS_Up_Close);
   SetIndexBuffer(4,OBOS_Dn_High);
   SetIndexBuffer(5,OBOS_Dn_Low);
   SetIndexBuffer(6,OBOS_Dn_Open);
   SetIndexBuffer(7,OBOS_Dn_Close);
   SetIndexBuffer(8,Up_Up_High);
   SetIndexBuffer(9,Up_Up_Low);
   SetIndexBuffer(10,Up_Up_Open);
   SetIndexBuffer(11,Up_Up_Close);
   SetIndexBuffer(12,Up_Dn_High);
   SetIndexBuffer(13,Up_Dn_Low);
   SetIndexBuffer(14,Up_Dn_Open);
   SetIndexBuffer(15,Up_Dn_Close);
   SetIndexBuffer(16,Dn_Up_High);
   SetIndexBuffer(17,Dn_Up_Low);
   SetIndexBuffer(18,Dn_Up_Open);
   SetIndexBuffer(19,Dn_Up_Close);
   SetIndexBuffer(20,Dn_Dn_High);
   SetIndexBuffer(21,Dn_Dn_Low);
   SetIndexBuffer(22,Dn_Dn_Open);
   SetIndexBuffer(23,Dn_Dn_Close);
   
   SetIndexBuffer(24,TSI);
   SetIndexBuffer(25, colorDirection);
   SetIndexStyle(25, DRAW_NONE);
   
   for (int i=0; i<24; i++){
      SetIndexStyle(i,DRAW_HISTOGRAM);
   }
   
   return(0);
}

int start(){
   
   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars>0) limit = Limit_Bars;
   
   for(i=limit; i>=0; i--){
   
      TSI[i] = iCustom(NULL,0,"TSI",TSI_Smooth1,TSI_Smooth2,0,i);
      
   }
   
   for(i=limit; i>=0; i--){
   
      ResetBuffers(i);
      
      bias = ColorCandle(TSI[i], TSI[i+1]);
      colorDirection[i] = bias;
   
      if(bias==OBOS_Positive){
         
         OBOS_Up_High[i]  = iHigh(NULL,0,i);
         OBOS_Up_Low[i]   = iLow(NULL,0,i);  
         OBOS_Up_Open[i]  = iOpen(NULL,0,i);
         OBOS_Up_Close[i] = iClose(NULL,0,i);  
      
      }
      else if(bias==OBOS_Negative){
         
         OBOS_Dn_High[i]  = iHigh(NULL,0,i);
         OBOS_Dn_Low[i]   = iLow(NULL,0,i);  
         OBOS_Dn_Open[i]  = iOpen(NULL,0,i);
         OBOS_Dn_Close[i] = iClose(NULL,0,i);
      
      }
      else if(bias==Up_Positive){
         
         Up_Up_High[i]  = iHigh(NULL,0,i);
         Up_Up_Low[i]   = iLow(NULL,0,i);  
         Up_Up_Open[i]  = iOpen(NULL,0,i);
         Up_Up_Close[i] = iClose(NULL,0,i);
      
      }
      else if(bias==Up_Negative){
         
         Up_Dn_High[i]  = iHigh(NULL,0,i);
         Up_Dn_Low[i]   = iLow(NULL,0,i);  
         Up_Dn_Open[i]  = iOpen(NULL,0,i);
         Up_Dn_Close[i] = iClose(NULL,0,i);
      
      }
      else if(bias==Dn_Positive){
         
         Dn_Up_High[i]  = iHigh(NULL,0,i);
         Dn_Up_Low[i]   = iLow(NULL,0,i);  
         Dn_Up_Open[i]  = iOpen(NULL,0,i);
         Dn_Up_Close[i] = iClose(NULL,0,i);
      
      }
      else if(bias==Dn_Negative){
         
         Dn_Dn_High[i]  = iHigh(NULL,0,i);
         Dn_Dn_Low[i]   = iLow(NULL,0,i);  
         Dn_Dn_Open[i]  = iOpen(NULL,0,i);
         Dn_Dn_Close[i] = iClose(NULL,0,i);
      
      }
      if (i == 0 && colorDirection[0] != colorDirection[1])
      {
         SendNotifications((int)colorDirection[0]);
      }
   }
   
   return(0);
}

int ColorCandle(double current_tsi, double previous_tsi)
{
   if (current_tsi > OB_Level){
      if (current_tsi > previous_tsi)
         return(OBOS_Positive);
      else
         return(OBOS_Negative);
   }
   else if (current_tsi < OS_Level){
      if (current_tsi > previous_tsi)
         return(OBOS_Positive);
      else
         return(OBOS_Negative);
   }
   else if (current_tsi > 0 && current_tsi < OB_Level){
      if (current_tsi > previous_tsi)
         return(Up_Positive);
      else
         return(Up_Negative);
   }
   else if (current_tsi < 0 && current_tsi > OS_Level){
      if (current_tsi > previous_tsi)
         return(Dn_Positive);
      else
         return(Dn_Negative);
   }
   return 0;
}

void ResetBuffers(int shift){
   OBOS_Up_High[shift] = EMPTY_VALUE;
   OBOS_Up_Low[shift] = EMPTY_VALUE;
   OBOS_Up_Open[shift] = EMPTY_VALUE;
   OBOS_Up_Close[shift] = EMPTY_VALUE;
   OBOS_Dn_High[shift] = EMPTY_VALUE;
   OBOS_Dn_Low[shift] = EMPTY_VALUE;
   OBOS_Dn_Open[shift] = EMPTY_VALUE;
   OBOS_Dn_Close[shift] = EMPTY_VALUE;
   Up_Up_High[shift] = EMPTY_VALUE;
   Up_Up_Low[shift] = EMPTY_VALUE;
   Up_Up_Open[shift] = EMPTY_VALUE;
   Up_Up_Close[shift] = EMPTY_VALUE;
   Up_Dn_High[shift] = EMPTY_VALUE;
   Up_Dn_Low[shift] = EMPTY_VALUE;
   Up_Dn_Open[shift] = EMPTY_VALUE;
   Up_Dn_Close[shift] = EMPTY_VALUE;
   Dn_Up_High[shift] = EMPTY_VALUE;
   Dn_Up_Low[shift] = EMPTY_VALUE;
   Dn_Up_Open[shift] = EMPTY_VALUE;
   Dn_Up_Close[shift] = EMPTY_VALUE;
   Dn_Dn_High[shift] = EMPTY_VALUE;
   Dn_Dn_Low[shift] = EMPTY_VALUE;
   Dn_Dn_Open[shift] = EMPTY_VALUE;
   Dn_Dn_Close[shift] = EMPTY_VALUE;
   return;
}

void SendNotifications(const int direction)
{
   static datetime _lastDatetime;
   datetime currentTime = iTime(NULL, NULL, 0);
   if (_lastDatetime == currentTime)
      return;

   _lastDatetime = currentTime;
   if (direction == 0)
      return;
      
   string tf = GetTimeframe();
   string alert_Subject;
   string alert_Body;
   switch (direction)
   {
      case OBOS_Positive:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to OBOS Positive";
         alert_Body = alert_Subject;
         break;
      case OBOS_Negative:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to OBOS Negative";
         alert_Body = alert_Subject;
         break;
      case Up_Positive:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to Up Positive";
         alert_Body = alert_Subject;
         break;
      case Up_Negative:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to Up Negative";
         alert_Body = alert_Subject;
         break;
      case Dn_Positive:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to Down Positive";
         alert_Body = alert_Subject;
         break;
      case Dn_Negative:
         alert_Subject = indicatorName + "(" + _Symbol + ", " + tf + ") Color changed to Down Negative";
         alert_Body = alert_Subject;
         break;
   }
   
   if (Sound_Alert)
      Alert(alert_Body);
   if (Email_Alert)
      SendMail(alert_Subject, alert_Body);
   if (Telegram_Alert && Telegram_Key != "")
      AlertTelegram(Telegram_Key, alert_Body, _Symbol, tf);
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
