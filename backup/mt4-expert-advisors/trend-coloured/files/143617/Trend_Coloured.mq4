// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71505

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   |
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.1"

//based on
//+------------------------------------------------------------------+
//|                                     Indicator: Trend Colored.mq4 |
//|                                       Created with EABuilder.com |
//|                                        https://www.eabuilder.com |
//+------------------------------------------------------------------+
#property description "Colored candlesticks showing the trend based on two moving averages and the slope of the slow moving average. For long"
#property description " term trends use Period2 = 200."

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 16

#property indicator_type1 DRAW_HISTOGRAM
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_color1 0x00FF00
#property indicator_label1 "Bullish"

#property indicator_type2 DRAW_HISTOGRAM
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_color2 0x00FF00
#property indicator_label2 "Bullish"

#property indicator_type3 DRAW_HISTOGRAM
#property indicator_style3 STYLE_SOLID
#property indicator_width3 1
#property indicator_color3 0x00FF00
#property indicator_label3 "Bullish"

#property indicator_type4 DRAW_HISTOGRAM
#property indicator_style4 STYLE_SOLID
#property indicator_width4 1
#property indicator_color4 0x00FF00
#property indicator_label4 "Bullish"

#property indicator_type5 DRAW_HISTOGRAM
#property indicator_style5 STYLE_SOLID
#property indicator_width5 3
#property indicator_color5 0x008000
#property indicator_label5 "Bullish Weak"

#property indicator_type6 DRAW_HISTOGRAM
#property indicator_style6 STYLE_SOLID
#property indicator_width6 3
#property indicator_color6 0x008000
#property indicator_label6 "Bullish Weak"

#property indicator_type7 DRAW_HISTOGRAM
#property indicator_style7 STYLE_SOLID
#property indicator_width7 1
#property indicator_color7 0x008000
#property indicator_label7 "Bullish Weak"

#property indicator_type8 DRAW_HISTOGRAM
#property indicator_style8 STYLE_SOLID
#property indicator_width8 1
#property indicator_color8 0x008000
#property indicator_label8 "Bullish Weak"

#property indicator_type9 DRAW_HISTOGRAM
#property indicator_style9 STYLE_SOLID
#property indicator_width9 3
#property indicator_color9 0x4763FF
#property indicator_label9 "Bearish Weak"

#property indicator_type10 DRAW_HISTOGRAM
#property indicator_style10 STYLE_SOLID
#property indicator_width10 3
#property indicator_color10 0x4763FF
#property indicator_label10 "Bearish Weak"

#property indicator_type11 DRAW_HISTOGRAM
#property indicator_style11 STYLE_SOLID
#property indicator_width11 1
#property indicator_color11 0x4763FF
#property indicator_label11 "Bearish Weak"

#property indicator_type12 DRAW_HISTOGRAM
#property indicator_style12 STYLE_SOLID
#property indicator_width12 1
#property indicator_color12 0x4763FF
#property indicator_label12 "Bearish Weak"

#property indicator_type13 DRAW_HISTOGRAM
#property indicator_style13 STYLE_SOLID
#property indicator_width13 3
#property indicator_color13 0x0000FF
#property indicator_label13 "Bearish"

#property indicator_type14 DRAW_HISTOGRAM
#property indicator_style14 STYLE_SOLID
#property indicator_width14 3
#property indicator_color14 0x0000FF
#property indicator_label14 "Bearish"

#property indicator_type15 DRAW_HISTOGRAM
#property indicator_style15 STYLE_SOLID
#property indicator_width15 1
#property indicator_color15 0x0000FF
#property indicator_label15 "Bearish"

#property indicator_type16 DRAW_HISTOGRAM
#property indicator_style16 STYLE_SOLID
#property indicator_width16 1
#property indicator_color16 0x0000FF
#property indicator_label16 "Bearish"

//--- indicator buffers
double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double Buffer5[];
double Buffer6[];
double Buffer7[];
double Buffer8[];
double Buffer9[];
double Buffer10[];
double Buffer11[];
double Buffer12[];
double Buffer13[];
double Buffer14[];
double Buffer15[];
double Buffer16[];

input int Period1 = 3;
input int Period2 = 34;
input int bars_limit = 10000; // Bars limit
double myPoint; //initialized in OnInit

input int button_x = 20; // Button X
input int button_y = 30; // Button Y
input string button_text = "Show/Hide"; // Button text

//Visibility controller v1.3
class VisibilityCotroller
{
   string buttonId;
   string visibilityId;
   bool show_data;
   bool recalc;
public:
   void Init(string id, string indicatorName, string caption, int x, int y)
   {
      recalc = false;
      visibilityId = indicatorName + "_visibility";
      double val;
      if (GlobalVariableGet(visibilityId, val))
         show_data = val != 0;
         
      buttonId = id;
      ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
      createButton(buttonId, caption, 65, 20, "Impact", 8, clrDarkRed, clrBlack, clrWhite);
      ObjectSetInteger(0, buttonId, OBJPROP_YDISTANCE, y);
      ObjectSetInteger(0, buttonId, OBJPROP_XDISTANCE, x);
   }

