//Available @ http://fxcodebase.com

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
 
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property indicator_width6  2
#property indicator_width7  2
#property strict

//
//
//
//
//
enum arrwType {
   atNONE          =44,//<<--NO ARROW-->>
   atThick         =0,//Thick
   atThin          =1,//Thin
   atHollow        =2,//Hollow
   atRound         =3,//Round
   atFractal       =4,//Fractal
   atDiagonalThin  =5,//Diagonal Thin
   atDiagonalThick =6,//Diagonal Thick
   atDiagonalHollow=7,//Diagonal Hollow
   atThumb         =8,//Thumb
   atFinger        =9,//Finger
   atBox           =10,//Box
   atEmptyBox      =11,//Empty Box
   atDot           =12,//Dot
   atBigDot        =13,//Big Dot
   atDiamondBig    =14,//Diamond big
   atDiamondSmall  =15,//Diamond small
   atCircle        =16,//Circle
   atDottedCircle  =17,//Dotted Circle
   atCircledStar   =18,//Circled Star
   atStar          =19,//Star
   atBigStar       =20,//Star 2
   atBomb          =21,//Bomb
   atSnow          =22,//Snow
   atDrop          =23,//Drop
   atOneBold       =24,//Number 1 (Filled Circle)
   atTwoBold       =25,//Number 2 (Filled Circle)
   atThreeBold     =26,//Number 3 (Filled Circle)
   atFourBold      =27,//Number 4 (Filled Circle)
   atFiveBold      =28,//Number 5 (Filled Circle)
   atSixBold       =29,//Number 6 (Filled Circle)
   atSevenBold     =30,//Number 7 (Filled Circle)
   atEightBold     =31,//Number 8 (Filled Circle)
   atNineBold      =32,//Number 9 (Filled Circle)
   atTenBold       =33,//Number 10(Filled Circle)
   atOne           =34,//Number 1
   atTwo           =35,//Number 2
   atThree         =36,//Number 3
   atFour          =37,//Number 4
   atFive          =38,//Number 5
   atSix           =39,//Number 6
   atSeven         =40,//Number 7
   atEight         =41,//Number 8
   atNine          =42,//Number 9
   atTen           =43,//Number 10
};

#define _disBar 1
#define _disLin 2
#define _disZer 4
enum enDisplayType
{
   dis_01=_disLin,                // Display bb stops line
   dis_02=_disBar,                // Display bb stops bars
   dis_03=_disZer,                // Display bb stops "zero" line
   dis_04=_disLin+_disBar,        // Display bb stops line and bars
   dis_05=_disLin+_disZer,        // Display bb stops line and "zero" line
   dis_06=_disBar+_disZer,        // Display bb stops bars and "zero" line
   dis_07=_disLin+_disBar+_disZer, // Display all
};
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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;  // Time frame
extern int             BandsPeriod     = 20;              // Bands period
extern double          BandsDeviation  = 1;               // Bands deviation
extern bool            BandsDeviationSample = false;      // Bands deviation with sample correction?
extern double          BandsRisk       = 1;               // Bands risk
extern enMaTypes       BandsMaType     = ma_sma;          // Bands average type
extern enPrices        Price           = pr_close;        // Price

extern bool            mimicC          = true;            // Mimic C
extern bool            alertsOn        = false;           // Turn alerts on?
extern bool            alertsOnCurrent = false;           // Alerts on still opened bar?
extern bool            alertsMessage   = true;            // Alerts should display message?
extern bool            alertsSound     = false;           // Alerts should play a sound?
extern bool            alertsNotify    = false;           // Alerts should send a notification?
extern bool            alertsEmail     = false;           // Alerts should send an email?
extern string          soundFile       = "alert2.wav";    // Sound file
extern enDisplayType   DisplayWhat     = _disLin+_disBar; // Display type
extern arrwType        arrowType       = atThin;          // Arrow Type
extern color           ColorUp         = clrLimeGreen;    // Color for up
extern color           ColorDn         = clrOrangeRed;    // Color for down
extern color           ColorNe         = clrDarkGray;     // Color for neutral and "zero" line
extern bool            Interpolate     = true;            // Interpolate in multi time frame mode?
//
//
//
//
//

