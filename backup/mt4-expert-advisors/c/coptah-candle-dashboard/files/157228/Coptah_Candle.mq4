// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75348

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0" 

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 10

#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 clrAqua
#property indicator_label1 "Normal UP"

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_color2 clrMagenta
#property indicator_label2 "Normal DN"

#property indicator_type3 DRAW_LINE
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_color3 clrAqua
#property indicator_label3 "Anomaly UP"

#property indicator_type4 DRAW_LINE
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_color4 clrMagenta
#property indicator_label4 "Anomaly DN"

#property indicator_type5 DRAW_LINE
#property indicator_style5 STYLE_SOLID
#property indicator_width5 1
#property indicator_color5 clrAqua
#property indicator_label5 "Sideway UP"

#property indicator_type6 DRAW_LINE
#property indicator_style6 STYLE_SOLID
#property indicator_width6 1
#property indicator_color6 clrMagenta
#property indicator_label6 "Sideway DN"

#property indicator_type7 DRAW_LINE
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_color7 clrAqua
#property indicator_label7 "Break UP"

#property indicator_type8 DRAW_LINE
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_color8 clrMagenta
#property indicator_label8 "Break DN"

#property indicator_type9 DRAW_LINE
#property indicator_style9 STYLE_SOLID
#property indicator_width9 1
#property indicator_color9 clrAqua
#property indicator_label9 "Bullish"

#property indicator_type10 DRAW_LINE
#property indicator_style10 STYLE_SOLID
#property indicator_width10 1
#property indicator_color10 clrMagenta
#property indicator_label10 "Bearish"

#define PLOT_MAXIMUM_BARS_BACK 5000
#define OMIT_OLDEST_BARS 50

//--- indicator buffers
double NormalUp[];
double NormalDn[];
double AnomalyUp[];
double AnomalyDn[];
double SidewayUp[];
double SidewayDn[];
double BreakUp[];
double BreakDn[];
double Bullish[];
double Bearish[];

