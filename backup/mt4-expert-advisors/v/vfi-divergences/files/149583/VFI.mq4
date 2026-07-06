//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73362

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
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  clrDarkGray
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrDeepSkyBlue
#property indicator_color4  clrDeepSkyBlue
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_style1  STYLE_DOT
#property indicator_level1  0
#property strict

//
//
//
//
//

enum enColorOn
{
   chg_onSlope, // Color change on slope change
   chg_onZero,  // Color change on zero level cross
   chg_onSign   // Color change on smooth value cross
};
extern ENUM_TIMEFRAMES    TimeFrame       = PERIOD_CURRENT; // Time frame
extern double             VfiCoeff        = 0.2;            // Volume flow coefficient
extern int                VfiPeriod       = 130;            // Calculation period
extern ENUM_APPLIED_PRICE VfiPrice        = PRICE_TYPICAL;  // Price to use
extern double             VolumeCoeff     = 2.5;            // Volume coefficient
extern int                PreSmoothPeriod = 3;              // Pre-smoothig period
extern ENUM_MA_METHOD     PreSmoothMethod = MODE_SMA;       // Pre-smoothig method
extern int                SmoothPeriod    = 3;              // Smoothig period
extern enColorOn          ColorOn         = chg_onZero;     // Color change on :
extern bool               alertsOn        = false;          // Turn alerts on?
extern bool               alertsOnCurrent = false;          // Alerts on current (still opened) bar?
extern bool               alertsMessage   = true;           // Alerts should show pop-up message?
extern bool               alertsSound     = false;          // Alerts should play alert sound?
extern bool               alertsNotify    = false;          // Alerts should send a push notification?
extern bool               alertsEmail     = false;          // Alerts should send an emil?
extern string             soundFile       = "alert2.wav";   // Sound file to use for alerts
extern bool               Interpolate     = true;           // Interpolate in multi time frame mode

double vfi[];
double vfs[];
double vfsua[];
double vfsub[];

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
   for (int i=0; i<indicator_buffers; i++) SetIndexStyle(i,DRAW_LINE);
   SetIndexBuffer(0,vfi);
   SetIndexBuffer(1,vfs);
   SetIndexBuffer(2,vfsua);
   SetIndexBuffer(3,vfsub);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" volume flow ("+(string)VfiPeriod+","+(string)VfiCoeff+","+(string)PreSmoothPeriod+","+(string)SmoothPeriod+")");
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

double work[][6];
#define _price  0
#define _volume 1
#define _voluma 2
#define _dvol   3
#define _vfi    4
#define _trend  5

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
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { vfi[0] = MathMin(limit+1,Bars-1); return(0); }
         if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      double alpha = 2.0 / (1.0+SmoothPeriod);    
      if (work[Bars-limit-1][_trend]==-1) CleanPoint(limit,vfsua,vfsub);
      for(int i = limit, r=Bars-i-1; i >= 0; i--,r++)
      {
         work[r][_price]  = iMA(NULL,0,PreSmoothPeriod,0,PreSmoothMethod,VfiPrice,i);
         work[r][_volume] = (double)Volume[i];
         work[r][_voluma] = 0;

            if (r==0) continue;
         
               work[r][_voluma] = work[r][_volume]; for (int k=1; k<VfiPeriod && (r-k)>=0; k++) work[r][_voluma] += work[r-k][_volume];
               work[r][_voluma] /= (double)VfiPeriod;
            
         //
         //
         //
         //
         //
         
            double mf     = work[r][_price]-work[r-1][_price];
            double inter  = MathLog(work[r][_price])-MathLog(work[r-1][_price]);
            double vinter = iDeviation(inter,30,i);
            double cutoff = VfiCoeff * vinter * Close[i];
            double vave   = work[r-1][_voluma];
            double vmax   = vave*VolumeCoeff;
            double vc     = MathMin(work[r][_volume],vmax);
            double directionalVolume = 0;
               if (mf> cutoff) directionalVolume =  vc;
               if (mf<-cutoff) directionalVolume = -vc;
         
               //
               //
               //
               //
               //
            
               work[r][_dvol] = directionalVolume;
               work[r][_vfi]  = directionalVolume;  for (int k=1; k<VfiPeriod && (r-k)>=0; k++) work[r][_vfi] += work[r-k][_dvol];
               if (vave!=0)
                     work[r][_vfi] /= vave;
               else  work[r][_vfi] = 0;
         
            vfi[i]   = work[r][_vfi];
            vfs[i]   = vfs[i+1]+alpha*(work[r][_vfi]-vfs[i+1]);
            vfsua[i] = EMPTY_VALUE;
            vfsub[i] = EMPTY_VALUE;
            switch (ColorOn)
            {
               case chg_onZero:   work[r][_trend] = (vfs[i]>0)        ? 1 : (vfs[i]<0)        ? -1: work[r-1][_trend]; break;
               case chg_onSlope:  work[r][_trend] = (vfs[i]>vfs[i+1]) ? 1 : (vfs[i]<vfs[i+1]) ? -1: work[r-1][_trend]; break;
               default:           work[r][_trend] = (vfi[i]>vfs[i])   ? 1 : (vfi[i]<vfs[i])   ? -1: work[r-1][_trend];
            }               
            if (work[r][_trend]==1) PlotPoint(i,vfsua,vfsub,vfs);
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
   if (work[Bars-limit-1][_trend]==-1) CleanPoint(limit,vfsua,vfsub);
   for(int i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         vfi[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,0,y);
         vfs[i]   = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,VfiCoeff,VfiPeriod,VfiPrice,VolumeCoeff,PreSmoothPeriod,PreSmoothMethod,SmoothPeriod,ColorOn,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,1,y);
         vfsua[i] = EMPTY_VALUE;
         vfsub[i] = EMPTY_VALUE;
               if (vfs[i]>0) work[r][_trend]= 1;
               if (vfs[i]<0) work[r][_trend]=-1;

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
                  
            int n,k; datetime time = iTime(NULL,TimeFrame,y);
               for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
               for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
               {
                  vfi[i+k]  = vfi[i]  + (vfi[i+n]  - vfi[i] )*k/n;
                  vfs[i+k]  = vfs[i]  + (vfs[i+n]  - vfs[i] )*k/n;
               }
   }
   for(int i = limit, r=Bars-i-1; i >= 0; i--,r++) if (work[r][_trend]==1) PlotPoint(i,vfsua,vfsub,vfs);
   return(0);         
}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double array[];
double iDeviation(double value, double period, int i)
{
   if (ArraySize(array)!=Bars) ArrayResize(array,Bars); i= Bars-i-1; array[i] = value;
   double avg = 0; for(int k=0; k<period && (i-k)>=0; k++) avg += array[i-k]; avg /= period;
   double sum = 0; for(int k=0; k<period && (i-k)>=0; k++) sum += (array[i-k]-avg)*(array[i-k]-avg);
   return(MathSqrt(sum/period));
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

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
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
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; whichBar=Bars-whichBar-1;
      if (work[whichBar][_trend] != work[whichBar-1][_trend])
      {
         if (work[whichBar][_trend] == 1) doAlert(whichBar,"up");
         if (work[whichBar][_trend] ==-1) doAlert(whichBar,"down");
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

           message = Symbol()+" "+timeFrameToString(_Period)+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" volume flow indicator state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(" volume flow indicator ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}