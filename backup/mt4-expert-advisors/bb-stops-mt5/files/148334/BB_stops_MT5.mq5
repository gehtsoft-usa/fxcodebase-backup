// More information about this indicator can be found at:
// //https://fxcodebase.com/code/viewtopic.php?f=38&t=72945

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots 3
#property  indicator_type1   DRAW_HISTOGRAM 
#property indicator_color1 clrLimeGreen
#property  indicator_type2   DRAW_HISTOGRAM 
#property indicator_color2  clrRed
#property  indicator_type3   DRAW_LINE
#property indicator_color3  clrBlack
#property indicator_style3 STYLE_SOLID

#property indicator_width1  2
#property indicator_width2  2
#property indicator_minimum 0
#property indicator_maximum 1
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
enum enMaTypes
{
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma,   // Linear weighted MA
   ma_tema    // Triple exponential moving average - TEMA
};

ENUM_TIMEFRAMES   TimeFrame                = PERIOD_CURRENT;  // Time frame
input int                BandsPeriod              = 20;              // Bands period
input double             BandsDeviation           = 1;               // Bands deviation
input bool               BandsDeviationSample     = false;           // Bands deviation with sample correction?
input double             BandsRisk                = 1;               // Bands risk
input enMaTypes          BandsMaType              = ma_sma;          // Bands average type
input enPrices           Price                    = pr_close;        // Price
input bool               alertsOn                 = false;           // Turn alerts on?
input bool               alertsOnCurrent          = false;           // Alerts on still opened bar?
input bool               alertsMessage            = true;            // Alerts should display message?
input bool               alertsSound              = false;           // Alerts should play a sound?
input bool               alertsNotify             = false;           // Alerts should send a notification?
input bool               alertsEmail              = false;           // Alerts should send an email?
input string             soundFile                = "alert2.wav";    // Sound file
input color              ColorUp                  = clrLimeGreen;    // Color for up
input color              ColorDn                  = clrOrangeRed;    // Color for down
input bool               verticalLinesVisible     = true;            // Show vertical lines
input bool               linesOnNewest            = true;            // Vertical lines drawn on newest bar of higher time frame bar true/false?
input string             verticalLinesID          = "bb Lines1";     // Vertical lines id
input color              verticalLinesUpColor     = clrBlue;         // Vertical lines up color
input color              verticalLinesDnColor     = clrRed;          // Vertical lines down color
input ENUM_LINE_STYLE    verticalLinesStyle       = STYLE_SOLID;     // Vertical lines color
input int                verticalLinesWidth       = 2;               // Vertical lines width
//
//
//
//
//

double histou[],histod[],zero[],amax[],amin[],bmin[],bmax[],trend[],count[];
string indicatorFileName;
double histoColors[];
// color  _histoColors[] = {clrLimeGreen, clrOrangeRed};

#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,BandsPeriod,BandsDeviation,BandsDeviationSample,BandsRisk,BandsMaType,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,ColorUp,ColorDn,verticalLinesVisible,linesOnNewest,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesStyle,verticalLinesWidth,_buff,_y)
;
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
        //  IndicatorBuffers(9);
         
				 SetIndexBuffer(0,histou, INDICATOR_DATA);   
				//  PlotIndexSetInteger(0, DRAW_COLOR_HISTOGRAM);
				//  SetIndexBuffer(1, histoColors, INDICATOR_COLOR_INDEX);   

				//  SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,ColorUp);
         SetIndexBuffer(1,histod, INDICATOR_DATA);   
				//  PlotIndexSetInteger(2, DRAW_HISTOGRAM);
         
				 SetIndexBuffer(2,zero, INDICATOR_DATA);
         SetIndexBuffer(3,amax, INDICATOR_CALCULATIONS);
         SetIndexBuffer(4,amin, INDICATOR_CALCULATIONS);
         SetIndexBuffer(5,bmax, INDICATOR_CALCULATIONS);
         SetIndexBuffer(6,bmin, INDICATOR_CALCULATIONS);
         SetIndexBuffer(7,trend,INDICATOR_CALCULATIONS);
         SetIndexBuffer(8,count,INDICATOR_CALCULATIONS);

         
      //
     
        // indicatorFileName = WindowExpertName();
        indicatorFileName = "BB_stops_MT5.ex5";
        // TimeFrame         = MathMax(TimeFrame,_Period);  
      // IndicatorShortName(timeFrameToString(TimeFrame)+"  BB stops");
      IndicatorSetString(INDICATOR_SHORTNAME, timeFrameToString(TimeFrame) + "  BB stops");
      return (0);
}  

