//Available @  https://fxcodebase.com/code/viewtopic.php?f=27&p=154365#p154365

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_chart_win
#property indicator_separate_window
#property indicator_buffers    6
#property indicator_color1     Green
#property indicator_color2     Red
#property indicator_color3     Gold
#property indicator_color4     LimeGreen
#property indicator_color5     PaleVioletRed
#property indicator_color6     PaleVioletRed
#property indicator_width1     3
#property indicator_width2     3
#property indicator_width3     3
#property indicator_width4     2
#property indicator_width5     2
#property indicator_width6     2
#property indicator_minimum    0
#property indicator_maximum    100
#property indicator_levelcolor DarkGray

//
//
//
//
//

extern int               Length                 = 7;
extern ENUM_APPLIED_PRICE Price                 = PRICE_TYPICAL;
extern double            levelOs                = 20;
extern double            levelOb                = 80;
//
input bool    T3Filter  = true;
extern int    T3Period  = 14;
extern int    T3Price   = PRICE_CLOSE;
extern int    T3Shift   = 0;
extern double b         = 0.618;
extern string TimeFrame = "current time frame";
#define INDI "T3 clean + shift",T3Period,T3Price,T3Shift,b,TimeFrame
//
extern bool              alertsOn               = true;
extern bool              alertsOnSlope          = true;
extern bool              alertsOnOsOb           = true;
extern bool              alertsOnCurrent        = false;
extern bool              alertsMessage          = true;
extern bool              alertsSound            = false;
extern bool              alertsNotify           = false;
extern bool              alertsEmail            = false;
extern string            soundFile              = "alert2.wav";
input bool               arrowsVisible          = true;              // Show arrows true/false?
input string             arrowsIdentifier       = "rsx arrows1";     // Arrows ID
input bool               arrowsOnNewest         = false;             // Arrows drawn on newest bar of higher time frame bar
input double             arrowsDisplaceUp       = 0.5;               // Arrow gap up
input double             arrowsDisplaceDn       = 0.5;               // Arrow gap down
input bool               arrowsOnZoneEnter      = false;             // Arrows on entering OB/OS zone true/false?
input color              arrowsUpZoneEnterColor = clrBlue;           // Arrows on entering OB/OS zone up color
input color              arrowsDnZoneEnterColor = clrRed;            // Arrows on entering OB/OS zone down
input int                arrowsUpZoneEnterCode  = 159;               // Arrows on entering OB/OS zone up code
input int                arrowsDnZoneEnterCode  = 159;               // Arrows on entering OB/OS zone down code
input int                arrowsUpZoneEnterSize  = 2;                 // Arrows on entering OB/OS zone up size
input int                arrowsDnZoneEnterSize  = 2;                 // Arrows on entering OB/OS zone down size
input bool               arrowsOnZoneExit       = true;              // Arrows on exiting OB/OS zone true/false?
input color              arrowsUpZoneExitColor  = clrRed;            // Arrows on exiting OB/OS zone up color
input color              arrowsDnZoneExitColor  = clrBlue;           // Arrows on exiting OB/OS zone down color
input int                arrowsUpZoneExitCode   = 234;               // Arrows on exiting OB/OS zone up code
input int                arrowsDnZoneExitCode   = 233;               // Arrows on exiting OB/OS zone down code
input int                arrowsUpZoneExitSize   = 2;                 // Arrows on exiting OB/OS zone up size
input int                arrowsDnZoneExitSize   = 2;                 // Arrows on exiting OB/OS zone down size

//
//
//
//
//

double rsx[];
double rsxDa[];
double rsxDb[];
double upArr[];
double dnArr[];
double trArr[];
double slope[];
double trend[], cross[];

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool initOK = true;
int init()
  {
   IndicatorBuffers(9);
   SetIndexBuffer(0, upArr);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 167);
   SetIndexBuffer(1, dnArr);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 167);
   SetIndexBuffer(2, trArr);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexArrow(2, 167);
   SetIndexBuffer(3, rsx);
   SetIndexBuffer(4, rsxDa);
   SetIndexBuffer(5, rsxDb);
   SetIndexBuffer(6, slope);
   SetIndexBuffer(7, trend);
   SetIndexBuffer(8, cross);
   SetLevelValue(0, levelOs);
   SetLevelValue(1, levelOb);
   IndicatorShortName("Rsx (" + Length + ")");
   ResetLastError();
   if(T3Filter)
     {
      double temp = iCustom(NULL, 0, INDI, 0, 0);
      if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
        {
         Alert("Please install the: T3 clean + shift.ex4 indicator to the MQL4/Indicators folder");
         initOK = false;
        }
     }
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   string lookFor       = arrowsIdentifier + ":";
   int    lookForLength = StringLen(lookFor);
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
      string objectName = ObjectName(i);
      if(StringSubstr(objectName, 0, lookForLength) == lookFor)
         ObjectDelete(objectName);
     }
  }


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

