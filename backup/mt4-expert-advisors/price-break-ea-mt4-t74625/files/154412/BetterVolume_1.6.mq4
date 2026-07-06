// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74625

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"

// BetterVolume 1.5.mq4 
// modified to correct start loop 

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 clrRed 
#property indicator_color2 clrDeepSkyBlue 
#property indicator_color3 clrYellow 
#property indicator_color4 clrLime 
#property indicator_color5 clrWhite 
#property indicator_color6 clrMagenta 	// Climax Churn 
#property indicator_color7 clrLightSeaGreen 	// Ma 		Maroon 

#property indicator_width1 4
#property indicator_width2 4
#property indicator_width3 4
#property indicator_width4 4
#property indicator_width5 4
#property indicator_width6 4

#property tester_indicator "BetterVolume 1.6.ex4"

enum enTimeFrames
{
         tf_cu  = 0,                                                    // Current time frame
         tf_m1  = PERIOD_M1,                                            // 1 minute
         tf_m5  = PERIOD_M5,                                            // 5 minutes
         tf_m15 = PERIOD_M15,                                           // 15 minutes
         tf_m30 = PERIOD_M30,                                           // 30 minutes
         tf_h1  = PERIOD_H1,                                            // 1 hour
         tf_h4  = PERIOD_H4,                                            // 4 hours
         tf_d1  = PERIOD_D1,                                            // Daily
         tf_w1  = PERIOD_W1,                                            // Weekly
         tf_mn1 = PERIOD_MN1,                                           // Monthly
         tf_n1  = -1,                                                   // First higher time frame
         tf_n2  = -2,                                                   // Second higher time frame
         tf_n3  = -3,                                                   // Third higher time frame
         tf_cus = 12345678                                              // Custom time frame
      };
extern enTimeFrames     TimeFrame             = tf_cu; 
extern int              NumberOfBars          = 0 ; // 1500 ; 500;
extern string           Note                  = "0 means Display all bars";
extern int              MAPeriod              = 14 ;
extern int              LookBack              = 20;
extern int              width1                = 4 ;
extern int              width2                = 4 ;
input bool              alertsOn              = true;              // Alerts on true/false?
input bool              alertsOnCurrent       = false;             // Alerts on open bar true/false?
input bool              alertsMessage         = true;              // Alerts message true/false?
input bool              alertsSound           = false;             // Alerts sound true/false?
input bool              alertsNotify          = false;             // Alerts notification true/false?
input bool              alertsEmail           = false;             // Alerts email true/false?
input string            soundFile             = "alert2.wav";      // Sound file
extern bool             IgnoreLightSeaGreen   = false;
extern bool             IgnoreWhite           = false;
extern bool             IgnoreFireBrick       = false;
extern bool             IgnoreDodgerBlue      = false;
extern bool             IgnoreLightSalmon     = false;
extern bool             IgnoreMagenta         = false;
input bool              Interpolate           = true;              // Interpolate in mtf mode

