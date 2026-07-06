// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75488

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 clrDeepSkyBlue
#property indicator_color2 clrSandyBrown
#property indicator_color3 clrSandyBrown
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
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

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT; // Time frame
extern int             SlwmaPeriod     = 27;             // Average period
extern enPrices        SlwmaPrice      = pr_close;       // Price to use
extern bool            AlertsOn        = false;          // Turn alerts on?
extern bool            AlertsOnCurrent = true;           // Alerts on current (still opened) bar?
extern bool            AlertsMessage   = true;           // Alerts should show pop-up message?
extern bool            AlertsSound     = false;          // Alerts should play alert sound?
extern bool            AlertsPushNotif = false;          // Alerts should send push notification?
extern bool            AlertsEmail     = false;          // Alerts should send email?
extern string            note5        = ".........Arrows settings.........";
extern bool              ShowArrows    = false;            // Arrows visible?
input bool             ArrowOnFirst    = true;             // Arrow on first bars true/false
input int              UpArrowSize     = 1;                // Up Arrow size
input int              UpArrowCode     = 221;              // Up Arrow code
input int              DnArrowCode     = 222;              // Down arrow code
input double           UpArrowGap      = 0.5;              // Up Arrow gap        
input color            UpArrowColor    = clrLimeGreen;     // Up Arrow Color
input color            DnArrowColor    = clrOrange;        // Down Arrow Color 
extern bool            Interpolate     = true;           // Interpolate in multi time frame mode?

double slwma[],slwmaDa[],slwmaDb[],upa[],dna[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,0,SlwmaPeriod,SlwmaPrice,AlertsOn,AlertsOnCurrent,AlertsMessage,AlertsSound,AlertsPushNotif,AlertsEmail,note5,ShowArrows,ArrowOnFirst,UpArrowSize,UpArrowCode,DnArrowCode,UpArrowGap,UpArrowColor,DnArrowColor,_buff,_ind)

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
   IndicatorBuffers(7);
   SetIndexBuffer(0,slwma);
   SetIndexBuffer(1,slwmaDa);
   SetIndexBuffer(2,slwmaDb);
   SetIndexBuffer(3 ,upa);   SetIndexStyle(3,ShowArrows ? DRAW_ARROW :  DRAW_NONE,EMPTY,UpArrowSize,UpArrowColor); SetIndexArrow(3,UpArrowCode);
   SetIndexBuffer(4, dna);   SetIndexStyle(4,ShowArrows ? DRAW_ARROW :  DRAW_NONE,EMPTY,UpArrowSize,DnArrowColor); SetIndexArrow(4,DnArrowCode);
   SetIndexBuffer(5,trend);
   SetIndexBuffer(6,count);

      //
      //
      //
      //
      //
      
      indicatorFileName = WindowExpertName();
      TimeFrame = MathMax(TimeFrame,_Period);
   IndicatorShortName("Smoothed LWMA ("+(string)SlwmaPeriod+")");
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
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars - counted_bars,Bars-1); count[0]=limit;
         if (TimeFrame!=_Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(6,0)*TimeFrame/_Period));
            if (trend[limit]==-1) CleanPoint(limit,slwmaDa,slwmaDb);
            for(int i=limit; i>=0; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                int x = y;
                if (ArrowOnFirst)
                      {  if (i<Bars-1) x = iBarShift(NULL,TimeFrame,Time[i+1]);               }
                else  {  if (i>0)      x = iBarShift(NULL,TimeFrame,Time[i-1]); else x = -1;  }
               slwma[i]   = _mtfCall(0,y);
               slwmaDa[i] = EMPTY_VALUE;
               slwmaDb[i] = EMPTY_VALUE;
               upa[i] = dna[i]  = EMPTY_VALUE; 
               trend[i]   = _mtfCall(5,y);
               if (x!=y)
                     {
                       upa[i] = _mtfCall(3,y);
                       dna[i] = _mtfCall(4,y);
                     }  
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                  
                  //
                  //
                  //
                  //
                  //
                  
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime ttime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<Bars && Time[i+n] >= ttime; n++) continue;	
                     for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)
                         _interpolate(slwma);
            }               
            for(int i=limit; i>=0; i--) if (trend[i]==-1) PlotPoint(i,slwmaDa,slwmaDb,slwma);
            return(0);
         }

   //
   //
   //
   //
   //

      if (trend[limit]==-1) CleanPoint(limit,slwmaDa,slwmaDb);
      for(int i=limit; i>=0; i--)
      {
         slwma[i]   = iSlwma(getPrice(SlwmaPrice,Open,Close,High,Low,i,Bars),SlwmaPeriod,i,0);
         slwmaDa[i] = EMPTY_VALUE;
         slwmaDb[i] = EMPTY_VALUE;
         upa[i] = dna[i]  = EMPTY_VALUE;  
         trend[i] = (i<Bars-1) ? (slwma[i]>slwma[i+1]) ? 1 : (slwma[i]<slwma[i+1]) ? -1  : trend[i+1]  : 0;       
         if (trend[i]==-1) PlotPoint(i,slwmaDa,slwmaDb,slwma);
         if (i<Bars-1 && trend[i]!=trend[i+1])
        
      {
         if (trend [i] == 1)  upa[i] = fmin(slwma[i],Low[i] )-iATR(NULL,0,15,i)*UpArrowGap;
         if (trend [i] == -1) dna[i] = fmax(slwma[i],High[i])+iATR(NULL,0,15,i)*UpArrowGap;
      }     
      }
      manageAlerts();
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
   if (AlertsOn)
   {
      int whichBar = 1; if (AlertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] ==  1) doAlert(whichBar,"up");
         if (trend[whichBar] == -1) doAlert(whichBar,"down");
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

       message = timeFrameToString(_Period)+" - "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" smoothed LWMA trend changed to "+doWhat;
          if (AlertsMessage)   Alert(message);
          if (AlertsEmail)     SendMail(Symbol()+" smoothed LWMA",message);
          if (AlertsPushNotif) SendNotification(message);
          if (AlertsSound)     PlaySound("alert2.wav");
   }
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//


double workSlwma[][2];
double iSlwma(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workSlwma,0)!= Bars) ArrayResize(workSlwma,Bars); r=Bars-r-1;

   //
   //
   //
   //
   //

      int SqrtPeriod = (int)MathFloor(MathSqrt(period)); instanceNo *= 2;
         workSlwma[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         double sumw = period;
         double sum  = period*price;
   
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   sumw  += weight;
                   sum   += weight*workSlwma[r-k][instanceNo];  
         }             
         workSlwma[r][instanceNo+1] = (sum/sumw);

         //
         //
         //
         //
         //
         
         sumw = SqrtPeriod;
         sum  = SqrtPeriod*workSlwma[r][instanceNo+1];
            for(int k=1; k<SqrtPeriod && (r-k)>=0; k++)
            {
               double weight = SqrtPeriod-k;
                      sumw += weight;
                      sum  += weight*workSlwma[r-k][instanceNo+1];  
            }
   return(sum/sumw);
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
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75488

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC  | 
// |                                                                         http://fxcodebase.com  |
// |                                                               Paypal:  https://goo.gl/9Rj74e   |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by : Mario Jemic   |                    
// |                                                                       mario.jemic@gmail.com    |
// |                                                                       https://mario-jemic.com/ | 
// |                                                             Patreon :  http://tiny.cc/1ybwxz   |   
// |                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
// +-----------------+----------------------+-------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                              |
// +-----------------+----------------------+-------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                   | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2         | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7           | 
// +-----------------+----------------------+-------------------------------------------------------+ 