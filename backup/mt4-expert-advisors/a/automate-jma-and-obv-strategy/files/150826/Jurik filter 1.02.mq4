// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=73717

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrOrange
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
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};
enum enDisplay
{
   en_lin,  // Display line
   en_lid,  // Display lines with dots
   en_dot   // Display dots
};
enum enFilterType
{
   flt_val, // Apply filter to jurik value
   flt_prc, // Apply filter to price
   flt_all  // Apply filter to all
};

extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT;   // Time frame
extern int                Length          = 34;               // Jurik and filter period to use
extern double             Phase           = 3.0;              // Jurik phase 
extern bool               Double          = false;            // Jurik smooth double
extern enPrices           Price           = pr_haweighted;    // Price to use
extern double             Filter          = 0;                // Filter to use for filtering (<=0 for no filtering)
extern enFilterType       FilterType      = flt_all;          // Filter should be applied to :
extern enDisplay          DisplayType     = en_lin;           // Display type
extern int                LinesWidth      = 3;                // Lines width (when lines are included in display)
extern bool               ArrowOnFirst    = true;             // Arrow on first bars
extern int                UpArrowSize     = 2;                // Up Arrow size
extern int                DnArrowSize     = 2;                // Down Arrow size
extern int                UpArrowCode     = 159;              // Up Arrow code
extern int                DnArrowCode     = 159;              // Down arrow code
extern double             UpArrowGap      = 0.5;              // Up Arrow gap        
extern double             DnArrowGap      = 0.5;              // Dn Arrow gap
extern color              UpArrowColor    = clrLime;          // Up Arrow Color
extern color              DnArrowColor    = clrRed;           // Down Arrow Color
extern int                Shift           = 0;                // JMA shift
extern bool               Interpolate     = true;             // Interpolate in multi time frame mode?

//
//
//
//

double jur[],jurDa[],jurDb[],arrowu[],arrowd[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,Length,Phase,Double,Price,Filter,FilterType,DisplayType,LinesWidth,ArrowOnFirst,UpArrowSize,DnArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,DnArrowGap,UpArrowColor,DnArrowColor,0,_buff,_ind)

//+------------------------------------------------------------------
//|                                                                 |
//+------------------------------------------------------------------
//
//

