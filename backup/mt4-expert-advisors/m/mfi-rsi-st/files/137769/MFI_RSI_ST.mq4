// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=70466

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
#property version "1.0"
#property strict

enum MODE_ST
{
   MAIN = 0,  // Main Line
   SIGNAL = 1 // Signal Line
};

enum PRICE_ST
{
   LOW_HIGH = 0,   // Low/High
   CLOSE_CLOSE = 1 // Close/Close
};

#property indicator_separate_window
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_buffers    3
#property indicator_color1     LightSeaGreen
#property indicator_color2     Red
#property indicator_level1     20.0
#property indicator_level2     80.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
//--- input parameters
input int MFIPeriod = 14; // MFI Period
input int RSIPeriod = 14; // RSI Period
input ENUM_APPLIED_PRICE RSIPrice = PRICE_CLOSE; // RSI Price Apply
input int StKPeriod = 5;  // Stochastic K Period
input int StDPeriod = 3; // Stochastic D Period
input int StSlowing = 3; // Stochastic Slowing
input PRICE_ST StPrice = LOW_HIGH; // Stochastic Price Apply
input ENUM_MA_METHOD StMAMethod = MODE_SMA; // Stochastic MA Method
input MODE_ST StMode = MAIN; // Stochastic Mode
input int DevPeriod = 10; //Deviation Period

//--- buffers
double SumBuffer[];
double SignalBuffer[];
double DeviationBuffer[];

int StartBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
{
   IndicatorBuffers(3);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0, SignalBuffer);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1, DeviationBuffer);
   SetIndexBuffer(2,SumBuffer);
   string short_name = "RSI(" + IntegerToString(RSIPeriod) + ") MFI(" + IntegerToString(MFIPeriod) + ")  Sto("+IntegerToString(StKPeriod)+","+IntegerToString(StDPeriod)+","+IntegerToString(StSlowing)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   SetIndexLabel(1,"Signal");
   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason)
{
   
}
//+------------------------------------------------------------------+
//| Stochastic oscillator                                            |
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
  
     int i,limit;
//---
   if(rates_total<=StDPeriod)
      return(0);
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
//--- macd counted in the 1-st buffer
   for(i=0; i<limit; i++)
   {
      double mfi = getMFIValue(i);
      double rsi = getRSIValue(i);
      double st = getStochasticValue(i);
      SumBuffer[i] = (mfi+rsi+st);
      SignalBuffer[i]=(mfi+rsi+st)/3;
   }
   int toSkip = DevPeriod;
   for (int pos = rates_total - 1 - MathMax(prev_calculated, toSkip); pos >= 0 && !IsStopped(); --pos)
   {
      DeviationBuffer[pos] = StDev(SumBuffer, DevPeriod, pos);
   }
   return(rates_total);
  
 
  }
//+------------------------------------------------------------------+


double getMFIValue(int shift = 0)
{
   return iMFI(NULL,0,MFIPeriod,shift);
}

double getRSIValue(int shift = 0)
{
   return iRSI(NULL,NULL,RSIPeriod,RSIPrice,shift);
}

double getStochasticValue(int shift = 0)
{
   int Price = 0;
   int Mode = 0;
   if(StPrice == CLOSE_CLOSE) Price = 1;
   if(StMode == SIGNAL) Mode = 1;
   return iStochastic(NULL,NULL,StKPeriod,StDPeriod,StSlowing,StMAMethod,Price,Mode,shift);
}

double StDev(double& data[], int period, int pos)
{
   return MathSqrt(Variance(data, period, pos));
}
double Variance(double& data[], int period, int pos)
{
   double sum = 0;
   double ssum = 0;
   for (int i = 0; i < period; i++)
   {
      sum += data[pos + i];
      ssum += MathPow(data[pos + i], 2);
   }
   return (ssum * period - sum * sum) / (period * (period - 1));
}

