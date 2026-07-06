// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75554

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
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrPaleVioletRed
#property indicator_width3  2
#property indicator_width4  2
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES TimeFrame             = PERIOD_CURRENT; // Time frame
extern bool            UseAutomaticMaPeriods = false;          // Use automatic settings?
extern ENUM_MA_METHOD  MaMethod              = MODE_SMMA;      // Smoothing method
extern int             MaPeriod              = 6;              // Smoothing period
extern bool            alertsOn              = false;          // Alerts on?
extern bool            alertsOnBody          = true;           // Alerts on body change?
extern bool            alertsOnWick          = false;          // Alerts on wick change?
extern bool            alertsOnCurrent       = false;          // Alerts on current?
extern bool            alertsMessage         = true;           // Alerts message?
extern bool            alertsNotification    = false;          // Alerts push notification?
extern bool            alertsSound           = false;          // Alerts sound?
extern bool            alertsEmail           = false;          // Alerts email?
extern bool            Interpolate           = true;           // Interpolate in multi time frame mode?

//
//
//
//
//

double hahu[],hahd[],hahbu[],hahbd[],trendw[],trendb[],count[];
string indicatorFileName;
#define _mtfCall(_buf,_ind) iCustom(NULL,TimeFrame,indicatorFileName,0,UseAutomaticMaPeriods,MaMethod,MaPeriod,alertsOn,alertsOnBody,alertsOnWick,alertsOnCurrent,alertsMessage,alertsNotification,alertsSound,alertsEmail,_buf,_ind)

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int init()
{
   IndicatorDigits(Digits);
   IndicatorBuffers(7);
   SetIndexBuffer(0,hahd);  SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1,hahu);  SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2,hahbd); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3,hahbu); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4,trendw);SetIndexStyle(4,DRAW_NONE); 
   SetIndexBuffer(5,trendb);SetIndexStyle(5,DRAW_NONE); 
   SetIndexBuffer(6,count);
      if (UseAutomaticMaPeriods)
         switch(_Period) 
         {
            case PERIOD_M1:  MaPeriod = 150; break;
            case PERIOD_M5:  MaPeriod =  60; break;
            case PERIOD_M15: MaPeriod =  80; break;
            case PERIOD_M30: MaPeriod = 192; break;
            case PERIOD_H1:  MaPeriod =  96; break;
            case PERIOD_H4:  MaPeriod = 120; break;
            default :        MaPeriod = 80;
         }
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         TimeFrame         = MathMax(TimeFrame,_Period);
      
      //
      //
      //
      //
      //
   
   return(0);
}   
 
//
//
//
//
//
     
int deinit() { return(0); }

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
            int limit = MathMin(Bars-counted_bars,Bars-1); count[0] = limit;
            if (TimeFrame != _Period)
            {
               limit = (int)MathMax(limit,MathMin(Bars-1,_mtfCall(6,0)*TimeFrame/Period()));
               for (int i=limit; i>=0; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     hahd[i]  = _mtfCall(0,y);
                     hahu[i]  = _mtfCall(1,y);
                     hahbd[i] = _mtfCall(2,y);
                     hahbu[i] = _mtfCall(3,y);
                     //
                     //
                     //
                     //
                     //

                        if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                           #define _interpolate(_buff) _buff[i+k] = _buff[i]+(_buff[i+n]-_buff[i])*k/n
                           int n,k; datetime time = iTime(NULL,TimeFrame,y);
                              for(n = 1; (i+n)<Bars && Time[i+n]>=time; n++) continue;	
                              for(k = 1; (k<n) && (i+n)<Bars && (i+k)<Bars; k++)
                              {
                                 _interpolate(hahbd); 
                                 _interpolate(hahbu); 
                                 _interpolate(hahd); 
                                 _interpolate(hahu); 
                           }               
                  }
                  return(0);
            }

   //
   //
   //
   //
   //
   
      for (int i=limit; i>=0; i--)
      {
         double haHigh,haLow,haOpen,haClose;
            calculateHA(MaPeriod,MaMethod,haOpen,haClose,haHigh,haLow,i);
            
            hahu[i]  = haHigh; 
            hahd[i]  = haLow;
            hahbu[i] = haOpen;
            hahbd[i] = haClose;
                     trendb[i] = (i<Bars-1) ? trendb[i+1] : 0;
                     trendw[i] = (i<Bars-1) ? trendw[i+1] : 0;
                     if (hahu[i] <hahd[i])  trendw[i] =  1;
                     if (hahu[i] >hahd[i])  trendw[i] = -1;
                     if (hahbu[i]<hahbd[i]) trendb[i] =  1;
                     if (hahbu[i]>hahbd[i]) trendb[i] = -1;
      }            
      manageAlerts();
      return(0);      
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

