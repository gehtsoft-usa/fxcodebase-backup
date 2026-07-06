// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69710
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

#include <MovingAverages.mqh>

#property indicator_buffers 1
#property indicator_color1 Black
//#property indicator_color2 Red
//--- input parameters
input int    InpBandsPeriod=18;      // P�riode
input int    InpBandsShift=0;        // Bands Shift
input double InpBandsDeviations=2.0; // D�viation
input int    Smooth=2;               // Lissage

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

//--- buffers
double ExtVolSmoothBuffer[];
double ExtVolDerBuffer[];
double ExtMovingBuffer[];
double ExtStdDevBuffer[];
Signaler* _signaler;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
   _signaler = new Signaler(_Symbol, (ENUM_TIMEFRAMES)_Period);
   _signaler.SetMessagePrefix(_Symbol + "/" + _signaler.GetTimeframeStr() + ": ");
   IndicatorBuffers(4);
   IndicatorDigits(Digits);
//--- middle line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ExtVolSmoothBuffer);
   SetIndexShift(0,InpBandsShift);
   SetIndexLabel(0,"D�riv� de la volatilit�");   

//   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,ExtVolDerBuffer);
//   SetIndexShift(1,InpBandsShift);
//   SetIndexLabel(1,"D�riv� de la volatilit�");   
//--- work buffer
   SetIndexBuffer(2,ExtMovingBuffer);
   //SetIndexBuffer(2,ExtUpperBuffer);
   //SetIndexBuffer(3,ExtLowerBuffer);
   SetIndexBuffer(3,ExtStdDevBuffer);
   //SetIndexBuffer(3,ExtVolDerBuffer);
//--- check for input parameter
   if(InpBandsPeriod<=0)
     {
      Print("Wrong input parameter Bands Period=",InpBandsPeriod);
      return(INIT_FAILED);
     }
//---
   SetIndexDrawBegin(0,InpBandsPeriod+InpBandsShift);
//--- initialization done
   return(INIT_SUCCEEDED);
  }
void OnDeinit(const int reason)
{
   delete _signaler;
   _signaler = NULL;  
}
datetime lastSignal;
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


   int i,pos;
//---
   if(rates_total<=InpBandsPeriod || InpBandsPeriod<=0)
      return(0);
//--- counting from 0 to rates_total
   ArraySetAsSeries(ExtVolSmoothBuffer,false);
   ArraySetAsSeries(ExtVolDerBuffer,false);
   ArraySetAsSeries(ExtMovingBuffer,false);
   //ArraySetAsSeries(ExtUpperBuffer,false);
   //ArraySetAsSeries(ExtLowerBuffer,false);
   ArraySetAsSeries(ExtStdDevBuffer,false);
   ArraySetAsSeries(close,false);
//--- initial zero
   if(prev_calculated<1)
     {
      for(i=0; i<InpBandsPeriod; i++)
        {
         ExtVolSmoothBuffer[i]=EMPTY_VALUE;
         ExtVolDerBuffer[i]=EMPTY_VALUE;
         ExtMovingBuffer[i]=EMPTY_VALUE;
         //ExtUpperBuffer[i]=EMPTY_VALUE;
         //ExtLowerBuffer[i]=EMPTY_VALUE;
         ExtStdDevBuffer[i]=EMPTY_VALUE;
        }
     }
//--- starting calculation
   if(prev_calculated>1)
      pos=prev_calculated-1;
   else
      pos=0;
      
//--- variation
      int   high_index=EMPTY_VALUE, low_index=EMPTY_VALUE ;
      
//--- main cycle
   for(i=pos; i<rates_total && !IsStopped(); i++)
     {
      //--- middle line
      ExtMovingBuffer[i]=SimpleMA(i,InpBandsPeriod,close);
      //--- calculate and write down StdDev
      ExtStdDevBuffer[i]=StdDev_Func(i,close,ExtMovingBuffer,InpBandsPeriod);
      //--- upper line
      //ExtUpperBuffer[i]=ExtMovingBuffer[i]+InpBandsDeviations*ExtStdDevBuffer[i];
      //--- lower line
      //ExtLowerBuffer[i]=ExtMovingBuffer[i]-InpBandsDeviations*ExtStdDevBuffer[i];
      //high_index=iHighest(NULL,0,MODE_HIGH,InpBandsPeriod,rates_total-i-1);
      //low_index=iLowest(NULL,0,MODE_LOW,InpBandsPeriod,rates_total-i-1);
      //ExtVolDerBuffer[i] = (ExtStdDevBuffer[i]*2 - ArrayMaximum(ExtUpperBuffer,InpBandsPeriod,rates_total-i-1) ) / (ArrayMaximum(ExtUpperBuffer,InpBandsPeriod,rates_total-i-1) - ArrayMinimum(ExtLowerBuffer,InpBandsPeriod,rates_total-i-1)) ;
      //high_index=ArrayMaximum(ExtStdDevBuffer,InpBandsPeriod,i-InpBandsPeriod+1);
      //low_index=ArrayMinimum(ExtStdDevBuffer,InpBandsPeriod,i-InpBandsPeriod+1);
      high_index=ArrayMaximum(ExtStdDevBuffer,InpBandsPeriod,i-InpBandsPeriod+1);
      low_index=ArrayMinimum(ExtStdDevBuffer,InpBandsPeriod,i-InpBandsPeriod+1);
      //ExtVolDerBuffer[i] = (ExtStdDevBuffer[i] - ExtStdDevBuffer[high_index]) / (ExtStdDevBuffer[high_index] - ExtStdDevBuffer[low_index]);
      if(i > InpBandsPeriod) {
         ExtVolDerBuffer[i] = (ExtStdDevBuffer[i] - ExtStdDevBuffer[high_index]) / (ExtStdDevBuffer[high_index] - ExtStdDevBuffer[low_index]);
         ExtVolSmoothBuffer[i] = iMAOnArray(ExtVolDerBuffer,0,Smooth,0,MODE_SMA,rates_total-(i+1));
         if(ExtVolSmoothBuffer[i] > 0) ExtVolSmoothBuffer[i] = 0;
         //ExtVolSmoothBuffer[i] = ExtVolDerBuffer[i];
         //ExtVolSmoothBuffer[i] = (ExtVolDerBuffer[i]+ExtVolDerBuffer[i-1])/2;
      }
      //---
     }
   
   if (lastSignal != Time[0])
   {
      if (ExtVolSmoothBuffer[0] <= -0.861 && ExtVolSmoothBuffer[1] > -0.861)
      {
         _signaler.SendNotifications("Slow down");
         lastSignal = Time[0];
      }
      else if (ExtVolSmoothBuffer[0] >= -0.0746 && ExtVolSmoothBuffer[1] > -0.0746)
      {
         _signaler.SendNotifications("Impulsion");
         lastSignal = Time[0];
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Calculate Standard Deviation                                     |
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
{
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position>=period)
     {
      //--- calcualte StdDev
      for(int i=0; i<period; i++)
         StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
         StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
     }
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
