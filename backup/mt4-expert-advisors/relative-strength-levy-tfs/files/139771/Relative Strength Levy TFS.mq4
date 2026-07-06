// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70749

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict
#property indicator_separate_window
#property indicator_buffers    1
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_label1    "RSL"
#property indicator_level1    1.0
#property indicator_color1    DodgerBlue
#property indicator_type1     DRAW_LINE

// --- Input Variable ------------------------------------------------------------------
input int InpMAPeriod               = 14;          // MA Period
input ENUM_MA_METHOD InpMAMethod    = MODE_SMA;    // MA Method
input ENUM_APPLIED_PRICE InpMAPrice = PRICE_CLOSE; // MA Applied Price
input string symbols = "EURUSD,USDJPY"; // Symbols
input ENUM_TIMEFRAMES tf = PERIOD_CURRENT; // Timeframe

// --- Indicator Buffer ----------------------------------------------------------------
double Buffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
//--- indicator buffers mapping
   SetIndexBuffer(0,Buffer);
   string sShortName="RSL("+IntegerToString(InpMAPeriod)+")";
   IndicatorShortName(sShortName);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Relative Strength Levy indicator                                 |
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
   if (!VerifyHistory()) 
   {
      return prev_calculated;
   }
   int bars = rates_total-1;
   if (prev_calculated > 0) 
      bars = rates_total - prev_calculated;

   string list[];
   StringSplit(symbols, ',', list);
   for (int i = 0; i < bars; i++)
   {
      double summ = 0;
      int count = 0;
      for (int ii = 0; ii < ArraySize(list); ++ii)
      {
         string symbol = list[ii];
         int index = i == 0 ? 0 : iBarShift(symbol, tf, time[i]);
         if (index >= 0)
         {
            summ += iClose(symbol, tf, index) / iMA(symbol, tf, InpMAPeriod, 0, InpMAMethod, InpMAPrice, index);
            ++count;
         }
      }
      Buffer[i] = count == 0 ? 0 : summ / count;
   }

   return rates_total;
}

bool VerifyHistory(string symbol = NULL) 
{
   if(symbol==NULL) symbol=_Symbol;
   bool x = true;
   datetime ArrayTime[];
   ArraySetAsSeries(ArrayTime,true);
   int copied = CopyTime(symbol,PERIOD_M1,0,2,ArrayTime);
   if(copied<0) x = false;
   return x;
}