double upb[],dnb[],upa[],dna[],histou[],histod[],zero[],amax[],amin[],bmin[],bmax[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandsPeriod,BandsDeviation,BandsDeviationSample,BandsRisk,BandsMaType,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_y)

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
      int czer,chup,chdn ,clup ,cldn ,arst ,arrUpCode ,arrDnCode;
   if (mimicC){
      TimeFrame       = PERIOD_CURRENT;  // Time frame
      BandsPeriod     = 20;              // Bands period
      BandsDeviation  = 2;               // Bands deviation
      BandsDeviationSample = false;      // Bands deviation with sample correction?
      BandsRisk       = 1;               // Bands risk
      BandsMaType     = ma_sma;          // Bands average type
      Price           = pr_close;        // Price
      czer = clrNONE;
      chup = clrNONE;
      chdn = clrNONE;
      clup = clrNONE;
      cldn = clrNONE;
      arst = DRAW_ARROW;
      arrUpCode = getArrowType(arrowType,true);
      arrDnCode = getArrowType(arrowType,false);
   } else {
      czer = ((DisplayWhat&_disZer)==0) ? clrNONE : ColorNe;
      chup = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorUp;
      chdn = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorDn;
      clup = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorUp;
      cldn = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorDn;
      arst = ((DisplayWhat&_disLin)==0) ? DRAW_LINE : DRAW_ARROW;
      arrUpCode = getArrowType(arrowType,true);
      arrDnCode = getArrowType(arrowType,false);
   }
   IndicatorBuffers(13);
         SetIndexBuffer(0,histou);   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,chup);
         SetIndexBuffer(1,histod);   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,EMPTY,chdn);
         SetIndexBuffer(2,zero);     SetIndexStyle(2,EMPTY,STYLE_DOT,0,czer);
         SetIndexBuffer(3,upb);      SetIndexStyle(3,EMPTY,EMPTY,EMPTY,clup);
         SetIndexBuffer(4,dnb);      SetIndexStyle(4,EMPTY,EMPTY,EMPTY,cldn);
         SetIndexBuffer(5,upa);      SetIndexStyle(5,arst,EMPTY,EMPTY,mimicC?ColorUp:clup); SetIndexArrow(5,arrUpCode);
         SetIndexBuffer(6,dna);      SetIndexStyle(6,arst,EMPTY,EMPTY,mimicC?ColorDn:cldn); SetIndexArrow(6,arrDnCode);
         SetIndexBuffer(7,amax);
         SetIndexBuffer(8,amin);
         SetIndexBuffer(9,bmax);
         SetIndexBuffer(10,bmin);
         SetIndexBuffer(11,trend);
         SetIndexBuffer(12,count);
         
      
      //
      //
      //
      //
      //
     
        indicatorFileName = WindowExpertName();
        TimeFrame         = MathMax(TimeFrame,_Period);  
      IndicatorShortName(timeFrameToString(TimeFrame)+"  C");
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

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& btime[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{

   int counted_bars = prev_calculated;
      if(counted_bars < 0) return(-1);
      if(counted_bars > 0) counted_bars--;
            int limit=MathMin(rates_total-counted_bars,rates_total-1); count[0] = limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)MathMax(limit,MathMin(rates_total-1,_mtfCall(12,0)*TimeFrame/_Period));
               for (int i=limit;i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,btime[i]);
                     zero[i]  = _mtfCall( 2,y);
                     bmax[i]  = _mtfCall( 9,y);
                     bmin[i]  = _mtfCall(10,y);
                     trend[i] = _mtfCall(11,y);
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,btime[i-1]))) continue;
                  
                     //
                     //
                     //
                     //
                     //
                  
                     #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                     int n,k; datetime time = iTime(NULL,TimeFrame,y);
                        for(n = 1; (i+n)<rates_total && btime[i+n] >= time; n++) continue;	
                        for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                        {
                           _interpolate(zero);
                           _interpolate(bmax);
                           _interpolate(bmin);
                        }                  
               }
               for (int i=limit;i>=0; i--)
               {
                  upb[i] = dnb[i] = EMPTY_VALUE;
                     if (trend[i] ==  1) { upb[i] = bmin[i]; histou[i] = high[i]; histod[i] = low[i]; }
                     if (trend[i] == -1) { dnb[i] = bmax[i]; histod[i] = high[i]; histou[i] = low[i]; }
                     upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
                     dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
               }         
               return(rates_total);
            }               

   //
   //
   //
   //
   //

   for(int i=limit; i>=0; i--)
   {
      double price = getPrice(Price,open,close,high,low,i);
      double dev   = iDeviation(price,BandsPeriod,BandsDeviationSample,i);
               zero[i]  = iCustomMa(BandsMaType,price,BandsPeriod,i,0);
               amax[i]  = zero[i]+dev*BandsDeviation;
               amin[i]  = zero[i]-dev*BandsDeviation;
   	         bmax[i]  = amax[i]+0.5*(BandsRisk-1)*(amax[i]-amin[i]);
	  	         bmin[i]  = amin[i]-0.5*(BandsRisk-1)*(amax[i]-amin[i]);
               trend[i] = (i<Bars-1) ? (price>amax[i+1]) ? 1 : (price<amin[i+1]) ? -1 : trend[i+1] : 0;
                       if (i<Bars-1)
                       {
                           if (trend[i]==-1 && amax[i]>amax[i+1]) amax[i] = amax[i+1];
                           if (trend[i]== 1 && amin[i]<amin[i+1]) amin[i] = amin[i+1];
                           if (trend[i]==-1 && bmax[i]>bmax[i+1]) bmax[i] = bmax[i+1];
                           if (trend[i]== 1 && bmin[i]<bmin[i+1]) bmin[i] = bmin[i+1];
                       }                  
               upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
               if (trend[i] ==  1) { upb[i] = bmin[i]; histou[i] = high[i]; histod[i] = low[i]; }
               if (trend[i] == -1) { dnb[i] = bmax[i]; histod[i] = high[i]; histou[i] = low[i]; }
               if (mimicC) {
                  if(i<Bars-1)
                    {
                     double prevMACD = iMACD(NULL,0,8,21,9,PRICE_CLOSE,MODE_MAIN,i+1);
                     double currMACD = iMACD(NULL,0,8,21,9,PRICE_CLOSE,MODE_MAIN,i);
                     upa[i] = (trend[i]!=trend[i+1] && trend[i]== 1) && currMACD>0 && prevMACD<0? upb[i] : EMPTY_VALUE;
                     dna[i] = (trend[i]!=trend[i+1] && trend[i]==-1) && currMACD<0 && prevMACD>0? dnb[i] : EMPTY_VALUE;
                    }
               } else
               {
                 upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
                 dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
               }
   }
   if (alertsOn)
   {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(" up");
            if (trend[whichBar] ==-1) doAlert(" down");       
         }         
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

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars; r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)length,r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx2];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars); instanceNo *= 2; int k;

   workSma[r][instanceNo+0] = price;
   workSma[r][instanceNo+1] = price; for(k=1; k<period && (r-k)>=0; k++) workSma[r][instanceNo+1] += workSma[r-k][instanceNo+0];  
   workSma[r][instanceNo+1] /= 1.0*k;
   return(workSma[r][instanceNo+1]);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
