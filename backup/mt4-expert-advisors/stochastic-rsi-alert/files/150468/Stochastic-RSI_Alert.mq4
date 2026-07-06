//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73619

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 100
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT

//--- plot Main
#property indicator_label1  "K"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Signal
#property indicator_label2  "D"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };

input int                     InpStockKPeriod               = 8;                                   // K
input int                     InpStockDPeriod               = 3;                                   // D
input int                     InpRSIPeriod                  = 14;                                  // RSI Period
input int                     InpStochastikPeriod           = 14;                                  // Stochastic Period
input ENUM_APPLIED_PRICE      InpRSIAppliedPrice            = PRICE_CLOSE;                         // RSI Applied Price
input int                     InpHighLevel                  = 80;                                  // High Level for Alert
input int                     InpLowLevel                   = 20;                                  // Low Level for Alert

input alert                   notificationsOn               = 1;                                   // Notifications
input bool                    desktop_notifications         = true;                                // Desktop MT4 notifications
input bool                    email_notifications           = false;                               // Email notifications
input bool                    push_notifications            = false;                               // Push mobile notifications
input bool                    sound_notifications           = false;                               // Sound notifications
input string                  sound_file                    = "Tick.wav";                          // Choose a sound file for notifications

//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
double         KBuffer[];
double         DBuffer[];
double         RSIBuffer[];
double         StochBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(4);
   IndicatorDigits(_Digits);
//--- indicator buffers mapping
   SetIndexBuffer(0, KBuffer);
   SetIndexBuffer(1, DBuffer);
   SetIndexBuffer(2, RSIBuffer);
   SetIndexBuffer(3, StochBuffer);
//---
   return(INIT_SUCCEEDED);
  }
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
   int limit = prev_calculated == 0 ? rates_total - (InpRSIPeriod + 1) : rates_total - prev_calculated + 1;
   for(int i = limit; i >= 0; i--)
     {
      RSIBuffer[i] = iRSI(_Symbol, _Period, InpRSIPeriod, InpRSIAppliedPrice, i);
      if(i < rates_total - (InpRSIPeriod + 2))
         StochBuffer[i] = Stoch(RSIBuffer, RSIBuffer, RSIBuffer, InpStochastikPeriod, i, rates_total);
      if(StochBuffer[i + InpStockKPeriod - 1] != EMPTY_VALUE)
         KBuffer[i] = SimpleMA(i, InpStockKPeriod, StochBuffer, rates_total);
      if(KBuffer[i + InpStockDPeriod - 1] != EMPTY_VALUE)
         DBuffer[i] = SimpleMA(i, InpStockDPeriod, KBuffer, rates_total);
     }
   if(notificationsOn > 0)
     {
      checkAlert();
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| calculating stochastic                                           |
//+------------------------------------------------------------------+
double Stoch(const double &source[], double &high[], double &low[], int length, int shift, const int &rates_total)
  {
   if(shift + length >= rates_total)
      return EMPTY_VALUE;
   double Highest = Highest(high, length, shift);
   double Lowest = Lowest(low, length, shift);
   if(Highest - Lowest == 0)
      return EMPTY_VALUE;
   return 100 * (source[shift] - Lowest) / (Highest - Lowest);
  }
//+------------------------------------------------------------------+
//| find lowest value in prev. X periods                             |
//+------------------------------------------------------------------+
double Lowest(double &low[], int length, int shift)
  {
   double Result = 0;
   for(int i = shift; i <= shift + length; i++)
     {
      if(Result == 0 || (low[i] < Result && low[i] != EMPTY_VALUE))
        {
         Result = low[i];
        }
     }
   return Result;
  }
//+------------------------------------------------------------------+
//| find highest value in prev. X periods                            |
//+------------------------------------------------------------------+
double Highest(double &high[], int length, int shift)
  {
   double Result = 0;
   for(int i = shift; i <= shift + length; i++)
     {
      if(Result == 0 || (high[i] > Result && high[i] != EMPTY_VALUE))
        {
         Result = high[i];
        }
     }
   return Result;
  }
//+------------------------------------------------------------------+
//| calculating simple moving average of an array                    |
//+------------------------------------------------------------------+
double SimpleMA(const int position, const int period, const double &price[], const int &rates_total)
  {
//---
   double result = 0.0;
   if(position <= rates_total - period && period > 0)
     {
      for(int i = 0; i < period; i++)
        {
         if(price[position + i] != EMPTY_VALUE)
           {
            result += price[position + i];
           }
        }
      result /= period;
     }
   return(result);
  }
//+------------------------------------------------------------------+
bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(KBuffer[0] >= InpHighLevel && KBuffer[1] < InpHighLevel)
        {
         Notify(1);
         alerted = true;
        }
      if(KBuffer[0] <= InpLowLevel && KBuffer[1] > InpLowLevel)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(KBuffer[1] >= InpHighLevel && KBuffer[2] < InpHighLevel)
        {
         Notify(11);
        }
      if(KBuffer[1] <= InpLowLevel && KBuffer[2] > InpLowLevel)
        {
         Notify(22);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Stoch-RSI: ";
   switch(type)
     {
      case 1:
         text += " Crosses high level before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Crosses low level before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Crossed high level after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Crossed low level after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+