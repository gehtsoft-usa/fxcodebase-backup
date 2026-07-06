//+------------------------------------------------------------------+
//|                                          Indicator: R-PSAROL.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property copyright "Created with EABuilder.com"
#property link      "https://www.eabuilder.com"
#property version   "1.00"
#property description ""
#property tester_indicator "period_open_line"
#property tester_indicator "psar-mtf-indicator"

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2

#property indicator_type1 DRAW_ARROW
#property indicator_width1 1
#property indicator_color1 0xFFAA00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_ARROW
#property indicator_width2 1
#property indicator_color2 0x0000FF
#property indicator_label2 "Sell"

//--- indicator buffers
double Buffer1[];
double Buffer2[];

extern int TimeFrame = 7;
extern double Step = 0.02;
extern double Maximum = 0.2;
extern ENUM_TIMEFRAMES TimeFramePSAR = PERIOD_CURRENT;
datetime time_alert; //used when sending alert
double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | R-PSAROL @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
   else if(type == "indicator")
     {
      Print(type+" | R-PSAROL @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(2);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexArrow(0, 241);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexArrow(1, 242);
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
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(Close[1+i] > iCustom(NULL, PERIOD_CURRENT, "period_open_line", "Time frame: 1-m1, 2-m5, 3-m15, 4-m30, 5-H1, 6-H4, 7-D1, 8-W1, 9-MN, 10-Y1", TimeFrame, 0, 1+i) //Candlestick Close > period_open_line
      && Close[1+i] > iCustom(NULL, PERIOD_CURRENT, "psar-mtf-indicator", TimeFramePSAR, Step, Maximum, 0, 1+i) //Candlestick Close > psar-mtf-indicator
      )
        {
         Buffer1[i] = Close[1+i]; //Set indicator value at Candlestick Close
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Buy"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(Close[1+i] < iCustom(NULL, PERIOD_CURRENT, "period_open_line", "Time frame: 1-m1, 2-m5, 3-m15, 4-m30, 5-H1, 6-H4, 7-D1, 8-W1, 9-MN, 10-Y1", TimeFrame, 0, 1+i) //Candlestick Close < period_open_line
      && Close[1+i] < iCustom(NULL, PERIOD_CURRENT, "psar-mtf-indicator", TimeFramePSAR, Step, Maximum, 0, 1+i) //Candlestick Close < psar-mtf-indicator
      )
        {
         Buffer2[i] = Close[1+i]; //Set indicator value at Candlestick Close
         if(i == 1 && Time[1] != time_alert) myAlert("indicator", "Sell"); //Alert on next bar open
         time_alert = Time[1];
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+