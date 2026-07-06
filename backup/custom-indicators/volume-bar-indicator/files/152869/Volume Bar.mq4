//+------------------------------------------------------------------+
//|                                      Indicator: Volume & Bar.mq4 |
//|                                            Created by Caldo Pape |
//|                                              caldopape@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Created by Caldo Pape"
#property link      "caldopape@gmail.com"
#property version   "1.00"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 4

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_color1 0x64664F
#property indicator_label1 ""

#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_DOT
#property indicator_width2 1
#property indicator_color2 0x8B8B8C
#property indicator_label2 ""

#property indicator_type3 DRAW_ARROW
#property indicator_width3 3
#property indicator_color3 0x00820B
#property indicator_label3 ""

#property indicator_type4 DRAW_ARROW
#property indicator_width4 3
#property indicator_color4 0x2D2DAD
#property indicator_label4 ""

#define PLOT_MAXIMUM_BARS_BACK 5000
#define OMIT_OLDEST_BARS 50

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];

double myPoint; //initialized in OnInit

void myAlert(string type, string message)
  {
   if(type == "print")
      Print(message);
   else if(type == "error")
     {
      Print(type+" | Volume & Bar @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
     }
   else if(type == "order")
     {
     }
   else if(type == "modify")
     {
     }
  }

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {   
   IndicatorBuffers(4);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexDrawBegin(0, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexDrawBegin(1, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexDrawBegin(2, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexArrow(2, 158);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexDrawBegin(3, MathMax(Bars(Symbol(), PERIOD_CURRENT)-PLOT_MAXIMUM_BARS_BACK+1, OMIT_OLDEST_BARS+1));
   SetIndexArrow(3, 158);
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
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   //--- initial zero
   if(prev_calculated < 1)
     {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
     }
   else
      limit++;
   
   //--- main loop
   for(int i = limit-1; i >= 0; i--)
     {
      if (i >= MathMin(PLOT_MAXIMUM_BARS_BACK-1, rates_total-1-OMIT_OLDEST_BARS)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(iVolume(NULL, PERIOD_CURRENT, i) > iVolume(NULL, PERIOD_CURRENT, 1+i) //Volumes > Volumes
      )
        {
         Buffer1[i] = iVolume(NULL, PERIOD_CURRENT, i); //Set indicator value at Volumes
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(iVolume(NULL, PERIOD_CURRENT, i) < iVolume(NULL, PERIOD_CURRENT, 1+i) //Volumes < Volumes
      )
        {
         Buffer2[i] = iVolume(NULL, PERIOD_CURRENT, i); //Set indicator value at Volumes
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(Close[i] > Open[i] //Candlestick Close > Candlestick Open
      )
        {
         Buffer3[i] = iVolume(NULL, PERIOD_CURRENT, i); //Set indicator value at Volumes
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(Close[i] < Open[i] //Candlestick Close < Candlestick Open
      )
        {
         Buffer4[i] = iVolume(NULL, PERIOD_CURRENT, i); //Set indicator value at Volumes
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+