void OnDeinit(const int reason) {   ObjectsDeleteAll(0,verticalLinesID+":");  }

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
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{

  //  int counted_bars = prev_calculated;
      // if(counted_bars < 0) return(-1);
      // if(counted_bars > 0) counted_bars--;
      // int limit=MathMin(rates_total-counted_bars,rates_total-1); count[0]=limit;

			int start;
	  	if (prev_calculated > 1) start = prev_calculated - 1; else { start = BandsPeriod + 1; }

				//  if (TimeFrame!=_Period)
          // {
              //  limit = (int)MathMax(limit,MathMin(rates_total-1,_mtfCall(8,0)*TimeFrame/_Period));
              //  for (int i=limit; i>=0 && !_StopFlag; i--)
          //      for (int i=100; i<limit && !_StopFlag; i++)
              //  {
          //         int y = iBarShift(NULL,TimeFrame,time[i]);
          //            histou[i] = _mtfCall(0,y);
          //            histod[i] = _mtfCall(1,y);
          //      }
              //  return(rates_total);
          // }


    //  for(int i=limit; i>=0 && !_StopFlag; i--)
		for (int i = start; i < rates_total && !IsStopped(); i++)
    {
        double price = getPrice(Price,open,close,high,low,i);
        // double price = close[i];
        double dev   = iDeviation(price, BandsPeriod, BandsDeviationSample, i);
        zero[i]      = iCustomMa(BandsMaType, price, BandsPeriod, i, 0);
        amax[i]      = zero[i] + dev * BandsDeviation;
        amin[i]      = zero[i] - dev * BandsDeviation;
        bmax[i]      = amax[i] + 0.5 * (BandsRisk - 1) * (amax[i] - amin[i]);
        bmin[i]      = amin[i] - 0.5 * (BandsRisk - 1) * (amax[i] - amin[i]);

        trend[i] = (i < Bars(NULL, 0) - 1) ? (price > amax[i - 1]) ? 1 : (price < amin[i - 1]) ? -1 : trend[i - 1] : 0;
        
				if (i < Bars(NULL, 0) - 1) 
				{
          if (trend[i] == -1 && amax[i] > amax[i - 1]) amax[i] = amax[i - 1];
          if (trend[i] == 1 && amin[i] < amin[i - 1]) amin[i] = amin[i - 1];
          if (trend[i] == -1 && bmax[i] > bmax[i - 1]) bmax[i] = bmax[i - 1];
          if (trend[i] == 1 && bmin[i] < bmin[i - 1]) bmin[i] = bmin[i - 1];
        }                  
               if (trend[i] ==  1) { histou[i] = 1; histod[i] = EMPTY_VALUE; }
               if (trend[i] == -1) { histod[i] = 1; histou[i] = EMPTY_VALUE; }
               
               //
               //
               //
               
               if (verticalLinesVisible)
               {
                  string tlookFor = verticalLinesID+":"+(string)time[i]; if (ObjectFind(0,tlookFor)==0) ObjectDelete(0,tlookFor);   
                  if (i<(rates_total-1) && trend[i]!=trend[i-1])
                  {
                    if (trend[i] == 1) drawLine(i,verticalLinesUpColor);
                    if (trend[i] ==-1) drawLine(i,verticalLinesDnColor);
                  }               
               }
      }
      if (alertsOn)
      {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar-1])
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

#define _devInstances 1
double workDev[][_devInstances];
double iDeviation(double value, int length, bool isSample, int i, int instanceNo=0)
{
   if (ArrayRange(workDev,0)!=Bars(NULL,0)) ArrayResize(workDev,Bars(NULL,0)); 
	//  i=Bars(NULL,0)-i-1; 
	//  i=Bars(NULL,0)-i-1; 
	 workDev[i][instanceNo] = value;
                 
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

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int instanceNo=0)
{
   int bars = Bars(NULL,0); 
	//  r = bars-r-1;
	//  r = bars-r-1;
   
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

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo] = price;
   double avg = price; int k=1; for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo];  
   return(avg/k);
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
   
      if (previousAlert != doWhat || previousTime != iTime(NULL, 0, 0)) {
          previousAlert  = doWhat;
          previousTime   = iTime(NULL, 0, 0);

          //
          //
          //
          //
          //

          // message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" BB stops state changed to "+doWhat;
          message = timeFrameToString(_Period)+" "+_Symbol+" BB stops state changed to "+doWhat;
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
      if (ArrayRange(workHa,0)!= Bars(NULL,0)) ArrayResize(workHa,Bars(NULL,0)); instanceNo*=4;
        //  int r = Bars(NULL,0)-i-1;
         int r = i;
         
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


void drawLine(int i,color theColor)
{
			int bars = iBars(NULL, 0);
      int    _i   = bars - i-1;
      string name = verticalLinesID + ":" + (string)iTime(NULL, 0, _i);
      datetime ltime = iTime(NULL, 0, _i);
      if (linesOnNewest) ltime += PeriodSeconds(_Period) - 1;
      ObjectCreate(0, name, OBJ_VLINE, 0, ltime, 0);
      ObjectSetInteger(0, name, OBJPROP_COLOR, theColor);
      ObjectSetInteger(0, name, OBJPROP_STYLE, verticalLinesStyle);
      ObjectSetInteger(0, name, OBJPROP_WIDTH, verticalLinesWidth);
      ObjectSetInteger(0, name, OBJPROP_BACK, true); 
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