int init()
{
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   IndicatorBuffers(7);
   int lstyle = DRAW_LINE;     if (DisplayType==en_dot) lstyle = DRAW_NONE;
   int astyle = DRAW_ARROW;    if (DisplayType<en_lid)  astyle = DRAW_NONE;
   SetIndexBuffer(0, jur);     SetIndexStyle(0,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(1, jurDa);   SetIndexStyle(1,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(2, jurDb);   SetIndexStyle(2,lstyle,EMPTY,LinesWidth);
   SetIndexBuffer(3, arrowu);  SetIndexStyle(3,astyle,0,UpArrowSize,UpArrowColor); SetIndexArrow(3,UpArrowCode);
   SetIndexBuffer(4, arrowd);  SetIndexStyle(4,astyle,0,DnArrowSize,DnArrowColor); SetIndexArrow(4,DnArrowCode);
   SetIndexBuffer(5, trend);
   SetIndexBuffer(6, count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
   for (int i=0; i<7; i++) SetIndexShift(i,Shift*TimeFrame/Period());
   IndicatorShortName(timeFrameToString(TimeFrame)+" JMA("+(string)Length+")");
return(0);
}
int deinit() { return(0); }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         if (TimeFrame != _Period)
         {
            limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(6,0)*TimeFrame/_Period));
            if (trend[limit]==-1) CleanPoint(limit,jurDa,jurDb);
            for (i=limit;i>=0 && !_StopFlag; i--)
            {
                int y = iBarShift(NULL,TimeFrame,Time[i]);
                int x = y;
                if (ArrowOnFirst)
                      {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
                else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
                     jur[i]    = _mtfCall(0,y);
   	               jurDa[i]  = EMPTY_VALUE;
                     jurDb[i]  = EMPTY_VALUE;
                     arrowu[i] = EMPTY_VALUE;
                     arrowd[i] = EMPTY_VALUE;
                     trend[i]  = _mtfCall(5,y);
                     if (x!=y)
                     {
                       arrowu[i] = _mtfCall(3,y);
                       arrowd[i] = _mtfCall(4,y);
                     }
                     
                     //
                     //
                     //
                     //
                     //
                     
                      if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                      #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                      int n,k; datetime time = iTime(NULL,TimeFrame,y);
                         for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                         for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) _interpolate(jur);
                      
                         
            }
            for(i=limit; i>=0; i--)  if (trend[i]==-1) PlotPoint(i,jurDa,jurDb,jur);    
     return(0);
     }
     
     //
     //
     //
     //
     //

     if (trend[limit]==-1) CleanPoint(limit,jurDa,jurDb);
     double pfilter = Filter; if (FilterType==flt_val) pfilter=0;
     double vfilter = Filter; if (FilterType==flt_prc) vfilter=0;
     for(i=limit; i>=0; i--)
     {
        double price = iFilter(getPrice(Price,Open,Close,High,Low,i,Bars),pfilter,Length,i,Bars,0);
        jur[i] = iFilter(iDSmooth(price,Length,Phase,Double,i),vfilter,Length,i,Bars,1);
        jurDa[i]  = EMPTY_VALUE;
        jurDb[i]  = EMPTY_VALUE;
        arrowu[i] = EMPTY_VALUE;
        arrowd[i] = EMPTY_VALUE;
        trend[i] = (i<Bars-1) ? (jur[i]>jur[i+1]) ? 1 : (jur[i]<jur[i+1]) ? -1 : trend[i+1] : 0;  
        if (trend[i]==-1) PlotPoint(i,jurDa,jurDb,jur);
        if (i<Bars-1 && trend[i]!=trend[i+1])
        {
           if (trend[i] ==  1) arrowu[i] = fmin(jur[i],Low[i] )-iATR(NULL,0,15,i)*UpArrowGap;
           if (trend[i] == -1) arrowd[i] = fmax(jur[i],High[i])+iATR(NULL,0,15,i)*DnArrowGap;
        } 
   }
return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

double wrk[][20];

#define bsmax  5
#define bsmin  6
#define volty  7
#define vsum   8
#define avolty 9

double iDSmooth(double price, double length, double phase, bool isDouble, int i, int s=0) 
{
   if (isDouble)
         return (iSmooth(iSmooth(price,MathSqrt(length),phase,i,s),MathSqrt(length),phase,i,s+10));
   else  return (iSmooth(price,length,phase,i,s));
}

//
//
//
//
//

double iSmooth(double price, double length, double phase, int i, int s=0)
{
   if (length <=1) return(price);
   if (ArrayRange(wrk,0) != Bars) ArrayResize(wrk,Bars);
   
   int r = Bars-i-1; 
      if (r==0) { int k; for(k=0; k<7; k++) wrk[r][k+s]=price; for(; k<10; k++) wrk[r][k+s]=0; return(price); }

   //
   //
   //
   //
   //
   
      double len1   = MathMax(MathLog(MathSqrt(0.5*(length-1)))/MathLog(2.0)+2.0,0);
      double pow1   = MathMax(len1-2.0,0.5);
      double del1   = price - wrk[r-1][bsmax+s];
      double del2   = price - wrk[r-1][bsmin+s];
      double div    = 1.0/(10.0+10.0*(MathMin(MathMax(length-10,0),100))/100);
      int    forBar = MathMin(r,10);
	
         wrk[r][volty+s] = 0;
               if(MathAbs(del1) > MathAbs(del2)) wrk[r][volty+s] = MathAbs(del1); 
               if(MathAbs(del1) < MathAbs(del2)) wrk[r][volty+s] = MathAbs(del2); 
         wrk[r][vsum+s] =	wrk[r-1][vsum+s] + (wrk[r][volty+s]-wrk[r-forBar][volty+s])*div;
         
         //
         //
         //
         //
         //
   
         wrk[r][avolty+s] = wrk[r-1][avolty+s]+(2.0/(MathMax(4.0*length,30)+1.0))*(wrk[r][vsum+s]-wrk[r-1][avolty+s]);
            double dVolty = 0;
            if (wrk[r][avolty+s] > 0)
                  dVolty = wrk[r][volty+s]/wrk[r][avolty+s];   
	               if (dVolty > MathPow(len1,1.0/pow1)) dVolty = MathPow(len1,1.0/pow1);
                  if (dVolty < 1)                      dVolty = 1.0;

      //
      //
      //
      //
      //
	        
   	double pow2 = MathPow(dVolty, pow1);
      double len2 = MathSqrt(0.5*(length-1))*len1;
      double Kv   = MathPow(len2/(len2+1), MathSqrt(pow2));

         if (del1 > 0) wrk[r][bsmax+s] = price; else wrk[r][bsmax+s] = price - Kv*del1;
         if (del2 < 0) wrk[r][bsmin+s] = price; else wrk[r][bsmin+s] = price - Kv*del2;
	
   //
   //
   //
   //
   //
      
      double R     = MathMax(MathMin(phase,100),-100)/100.0 + 1.5;
      double beta  = 0.45*(length-1)/(0.45*(length-1)+2);
      double alpha = MathPow(beta,pow2);

         wrk[r][0+s] = price + alpha*(wrk[r-1][0+s]-price);
         wrk[r][1+s] = (price - wrk[r][0+s])*(1-beta) + beta*wrk[r-1][1+s];
         wrk[r][2+s] = (wrk[r][0+s] + R*wrk[r][1+s]);
         wrk[r][3+s] = (wrk[r][2+s] - wrk[r-1][4+s])*MathPow((1-alpha),2) + MathPow(alpha,2)*wrk[r-1][3+s];
         wrk[r][4+s] = (wrk[r-1][4+s] + wrk[r][3+s]); 

   //
   //
   //
   //
   //

   return(wrk[r][4+s]);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

#define _filterInstances     2
#define _filterInstancesSize 3
double workFil[][_filterInstances*_filterInstancesSize];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int bars, int instanceNo=0)
{
   if (filter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= bars) ArrayResize(workFil,bars); i = #ifdef __MQL4__ bars-i-1 #else i #endif; instanceNo*=_filterInstancesSize;
   
   //
   //
   //
   //
   //
   
   workFil[i][instanceNo+_fprice]  = tprice; if (i<1) return(tprice);
   workFil[i][instanceNo+_fchange] = MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]);
   workFil[i][instanceNo+_fachang] = workFil[i][instanceNo+_fchange];

   for (int k=1; k<period && (i-k)>=0; k++) workFil[i][instanceNo+_fachang] += workFil[i-k][instanceNo+_fchange];
                                            workFil[i][instanceNo+_fachang] /= period;
    
   double stddev = 0; for (int k=0;  k<period && (i-k)>=0; k++) stddev += MathPow(workFil[i-k][instanceNo+_fchange]-workFil[i-k][instanceNo+_fachang],2);
          stddev = MathSqrt(stddev/(double)period); 
   double filtev = filter * stddev;
   if( MathAbs(workFil[i][instanceNo+_fprice]-workFil[i-1][instanceNo+_fprice]) < filtev ) workFil[i][instanceNo+_fprice]=workFil[i-1][instanceNo+_fprice];
        return(workFil[i][instanceNo+_fprice]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int bars, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
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

//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}


//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+