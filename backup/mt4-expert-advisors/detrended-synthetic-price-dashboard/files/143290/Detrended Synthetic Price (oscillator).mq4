// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71434

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
#property version   "1.0"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1  clrDimGray
#property indicator_color2  clrDimGray
#property indicator_color3  clrDarkGray
#property indicator_color4  clrLimeGreen
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrOrangeRed
#property indicator_color7  clrOrangeRed
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  3
#property indicator_width7  3
#property strict

//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};
enum enColorOn
{
   chg_onZero,   // Change color on zero cross
   chg_onOuter,  // Change color on levels cross
   chg_onOuter2, // Change color on opposite levels cross
   chg_onSlope   // Change color on slope change
};
input  int             DspPeriod    = 14;          // DSP period
input  enPrices        Price        = pr_median;   // DSP price
extern int             SignalPeriod = 9;           // Signal period
input  enColorOn       ColorOn      = chg_onOuter; // Change color on :

double val[],valua[],valub[],valda[],valdb[],levelu[],leveld[],state[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnInit()
{
   IndicatorBuffers(8);
      SetIndexBuffer( 0, levelu);
      SetIndexBuffer( 1, leveld);
      SetIndexBuffer( 2, val); 
      SetIndexBuffer( 3, valua); 
      SetIndexBuffer( 4, valub); 
      SetIndexBuffer( 5, valda); 
      SetIndexBuffer( 6, valdb); 
      SetIndexBuffer( 7, state); 
   IndicatorShortName("DSP oscillator ("+(string)DspPeriod+")");
   return(0);
}
void OnDeinit(const int reason) { }
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double   &open[],
                const double   &high[],
                const double   &low[],
                const double   &close[],
                const long     &tick_volume[],
                const long     &volume[],
                const int      &spread[])
{
   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
         int limit=MathMin(rates_total-counted_bars,rates_total-1);
         
   //
   //
   //
   //
   //

   double alphas = 2.0/(1.0+SignalPeriod);
   double alpham = 2.0/(1.0+DspPeriod);
   if (state[limit]== 1) CleanPoint(limit,valua,valub);
   if (state[limit]==-1) CleanPoint(limit,valda,valdb);
   for(int i=limit; i>=0 && !_StopFlag; i--)
   {
      double price = getPrice(Price,open,close,high,low,i,rates_total);
         val[i]    = iEma(price,alpham,i,rates_total,0)-iEma(price,alpham/2.0,i,rates_total,1);
         levelu[i] = (i<Bars-1) ? (val[i]>0) ? levelu[i+1]+alphas*(val[i]-levelu[i+1]) : levelu[i+1] : 0;
         leveld[i] = (i<Bars-1) ? (val[i]<0) ? leveld[i+1]+alphas*(val[i]-leveld[i+1]) : leveld[i+1] : 0;
                switch(ColorOn)
                {
                  case chg_onOuter  : state[i] = (val[i]>levelu[i]) ? 1 : (val[i]<leveld[i]) ? -1 : 0;                                 break;
                  case chg_onOuter2 : state[i] = (val[i]>levelu[i]) ? 1 : (val[i]<leveld[i]) ? -1 : (i<rates_total-1) ? state[i+1]: 0; break;
                  case chg_onZero   : state[i] = (val[i]>0)         ? 1 : (val[i]<0)         ? -1 : 0;                                 break;
                  default :           state[i] = (i<rates_total-1) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : state[i+1] : 0;
                }
                valda[i] = EMPTY_VALUE;
                valdb[i] = EMPTY_VALUE;
                valua[i] = EMPTY_VALUE;
                valub[i] = EMPTY_VALUE;
         if (state[i] ==  1) PlotPoint(i,valua,valub,val);
         if (state[i] == -1) PlotPoint(i,valda,valdb,val);
   }
   return(rates_total);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

double workEma[][2];
double iEma(double price, double alpha, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars); r=_bars-r-1;

   workEma[r][instanceNo] = price;
   if (r>0)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+alpha*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize;
         int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen;
         if (r>0)
                haOpen  = (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0;
         else   haOpen  = (open[i]+close[i])/2;
         double haClose = (open[i] + high[i] + low[i] + close[i]) / 4.0;
         double haHigh  = MathMax(high[i], MathMax(haOpen,haClose));
         double haLow   = MathMin(low[i] , MathMin(haOpen,haClose));

         if(haOpen  <haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else                 { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                                workHa[r][instanceNo+2] = haOpen;
                                workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:     return(haClose);
            case pr_haopen:      return(haOpen);
            case pr_hahigh:      return(haHigh);
            case pr_halow:       return(haLow);
            case pr_hamedian:    return((haHigh+haLow)/2.0);
            case pr_hamedianb:   return((haOpen+haClose)/2.0);
            case pr_hatypical:   return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:  return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:   return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}   