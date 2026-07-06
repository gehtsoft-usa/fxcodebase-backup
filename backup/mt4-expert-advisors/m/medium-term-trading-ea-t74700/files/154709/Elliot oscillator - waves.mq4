// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=74700

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1  clrDeepSkyBlue
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrGold
#property indicator_color4  clrGold
#property indicator_color5  clrDimGray
#property indicator_color6  clrDimGray
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame        = PERIOD_CURRENT;    // Time frame
extern int             shortPeriod      =  5;                // Short period
extern int             longPeriod       = 35;                // Long period 
extern ENUM_APPLIED_PRICE Price         = PRICE_MEDIAN;      // Price (original should be median)
extern ENUM_MA_METHOD  MaMethod         = MODE_SMA;          // Average method to use (original should be SMA)
extern string          linesIdentifier  = "ew1";             // Unique ID for the indicator
extern color           linesColor       = clrBlack;          // Zigzag lines color
extern ENUM_LINE_STYLE linesStyle       = STYLE_DOT;         // Zigzag lines style
extern bool            alertsOn         = false;             // Turn alerts on?
extern bool            alertsOnCurrent  = true;              // Alerts on still opened bar?
extern bool            alertsMessage    = true;              // Alerts should display a message?
extern bool            alertsSound      = false;             // Alerts should play alert sound?
extern bool            alertsEmail      = false;             // Alerts should send email?
extern bool            alertsPush       = false;             // Alerts should send notification?
extern bool            Interpolate      = true;              // Interpolate in mtf mode?

double ellBuffer[],ellUBuffer[],ellDBuffer[],mauBuffer[],madBuffer[],peakUp[],peakDn[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,shortPeriod,longPeriod,Price,MaMethod,linesIdentifier,linesColor,linesStyle,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,alertsPush,_buff,_ind)

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
   IndicatorBuffers(9);
   SetIndexBuffer(0,ellUBuffer,INDICATOR_DATA); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,ellDBuffer,INDICATOR_DATA); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,peakUp,    INDICATOR_DATA); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,peakDn,    INDICATOR_DATA); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,mauBuffer, INDICATOR_DATA);
   SetIndexBuffer(5,madBuffer, INDICATOR_DATA);
   SetIndexBuffer(6,trend);
   SetIndexBuffer(7,ellBuffer); 
   SetIndexBuffer(8,count); 
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period); 
   
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" Elliot oscillator ( "+(string)shortPeriod+","+(string)longPeriod+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
   string lookFor = linesIdentifier+":";
   for (int i=ObjectsTotal(); i>=0; i--)
      {
         string name = ObjectName(i);
         if (StringFind(name,lookFor)==0) ObjectDelete(name);
      }
}

//
//
//
//
//

