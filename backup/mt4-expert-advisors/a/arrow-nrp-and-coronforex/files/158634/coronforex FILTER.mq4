//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75721

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

extern int    Length          = 7;
extern int    Price           = PRICE_TYPICAL;
extern double levelOs         = 20;
extern double levelOb         = 80;
extern bool   alertsOn        = true;
extern bool   alertsOnSlope   = true;
extern bool   alertsOnOsOb    = true;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsNotify    = false;
extern bool   alertsEmail     = false;
extern string soundFile       = "alert2.wav";

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
double trend[];

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
   IndicatorBuffers(8);
      SetIndexBuffer(0,upArr);  SetIndexStyle(0,DRAW_ARROW); SetIndexArrow(0,167);
      SetIndexBuffer(1,dnArr);  SetIndexStyle(1,DRAW_ARROW); SetIndexArrow(1,167);
      SetIndexBuffer(2,trArr);  SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,167);
      SetIndexBuffer(3,rsx);
      SetIndexBuffer(4,rsxDa);
      SetIndexBuffer(5,rsxDb);
      SetIndexBuffer(6,slope);
      SetIndexBuffer(7,trend);
      SetLevelValue(0,levelOs);
      SetLevelValue(1,levelOb);
   IndicatorShortName("Rsx ("+Length+")");
   return(0);
}
int deinit() { return(0); }

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
         if (ArrayRange(wrkBuffer,0) != Bars) ArrayResize(wrkBuffer,Bars);
         if (slope[limit]==-1) CleanPoint(limit,rsxDa,rsxDb);

   //
   //
   //
   //
   //
   
   double Kg = (3.0)/(2.0+Length); 
   double Hg = 1.0-Kg;
   for(i=limit, r=Bars-i-1; i>=0; i--, r++)
   {
      wrkBuffer[r][12] = iMA(NULL,0,1,0,MODE_SMA,Price,i);
      if (i==(Bars-1)) { for (int c=0; c<12; c++) wrkBuffer[r][c] = 0; continue; }  

      //
      //
      //
      //
      //
      
      double mom = wrkBuffer[r][12]-wrkBuffer[r-1][12];
      double moa = MathAbs(mom);
      for (int k=0; k<3; k++)
      {
         int kk = k*2;
            wrkBuffer[r][kk+0] = Kg*mom                + Hg*wrkBuffer[r-1][kk+0];
            wrkBuffer[r][kk+1] = Kg*wrkBuffer[r][kk+0] + Hg*wrkBuffer[r-1][kk+1]; mom = 1.5*wrkBuffer[r][kk+0] - 0.5 * wrkBuffer[r][kk+1];
            wrkBuffer[r][kk+6] = Kg*moa                + Hg*wrkBuffer[r-1][kk+6];
            wrkBuffer[r][kk+7] = Kg*wrkBuffer[r][kk+6] + Hg*wrkBuffer[r-1][kk+7]; moa = 1.5*wrkBuffer[r][kk+6] - 0.5 * wrkBuffer[r][kk+7];
      }
      if (moa != 0)
           rsx[i] = MathMax(MathMin((mom/moa+1.0)*50.0,100.00),0.00); 
      else rsx[i] = 50;
      
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
      slope[i] = slope[i+1];
      trend[i] = 0;
         if (rsx[i]>rsx[i+1])                  slope[i] = 1;
         if (rsx[i]<rsx[i+1])                  slope[i] =-1;
         if (rsx[i]<levelOs)                   trend[i] = 1; 
         if (rsx[i]>levelOb)                   trend[i] =-1;
         if (rsx[i]>levelOs && rsx[i]<levelOb) trend[i] = 0; 
         if (trend[i] == 0) trArr[i] = 50.0; 
         if (trend[i] == 1) upArr[i] = 50.0;
         if (trend[i] ==-1) dnArr[i] = 50.0;
         if (slope[i] ==-1) PlotPoint(i,rsxDa,rsxDb,rsx);
   }
   
   //
   //
   //
   //
   //
   
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1;
      
      //
      //
      //
      //
      //
      
      static datetime time1 = 0;
      static string   mess1 = "";
         if (alertsOnSlope && slope[whichBar] != slope[whichBar+1])
         {
            if (slope[whichBar] ==  1) doAlert(time1,mess1,whichBar," rsx sloping up");
            if (slope[whichBar] == -1) doAlert(time1,mess1,whichBar," rsx sloping down");
         }            
      static datetime time2 = 0;
      static string   mess2 = "";
         if (alertsOnOsOb && trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] ==  1) doAlert(time2,mess2,whichBar," rsx oversold");
            if (trend[whichBar] == -1) doAlert(time2,mess2,whichBar," rsx overbought");
            if (trend[whichBar] ==  0) doAlert(time2,mess2,whichBar," rsx trade");
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
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (first[i+1] == EMPTY_VALUE)
      {
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
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

          message =  StringConcatenate(Symbol(),TimeToStr(TimeLocal(),TIME_SECONDS)," rsx changed to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol()," rsx "),message);
             if (alertsSound)   PlaySound(soundFile);
      }
}
//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75721

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