double red[],blue[],yellow[],green[],white[],magenta[],v4[],count[];
color CurrentColor[3] = {White, White, White};
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,NumberOfBars,"",MAPeriod,LookBack,width1,width2,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,IgnoreLightSeaGreen,IgnoreWhite,IgnoreFireBrick,IgnoreDodgerBlue,IgnoreLightSalmon,IgnoreMagenta,_buff,_ind)

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   IndicatorBuffers(8);
   SetIndexBuffer(0,red);    SetIndexStyle(0,DRAW_HISTOGRAM,0,width2);SetIndexLabel(0,"Climax High ");
   SetIndexBuffer(1,blue);   SetIndexStyle(1,DRAW_HISTOGRAM,0,width1);SetIndexLabel(1,"Neutral");
   SetIndexBuffer(2,yellow); SetIndexStyle(2,DRAW_HISTOGRAM,0,width1);SetIndexLabel(2,"Low ");
   SetIndexBuffer(3,green);  SetIndexStyle(3,DRAW_HISTOGRAM,0,width1);SetIndexLabel(3,"HighChurn ");
   SetIndexBuffer(4,white);  SetIndexStyle(4,DRAW_HISTOGRAM,0,width2);SetIndexLabel(4,"Climax Low ");
   SetIndexBuffer(5,magenta);SetIndexStyle(5,DRAW_HISTOGRAM,0,width1);SetIndexLabel(5,"ClimaxChurn ");
   SetIndexBuffer(6,v4);     SetIndexStyle(6,DRAW_LINE,0,1);SetIndexLabel(6,"Average("+MAPeriod+")");
   SetIndexBuffer(7,count);
      
   indicatorFileName = WindowExpertName();
   TimeFrame         = (enTimeFrames)timeFrameValue(TimeFrame);
   
   IndicatorShortName(timeFrameToString(TimeFrame)+" Better Volume 1.5" );
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit() {  return(0);  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0] = limit;
         
         //
         //
         //
         
         if (TimeFrame != _Period)
         {
            limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(7,0)*TimeFrame/_Period));
            for(int i=limit; i>=0 && !_StopFlag; i--)
            {
               int y = iBarShift(NULL,TimeFrame,Time[i]);
                  red[i]     = _mtfCall(0,y);
                  blue[i]    = _mtfCall(1,y);
                  yellow[i]  = _mtfCall(2,y);
                  green[i]   = _mtfCall(3,y);
                  white[i]   = _mtfCall(4,y);
                  magenta[i] = _mtfCall(5,y);
                  v4[i]      = _mtfCall(6,y);
                  
                  //
                  //
                  //
                     
                  if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                    #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                    int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                       for(n = 1; (i+n)<Bars && Time[i+n] >= btime; n++) continue;	
                       for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                       {
                          //if (red[i]    != EMPTY_VALUE) red[i+k]     = NormalizeDouble(Volume[i+k],0);
  	                       //if (blue[i]   != EMPTY_VALUE) blue[i+k]    = NormalizeDouble(Volume[i+k],0);
  	                       //if (yellow[i] != EMPTY_VALUE) yellow[i+k]  = NormalizeDouble(Volume[i+k],0);
  	                       //if (green[i]  != EMPTY_VALUE) green[i+k]   = NormalizeDouble(Volume[i+k],0);
  	                       //if (white[i]  != EMPTY_VALUE) white[i+k]   = NormalizeDouble(Volume[i+k],0);
  	                       //if (magenta[i]!= EMPTY_VALUE) magenta[i+k] = NormalizeDouble(Volume[i+k],0);
  	                       _interpolate(v4);
                       }                 
         }
   return(0);
   }  
   
   //
   //
   //
   
   double VolLowest,Range,Value2,Value3,HiValue2,HiValue3,LoValue3,tempv2,tempv3,tempv;
   if (NumberOfBars == 0)limit = Bars-counted_bars;
   if (NumberOfBars > 0 && NumberOfBars < Bars ) limit = NumberOfBars - counted_bars;
   for(i=0; i<limit; i++)   
      {
         red[i] = EMPTY_VALUE; blue[i] = Volume[i]; yellow[i] = EMPTY_VALUE; green[i] = EMPTY_VALUE; white[i] = EMPTY_VALUE; magenta[i] = EMPTY_VALUE;
         Value2=0;Value3=0;HiValue2=0;HiValue3=0;LoValue3=99999999;tempv2=0;tempv3=0;tempv=0;
         if (i <= 2) CurrentColor[i] = clrWhite;


         VolLowest = Volume[iLowest(NULL,0,MODE_VOLUME,20,i)];
         if (Volume[i] == VolLowest)
            {
               yellow[i] = NormalizeDouble(Volume[i],0);
               blue[i]=EMPTY_VALUE;
               if (i <= 2) CurrentColor[i] = clrFireBrick;
            }

         Range = (High[i]-Low[i]);
         Value2 = Volume[i]*Range;

         if (Range != 0) Value3 = Volume[i]/Range;
         for (n=i;n<i+MAPeriod;n++){   tempv= Volume[n] + tempv; } 
         v4[i] = NormalizeDouble(tempv/MAPeriod,0);
         for (n=i;n<i+LookBack;n++)
         {
             tempv2 = Volume[n]*((High[n]-Low[n])); 
               if (tempv2 >= HiValue2) HiValue2 = tempv2;
               if (Volume[n]*((High[n]-Low[n])) != 0 )
               {           
                  tempv3 = Volume[n] / ((High[n]-Low[n]));
                  if (tempv3 > HiValue3)  HiValue3 = tempv3; 
                  if (tempv3 < LoValue3)  LoValue3 = tempv3;
               } 
         }
         if (Value2 == HiValue2  && Close[i] > (High[i] + Low[i]) / 2)
         {
               red[i]    = NormalizeDouble(Volume[i],0);
               blue[i]   = EMPTY_VALUE;
               yellow[i] = EMPTY_VALUE;
               if (i <= 2) CurrentColor[i] = clrLightSeaGreen;
         }   

         if (Value3 == HiValue3)
         {
               green[i]  = NormalizeDouble(Volume[i],0);                
               blue[i]   = EMPTY_VALUE;
               yellow[i] = EMPTY_VALUE;
               red[i]    = EMPTY_VALUE;
               if (i <= 2) CurrentColor[i] = clrDodgerBlue;
         }
         if (Value2 == HiValue2 && Value3 == HiValue3)
         {
               magenta[i] = NormalizeDouble(Volume[i],0);
               blue[i]    = EMPTY_VALUE;
               red[i]     = EMPTY_VALUE;
               green[i]   = EMPTY_VALUE;
               yellow[i]  = EMPTY_VALUE;
               if (i <= 2) CurrentColor[i] = clrMagenta;
            } 
         if (Value2 == HiValue2  && Close[i] <= (High[i] + Low[i]) / 2)
            {
               white[i]   = NormalizeDouble(Volume[i],0);
               magenta[i] = EMPTY_VALUE;
               blue[i]    = EMPTY_VALUE;
               red[i]     = EMPTY_VALUE;
               green[i]   = EMPTY_VALUE;
               yellow[i]  = EMPTY_VALUE;
               if (i <= 2) CurrentColor[i] = clrLightSalmon;
            }
      }
