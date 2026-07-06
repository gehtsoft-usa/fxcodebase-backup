// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73262

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
#property indicator_buffers 3
#property indicator_color1  clrFireBrick
#property indicator_color2  clrFireBrick
#property indicator_color3  clrFireBrick
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
enum enMaTypes
{
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
   ma_slwma,   // Smoothed LWMA
   ma_dsema,   // Double Smoothed Exponential average
   ma_tema,    // Triple exponential moving average - TEMA
   ma_lsma,    // Linear regression value (lsma)
   ma_dema     // Double exponential moving average - DEMA
};

extern ENUM_TIMEFRAMES  TimeFrame       = PERIOD_CURRENT;  // Time frame
input int               MaPeriod        = 49;              // Ma period
input enMaTypes         MaMode          = ma_lwma;         // Ma averaging type
input enPrices          Price           = pr_close;        // Price
input int               AtrPeriod       = 18;              // Atr period
input enMaTypes         AtrMaType       = ma_sma;          // Atr averaging type
input double            KATR            = 1.6;           // Atr multiplier
input bool              ShowMidMa       = true;            // Show middle moving average
input bool              alertsOn        = true;            // Alerts on/off?
input bool              alertsOnCurrent = false;           // Alerts open bar on/off?
input bool              alertsMessage   = true;            // Alerts message on/off?
input bool              alertsSound     = false;           // Alerts sound on/off?
input bool              alertsNotify    = false;           // Alerts notification on/off?
input bool              alertsEmail     = false;           // Alerts email on/off?
input string            soundFile       = "1 Hour Touching Suraj.wav";    // Sound file
input bool              Interpolate     = true;            // Interpolate in multi time frame mode

double mb[],ub[],lb[],vala[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,MaPeriod,MaMode,Price,AtrPeriod,AtrMaType,KATR,ShowMidMa,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int OnInit()
{
  IndicatorBuffers(5);
  SetIndexBuffer(0,mb,INDICATOR_DATA); SetIndexStyle(0,ShowMidMa ? DRAW_LINE : DRAW_NONE);
  SetIndexBuffer(1,ub,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE);
  SetIndexBuffer(2,lb,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE);
  SetIndexBuffer(3,vala);
  SetIndexBuffer(4,count);
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//
//
//
//
//

int  OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   int i=rates_total-prev_calculated+1; if (i>=rates_total) i=rates_total-1; count[0]=i;
      if (TimeFrame!=_Period)
      {
         i = (int)fmax(i,fmin(rates_total-1,_mtfCall(4,0)*TimeFrame/_Period));
         for (; i>=0 && !_StopFlag; i--)
         {
             int y = iBarShift(NULL,TimeFrame,time[i]);
                mb[i] = _mtfCall(0,y);
                ub[i] = _mtfCall(1,y);
                lb[i] = _mtfCall(2,y);
                
                //
                //
                //
                //
                //
                     
                if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                  #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                  int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                     for(n = 1; (i+n)<rates_total && time[i+n] >= btime; n++) continue;	
                     for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) 
                     {
                        _interpolate(mb); 
                        _interpolate(ub);
                        _interpolate(lb);
                     } 
         }  
   return(rates_total);
   }
   
   //
   //
   //
   //
   //
   
   for (; i>=0 && !_StopFlag; i--)
   {
      int    atrPeriod = (AtrPeriod>0) ? AtrPeriod : MaPeriod;
      double price = getPrice(Price,open,close,high,low,i,rates_total);
      double tr   = (i<rates_total-1) ? fmax(high[i],close[i+1])-fmin(low[i],close[i+1]) : high[i]-low[i];
      double atr  = iCustomMa(AtrMaType,tr,atrPeriod,i,rates_total,0);
            mb[i] = iCustomMa(MaMode,price,MaPeriod, i,rates_total,1);
            ub[i] = mb[i] + (KATR*atr);
            lb[i] = mb[i] - (KATR*atr);
            vala[i] = (low[i]<=lb[i]) ? 1 : (high[i]>=ub[i]) ? -1 : 0; 
   }
   manageAlerts();
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

#define _maInstances 2
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)MathCeil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,length,r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)MathCeil(length),r,bars,instanceNo));
      case ma_slwma : return(iSlwma(price,(int)MathCeil(length),r,bars,instanceNo));
      case ma_dsema : return(iDsema(price,length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,length,r,bars,instanceNo));
      case ma_lsma  : return(iLinr(price,(int)MathCeil(length),r,bars,instanceNo));
      case ma_dema  : return(iDema(price,length,r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
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

//
//
//
//
//


double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSlwma,0)!= _bars) ArrayResize(workSlwma,_bars); 

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

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= _bars) ArrayResize(workDsema,_bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
   workDsema[r][_ema1+instanceNo] = price;
   workDsema[r][_ema2+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]); }
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
      if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}

//
//
//
//
//

double workDema[][_maWorkBufferx2];
#define _dema1 0
#define _dema2 1

double iDema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (period<=1) return(price);
   if (ArrayRange(workDema,0)!= bars) ArrayResize(workDema,bars); instanceNo*=2;

   //
   //
   //
   //
   //
      
   workDema[r][_dema1+instanceNo] = price;
   workDema[r][_dema2+instanceNo] = price;
   double alpha = 2.0 / (1.0+period);
   if (r>0)
   {
          workDema[r][_dema1+instanceNo] = workDema[r-1][_dema1+instanceNo]+alpha*(price                         -workDema[r-1][_dema1+instanceNo]);
          workDema[r][_dema2+instanceNo] = workDema[r-1][_dema2+instanceNo]+alpha*(workDema[r][_dema1+instanceNo]-workDema[r-1][_dema2+instanceNo]); }
   return(workDema[r][_dema1+instanceNo]*2.0-workDema[r][_dema2+instanceNo]);
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

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (vala[whichBar] != vala[whichBar+1])
      {
         if (vala[whichBar] == -1) doAlert(whichBar,"crossed lower band");
         if (vala[whichBar] == +1) doAlert(whichBar,"crossed upper band");
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

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Atr Bands "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Atr Bands ",message);
          if (alertsSound)   PlaySound(soundFile);
      }
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