// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69947


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 clrDodgerBlue
#property indicator_width1 2

//--- input parameters
input int      InpLookBack = 10;       // Look Back
input double   InpMaxBodySize = 25;     // Maximum Body Size(in percentage)
input int      InpArrowCode = 117;     // Symbol Code

double BufferSmallCandleSignal[];
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- initialize the point value
 
   
//--- indicator buffers mapping
   SetIndexBuffer(0, BufferSmallCandleSignal);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, InpArrowCode);
   SetIndexEmptyValue(0, EMPTY_VALUE);

   IndicatorDigits(Digits);
   IndicatorShortName(StringFormat("Small Candle Indentifier(%d, %.2f, %d)", InpLookBack, InpMaxBodySize, InpArrowCode));
   SetIndexLabel(0, StringFormat("Small Candle Indentifier(%d, %.2f, %d)", InpLookBack, InpMaxBodySize, InpArrowCode));
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
                const int &spread[]) {
//---
   int limit = rates_total - prev_calculated;
   if(prev_calculated == 0) limit -= InpLookBack - 2;

   for(int candleIndex = limit; candleIndex >= 0; candleIndex--) {
      if( GetAverageOfCandleRange(candleIndex, InpLookBack, close, open)  > MathAbs(close[candleIndex]-open[candleIndex])){
         BufferSmallCandleSignal[candleIndex] = low[candleIndex] - iATR(_Symbol, 0, 10, 0) * 0.25;
      }else{
         BufferSmallCandleSignal[candleIndex] = EMPTY_VALUE;
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAverageOfCandleRange(const int currentIndex, const int range, const double &close[], const double &open[]) {
   //--- error checking
   if(range == 0) return 0;
   int endLimit = currentIndex + range;
   if(endLimit > Bars - 1) endLimit = Bars - 1;
   
   //--- calcualte the average
   double average = 0;
   for(int candleIndex = currentIndex; candleIndex < endLimit; candleIndex++) {
      average += MathAbs(close[candleIndex] - open[candleIndex]) / range;
   }
   return (average/100)*InpMaxBodySize;
}
//+------------------------------------------------------------------+
