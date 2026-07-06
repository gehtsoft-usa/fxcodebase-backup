//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76171

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
#property indicator_plots 4
#property indicator_buffers 5
#property indicator_color1 clrLime   // Up color
#property indicator_color2 clrRed    // Down color
#property indicator_color3 clrLime   // Up arrow color
#property indicator_color4 clrRed    // Down arrow color
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

extern int SmoothingPeriod = 2;   // smoothing period for reflected value
extern int UpArrowCode = 233;     // Wingdings code for up arrow
extern int DownArrowCode = 234;   // Wingdings code for down arrow
extern int ArrowOffsetPoints = 20; // Offset in points for arrow placement
extern int barsLimit = 1000;      // Limit for bars to process

double RefUpBuffer[], RefDownBuffer[];
double UpArrowBuffer[], DownArrowBuffer[];
double TrendBuffer[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateWMA(const double &priceArray[], int total, int index, int length)
  {
   if(length <= 1 || index + length > total)
      return(priceArray[index]);
   double sum = 0.0, wsum = 0.0;
   for(int j = 0; j < length; j++)
     {
      double p = priceArray[index + j];
      int weight = (length - j);
      sum   += p * weight;
      wsum  += weight;
     }
   return(sum / wsum);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateHMA(const double &priceArray[], int total, int index, int length)
  {
   int half = length / 2;
   double wmaHalf = CalculateWMA(priceArray, total, index, half);
   double wmaFull = CalculateWMA(priceArray, total, index, length);
   int sqrtn = int(MathSqrt(length));
   if(sqrtn < 1)
      sqrtn = 1;
   double sum = 0.0, wsum = 0.0;
   for(int k = 0; k < sqrtn; k++)
     {
      double wh = CalculateWMA(priceArray, total, index + k, half);
      double wf = CalculateWMA(priceArray, total, index + k, length);
      double d = (2.0 * wh - wf);
      int weight = (sqrtn - k);
      sum  += d * weight;
      wsum += weight;
     }
   return(sum / wsum);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(5);
   SetIndexBuffer(0, RefUpBuffer);
   SetIndexStyle(0, DRAW_LINE, STYLE_SOLID, 2, clrLime);
   SetIndexLabel(0, "Reflected EMA Up");
   SetIndexBuffer(1, RefDownBuffer);
   SetIndexStyle(1, DRAW_LINE, STYLE_SOLID, 2, clrRed);
   SetIndexLabel(1, "Reflected EMA Down");
//
   SetIndexBuffer(2, UpArrowBuffer);
   SetIndexStyle(2, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(2, UpArrowCode);
   SetIndexLabel(2, "Up Arrow");
   SetIndexBuffer(3, DownArrowBuffer);
   SetIndexStyle(3, DRAW_ARROW, STYLE_SOLID, 2);
   SetIndexArrow(3, DownArrowCode);
   SetIndexLabel(3, "Down Arrow");
//
   SetIndexBuffer(4, TrendBuffer);
   SetIndexStyle(4, DRAW_LINE, STYLE_DASH, 0, clrNONE);
   SetIndexLabel(4, "Trend Buffer");
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
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
   int i, limit = MathMin(rates_total, barsLimit);
   for(i = 0; i < limit; i++)
     {
      UpArrowBuffer[i] = EMPTY_VALUE;
      DownArrowBuffer[i] = EMPTY_VALUE;
      TrendBuffer[i] = 0.0;
      double hmaShort = CalculateHMA(close, rates_total, i, 36);
      double hmaLong = CalculateHMA(close, rates_total, i, 44);
      double diff = fabs(hmaShort - hmaLong);
      double reflected = hmaShort + ((hmaShort > hmaLong) ? diff : -diff);
      static double refArr[];
      if(ArraySize(refArr) != rates_total)
         ArrayResize(refArr, rates_total);
      refArr[i] = reflected;
      double hmaSmooth = CalculateHMA(refArr, rates_total, i, SmoothingPeriod);
      if(reflected > hmaSmooth)
        {
         RefUpBuffer[i] = reflected;
         RefDownBuffer[i] = reflected;
        }
      else
        {
         RefUpBuffer[i] = reflected;
         RefDownBuffer[i] = EMPTY_VALUE;
        }
      if(i >= 0)
        {
         double ref0 = RefUpBuffer[i];
         double ref1 = RefUpBuffer[i + 1];
         double ref2 = RefUpBuffer[i + 2];
         if(ref0 > ref1 && ref1 <= ref2)
           {
            UpArrowBuffer[i] = low[i] - ArrowOffsetPoints * Point();
           }
         else
            if(ref0 < ref1 && ref1 >= ref2)
              {
               DownArrowBuffer[i] = high[i] + ArrowOffsetPoints * Point();
               TrendBuffer[i] = -1.0;
              }
        }
     }
   for(i = 0; i < limit; i++)
     {
      if(UpArrowBuffer[i] != EMPTY_VALUE && UpArrowBuffer[i] > 0)
         TrendBuffer[i] = 1.0;
      if(DownArrowBuffer[i] != EMPTY_VALUE && DownArrowBuffer[i] > 0)
         TrendBuffer[i] = -1.0;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=76171

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