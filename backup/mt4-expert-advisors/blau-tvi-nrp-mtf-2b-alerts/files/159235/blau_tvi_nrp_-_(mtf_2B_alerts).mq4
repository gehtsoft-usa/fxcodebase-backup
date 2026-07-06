//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75932&p=159235#p159235

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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
#property indicator_separate_window
#property strict
#property indicator_buffers 3
#property indicator_label1  "Blau TVI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_width1  2
#property indicator_label2  "Blau TVI"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrOrangeRed
#property indicator_width2  2
#property indicator_label3  "Blau TVI"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_width3  2

//
//
//
//
//

enum enColorOn
{
   cc_onSlope,   // Change color on slope change
   cc_onZero     // Change color on zero cross
};

extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_CURRENT;    // Time frame to use
input double          tr               = 12;                // Period 1
input double          s                = 12;                // Period 2
input double          u                = 5;                 // Period 3
input enColorOn       ColorOn          = cc_onSlope;        // Color change on :
input bool            arrowsVisible    = false;             // Arrows visible true/false?
input bool            arrowsOnNewest   = false;             // Arrows drawn on newest bar of higher time frame bar true/false?
input string          arrowsIdentifier = "tvi Arrows1";     // Unique ID for arrows
input double          arrowsUpperGap   = 0.5;               // Upper arrow gap
input double          arrowsLowerGap   = 0.5;               // Lower arrow gap
input color           arrowsUpColor    = clrBlue;           // Up arrow color
input color           arrowsDnColor    = clrCrimson;        // Down arrow color
input int             arrowsUpCode     = 116;               // Up arrow code
input int             arrowsDnCode     = 116;               // Down arrow code
input int             arrowsUpSize     = 2;                 // Up arrow size
input int             arrowsDnSize     = 2;                 // Down arrow size
input double          levUp            = 4.0;               // Upper level
input double          levDn            = -4.0;              // Lower level
input color           levClr           = clrMediumOrchid;   // Level color
input ENUM_LINE_STYLE levSty           = STYLE_DOT;         // Level style 
input bool            Interpolate      = true;              // Interpolate in mtf mode?

enum alert
  {
   Off = 0, // Off
   Current = 1, // At current bar
   Previous = 2 // At previous closed bar
  };
input alert  notificationsOn       = 1;                      // Notifications
input bool   desktop_notifications = true;                   // Desktop MT4 notifications
input bool   email_notifications   = false;                  // Email notifications
input bool   push_notifications    = false;                  // Push mobile notifications
input bool   sound_notifications   = false;                  // Sound notifications
input string sound_file = "Tick.wav";                        // Choose a sound file for notifications

double val[],valda[],valdb[],valc[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_ind) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,tr,s,u,ColorOn,arrowsVisible,arrowsOnNewest,arrowsIdentifier,arrowsUpperGap,arrowsLowerGap,arrowsUpColor,arrowsDnColor,arrowsUpCode,arrowsDnCode,arrowsUpSize,arrowsDnSize,levUp,levDn,levClr,levSty,_buff,_ind)

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc);
   SetIndexBuffer(4,count); 
   
   
   IndicatorSetInteger(INDICATOR_LEVELS,3);
   IndicatorSetDouble( INDICATOR_LEVELVALUE,0,levUp);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,0,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,levClr);  
   IndicatorSetDouble( INDICATOR_LEVELVALUE,1,levDn);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,1,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,levClr);  
   IndicatorSetDouble( INDICATOR_LEVELVALUE,2,0);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE,2,levSty);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,levClr);  
   
   indicatorFileName = WindowExpertName();
   TimeFrame         = fmax(TimeFrame,_Period);
  
   IndicatorSetString(INDICATOR_SHORTNAME,timeFrameToString(TimeFrame)+" Blau TVI ("+DoubleToStr(tr,2)+","+DoubleToStr(s,2)+","+DoubleToStr(u,2)+")");
return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{ 
    string lookFor       = arrowsIdentifier+":";
    int    lookForLength = StringLen(lookFor);
    for (int i=ObjectsTotal()-1; i>=0; i--)
    {
       string objectName = ObjectName(i);
       if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
    }
}

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
                 const int&      spread[])