#define _haInstances     1
#define _haInstancesSize 4
double workHa[][_haInstances*_haInstancesSize];
#define _haH 0
#define _haL 1
#define _haO 2
#define _haC 3

void calculateHA(int maPeriod, int maMethod, double& tOpen, double& tClose, double& tHigh, double& tLow, int i, int instanceNo=0)
{
   if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); int r=Bars-i-1; instanceNo*=_haInstancesSize;
   
   //
   //
   //
   //
   //
   
      double maOpen  = iMA(NULL,0,maPeriod,0,maMethod,PRICE_OPEN ,i);
      double maClose = iMA(NULL,0,maPeriod,0,maMethod,PRICE_CLOSE,i);
      double maLow   = iMA(NULL,0,maPeriod,0,maMethod,PRICE_LOW  ,i);
      double maHigh  = iMA(NULL,0,maPeriod,0,maMethod,PRICE_HIGH ,i);
      double haOpen  = (r>0) ? (workHa[r-1][instanceNo+_haO] + workHa[r-1][instanceNo+_haC])/2.0 : maOpen;
      double haClose = (maOpen+maHigh+maLow+maClose)/4;
      double haHigh  = MathMax(maHigh, MathMax(haOpen, haClose));
      double haLow   = MathMin(maLow,  MathMin(haOpen, haClose));

      if(haOpen<haClose) { workHa[r][instanceNo+_haH] = haLow;  workHa[r][instanceNo+_haL] = haHigh; } 
      else               { workHa[r][instanceNo+_haH] = haHigh; workHa[r][instanceNo+_haL] = haLow;  } 
                           workHa[r][instanceNo+_haO] = haOpen;
                           workHa[r][instanceNo+_haC] = haClose;
      //
      //
      //
      //
      //
      
   tHigh  = workHa[r][instanceNo+_haH];
   tLow   = workHa[r][instanceNo+_haL];
   tOpen  = workHa[r][instanceNo+_haO];
   tClose = workHa[r][instanceNo+_haC];
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
      
      //
      //
      //
      //
      //
      
      static datetime prevTime1  = 0;
      static string   prevAlert1 = "";
         if (alertsOnBody && trendb[whichBar] != trendb[whichBar+1])
         {
            if (trendb[whichBar] ==  1) doAlert(prevTime1,prevAlert1," Main HA trend changed to up");
            if (trendb[whichBar] == -1) doAlert(prevTime1,prevAlert1," Main HA trend changed to down");
         }
      static datetime prevTime2  = 0;
      static string   prevAlert2 = "";
         if (alertsOnWick && trendw[whichBar] != trendw[whichBar+1])
         {
            if (trendw[whichBar] ==  1) doAlert(prevTime2,prevAlert2," HA wick trend changed to up");
            if (trendw[whichBar] == -1) doAlert(prevTime2,prevAlert2," HA wick trend changed to down");
         }
   }
}

//
//
//
//
//

void doAlert(datetime& previousTime, string& previousAlert, string doWhat)
{
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+doWhat;
          if (alertsMessage)      Alert(message);
          if (alertsNotification) SendNotification(message);
          if (alertsEmail)        SendMail(StringConcatenate(Symbol(),"HA smoothed 3 "),message);
          if (alertsSound)        PlaySound("alert2.wav");
   }
}
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75554

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