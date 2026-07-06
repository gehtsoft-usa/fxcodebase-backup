// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71272


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
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property description ""

#include <stdlib.mqh>
#include <stderror.mqh>

//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 4

#property indicator_type1 DRAW_LINE
#property indicator_style1 STYLE_SOLID
#property indicator_width1 3
#property indicator_color1 0x11FF00
#property indicator_label1 "Buy"

#property indicator_type2 DRAW_LINE
#property indicator_style2 STYLE_SOLID
#property indicator_width2 3
#property indicator_color2 0xF700FF
#property indicator_label2 "Sell"

#property indicator_type3 DRAW_ARROW
#property indicator_width3 5
#property indicator_color3 0x1AFF00
#property indicator_label3 "Buy"

#property indicator_type4 DRAW_ARROW
#property indicator_width4 5
#property indicator_color4 0xEE00FF
#property indicator_label4 "Sell"

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
      Print(type+" | Indicator01 @ "+Symbol()+","+IntegerToString(Period())+" | "+message);
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
   SetIndexBuffer(1, Buffer2);
   SetIndexEmptyValue(1, EMPTY_VALUE);
   SetIndexBuffer(2, Buffer3);
   SetIndexEmptyValue(2, EMPTY_VALUE);
   SetIndexArrow(2, 241);
   SetIndexBuffer(3, Buffer4);
   SetIndexEmptyValue(3, EMPTY_VALUE);
   SetIndexArrow(3, 242);
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
      if (i >= MathMin(5000-1, rates_total-1-50)) continue; //omit some old rates to prevent "Array out of range" or slow calculation   
      
      //Indicator Buffer 1
      if(iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i) //Moving Average > Moving Average
      )
        {
         Buffer1[i] = iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i); //Set indicator value at Moving Average
        }
      else
        {
         Buffer1[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 2
      if(iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i) //Moving Average < Moving Average
      )
        {
         Buffer2[i] = iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i); //Set indicator value at Moving Average
        }
      else
        {
         Buffer2[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 3
      if(iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i) > iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i)
      && iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i+1) < iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i+1) //Moving Average crosses above Moving Average
      )
        {
         Buffer3[i] = iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i); //Set indicator value at Moving Average
        }
      else
        {
         Buffer3[i] = EMPTY_VALUE;
        }
      //Indicator Buffer 4
      if(iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i) < iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i)
      && iMA(NULL, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE, i+1) > iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i+1) //Moving Average crosses below Moving Average
      )
        {
         Buffer4[i] = iMA(NULL, PERIOD_CURRENT, 155, 0, MODE_EMA, PRICE_CLOSE, i); //Set indicator value at Moving Average
        }
      else
        {
         Buffer4[i] = EMPTY_VALUE;
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+