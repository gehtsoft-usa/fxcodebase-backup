#property indicator_chart_window
#property indicator_buffers 10
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrSandyBrown
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrSandyBrown
#property indicator_color5  clrDeepSkyBlue
#property indicator_color6  clrSandyBrown
#property indicator_color7  clrSandyBrown
#property indicator_color8  clrDeepSkyBlue
#property indicator_color9  clrSandyBrown
#property indicator_color10 clrSandyBrown
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
#define _disSar 0x001
#define _disBar 0x010
#define _disAma 0x100
enum enDisplayType
{
   _dis01=_disSar,                 // Display SAR value
   _dis02=_disAma,                 // Display Kaufman AMA value
   _dis03=_disBar,                 // Display colored bars
   _dis04=_disSar+_disAma,         // Display SAR and Kaufman AMA
   _dis05=_disSar+_disBar,         // Display SAR and colored bars
   _dis06=_disAma+_disBar,         // Display Kaufman AMA and colored bars
   _dis07=_disAma+_disSar+_disBar  // Display all
};
enum enFilterOn
{
   flt_val, // Filter the Kaufman AMA value
   flt_prc, // Filter the price prior to usage
   flt_both // Filter the Kaufman AMA and the price
};

extern ENUM_TIMEFRAMES TimeFrame = PERIOD_CURRENT; // Time frame to use
extern double     AccStep         = 0.02;      // Accumulation step
extern double     AccLimit        = 0.2;       // Accumulation limit
extern int        AmaPeriod       = 10;        // Kaufman AMA period
extern enPrices   AmaPriceH       = pr_close;  // Price to be used by Kaufman AMA high
extern enPrices   AmaPriceL       = pr_close;  // Price to be used by Kaufman AMA low
extern double     FastEnd         = 2;         // Kaufman AMA fast end
extern double     SlowEnd         = 30;        // Kaufman AMA slow end
extern double     SmoothPower     = 2;         // Smooth power
extern bool       JurikFDAdaptive = true;      // Should the Kaufman AMA be Jurik fractal dimension adaptive?
extern double     JurikCount      = 2.0;       // Jurik fractal dimension window size
extern double     Filter          = 0;         // Filter
extern enFilterOn FilterOn        = flt_prc;   // Filter on : 
extern bool       alertsOn        = false;     // Turn alerts on?
extern bool       alertsOnCurrent = true;      // Alerts on current (still opened) bar?
extern bool       alertsMessage   = true;      // Alerts should display alert message?
extern bool       alertsSound     = true;      // Alerts should play alert sound?
extern bool       alertsEmail     = false;     // Alerts should send alert email?
extern bool       alertsPushNotif = false;     // Alerts should send notification?
extern enDisplayType DisplayType  = _disSar;   // What should be displayed?
extern int        LineWidth       = 2;         // Lines width
extern int        ArrowsWidth     = 0;         // Arrows (dots) width
extern bool       Interpolate     = true;      // Interpolate in multi time frame mode?

