// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=149916#p149916

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 

#property indicator_chart_window

#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "ColorCandles"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrSilver,clrLimeGreen,clrDarkOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };
enum enCandleTypes
  {
   price,     // Price candles
   heikenashi // Heiken Ashi candles
  };
input enCandleTypes inpCandleType = heikenashi; // Type of candles
input int       inpMaPeriod      = 7;        // Smoothing period
input enMaTypes inpMaMetod       = ma_lwma;  // Smoothing method
input int       inpStep          = 0;        // Step size
input bool      inpBetterFormula = false;    // Use better formula

double line[];

double    buf_open[];
double    buf_high[];
double    buf_low[];
double    buf_close[];
double    buf_color[];

double    ha_open_buffer[];
double    ha_close_buffer[];

input int inpPeriod = 10;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0, buf_open, INDICATOR_DATA);
   SetIndexBuffer(1, buf_high, INDICATOR_DATA);
   SetIndexBuffer(2, buf_low, INDICATOR_DATA);
   SetIndexBuffer(3, buf_close, INDICATOR_DATA);
   SetIndexBuffer(4, buf_color, INDICATOR_COLOR_INDEX);
   ArrayResize(ha_open_buffer, 0);
   ArrayResize(ha_close_buffer, 0);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time[],
                const double&   open[],
                const double&   high[],
                const double&   low[],
                const double&   close[],
                const long&     tick_volume[],
                const long&     volume[],
                const int&      spread[])
  {
   int start;
   double _pointModifier = MathPow(10, SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2);
   if(prev_calculated > 1)
      start = prev_calculated - 1;
   else
     {
      start = inpPeriod + 1;
     }
   for(int i = start; i < rates_total && !IsStopped(); i++)
     {
      if(ArraySize(ha_open_buffer) != rates_total)
        {
         ArrayResize(ha_open_buffer, rates_total);
         ArrayResize(ha_close_buffer, rates_total);
         ArrayInitialize(ha_open_buffer, EMPTY_VALUE);
         ArrayInitialize(ha_close_buffer, EMPTY_VALUE);
        }
      double maOpen  = iCustomMa(inpMaMetod, open[i], inpMaPeriod, i, rates_total, 0);
      double maClose = iCustomMa(inpMaMetod, close[i], inpMaPeriod, i, rates_total, 1);
      double maLow   = iCustomMa(inpMaMetod, low[i], inpMaPeriod, i, rates_total, 2);
      double maHigh  = iCustomMa(inpMaMetod, high[i], inpMaPeriod, i, rates_total, 3);
      double haClose = (inpBetterFormula) ? (maHigh != maLow) ? (maOpen + maClose) / 2 + (((maClose - maOpen) / (maHigh - maLow)) * MathAbs((maClose - maOpen) / 2)) : (maOpen + maClose) / 2 : (maOpen + maHigh + maLow + maClose) / 4;
      double haOpen  = (i > 0 && ha_open_buffer[i - 1] != EMPTY_VALUE && ha_close_buffer[i - 1] != EMPTY_VALUE) ? (ha_open_buffer[i - 1] + ha_close_buffer[i - 1]) / 2 : open[i];
      double haHigh  = MathMax(maHigh, MathMax(haOpen, haClose));
      double haLow   = MathMin(maLow,  MathMin(haOpen, haClose));
      ha_open_buffer[i] = haOpen;
      ha_close_buffer[i] = haClose;
      if(haOpen > haClose)
         buf_color[i] = 2;
      else
         if(haOpen < haClose)
            buf_color[i] = 1;
         else
            buf_color[i] = (i > 0) ? buf_color[i - 1] : 0;
      buf_low[i] = haLow;
      buf_high[i] = haHigh;
      buf_open[i] = haOpen;
      buf_close[i] = haClose;
      if(i > 0 && inpStep > 0)
        {
         if(MathAbs(buf_high[i] - buf_high[i - 1]) < inpStep * _pointModifier * _Point)
            buf_high[i] = buf_high[i - 1];
         if(MathAbs(buf_low[i] - buf_low[i - 1]) < inpStep * _pointModifier * _Point)
            buf_low[i] = buf_low[i - 1];
         if(MathAbs(buf_open[i] - buf_open[i - 1]) < inpStep * _pointModifier * _Point)
            buf_open[i] = buf_open[i - 1];
         if(MathAbs(buf_close[i] - buf_close[i - 1]) < inpStep * _pointModifier * _Point)
            buf_close[i] = buf_close[i - 1];
        }
      if(inpCandleType == price)
        {
         buf_open[i]  = open[i];
         buf_high[i]  = high[i];
         buf_low[i]   = low[i];
         buf_close[i] = close[i];
        }
     }
   return (rates_total);
  }

#define _maInstances 4
#define _maWorkBufferx1 1*_maInstances

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo = 0)
  {
   switch(mode)
     {
      case ma_sma   :
         return(iSma(price, (int)length, r, bars, instanceNo));
      case ma_ema   :
         return(iEma(price, length, r, bars, instanceNo));
      case ma_smma  :
         return(iSmma(price, (int)length, r, bars, instanceNo));
      case ma_lwma  :
         return(iLwma(price, (int)length, r, bars, instanceNo));
      default       :
         return(price);
     }
  }

double workSma[][_maWorkBufferx1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSma(double price, int period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workSma, 0) != _bars)
      ArrayResize(workSma, _bars);
   workSma[r][instanceNo] = price;
   double avg = price;
   int k = 1;
   for(; k < period && (r - k) >= 0; k++)
      avg += workSma[r - k][instanceNo];
   avg /= (double)k;
   return(avg);
  }

double workEma[][_maWorkBufferx1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iEma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workEma, 0) != _bars)
      ArrayResize(workEma, _bars);
   workEma[r][instanceNo] = price;
   if(r > 0 && period > 1)
      workEma[r][instanceNo] = workEma[r - 1][instanceNo] + (2.0 / (1.0 + period)) * (price - workEma[r - 1][instanceNo]);
   return(workEma[r][instanceNo]);
  }

double workSmma[][_maWorkBufferx1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iSmma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workSmma, 0) != _bars)
      ArrayResize(workSmma, _bars);
   workSmma[r][instanceNo] = price;
   if(r > 1 && period > 1)
      workSmma[r][instanceNo] = workSmma[r - 1][instanceNo] + (price - workSmma[r - 1][instanceNo]) / period;
   return(workSmma[r][instanceNo]);
  }

double workLwma[][_maWorkBufferx1];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double iLwma(double price, double period, int r, int _bars, int instanceNo = 0)
  {
   if(ArrayRange(workLwma, 0) != _bars)
      ArrayResize(workLwma, _bars);
   workLwma[r][instanceNo] = price;
   if(period < 1)
      return(price);
   double sumw = period;
   double sum  = period * price;
   for(int k = 1; k < period && (r - k) >= 0; k++)
     {
      double weight = period - k;
      sumw  += weight;
      sum   += weight * workLwma[r - k][instanceNo];
     }
   return(sum / sumw);
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=149916#p149916

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+