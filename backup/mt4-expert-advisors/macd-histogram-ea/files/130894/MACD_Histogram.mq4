// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69345

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//|                         https://AppliedMachineLearning.systems   |
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

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 DodgerBlue
#property indicator_color2 Red
#property indicator_color3 Silver
#property indicator_color4 Lime
#property indicator_color5 Red
#property indicator_level1 0
//----
#define arrowsDisplacement 0.0001
//---- input parameters
string separator1 = "*** MACD Settings ***";
extern int FastMAPeriod = 12;
extern int SlowMAPeriod = 26;
extern int SignalMAPeriod = 9;
string separator2 = "*** Indicator Settings ***";
bool   drawIndicatorTrendLines = true;
bool   drawPriceTrendLines = true;
bool   displayAlert = true;
//---- buffers
double MACDLineBuffer[];
double SignalLineBuffer[];
double HistogramBuffer[];
double bullishDivergence[];
double bearishDivergence[];
//---- variables
double alpha = 0;
double alpha_1 = 0;
//----
static datetime lastAlertTime;
static string   indicatorName;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
{
   IndicatorDigits(Digits + 1);
   //---- indicators
   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, MACDLineBuffer);
   SetIndexDrawBegin(0, SlowMAPeriod);
   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, SignalLineBuffer);
   SetIndexDrawBegin(1, SlowMAPeriod + SignalMAPeriod);
   SetIndexStyle(2, DRAW_HISTOGRAM, STYLE_SOLID,2);
   SetIndexBuffer(2, HistogramBuffer);
   SetIndexDrawBegin(2, SlowMAPeriod + SignalMAPeriod);
   SetIndexStyle(3, DRAW_ARROW);
   SetIndexArrow(3, 233);
   SetIndexBuffer(3, bullishDivergence);
   SetIndexStyle(4, DRAW_ARROW);
   SetIndexArrow(4, 234);
   SetIndexBuffer(4, bearishDivergence);
   //---- name for DataWindow and indicator subwindow label
   indicatorName =("MACD(" + FastMAPeriod+"," + SlowMAPeriod + "," + SignalMAPeriod + ")");
   SetIndexLabel(2, "MACD");
   SetIndexLabel(3, "Signal");
   SetIndexLabel(4, "Histogr");
   IndicatorShortName(indicatorName);  
   //----
	  alpha = 2.0 / (SignalMAPeriod + 1.0);
	  alpha_1 = 1.0 - alpha;
   //----
   return(0);
}
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 19) != "MACD_DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int limit;
   int counted_bars = IndicatorCounted();
   //---- check for possible errors
   if(counted_bars < 0) 
       return(-1);
   //---- last counted bar will be recounted
   if(counted_bars > 0) 
       counted_bars--;
   limit = Bars - counted_bars;
   CalculateIndicator(counted_bars);