double wrkBuffer[][13];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
  if(!initOK)
   return(0);
   int i, r, counted_bars = IndicatorCounted();
   if(counted_bars < 0)
      return(-1);
   if(counted_bars > 0)
      counted_bars--;
   int limit = MathMin(Bars - counted_bars, Bars - 1);
   if(ArrayRange(wrkBuffer, 0) != Bars)
      ArrayResize(wrkBuffer, Bars);
   if(slope[limit] == -1)
      CleanPoint(limit, rsxDa, rsxDb);
//
//
//
//
//
   double Kg = (3.0) / (2.0 + Length);
   double Hg = 1.0 - Kg;
   for(i = limit, r = Bars - i - 1; i >= 0; i--, r++)
     {
      wrkBuffer[r][12] = iMA(NULL, 0, 1, 0, MODE_SMA, Price, i);
      if(i == (Bars - 1))
        {
         for(int c = 0; c < 12; c++)
            wrkBuffer[r][c] = 0;
         continue;
        }
      //
      //
      //
      //
      //
      double mom = wrkBuffer[r][12] - wrkBuffer[r - 1][12];
      double moa = MathAbs(mom);
      for(int k = 0; k < 3; k++)
        {
         int kk = k * 2;
         wrkBuffer[r][kk + 0] = Kg * mom                + Hg * wrkBuffer[r - 1][kk + 0];
         wrkBuffer[r][kk + 1] = Kg * wrkBuffer[r][kk + 0] + Hg * wrkBuffer[r - 1][kk + 1];
         mom = 1.5 * wrkBuffer[r][kk + 0] - 0.5 * wrkBuffer[r][kk + 1];
         wrkBuffer[r][kk + 6] = Kg * moa                + Hg * wrkBuffer[r - 1][kk + 6];
         wrkBuffer[r][kk + 7] = Kg * wrkBuffer[r][kk + 6] + Hg * wrkBuffer[r - 1][kk + 7];
         moa = 1.5 * wrkBuffer[r][kk + 6] - 0.5 * wrkBuffer[r][kk + 7];
        }
      if(moa != 0)
         rsx[i] = MathMax(MathMin((mom / moa + 1.0) * 50.0, 100.00), 0.00);
      else
         rsx[i] = 50;
      //
      //
      //
      //
      //
      rsxDa[i] = EMPTY_VALUE;
      rsxDb[i] = EMPTY_VALUE;
      upArr[i] = EMPTY_VALUE;
      dnArr[i] = EMPTY_VALUE;
      trArr[i] = EMPTY_VALUE;
      slope[i] = slope[i + 1];
      trend[i] = 0;
      if(rsx[i] > rsx[i + 1])
         slope[i] = 1;
      if(rsx[i] < rsx[i + 1])
         slope[i] = -1;
      if(rsx[i] < levelOs)
         trend[i] = 1;
      if(rsx[i] > levelOb)
         trend[i] = -1;
      if(rsx[i] > levelOs && rsx[i] < levelOb)
         trend[i] = 0;
      cross[i] = (i < Bars - 1) ? (rsx[i] > levelOb) ? 1 : (rsx[i] < levelOs) ? -1 : (rsx[i] < levelOb && rsx[i] > levelOs) ? 0 : cross[i + 1] : 0;
      if(trend[i] == 0)
         trArr[i] = 50.0;
      if(trend[i] == 1)
         upArr[i] = 50.0;
      if(trend[i] == -1)
         dnArr[i] = 50.0;
      if(slope[i] == -1)
         PlotPoint(i, rsxDa, rsxDb, rsx);
      if(arrowsVisible)
        {
         string lookFor = arrowsIdentifier + ":" + (string)Time[i];
         ObjectDelete(lookFor);
         if(i < (Bars - 1) && cross[i] != cross[i + 1])
           {
            if(arrowsOnZoneEnter && cross[i]   == 1)
               drawArrow(i, arrowsUpZoneEnterColor, arrowsUpZoneEnterCode, arrowsUpZoneEnterSize, false);
            if(arrowsOnZoneEnter && cross[i]   == -1)
               drawArrow(i, arrowsDnZoneEnterColor, arrowsDnZoneEnterCode, arrowsDnZoneEnterSize, true);
            if(arrowsOnZoneExit  && cross[i + 1] == -1 && cross[i] != 1)
               drawArrow(i, arrowsDnZoneExitColor, arrowsDnZoneExitCode, arrowsDnZoneExitSize, false);
            if(arrowsOnZoneExit  && cross[i + 1] == 1 && cross[i] != -1)
               drawArrow(i, arrowsUpZoneExitColor, arrowsUpZoneExitCode, arrowsUpZoneExitSize, true);
           }
        }
     }
