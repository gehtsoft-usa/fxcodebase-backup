//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75034 

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

#property indicator_separate_window
#property indicator_buffers    7
#property indicator_color1     clrGray
#property indicator_levelcolor clrPeru
#property indicator_maximum    100
#property indicator_minimum    0
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

extern bool allowRepaint = false; // Allow Repaint Arrows
extern int                Length           = 14;               // Rsx length
extern enPrices           Price            = pr_median;        // Rsx price
extern color              ColorUp          = clrLimeGreen;     // Color for up
extern color              ColorDown        = clrRed;           // Color for down
extern color              ShadowColor      = clrGray;          // Shadow color
extern int                LineWidth        = 3;                // Main line width
extern int                ShadowWidth      = 0;                // Shadow width (<=0 main line width+3) 
extern double             levelOb          = 70;               // Overbought level
extern double             levelOs          = 30;               // Oversold level
extern bool               arrowsVisible    = true;             // Arrows visible?
extern string             arrowsIdentifier = "rsx Arrows1";    // Unique ID for arrows
extern double             arrowsUpperGap   = 1.0;              // Upper arrow gap
extern double             arrowsLowerGap   = 1.0;              // Lower arrow gap
extern color              arrowsUpColor    = clrDeepSkyBlue;   // Up arrow color
extern color              arrowsDnColor    = clrPaleVioletRed; // Down arrow color
extern int                arrowsUpCode     = 139;              // Up arrow code
extern int                arrowsDnCode     = 139;              // Down arrow code
extern bool               alertsOn         = false;            // Turn alerts on?
extern bool               alertsOnCurrent  = false;            // Alerts on still opened bar?
extern bool               alertsMessage    = true;             // Alerts should display message?
extern bool               alertsSound      = false;            // Alerts should play a sound?
extern bool               alertsNotify     = false;            // Alerts should send a notification?
extern bool               alertsEmail      = false;            // Alerts should send an email?
extern string             soundFile        = "alert2.wav";     // Sound file


double rsx[],buffer1da[],buffer1db[],buffer1ua[],buffer1ub[],shadowa[],shadowb[],value[],trend[];

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

int init()
{
   int shadowWidth = (ShadowWidth<=0) ? LineWidth+3 : ShadowWidth;
   IndicatorBuffers(9);
   SetIndexBuffer(0, rsx);       SetIndexStyle(0,EMPTY,EMPTY,LineWidth);
   SetIndexBuffer(1, shadowa);   SetIndexStyle(1,EMPTY,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(2, shadowb);   SetIndexStyle(2,EMPTY,EMPTY,shadowWidth,ShadowColor);
   SetIndexBuffer(3, buffer1ua); SetIndexStyle(3,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(4, buffer1ub); SetIndexStyle(4,EMPTY,EMPTY,LineWidth,ColorUp);
   SetIndexBuffer(5, buffer1da); SetIndexStyle(5,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(6, buffer1db); SetIndexStyle(6,EMPTY,EMPTY,LineWidth,ColorDown);
   SetIndexBuffer(7, trend);
   SetIndexBuffer(8, value);
   SetLevelValue(0,levelOs);
   SetLevelValue(1,levelOb);
   SetLevelValue(2,50);
      
   IndicatorShortName("Rsx ("+(string)Length+")");
return(0);
}
int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
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

double wrkBuffer[][13];
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         
   //
   //
   //
   //
   //
   
     double Kg = (3.0)/(2.0+Length); 
     double Hg = 1.0-Kg;
     if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
     if (value[limit]==-1) { CleanPoint(limit,buffer1da,buffer1db); CleanPoint(limit,shadowa,shadowb); }
     if (value[limit]== 1) { CleanPoint(limit,buffer1ua,buffer1ub); CleanPoint(limit,shadowa,shadowb); }
     
     for(i=limit, r=Bars-i-1; i>=0; i--, r++)
     {
        wrkBuffer[r][12] = getPrice(Price,Open,Close,High,Low,i);
        if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

        //
        //
        //
        //
        //
      
        double mom = wrkBuffer[r][12]-wrkBuffer[r-1][12];
        double moa = fabs(mom);
        for (int k=0; k<3; k++)
        {
           int kk = k*2;
              wrkBuffer[r][kk+0] = Kg*mom                + Hg*wrkBuffer[r-1][kk+0];
              wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; mom = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
              wrkBuffer[r][kk+6] = Kg*moa                + Hg*wrkBuffer[r-1][kk+6];
              wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; moa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
        }
        if (moa != 0)
             rsx[i] = fmax(fmin((mom/moa+1.0)*50.0,100.00),0.00); 
        else rsx[i] = 50;
        buffer1da[i] = EMPTY_VALUE;
        buffer1db[i] = EMPTY_VALUE;
        buffer1ua[i] = EMPTY_VALUE;
        buffer1ub[i] = EMPTY_VALUE;
        shadowa[i]   = EMPTY_VALUE;
        shadowb[i]   = EMPTY_VALUE;       
        value[i] =  (rsx[i]>levelOb)  ? -1 : (rsx[i]<levelOs) ?  1 :  0;   
        trend[i] =  (rsx[i]>levelOb)  ?  1 : (rsx[i]<levelOs) ? -1 :  0;  
        if (value[i] == -1) { PlotPoint(i,buffer1da,buffer1db,rsx); PlotPoint(i,shadowa,shadowb,rsx); }
        if (value[i] ==  1) { PlotPoint(i,buffer1ua,buffer1ub,rsx); PlotPoint(i,shadowa,shadowb,rsx); }     
        
        //
        //
        //
        //
        //
      
         if (arrowsVisible)
          {
               if (allowRepaint) { string lookFor = arrowsIdentifier+":"+(string)Time[i]; ObjectDelete(lookFor); }
            
               if (i<Bars-1 && trend[i] != trend[i+1])
               {
                  if (trend[i+1] ==  1 && trend[i] != 1) drawArrow(i,arrowsDnColor,arrowsDnCode, true);
                  if (trend[i+1] == -1 && trend[i] !=-1) drawArrow(i,arrowsUpColor,arrowsUpCode,false);
               }
            }
     }
     if (alertsOn)
     {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
        if (trend[whichBar] != trend[whichBar+1])
        {
           if (trend[whichBar+1] ==  1 && trend[whichBar] != 1) doAlert(whichBar,"sell");
           if (trend[whichBar+1] == -1 && trend[whichBar] !=-1) doAlert(whichBar,"buy");
        }         
     }
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
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
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

#define priceInstances 3
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

        message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Rsx ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsNotify)  SendNotification(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol()," Rsx "),message);
          if (alertsSound)   PlaySound(soundFile);
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

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+(string)Time[i];
   double gap  = iATR(NULL,0,20,i);   
   
      //
      //
      //
      //
      //

      //int add = 0; if (!arrowsOnFirst) add = _Period*60-1;
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i] + arrowsUpperGap * gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i]  - arrowsLowerGap * gap);
}

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