   void DeInit()
   {
      ObjectDelete(ChartID(), buttonId);
   }

   bool HandleButtonClicks()
   {
      if (ObjectGetInteger(0, buttonId, OBJPROP_STATE))
      {
         ObjectSetInteger(0, buttonId, OBJPROP_STATE, false);
         show_data = !show_data;
         GlobalVariableSet(visibilityId, show_data ? 1.0 : 0.0);
         recalc = true;
         return true;
      }
      return false;
   }

   bool IsRecalcNeeded()
   {
      return recalc;
   }

   void ResetRecalc()
   {
      recalc = false;
   }

   bool IsVisible()
   {
      return show_data;
   }

private:
   void createButton(string buttonID,string buttonText,int width,int height,string font,int fontSize,color bgColor,color borderColor,color txtColor)
   {
      ObjectDelete(0,buttonID);
      ObjectCreate(0,buttonID,OBJ_BUTTON,0,0,0);
      ObjectSetInteger(0,buttonID,OBJPROP_COLOR,txtColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BGCOLOR,bgColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_COLOR,borderColor);
      ObjectSetInteger(0,buttonID,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      ObjectSetInteger(0,buttonID,OBJPROP_XDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_YDISTANCE,9999);
      ObjectSetInteger(0,buttonID,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,buttonID,OBJPROP_YSIZE,height);
      ObjectSetString(0,buttonID,OBJPROP_FONT,font);
      ObjectSetString(0,buttonID,OBJPROP_TEXT,buttonText);
      ObjectSetInteger(0,buttonID,OBJPROP_FONTSIZE,fontSize);
      ObjectSetInteger(0,buttonID,OBJPROP_SELECTABLE,0);
      ObjectSetInteger(0,buttonID,OBJPROP_CORNER,2);
      ObjectSetInteger(0,buttonID,OBJPROP_HIDDEN,1);
   }
};

VisibilityCotroller visibility;
void myAlert(string type, string message)
{
   if(type == "print")
      Print(message);
   else if(type == "error")
   {
      Print(type+" | Trend Colored @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
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
   IndicatorBuffers(16);
   SetIndexBuffer(0, Buffer1);
   SetIndexEmptyValue(0, EMPTY_VALUE);
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexBuffer(4, Buffer5);
   SetIndexEmptyValue(4, EMPTY_VALUE);
   SetIndexBuffer(5, Buffer6);
   SetIndexEmptyValue(5, EMPTY_VALUE);
   SetIndexBuffer(6, Buffer7);
   SetIndexEmptyValue(6, EMPTY_VALUE);
   SetIndexBuffer(7, Buffer8);
   SetIndexEmptyValue(7, EMPTY_VALUE);
   SetIndexBuffer(8, Buffer9);
   SetIndexEmptyValue(8, EMPTY_VALUE);
   SetIndexBuffer(9, Buffer10);
   SetIndexEmptyValue(9, EMPTY_VALUE);
   SetIndexBuffer(10, Buffer11);
   SetIndexEmptyValue(10, EMPTY_VALUE);
   SetIndexBuffer(11, Buffer12);
   SetIndexEmptyValue(11, EMPTY_VALUE);
   SetIndexBuffer(12, Buffer13);
   SetIndexEmptyValue(12, EMPTY_VALUE);
   SetIndexBuffer(13, Buffer14);
   SetIndexEmptyValue(13, EMPTY_VALUE);
   SetIndexBuffer(14, Buffer15);
   SetIndexEmptyValue(14, EMPTY_VALUE);
   SetIndexBuffer(15, Buffer16);
   SetIndexEmptyValue(15, EMPTY_VALUE);
   //initialize myPoint
   myPoint = Point();
   if(Digits() == 5 || Digits() == 3)
   {
      myPoint *= 10;
   }
   visibility.Init("show_hide_tc", "tc", button_text, button_x, button_y);
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   visibility.DeInit();  
}

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
{
   if (visibility.HandleButtonClicks())
   {
      ChartRedraw();
   }
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
   visibility.HandleButtonClicks();
   int limit = rates_total - prev_calculated;
   //--- counting from 0 to rates_total
   ArraySetAsSeries(Buffer1, true);
   ArraySetAsSeries(Buffer2, true);
   ArraySetAsSeries(Buffer3, true);
   ArraySetAsSeries(Buffer4, true);
   ArraySetAsSeries(Buffer5, true);
   ArraySetAsSeries(Buffer6, true);
   ArraySetAsSeries(Buffer7, true);
   ArraySetAsSeries(Buffer8, true);
   ArraySetAsSeries(Buffer9, true);
   ArraySetAsSeries(Buffer10, true);
   ArraySetAsSeries(Buffer11, true);
   ArraySetAsSeries(Buffer12, true);
   ArraySetAsSeries(Buffer13, true);
   ArraySetAsSeries(Buffer14, true);
   ArraySetAsSeries(Buffer15, true);
   ArraySetAsSeries(Buffer16, true);
   //--- initial zero
   if(prev_calculated < 1)
   {
      ArrayInitialize(Buffer1, EMPTY_VALUE);
      ArrayInitialize(Buffer2, EMPTY_VALUE);
      ArrayInitialize(Buffer3, EMPTY_VALUE);
      ArrayInitialize(Buffer4, EMPTY_VALUE);
      ArrayInitialize(Buffer5, EMPTY_VALUE);
      ArrayInitialize(Buffer6, EMPTY_VALUE);
      ArrayInitialize(Buffer7, EMPTY_VALUE);
      ArrayInitialize(Buffer8, EMPTY_VALUE);
      ArrayInitialize(Buffer9, EMPTY_VALUE);
      ArrayInitialize(Buffer10, EMPTY_VALUE);
      ArrayInitialize(Buffer11, EMPTY_VALUE);
      ArrayInitialize(Buffer12, EMPTY_VALUE);
      ArrayInitialize(Buffer13, EMPTY_VALUE);
      ArrayInitialize(Buffer14, EMPTY_VALUE);
      ArrayInitialize(Buffer15, EMPTY_VALUE);
      ArrayInitialize(Buffer16, EMPTY_VALUE);
   }
   int pc = prev_calculated;

   if (visibility.IsRecalcNeeded())
   {
      if (!visibility.IsVisible())
      {
         Print("Hide");
         ArrayInitialize(Buffer1, EMPTY_VALUE);
         ArrayInitialize(Buffer2, EMPTY_VALUE);
         ArrayInitialize(Buffer3, EMPTY_VALUE);
         ArrayInitialize(Buffer4, EMPTY_VALUE);
         ArrayInitialize(Buffer5, EMPTY_VALUE);
         ArrayInitialize(Buffer6, EMPTY_VALUE);
         ArrayInitialize(Buffer7, EMPTY_VALUE);
         ArrayInitialize(Buffer8, EMPTY_VALUE);
         ArrayInitialize(Buffer9, EMPTY_VALUE);
         ArrayInitialize(Buffer10, EMPTY_VALUE);
         ArrayInitialize(Buffer11, EMPTY_VALUE);
         ArrayInitialize(Buffer12, EMPTY_VALUE);
         ArrayInitialize(Buffer13, EMPTY_VALUE);
         ArrayInitialize(Buffer14, EMPTY_VALUE);
         ArrayInitialize(Buffer15, EMPTY_VALUE);
         ArrayInitialize(Buffer16, EMPTY_VALUE);
         visibility.ResetRecalc();
         return 0;
      }
      else
      {
         Print("SHow");
         pc = 0;
      }
      visibility.ResetRecalc();
   }
   if (!visibility.IsVisible())
   {
      return 0;
   }
   
   int toSkip = 1;
   for (int i = MathMin(bars_limit, rates_total - 1 - MathMax(pc - 1, toSkip)); i >= 0 && !IsStopped(); --i)
   {
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer1[i] = Open[i]; //Set indicator value at Candlestick Open
      }
      else
      {
         Buffer1[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 2
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer2[i] = Close[i]; //Set indicator value at Candlestick Close
      }
      else
      {
         Buffer2[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 3
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer3[i] = High[i]; //Set indicator value at Candlestick High
      }
      else
      {
         Buffer3[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 4
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer4[i] = Low[i]; //Set indicator value at Candlestick Low
      }
      else
      {
         Buffer4[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 5
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer5[i] = Open[i]; //Set indicator value at Candlestick Open
      }
      else
      {
         Buffer5[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 6
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer6[i] = Close[i]; //Set indicator value at Candlestick Close
      }
      else
      {
         Buffer6[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 7
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer7[i] = High[i]; //Set indicator value at Candlestick High
      }
      else
      {
         Buffer7[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 8
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer8[i] = Low[i]; //Set indicator value at Candlestick Low
      }
      else
      {
         Buffer8[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 9
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer9[i] = Open[i]; //Set indicator value at Candlestick Open
      }
      else
      {
         Buffer9[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 10
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer10[i] = Close[i]; //Set indicator value at Candlestick Close
      }
      else
      {
         Buffer10[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 11
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer11[i] = High[i]; //Set indicator value at Candlestick High
      }
      else
      {
         Buffer11[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 12
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average > Moving Average
      )
      {
         Buffer12[i] = Low[i]; //Set indicator value at Candlestick Low
      }
      else
      {
         Buffer12[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 13
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer13[i] = Open[i]; //Set indicator value at Candlestick Open
      }
      else
      {
         Buffer13[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 14
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer14[i] = Close[i]; //Set indicator value at Candlestick Close
      }
      else
      {
         Buffer14[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 15
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer15[i] = High[i]; //Set indicator value at Candlestick High
      }
      else
      {
         Buffer15[i] = EMPTY_VALUE;
      }
      //Indicator Buffer 16
      if(iMA(NULL, PERIOD_CURRENT, Period1, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      && iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, Period2, 0, MODE_SMA, PRICE_CLOSE, 1+i) //Moving Average < Moving Average
      )
      {
         Buffer16[i] = Low[i]; //Set indicator value at Candlestick Low
      }
      else
      {
         Buffer16[i] = EMPTY_VALUE;
      }
   }
   return(rates_total);
}
//+------------------------------------------------------------------+