int start()
{
   double alpha = 2.0/(1.0+longPeriod+ceil(shortPeriod/2.0));
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-longPeriod); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(8,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     ellUBuffer[i] = _mtfCall(0,y);
                     ellDBuffer[i] = _mtfCall(1,y);
                     peakUp[i]     = _mtfCall(2,y);
                     peakDn[i]     = _mtfCall(3,y);
                     mauBuffer[i]  = _mtfCall(4,y);
                     madBuffer[i]  = _mtfCall(5,y);
                     ellBuffer[i]  = _mtfCall(7,y);
                 
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++)  
                           {
                              _interpolate(mauBuffer);
                              _interpolate(madBuffer);
                              _interpolate(ellBuffer); 
                              if (ellUBuffer[i]!= EMPTY_VALUE) ellUBuffer[i+k] = ellBuffer[i+k];
  	                           if (ellDBuffer[i]!= EMPTY_VALUE) ellDBuffer[i+k] = ellBuffer[i+k];
  	                           if (peakUp[i]!= EMPTY_VALUE)     peakUp[i+k]     = ellBuffer[i+k];
  	                           if (peakDn[i]!= EMPTY_VALUE)     peakDn[i+k]     = ellBuffer[i+k];
                           }
                                                      
        }   
   return(0);
   }
       
   //
   //
   //
   //
   //

      int      tcount        = 0;
      int      direction     = 0;   
      int      startFrom     = 0;
      double   lastPeakPrice = 0;
      datetime lastPeakTime  = 0;
           for (;limit<(Bars-longPeriod); limit++)
               {
                  if (peakDn[limit]!=EMPTY_VALUE) { if (tcount==0) { tcount ++; continue; } direction=-1; startFrom = limit; break; }
                  if (peakUp[limit]!=EMPTY_VALUE) { if (tcount==0) { tcount ++; continue; } direction= 1; startFrom = limit; break; }
               }

   //
   //
   //
   //
   //
   
   for(i = limit; i >= 0; i--)
   {
      ellBuffer[i]  = iMA(NULL,0,shortPeriod,0,MaMethod,Price,i)-iMA(NULL,0,longPeriod,0,MaMethod,Price,i);
      ellUBuffer[i] = ellDBuffer[i] = EMPTY_VALUE;

         if (mauBuffer[i+1]==EMPTY_VALUE) if (ellBuffer[i]>0) mauBuffer[i+1] = ellBuffer[i]; else  mauBuffer[i+1] = 0;
         if (madBuffer[i+1]==EMPTY_VALUE) if (ellBuffer[i]<0) madBuffer[i+1] = ellBuffer[i]; else  madBuffer[i+1] = 0;
            
      madBuffer[i] = madBuffer[i+1];
      mauBuffer[i] = mauBuffer[i+1];
      trend[i]     = trend[i+1];
      peakUp[i]    = peakDn[i] = EMPTY_VALUE;
         
      //
      //
      //
      //
      //
         
      if (ellBuffer[i] < 0) { madBuffer[i] = madBuffer[i+1]+alpha*(ellBuffer[i]-madBuffer[i+1]); ellDBuffer[i] = ellBuffer[i]; }
      if (ellBuffer[i] > 0) { mauBuffer[i] = mauBuffer[i+1]+alpha*(ellBuffer[i]-mauBuffer[i+1]); ellUBuffer[i] = ellBuffer[i]; }
         
         
         //
         //
         //
         //
         //
         
         ObjectDelete(linesIdentifier+":"+(string)Time[i]);
         if (ellBuffer[i] > 0 && ellBuffer[i]>mauBuffer[i])
         {
            if (direction < 0) { markLow(i,startFrom,lastPeakPrice,lastPeakTime); startFrom = i; }
                direction = 1; trend[i] = 1;
         }
         if (ellBuffer[i] < 0 && ellBuffer[i]<madBuffer[i])
         {
            if (direction > 0) { markHigh(i,startFrom,lastPeakPrice,lastPeakTime); startFrom = i; }
                direction = -1;  trend[i] = -1;
         }
   }
   if (direction > 0) markHigh(0,startFrom,lastPeakPrice,lastPeakTime); 
   if (direction < 0) markLow (0,startFrom,lastPeakPrice,lastPeakTime); 
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,DoubleToStr(mauBuffer[whichBar],5)+" crossed up");
         if (trend[whichBar] ==-1) doAlert(whichBar,DoubleToStr(madBuffer[whichBar],5)+" crossed down");
      }         
   }      
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

void markLow(int tstart, int end, double& lastPeakPrice, datetime& lastPeakTime)
{
   while (ellBuffer[tstart+1]>0 && tstart<Bars) tstart++;
   while (ellBuffer[end+1]   <0 && end   <Bars) end++;
   int peakAt = ArrayMinimum(Low,end-tstart+1,tstart); peakDn[peakAt] = ellBuffer[peakAt];
   
   //
   //
   //
   //
   //
   
   if (lastPeakPrice!=0) drawLine(lastPeakPrice,lastPeakTime,Low[peakAt],Time[peakAt]);
       lastPeakPrice = Low[peakAt];
       lastPeakTime  = Time[peakAt];
}
void markHigh(int tstart, int end, double& lastPeakPrice, datetime& lastPeakTime)
{
   while (ellBuffer[tstart+1]<0 && tstart<Bars) tstart++;
   while (ellBuffer[end+1]   >0 && end   <Bars) end++;
   int peakAt = ArrayMaximum(High,end-tstart+1,tstart); peakUp[peakAt] = ellBuffer[peakAt];
   
   //
   //
   //
   //
   //
   
   if (lastPeakPrice!=0) drawLine(lastPeakPrice,lastPeakTime,High[peakAt],Time[peakAt]);
       lastPeakPrice = High[peakAt];
       lastPeakTime  = Time[peakAt];
}

//
//
//
//
//

void drawLine(double startPrice, datetime startTime, double endPrice, datetime endTime)
{
   string name = linesIdentifier+":"+(string)startTime;
      ObjectCreate(name,OBJ_TREND,0,startTime,startPrice,endTime,endPrice);
         ObjectSet(name,OBJPROP_STYLE,linesStyle);
         ObjectSet(name,OBJPROP_COLOR,linesColor);
         ObjectSet(name,OBJPROP_RAY,false);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
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

        message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Elliot oscillator level "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(_Symbol+" Elliot oscillator ",message);
          if (alertsPush)    SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
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
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+