//----
   for(int i = limit; i >= 0; i--)
     {
       MACDLineBuffer[i] = iMA(NULL, 0, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i) - 
                           iMA(NULL, 0, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
       SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
       HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       CalculateMACD(i);
       CatchBullishDivergence(i + 2);
       CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMACD(int i)
  {
   MACDLineBuffer[i] = iMA(NULL, 0, FastMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i) - 
                       iMA(NULL, 0, SlowMAPeriod, 0, MODE_EMA, PRICE_CLOSE, i);
   SignalLineBuffer[i] = alpha*MACDLineBuffer[i] + alpha_1*SignalLineBuffer[i+1];
   HistogramBuffer[i] = MACDLineBuffer[i] - SignalLineBuffer[i];      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;  
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
//----   
   if(MACDLineBuffer[currentTrough] > MACDLineBuffer[lastTrough] && 
      Low[currentTrough] < Low[lastTrough])
     {
       bullishDivergence[currentTrough] = MACDLineBuffer[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                             Low[lastTrough], Lime, STYLE_SOLID);
       //----
       if(drawIndicatorTrendLines == true)
          DrawIndicatorTrendLine(Time[currentTrough], 
                                 Time[lastTrough], 
                                 MACDLineBuffer[currentTrough],
                                 MACDLineBuffer[lastTrough], 
                                 Lime, STYLE_SOLID);
       //----
       if(displayAlert == true)
          DisplayAlert("Classical bullish divergence on: ", 
                        currentTrough);  
     }
//----   
   if(MACDLineBuffer[currentTrough] < MACDLineBuffer[lastTrough] && 
      Low[currentTrough] > Low[lastTrough])
     {
       bullishDivergence[currentTrough] = MACDLineBuffer[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], Lime, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)                            
           DrawIndicatorTrendLine(Time[currentTrough], 
                                  Time[lastTrough], 
                                  MACDLineBuffer[currentTrough],
                                  MACDLineBuffer[lastTrough], 
                                  Lime, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("Reverse bullish divergence on: ", 
                        currentTrough);   
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
//----   
   if(MACDLineBuffer[currentPeak] < MACDLineBuffer[lastPeak] && 
      High[currentPeak] > High[lastPeak])
     {
       bearishDivergence[currentPeak] = MACDLineBuffer[currentPeak] + 
                                        arrowsDisplacement;
      
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_SOLID);
                            
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  MACDLineBuffer[currentPeak],
                                  MACDLineBuffer[lastPeak], Red, STYLE_SOLID);

       if(displayAlert == true)
           DisplayAlert("Classical bearish divergence on: ", 
                        currentPeak);  
     }
   if(MACDLineBuffer[currentPeak] > MACDLineBuffer[lastPeak] && 
      High[currentPeak] < High[lastPeak])
     {
       bearishDivergence[currentPeak] = MACDLineBuffer[currentPeak] + 
                                        arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], Red, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  MACDLineBuffer[currentPeak],
                                  MACDLineBuffer[lastPeak], Red, STYLE_DOT);
       //----
       if(displayAlert == true)
           DisplayAlert("Reverse bearish divergence on: ", 
                        currentPeak);   
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(MACDLineBuffer[shift] >= MACDLineBuffer[shift+1] && MACDLineBuffer[shift] > MACDLineBuffer[shift+2] && 
      MACDLineBuffer[shift] > MACDLineBuffer[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(MACDLineBuffer[shift] <= MACDLineBuffer[shift+1] && MACDLineBuffer[shift] < MACDLineBuffer[shift+2] && 
      MACDLineBuffer[shift] < MACDLineBuffer[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
       if(SignalLineBuffer[i] >= SignalLineBuffer[i+1] && SignalLineBuffer[i] >= SignalLineBuffer[i+2] &&
          SignalLineBuffer[i] >= SignalLineBuffer[i-1] && SignalLineBuffer[i] >= SignalLineBuffer[i-2])
         {
           for(int j = i; j < Bars; j++)
             {
               if(MACDLineBuffer[j] >= MACDLineBuffer[j+1] && MACDLineBuffer[j] > MACDLineBuffer[j+2] &&
                  MACDLineBuffer[j] >= MACDLineBuffer[j-1] && MACDLineBuffer[j] > MACDLineBuffer[j-2])
                   return(j);
             }
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
        if(SignalLineBuffer[i] <= SignalLineBuffer[i+1] && SignalLineBuffer[i] <= SignalLineBuffer[i+2] &&
           SignalLineBuffer[i] <= SignalLineBuffer[i-1] && SignalLineBuffer[i] <= SignalLineBuffer[i-2])
          {
            for (int j = i; j < Bars; j++)
              {
                if(MACDLineBuffer[j] <= MACDLineBuffer[j+1] && MACDLineBuffer[j] < MACDLineBuffer[j+2] &&
                   MACDLineBuffer[j] <= MACDLineBuffer[j-1] && MACDLineBuffer[j] < MACDLineBuffer[j-2])
                    return(j);
              }
          }
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       Alert(message, Symbol(), " , ", Period(), " minutes chart");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "MACD_DivergenceLine.0# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = "MACD_DivergenceLine.0$# " + DoubleToStr(x1, 0);
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+



