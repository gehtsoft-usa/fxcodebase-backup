// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70279


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

#property indicator_separate_window
#property indicator_minimum 0
#property indicator_maximum 1

#property indicator_buffers 1
#property indicator_plots   1
//--- plot SmoothedRSI
#property indicator_label1  "Smoothed RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int      InpLength = 10;         // Length


//--- indicator buffers
double         ExtSmoothedRSIBuffer[], ExtValue[], ExtCUBuffer[], ExtCDBuffer[];

#define        LABEL "Smoothed RSI("+string(InpLength)+")"
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   IndicatorBuffers(4);
   SetIndexBuffer(0, ExtSmoothedRSIBuffer);
   SetIndexBuffer(1, ExtValue, INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, ExtCUBuffer, INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, ExtCDBuffer, INDICATOR_CALCULATIONS);
   SetIndexEmptyValue(0, EMPTY_VALUE);

   SetIndexLabel(0, LABEL);
   IndicatorShortName(LABEL);
   IndicatorDigits(2);
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
   static int startBar = 1;
   if(prev_calculated == 0) {
      startBar = rates_total - 4;
   } else {
      startBar = rates_total - prev_calculated;
   }

   for(int barIndex = startBar; barIndex >= 0; barIndex--) {
      ExtValue[barIndex] = (close[barIndex] + 2 * close[barIndex + 1] + 2 * close[barIndex + 2] + close[barIndex + 3] ) / 6;

      if(prev_calculated == 0 && barIndex > startBar - 1) {
         ExtSmoothedRSIBuffer[barIndex] = 0;
         continue;
      }

      ExtCUBuffer[barIndex] = (ExtValue[barIndex] > ExtValue[barIndex + 1] ? ExtValue[barIndex] - ExtValue[barIndex + 1] : 0);
      ExtCDBuffer[barIndex] = (ExtValue[barIndex] < ExtValue[barIndex + 1] ? ExtValue[barIndex + 1] - ExtValue[barIndex] : 0);

      if(prev_calculated > 0 || (startBar - barIndex - 1) > InpLength) {
         double cu = sum(ExtCUBuffer, InpLength, barIndex);
         double cd = sum(ExtCDBuffer, InpLength, barIndex);

         ExtSmoothedRSIBuffer[barIndex] = (cu + cd != 0 ? cu / (cu + cd) : 0);
      }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Sliding Sum                                                      |
//+------------------------------------------------------------------+
double sum(const double &arr[], const int length, const int currStart) {
   double sum = 0;
   for(int i = currStart; i < currStart + length; i++) {
      sum += arr[i];
   }
   return sum;
}
//+------------------------------------------------------------------+