// 
//
//
//
//

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=Bars) ArrayResize(workDev,Bars); i=Bars-i-1; workDev[i][instanceNo] = value;
                 
   //
   //
   //
   //
   //
   
      double oldMean   = value;
      double newMean   = value;
      double squares   = 0; int k;
      for (k=1; k<length && (i-k)>=0; k++)
      {
         newMean  = (workDev[i-k][instanceNo]-oldMean)/(k+1)+oldMean;
         squares += (workDev[i-k][instanceNo]-oldMean)*(workDev[i-k][instanceNo]-newMean);
         oldMean  = newMean;
      }
      return(MathSqrt(squares/MathMax(k-isSample,1)));
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" BB stops state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" BB stops ",message);
             if (alertsSound)   PlaySound(soundFile);
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
//

#define priceInstances 1
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

int getArrowType(arrwType aType, bool forUp = true)
{
   if      (aType == atThick         ) {return (forUp ? 233:234);}
   else if (aType == atThin          ) {return (forUp ? 225:226);}
   else if (aType == atHollow        ) {return (forUp ? 241:242);}
   else if (aType == atRound         ) {return (forUp ? 221:222);}
   else if (aType == atFractal       ) {return (forUp ? 217:218);}
   else if (aType == atDiagonalThin  ) {return (forUp ? 228:230);}
   else if (aType == atDiagonalThick ) {return (forUp ? 236:238);}
   else if (aType == atDiagonalHollow) {return (forUp ? 246:248);}
   else if (aType == atThumb         ) {return (forUp ? 67 : 68);}
   else if (aType == atFinger        ) {return (forUp ? 71 : 72);}
   else if (aType == atBox           ) {return (forUp ? 110:110);}
   else if (aType == atBomb          ) {return (forUp ? 77 : 77);}
   else if (aType == atEmptyBox      ) {return (forUp ? 111:111);}
   else if (aType == atDot           ) {return (forUp ? 159:159);}
   else if (aType == atBigDot        ) {return (forUp ? 108:108);}
   else if (aType == atDiamondBig    ) {return (forUp ? 117:117);}
   else if (aType == atDiamondSmall  ) {return (forUp ? 119:119);}
   else if (aType == atCircle        ) {return (forUp ? 161:161);}
   else if (aType == atDottedCircle  ) {return (forUp ? 164:164);}
   else if (aType == atStar          ) {return (forUp ? 171:171);}
   else if (aType == atBigStar       ) {return (forUp ? 179:179);}
   else if (aType == atSnow          ) {return (forUp ? 84 : 84);}
   else if (aType == atOneBold)        {return (forUp ? 140:140);}
   else if (aType == atTwoBold)        {return (forUp ? 141:141);}
   else if (aType == atThreeBold)      {return (forUp ? 142:142);}
   else if (aType == atFourBold)       {return (forUp ? 143:143);}
   else if (aType == atFiveBold)       {return (forUp ? 144:144);}
   else if (aType == atSixBold)        {return (forUp ? 145:145);}
   else if (aType == atSevenBold)      {return (forUp ? 146:146);}
   else if (aType == atEightBold)      {return (forUp ? 147:147);}
   else if (aType == atNineBold)       {return (forUp ? 148:148);}
   else if (aType == atTenBold)        {return (forUp ? 149:149);}   
   else if (aType == atOne)            {return (forUp ? 129:129);}
   else if (aType == atTwo)            {return (forUp ? 130:130);}
   else if (aType == atThree)          {return (forUp ? 131:131);}
   else if (aType == atFour)           {return (forUp ? 132:132);}
   else if (aType == atFive)           {return (forUp ? 133:133);}
   else if (aType == atSix)            {return (forUp ? 134:134);}
   else if (aType == atSeven)          {return (forUp ? 135:135);}
   else if (aType == atEight)          {return (forUp ? 136:136);}
   else if (aType == atNine)           {return (forUp ? 137:137);}
   else if (aType == atTen)            {return (forUp ? 138:138);}
   else if (aType == atCircledStar)    {return (forUp ? 181:181);}
   else if (aType == atDrop)           {return (forUp ? 83:83);}
   else if (aType == atNONE)           {return (forUp ? -1:-1);}
   else                                {return (forUp ? 233:234);}
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