// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70886

//+------------------------------------------------------------------+
//|                               Copyright © 2021, Gehtsoft USA LLC |
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

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1  clrYellow
#property indicator_color2  clrDeepPink
#property indicator_color3  clrDeepPink
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
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

input int                inpPeriod           = 14;          // Ama period
input int                inpFastPeriod       = 2;           // Ama fast end period
input int                inpSlowPeriod       = 30;          // Ama slow end period
input double             inpPower            = 2;           // Ama smooth power
input int                inpFilter           = 50;          // Filter
input int                inpFilterPeriod     = 4;           // Filter period
input double             inpFilterDifference = 50;          // Filter difference
input enPrices           inpPrice            = pr_close;    // Ama price
input bool               alertsOn            = false;        // Alerts on true/false?
input bool               alertsOnCurrent     = false;       // Alerts on current bar true/false?
input bool               alertsMessage       = false;        // Alerts pop-up message true/false?
input bool               alertsSound         = true;       // Alerts sound true/false?
input bool               alertsNotify        = false;       // Alerts push notification true/false?
input bool               alertsEmail         = false;       // Alerts email true/false?
input string             soundFile           = "alert2.wav";// Sound file

double val[],valc[],ama[],valDa[],valDb[];

//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
//
//

int OnInit()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,val,  INDICATOR_DATA);
   SetIndexBuffer(1,valDa,INDICATOR_DATA);
   SetIndexBuffer(2,valDb,INDICATOR_DATA);
   SetIndexBuffer(3,ama,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,valc, INDICATOR_CALCULATIONS);

   IndicatorShortName("KAMA with filter ("+(string)inpPeriod+")");
return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason){  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
   int i,counted_bars=prev_calculated;
       if(counted_bars<0) return(-1);
       if(counted_bars>0) counted_bars--;
          int limit = fmin(rates_total-counted_bars,rates_total-1); 
   
   //
   //
   //
   //
   //
   
   if (valc[limit]==-1) CleanPoint(limit,valDa,valDb);
   for(i=limit; i>=0; i--) 
   {
      ama[i] = iKama(getPrice(inpPrice,open,close,high,low,i,rates_total),inpPeriod,inpFastPeriod,inpSlowPeriod,inpPower,i,open,close,high,low,rates_total);
      val[i] = ama[i];
      
      //
      //
      //
      //
      //
      
      if(inpFilter>0)
      {
        double sAmaDiff    = 0; for(int k=0; k<inpSlowPeriod && (i+k+1)<rates_total; k++) sAmaDiff += fabs(ama[i+k]-ama[i+k+1]);
        double cAmaDiff    = (i<rates_total-1) ? ama[i]-ama[i+1] : 0;
        double aAmaDiff    = fabs(cAmaDiff);
        double filterValue = NormalizeDouble(inpFilter*sAmaDiff/(100.0*inpSlowPeriod),_Digits);

         if(cAmaDiff>0)
            if(cAmaDiff<filterValue && high[i]<=(high[ArrayMaximum(high,inpFilterPeriod,i)]+inpFilterDifference*_Point))
               val[i] = (i<rates_total-1) ? val[i+1]: ama[i];
         if(cAmaDiff<0)
            if(aAmaDiff<filterValue &&  low[i]>= (low[ArrayMinimum( low,inpFilterPeriod,i)]-inpFilterDifference*_Point))
               val[i] = (i<rates_total-1) ? val[i+1]: ama[i];
        }
        valDa[i] = EMPTY_VALUE;
        valDb[i] = EMPTY_VALUE;
        valc[i]=(i<rates_total-1) ?(val[i]>val[i+1]) ? 1 :(val[i]<val[i+1]) ? -1 : valc[i+1]: 0;
        if (valc[i]==-1) PlotPoint(i,valDa,valDb,val);
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      if (valc[whichBar] != valc[whichBar+1])
      {
        if (valc[whichBar] ==  1) doAlert(whichBar," sloping up");
        if (valc[whichBar] == -1) doAlert(whichBar," sloping down");
      }
   }
return(rates_total);
}

//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
//
//

#define amaInstances     1
#define amaInstancesSize 3
double workAma[][amaInstances*amaInstancesSize];
#define _diff  0
#define _kama  1
#define _price 2

//
//
//
//
//

double iKama(double price,int period,double fast,double slow,double power,int i,const double &open[],const double &close[],const double &high[],const double &low[],int bars,int iNo=0)
{
   if(ArrayRange(workAma,0)!=bars) ArrayResize(workAma,bars);  int r = Bars-i-1; iNo*=amaInstancesSize;
   double fastend = (2.0 /(fast + 1));
   double slowend = (2.0 /(slow + 1));
   
   //
   //
   //
   //
   //
   
   double efratio= 1; workAma[r][iNo+_price]=price;
   double signal = (r>=period) ? fabs(price-workAma[r-period][iNo+_price]) : 0;
   double noise  = 0;
   workAma[r][iNo+_diff] = (r>0) ? fabs(price-workAma[r-1][iNo+_price]) : 0;
   for(int k=0; k<period && r-k>=0; k++) noise+=workAma[r-k][iNo+_diff];
      
   //
   //
   //
   //
   //
   
   if(noise!=0)
        efratio = signal/noise;
   else efratio = 1;
   
   double smooth = pow(efratio*(fastend-slowend)+slowend,power);
   workAma[r][iNo+_kama] = (r>0) ? workAma[r-1][iNo+_kama]+smooth*(price-workAma[r-1][iNo+_kama]) : price;
return(workAma[r][iNo+_kama]);
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
      if (ArrayRange(workHa,0)!= bars) ArrayResize(workHa,bars); instanceNo*=_priceInstancesSize; int r = bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*fabs((close[i]-open[i])/2.0));
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

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //
       
       message = timeFrameToString(_Period)+" "+Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Kaufman "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Kaufman ",message);
          if (alertsSound)   PlaySound(soundFile);
       
   }
}
