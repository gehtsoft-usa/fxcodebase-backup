// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71186

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  | 
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   | 
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |                    
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
// based on Max Michael

#property indicator_chart_window
#property indicator_buffers 5
#property strict

#property indicator_color1 clrBlue
#property indicator_color2 clrRed
#property indicator_color3 clrBlue
#property indicator_color4 clrRed
#property indicator_color5 clrGoldenrod

// inputs
input int Length = 89;
input int Level_Up = 50;
input int Level_Dn = 50;
input bool ShowRSIbands = true;
input int bars_limit = 5000;

// globals
double LevUp, LevDn;

// buffers
double emaUp[];
double emaDn[];
double Eup[];
double Edn[];
double Stop[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
{
   IndicatorShortName("RSI(" + IntegerToString(Length) + ") ");
   SetIndexBuffer(0, emaUp);
   SetIndexStyle(0, DRAW_NONE);
   SetIndexBuffer(1, emaDn);
   SetIndexStyle(1, DRAW_NONE);
   if (ShowRSIbands)
   {
      SetIndexBuffer(2, Eup);
      SetIndexStyle(2, DRAW_LINE);
      SetIndexBuffer(3, Edn);
      SetIndexStyle(3, DRAW_LINE);
   }
   else
   {
      SetIndexBuffer(2, Eup);
      SetIndexStyle(2, DRAW_NONE);
      SetIndexBuffer(3, Edn);
      SetIndexStyle(3, DRAW_NONE);
   }
   SetIndexBuffer(4, Stop);
   SetIndexStyle(4, DRAW_LINE);
   SetIndexLabel(4, "RSI stop level");
   // Convert level values to percent
   LevUp = (Level_Up - 50) / 20.0;
   LevDn = (50 - Level_Dn) / 20.0;
   return (0);
}

int deinit() { return (0); }

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
   if (prev_calculated <= 0 || prev_calculated > rates_total)
   {
      ArrayInitialize(emaUp, EMPTY_VALUE);
      ArrayInitialize(emaDn, EMPTY_VALUE);
   }
   bool timeSeries = ArrayGetAsSeries(time); 
   bool openSeries = ArrayGetAsSeries(open); 
   bool highSeries = ArrayGetAsSeries(high); 
   bool lowSeries = ArrayGetAsSeries(low); 
   bool closeSeries = ArrayGetAsSeries(close); 
   bool tickVolumeSeries = ArrayGetAsSeries(tick_volume); 
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   double wilders = Length * 2 - 1;
   double alpha = 2.0 / (1 + wilders);
   // Differential equation of length, level, delta.
   double delta_up = (wilders / ((1 + 1 / wilders) * 5)) * LevUp;
   double delta_dn = (wilders / ((1 + 1 / wilders) * 5)) * LevDn;

   int toSkip = 1;
   for (int i = MathMin(bars_limit, rates_total - 1 - MathMax(prev_calculated, toSkip)); i >= 0 && !IsStopped(); --i)
   {
      double Su = (Close[i] - Close[i + 1] > 0) ? Close[i] - Close[i + 1] : 0;
      double Sd = (Close[i] - Close[i + 1] < 0) ? Close[i + 1] - Close[i] : 0;
      emaUp[i] = (Su - emaUp[i + 1]) * alpha + emaUp[i + 1];
      emaDn[i] = (Sd - emaDn[i + 1]) * alpha + emaDn[i + 1];
      double ccrange = emaUp[i] + emaDn[i];
      Eup[i] = ccrange * delta_up + iMA(NULL, 0, wilders, 0, MODE_EMA, PRICE_CLOSE, i);
      Edn[i] = -ccrange * delta_dn + iMA(NULL, 0, wilders, 0, MODE_EMA, PRICE_CLOSE, i);
      double prev = Stop[i + 1];
      if (Close[i] > prev && Close[i + 1] > prev)
      {
         Stop[i] = MathMax(prev, Edn[i]); //uptrend
      }
      else if (Close[i] < prev && Close[i + 1] < prev)
      {
         Stop[i] = MathMin(prev, Eup[i]); //dntrend
      }
      else if (Close[i] > prev)
      {
         Stop[i] = Edn[i]; //change of trend up else down
      }
      else
      {
         Stop[i] = Eup[i];
      }
   }
   
   ArraySetAsSeries(time, timeSeries);
   ArraySetAsSeries(open, openSeries);
   ArraySetAsSeries(high, highSeries);
   ArraySetAsSeries(low, lowSeries);
   ArraySetAsSeries(close, closeSeries);
   ArraySetAsSeries(tick_volume, tickVolumeSeries);
   return rates_total;
}