//
//
//
//
//
   if(alertsOn)
     {
      int whichBar = 1;
      if(alertsOnCurrent)
         whichBar = 0;
      static datetime time1 = 0;
      static string   mess1 = "";
      if(alertsOnSlope && slope[whichBar] != slope[whichBar + 1])
        {
         if(slope[whichBar] ==  1)
            doAlert(time1, mess1, whichBar, " rsx sloping up");
         if(slope[whichBar] == -1)
            doAlert(time1, mess1, whichBar, " rsx sloping down");
        }
      static datetime time2 = 0;
      static string   mess2 = "";
      if(alertsOnOsOb && trend[whichBar] != trend[whichBar + 1])
        {
         if(trend[whichBar] ==  1)
            doAlert(time2, mess2, whichBar, " rsx oversold");
         if(trend[whichBar] == -1)
            doAlert(time2, mess2, whichBar, " rsx overbought");
         if(trend[whichBar] ==  0)
            doAlert(time2, mess2, whichBar, " rsx trade");
        }
     }
   return(0);
  }

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawArrow(int i, color theColor, int theCode, int theSize, bool tup)
  {
   double val = iCustom(Symbol(), Period(), INDI, 0, i);
   string name = arrowsIdentifier + ":" + (string)Time[i];
   double gap  = iATR(NULL, 0, 20, i);
   if(T3Filter)
     {
      if(!tup && Close[i] < val)
         return;
      if(tup && Close[i] > val)
         return;
     }
//
//
//
//
//
   datetime time = Time[i]; //if (arrowsOnNewest) time += _Period*60-1;
   ObjectCreate(name, OBJ_ARROW, 0, time, 0);
   ObjectSet(name, OBJPROP_ARROWCODE, theCode);
   ObjectSet(name, OBJPROP_WIDTH,    theSize);
   ObjectSet(name, OBJPROP_COLOR,    theColor);
   if(tup)
      ObjectSet(name, OBJPROP_PRICE1, High[i] + arrowsDisplaceUp * gap);
   else
      ObjectSet(name, OBJPROP_PRICE1, Low[i]  - arrowsDisplaceDn * gap);
  }


//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPoint(int i, double& first[], double& second[])
  {
   if((second[i]  != EMPTY_VALUE) && (second[i + 1] != EMPTY_VALUE))
      second[i + 1] = EMPTY_VALUE;
   else
      if((first[i] != EMPTY_VALUE) && (first[i + 1] != EMPTY_VALUE) && (first[i + 2] == EMPTY_VALUE))
         first[i + 1] = EMPTY_VALUE;
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PlotPoint(int i, double& first[], double& second[], double& from[])
  {
   if(first[i + 1] == EMPTY_VALUE)
     {
      if(first[i + 2] == EMPTY_VALUE)
        {
         first[i]   = from[i];
         first[i + 1] = from[i + 1];
         second[i]  = EMPTY_VALUE;
        }
      else
        {
         second[i]   =  from[i];
         second[i + 1] =  from[i + 1];
         first[i]    = EMPTY_VALUE;
        }
     }
   else
     {
      first[i]  = from[i];
      second[i] = EMPTY_VALUE;
     }
  }

//
//
//
//
//

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat)
  {
   string message;
   if(previousAlert != doWhat || previousTime != Time[forBar])
     {
      previousAlert  = doWhat;
      previousTime   = Time[forBar];
      //
      //
      //
      //
      //
      message =  StringConcatenate(Symbol(), TimeToStr(TimeLocal(), TIME_SECONDS), " rsx changed to ", doWhat);
      if(alertsMessage)
         Alert(message);
      if(alertsNotify)
         SendNotification(message);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), " rsx "), message);
      if(alertsSound)
         PlaySound(soundFile);
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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