double sarUp[],histoup[];
double sarDn[],histodn[];
double ama[],amada[],amadb[];
double amb[],ambda[],ambdb[],trend[];
string indicatorFileName;
bool   returnBars;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(11);
      int atype = ((DisplayType&_disAma)==0) ? DRAW_NONE : DRAW_LINE;
      int stype = ((DisplayType&_disSar)==0) ? DRAW_NONE : DRAW_ARROW;
      int htype = ((DisplayType&_disBar)==0) ? DRAW_NONE : DRAW_HISTOGRAM;
         SetIndexBuffer(0,histoup); SetIndexStyle(0,htype);
         SetIndexBuffer(1,histodn); SetIndexStyle(1,htype);
         SetIndexBuffer(2,sarUp);   SetIndexStyle(2,stype,EMPTY,ArrowsWidth); SetIndexArrow(2,159);
         SetIndexBuffer(3,sarDn);   SetIndexStyle(3,stype,EMPTY,ArrowsWidth); SetIndexArrow(3,159);
         SetIndexBuffer(4,ama);     SetIndexStyle(4,atype,EMPTY,LineWidth);
         SetIndexBuffer(5,amada);   SetIndexStyle(5,atype,EMPTY,LineWidth);
         SetIndexBuffer(6,amadb);   SetIndexStyle(6,atype,EMPTY,LineWidth);
         SetIndexBuffer(7,amb);     SetIndexStyle(7,atype,EMPTY,LineWidth);
         SetIndexBuffer(8,ambda);   SetIndexStyle(8,atype,EMPTY,LineWidth);
         SetIndexBuffer(9,ambdb);   SetIndexStyle(9,atype,EMPTY,LineWidth);
         SetIndexBuffer(10,trend);
      indicatorFileName = WindowExpertName();
      returnBars        = TimeFrame==-99;
      TimeFrame         = MathMax(TimeFrame,_Period);
   return(0);
}
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sarUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
    
   if (TimeFrame == Period())
   { 
      if (sarDn[limit]!=EMPTY_VALUE) { CleanPoint(limit,amada,amadb); CleanPoint(limit,ambda,ambdb); }
      for(int i = limit; i >= 0; i--)
      {
         double sarClose;
         double sarOpen;
         double sarPosition;
         double sarChange;
         amada[i] = EMPTY_VALUE;
         amadb[i] = EMPTY_VALUE;
         ambda[i] = EMPTY_VALUE;
         ambdb[i] = EMPTY_VALUE;
            double pfilter = Filter; if (FilterOn==flt_val) pfilter=0;            
            double vfilter = Filter; if (FilterOn==flt_prc) vfilter=0;            
            double priceh = iFilter(getPrice(AmaPriceH,Open,Close,High,Low,i,0),pfilter,AmaPeriod,i,0);
            double pricel = iFilter(getPrice(AmaPriceL,Open,Close,High,Low,i,1),pfilter,AmaPeriod,i,1);
               ama[i] = iFilter(iKama(MathMax(priceh,pricel),AmaPeriod,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,i,0),vfilter,AmaPeriod,i,2);
               amb[i] = iFilter(iKama(MathMin(priceh,pricel),AmaPeriod,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,i,1),vfilter,AmaPeriod,i,3);
            iParabolic(ama[i],amb[i],AccStep,AccLimit,sarClose,sarOpen,sarPosition,sarChange,i);
            sarUp[i]   = EMPTY_VALUE;
            sarDn[i]   = EMPTY_VALUE;
            if (sarPosition==1)
                  { sarUp[i] = sarClose; trend[i] =  1; histoup[i] = High[i]; histodn[i] = Low[i]; }
            else  { sarDn[i] = sarClose; trend[i] = -1; histodn[i] = High[i]; histoup[i] = Low[i]; }
            if (sarDn[i] != EMPTY_VALUE) { PlotPoint(i,amada,amadb,ama); PlotPoint(i,ambda,ambdb,amb); }
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = (int)MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   if (sarDn[limit]!=EMPTY_VALUE)  { CleanPoint(limit,amada,amadb); CleanPoint(limit,ambda,ambdb); }
   for (int i=limit;i>=0;i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         sarUp[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,AmaPeriod,AmaPriceH,AmaPriceL,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,Filter,FilterOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif, 2,y); 
         sarDn[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,AmaPeriod,AmaPriceH,AmaPriceL,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,Filter,FilterOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif, 3,y); 
         ama[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,AmaPeriod,AmaPriceH,AmaPriceL,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,Filter,FilterOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif, 4,y); 
         amb[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,AmaPeriod,AmaPriceH,AmaPriceL,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,Filter,FilterOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif, 7,y); 
         trend[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,AmaPeriod,AmaPriceH,AmaPriceL,FastEnd,SlowEnd,SmoothPower,JurikFDAdaptive,JurikCount,Filter,FilterOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPushNotif,10,y); 
         amada[i] = EMPTY_VALUE;
         amadb[i] = EMPTY_VALUE;
         ambda[i] = EMPTY_VALUE;
         ambdb[i] = EMPTY_VALUE;
            if (trend[i]== 1) { histoup[i] = High[i]; histodn[i] = Low[i]; }
            if (trend[i]==-1) { histodn[i] = High[i]; histoup[i] = Low[i]; }
         
         //
         //
         //
         //
         //
      
         if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
         //
         //
         //
         //
         //
                  
         int n,j; datetime time = iTime(NULL,TimeFrame,y);
            for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
            for(j = 1; j<n && (i+n)<Bars && (i+j)<Bars; j++)
            {
               ama[i+j] = ama[i] + (ama[i+n]-ama[i])*j/n;
               amb[i+j] = amb[i] + (amb[i+n]-amb[i])*j/n;
               if (sarUp[i+n]!=EMPTY_VALUE && sarUp[i]!= EMPTY_VALUE) sarUp[i+j] = sarUp[i] + (sarUp[i+n]-sarUp[i])*j/n;
               if (sarDn[i+n]!=EMPTY_VALUE && sarDn[i]!= EMPTY_VALUE) sarDn[i+j] = sarDn[i] + (sarDn[i+n]-sarDn[i])*j/n;
            }
   }
   for (int i=limit;i>=0;i--) if (sarDn[i] != EMPTY_VALUE) { PlotPoint(i,amada,amadb,ama); PlotPoint(i,ambda,ambdb,amb); }
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar," up");
         if (trend[whichBar] == -1) doAlert(whichBar," down");
      }
   }
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

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" parabolic SAR of Kaufman AMA trend changed to "+doWhat;
          if (alertsMessage)   Alert(message);
          if (alertsEmail)     SendMail(StringConcatenate(Symbol()," parabolic SAR of Kaufman AMA "),message);
          if (alertsPushNotif) SendNotification(StringConcatenate(Symbol()," parabolic SAR of Kaufman AMA "+message));
          if (alertsSound)     PlaySound("alert2.wav");
   }
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

#define filterInstances 4
double workFil[][filterInstances*3];

#define _fchange 0
#define _fachang 1
#define _fprice  2