//----

//----
   if ((CurrentColor[1] != CurrentColor[2]))
   {
      if ((CurrentColor[1] == clrLightSeaGreen) && (IgnoreLightSeaGreen)) return(0);
      if ((CurrentColor[1] == clrWhite)         && (IgnoreWhite))         return(0);
      if ((CurrentColor[1] == clrFireBrick)     && (IgnoreFireBrick))     return(0);
      if ((CurrentColor[1] == clrDodgerBlue)    && (IgnoreDodgerBlue))    return(0);
      if ((CurrentColor[1] == clrLightSalmon)   && (IgnoreLightSalmon))   return(0);
      if ((CurrentColor[1] == clrMagenta)       && (IgnoreMagenta))       return(0);
   }
   
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
      static datetime time1 = 0;
      static string   mess1 = "";
         if (red[whichBar+1]     == EMPTY_VALUE && red[whichBar]     != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax High");
         if (blue[whichBar+1]    == EMPTY_VALUE && blue[whichBar]    != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Neutral");
         if (yellow[whichBar+1]  == EMPTY_VALUE && yellow[whichBar]  != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Low");
         if (green[whichBar+1]   == EMPTY_VALUE && green[whichBar]   != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"High Churn");
         if (white[whichBar+1]   == EMPTY_VALUE && white[whichBar]   != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax Low");
         if (magenta[whichBar+1] == EMPTY_VALUE && magenta[whichBar] != EMPTY_VALUE) doAlert(time1,mess1,whichBar,"Climax Churn");          
   }                   
return(0);
}
  
  //
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];
       
       //
       //
       //
       //
       //

       message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Better Volume "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(_Symbol+" Better Volume ",message);
          if (alertsSound)   PlaySound(soundFile);
      }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}
int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : fabs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)fmin(i+add,size-1)]);
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