{
   int i,limit=fmin(rates_total-prev_calculated+1,rates_total-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(rates_total-1,_mtfCall(4,0)*TimeFrame/_Period));
               if (valc[i]==-1) iCleanPoint(limit,valda,valdb);
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,time[i]);
                     val[i]   = _mtfCall(0,y);
                     valda[i] = valdb[i] = EMPTY_VALUE; 
                     valc[i]  = _mtfCall(3,y);
                 
                     //
                     //
                     //
                     //
                     //
                     
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime btime = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<rates_total && time[i+n] >= btime; n++) continue;	
                           for(k = 1; k<n && (i+n)<rates_total && (i+k)<rates_total; k++) _interpolate(val);
                                                       
              }   
              for (i=limit;i>=0 && !_StopFlag; i--)  if (valc[i] == -1) iPlotPoint(i,valda,valdb,val); 
	return(rates_total);
	}      
   
   //
   //
   //
   //
   //
   
   if (valc[i]==-1) iCleanPoint(limit,valda,valdb);
   for(i=limit;i>=0 && !_StopFlag; i--)
   {
      double upTic = (tick_volume[i]+(close[i]-open[i])/_Point)/2.0;
      double dnTic = (tick_volume[i]-upTic);
      double avgUp = iEma(iEma(upTic,tr,i,rates_total,0),s,i,rates_total,1);
      double avgDn = iEma(iEma(dnTic,tr,i,rates_total,2),s,i,rates_total,3);
      val[i]   = (avgUp+avgDn != 0) ? iEma(100.0*(avgUp-avgDn)/(avgUp+avgDn),u,i,rates_total,4) : 0;   
      
      switch(ColorOn)
      {
           case cc_onZero: if (i<rates_total-1) valc[i] = (val[i]>0)        ? 1 : (val[i]<0)        ? -1 : valc[i+1]; break;
           default :       if (i<rates_total-1) valc[i] = (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? -1 : valc[i+1];
      }      
      valda[i] = valdb[i] = EMPTY_VALUE; if (valc[i] == -1) iPlotPoint(i,valda,valdb,val);  
      
      //
      //
      //
      //
      //
      
      if (arrowsVisible)
      {
         string lookFor = arrowsIdentifier+":"+(string)time[i]; ObjectDelete(lookFor);            
         if (i<(rates_total-1) && valc[i] != valc[i+1])
         {
            if (valc[i] == 1) drawArrow(i,arrowsUpColor,arrowsUpCode,arrowsUpSize,false);
            if (valc[i] ==-1) drawArrow(i,arrowsDnColor,arrowsDnCode,arrowsDnSize, true);
         }
      }    
   }
     if(notificationsOn > 0)
     {
      checkAlert();
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

double workEma[][5];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);  r = _bars-r-1;

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void iCleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}
void iPlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
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

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void drawArrow(int i,color theColor,int theCode, int theSize, bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      datetime atime = Time[i]; if (arrowsOnNewest) atime += _Period*60-1;      
      ObjectCreate(name,OBJ_ARROW,0,atime,0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_WIDTH,theSize);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

 
bool alerted;
void checkAlert()
  {
   bool nb = IsNewBar();
   if(nb)
      alerted = false;
   if(notificationsOn == 1 && !alerted)
     {
      if(valc[0] != valc[1] && valc[0] == 1)
        {
         Notify(1);
         alerted = true;
        }
      if(valc[0] != valc[1] && valc[0] == -1)
        {
         Notify(2);
         alerted = true;
        }
     }
   if(notificationsOn == 2 && nb)
     {
      if(valc[1] != valc[2] && valc[1] == 1)
        {
         Notify(11);
        }
      if(valc[1] != valc[2] && valc[1] == -1)
        {
         Notify(22);
        }
     }
  }
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsNewBar()
  {
   static datetime lastbar;
   datetime curbar = (datetime)SeriesInfoInteger(_Symbol, _Period, SERIES_LASTBAR_DATE);
   if(lastbar != curbar)
     {
      lastbar = curbar;
      return true;
     }
   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Notify(int type)
  {
   string text = "Blau fvi nrp: ";
   switch(type)
     {
      case 1:
         text += " Turn UP before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 2:
         text += " Turn DOWN before bar closes - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 11:
         text += " Turned UP after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
      case 22:
         text += " Turned DOWN after bar closed - " + _Symbol + " " + GetTimeFrame(_Period);
         break;
     }
   text += " ";
   if(desktop_notifications)
      Alert(text);
   if(push_notifications)
      SendNotification(text);
   if(email_notifications)
      SendMail("MetaTrader Notification", text);
   if(sound_notifications)
      PlaySound(sound_file);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetTimeFrame(int lPeriod)
  {
   switch(lPeriod)
     {
      case PERIOD_M1:
         return ("M1");
      case PERIOD_M5:
         return ("M5");
      case PERIOD_M15:
         return ("M15");
      case PERIOD_M30:
         return ("M30");
      case PERIOD_H1:
         return ("H1");
      case PERIOD_H4:
         return ("H4");
      case PERIOD_D1:
         return ("D1");
      case PERIOD_W1:
         return ("W1");
      case PERIOD_MN1:
         return ("MN1");
     }
   return IntegerToString(lPeriod);
  }
//+------------------------------------------------------------------+
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75932&p=159235#p159235

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright ©  2025, Gehtsoft USA LLC  | 
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