double iFilter(double tprice, double filter, int period, int i, int instanceNo=0)
{
   if (filter<=0) return(tprice);
   if (ArrayRange(workFil,0)!= Bars) ArrayResize(workFil,Bars); i = Bars-i-1; instanceNo*=3;
   
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

//
//
//
//
//

#define amaInstances 2
double workAma[][amaInstances*3];
#define _diff  0
#define _kama  1
#define _price 2

double iKama(double price, int period, double fast, double slow, double power, bool JurikFD, double JurikCnt, int i, int instanceNo=0)
{
   if (ArrayRange(workAma,0)!=Bars) ArrayResize(workAma,Bars);  int r = Bars-i-1; if (r<period) return(price); instanceNo*=3;
   double fastend = (2.0 /(fast + 1));
   double slowend = (2.0 /(slow + 1));
   
   //
   //
   //
   //
   //

      double efratio=1; workAma[r][instanceNo+_price] = price;
      if (JurikFD) efratio = MathMin(2.0-iJurikFractalDimension(period,JurikCnt,i),1.5);
      else
      {
         double signal = MathAbs(price-workAma[r-period][instanceNo+_price]);
         double noise  = 0;
            workAma[r][instanceNo+_diff] = MathAbs(price-workAma[r-1][instanceNo+_price]);
            for (int k=0; k<period; k++) 
                  noise += workAma[r-k][instanceNo+_diff];

            //
            //
            //
            //
            //

            if (noise != 0)
                  efratio = signal/noise;
            else  efratio = 1;
      }
      double smooth = MathPow(efratio*(fastend-slowend)+slowend,power);
          workAma[r][instanceNo+_kama] = workAma[r-1][instanceNo+_kama] + smooth*(price-workAma[r-1][instanceNo+_kama]);
   return(workAma[r][instanceNo+_kama]);
}

//
//
//
//
//

double workFd[][2];
#define _smlRange 0
#define _smlSumm  1

//
//
//
//
//

double iJurikFractalDimension(int size, double count,int i)
{
   if (ArrayRange(workFd,0)!=Bars) ArrayResize(workFd,Bars);

   int window1  = (int)(size*(count-1));
   int window2  = (int)(size* count);
   int r        = Bars-i-1;

   //
   //
   //
   //
   //

      workFd[r][_smlRange] = iFdRange(size,i);
      workFd[r][_smlSumm]  = workFd[r-1][_smlSumm]+workFd[r][_smlRange];
      
      if (r>=window1)
      {
         workFd[r][_smlSumm] -= workFd[r-window1][_smlRange];
         if (r>=window2)
               return(2.0-MathLog(iFdRange(window2,i)/(workFd[r][_smlSumm]/window1))/MathLog(count));
         else  return(0.5);   
      }
      else return(0.5);
}
double iFdRange(int size,int i) { return(MathMax(Close[size+i],High[ArrayMaximum(High,size,i)])-MathMin(Close[size+i],Low[ArrayMinimum(Low,size,i)]));} 

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double work[][7];
#define _high     0
#define _low      1
#define _ohigh    2
#define _olow     3
#define _open     4
#define _position 5
#define _af       6


void iParabolic(double high, double low, double step, double limit, double& pClose, double& pOpen, double& pPosition, double& pChange, int i)
{
   if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars); i = Bars-i-1;
   
   //
   //
   //
   //
   //
   
      pChange = 0;
         work[i][_ohigh]    = high;
         work[i][_olow]     = low;
            if (i<1)
               {
                  work[i][_high]     = high;
                  work[i][_low]      = low;
                  work[i][_open]     = high;
                  work[i][_position] = -1;
                  return;
               }
         work[i][_open]     = work[i-1][_open];
         work[i][_af]       = work[i-1][_af];
         work[i][_position] = work[i-1][_position];
         work[i][_high]     = MathMax(work[i-1][_high],high);
         work[i][_low]      = MathMin(work[i-1][_low] ,low );
      
   //
   //
   //
   //
   //
            
   if (work[i][_position] == 1)
      if (low<=work[i][_open])
         {
            work[i][_position] = -1;
               pChange = -1;
               pClose  = work[i][_high];
                         work[i][_high] = high;
                         work[i][_low]  = low;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }
      else
         {
               pClose = work[i][_open];
                    if (work[i][_high]>work[i-1][_high] && work[i][_af]<limit) work[i][_af] = MathMin(work[i][_af]+step,limit);
                        work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
   else
      if (high>=work[i][_open])
         {
            work[i][_position] = 1;
               pChange = 1;
               pClose  = work[i][_low];
                         work[i][_low]  = low;
                         work[i][_high] = high;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
      else
         {
               pClose = work[i][_open];
               if (work[i][_low]<work[i-1][_low] && work[i][_af]<limit) work[i][_af] = MathMin(work[i][_af]+step,limit);
                   work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }

   //
   //
   //
   //
   //
   
   pOpen     = work[i][_open];
   pPosition = work[i][_position];
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

#define priceInstances 2
double workHa[][priceInstances*4];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=4;
         int r = Bars-i-1;
         
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