datetime time_alert; //used when sending alert
extern bool Audible_Alerts = true;
extern bool Push_Notifications = true;
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | Coptah_Candle @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      if(Audible_Alerts) Alert(type+" | Coptah_Candle @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
      if(Push_Notifications) SendNotification(type+" | Coptah_Candle @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(10);
   SetIndexBuffer(0, NormalUp);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexDrawBegin(0, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(1, NormalDn);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexDrawBegin(1, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(2, AnomalyUp);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexDrawBegin(2, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(3, AnomalyDn);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexDrawBegin(3, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(4, SidewayUp);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexDrawBegin(4, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(5, SidewayDn);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexDrawBegin(5, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(6, BreakUp);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexDrawBegin(6, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(7, BreakDn);
   SetIndexEmptyValue(7, EMPTY_VALUE);
   SetIndexDrawBegin(7, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(8, Bullish);
   SetIndexEmptyValue(8, EMPTY_VALUE);
   SetIndexDrawBegin(8, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(9, Bearish);
   SetIndexEmptyValue(9, EMPTY_VALUE);
   SetIndexDrawBegin(9, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
     {
      myPoint *= 10;
     }
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
  {
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(NormalUp, true);
   ArraySetAsSeries(NormalDn, true);
   ArraySetAsSeries(AnomalyUp, true);
   ArraySetAsSeries(AnomalyDn, true);
   ArraySetAsSeries(SidewayUp, true);
   ArraySetAsSeries(SidewayDn, true);
   ArraySetAsSeries(BreakUp, true);
   ArraySetAsSeries(BreakDn, true);
   ArraySetAsSeries(Bullish, true);
   ArraySetAsSeries(Bearish, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(NormalUp, EMPTY_VALUE);
      ArrayInitialize(NormalDn, EMPTY_VALUE);
      ArrayInitialize(AnomalyUp, EMPTY_VALUE);
      ArrayInitialize(AnomalyDn, EMPTY_VALUE);
      ArrayInitialize(SidewayUp, EMPTY_VALUE);
      ArrayInitialize(SidewayDn, EMPTY_VALUE);
      ArrayInitialize(BreakUp, EMPTY_VALUE);
      ArrayInitialize(BreakDn, EMPTY_VALUE);
      ArrayInitialize(Bullish, EMPTY_VALUE);
      ArrayInitialize(Bearish, EMPTY_VALUE);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(PLOT_MAXIMUM_BARS_BACK-1, rates_total-1-OMIT_OLDEST_BARS)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(Open[i] > Open[1+i] //Candlestick Open > Candlestick Open
      && High[i] > High[1+i] //Candlestick High > Candlestick High
      && Low[i] > Low[1+i] //Candlestick Low > Candlestick Low
      )
        {
         NormalUp[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Normal Up"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         NormalUp[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(Open[i] < Open[1+i] //Candlestick Open < Candlestick Open
      && Low[i] < Low[1+i] //Candlestick Low < Candlestick Low
      && High[i] < High[1+i] //Candlestick High < Candlestick High
      )
        {
         NormalDn[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Normal Dn"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         NormalDn[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(Open[i] < Open[1+i] //Candlestick Open < Candlestick Open
      && High[i] > High[1+i] //Candlestick High > Candlestick High
      && Low[i] > Low[1+i] //Candlestick Low > Candlestick Low
      )
        {
         AnomalyUp[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Anomaly Up"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         AnomalyUp[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(Open[i] > Open[1+i] //Candlestick Open > Candlestick Open
      && Low[i] < Low[1+i] //Candlestick Low < Candlestick Low
      && High[i] < High[1+i] //Candlestick High < Candlestick High
      )
        {
         AnomalyDn[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Anomaly Dn"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         AnomalyDn[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 5
      if(Open[i] > Open[1+i] //Candlestick Open > Candlestick Open
      && High[i] < High[1+i] //Candlestick High < Candlestick High
      && Low[i] > Low[1+i] //Candlestick Low > Candlestick Low
      )
        {
         SidewayUp[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Sideway Up"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         SidewayUp[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 6
      if(Open[i] < Open[1+i] //Candlestick Open < Candlestick Open
      && Low[i] > Low[1+i] //Candlestick Low > Candlestick Low
      && High[i] < High[1+i] //Candlestick High < Candlestick High
      )
        {
         SidewayDn[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Sideway Dn"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         SidewayDn[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 7
      if(Open[i] > Open[1+i] //Candlestick Open > Candlestick Open
      && High[i] > High[1+i] //Candlestick High > Candlestick High
      && Low[i] < Low[1+i] //Candlestick Low < Candlestick Low
      )
        {
         BreakUp[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Break Up"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         BreakUp[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 8
      if(Open[i] < Open[1+i] //Candlestick Open < Candlestick Open
      && Low[i] < Low[1+i] //Candlestick Low < Candlestick Low
      && High[i] > High[1+i] //Candlestick High > Candlestick High
      )
        {
         BreakDn[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Break Dn"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         BreakDn[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 9
      if(Low[1+i] < Low[2+i] //Candlestick Low < Candlestick Low
      && High[1+i] > High[2+i] //Candlestick High > Candlestick High
      && Close[1+i] > Open[2+i] //Candlestick Close > Candlestick Open
      && Open[1+i] < Close[1+i] //Candlestick Open < Candlestick Close
      && Open[2+i] > Close[2+i] //Candlestick Open > Candlestick Close
      )
        {
         Bullish[i] = Low[i]; //Set indicator value at Candlestick Low
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Bullish"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Bullish[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 10
      if(High[1+i] > High[2+i] //Candlestick High > Candlestick High
      && Low[1+i] < Low[2+i] //Candlestick Low < Candlestick Low
      && Close[1+i] < Open[2+i] //Candlestick Close < Candlestick Open
      && Open[1+i] > Close[1+i] //Candlestick Open > Candlestick Close
      && Open[2+i] < Close[2+i] //Candlestick Open < Candlestick Close
      )
        {
         Bearish[i] = High[i]; //Set indicator value at Candlestick High
         if(i == 0 && Time[0] != time_alert) { myAlert("indicator", "Bearish"); time_alert = Time[0]; } //Instant alert, only once per bar
        }
      else
        {
         Bearish[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 