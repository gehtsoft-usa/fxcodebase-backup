// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70130

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_maximum 1
#property strict

//
//
//
//
//

enum enTimeFrames
{
   tf_cu  = 0,              // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mb1 = PERIOD_MN1,     // Monthly
   tf_cus = 12345678        // Custom time frame
};


extern enTimeFrames    TimeFrame             = tf_cu;             // Time frame
extern int             TimeFrameCustom       = 0;                 // Custom time frame to use (if custom time frame used)
extern int             Tenkan                = 9;                 // Tenkan Period
extern int             Kijun                 = 26;                // Kijun Period
extern int             Senkou                = 52;                // Senkou Period
extern int             KijunShift            = 0;                 // Shift Histogram to the right(+) or left(-)
extern int             HistoWidth            = 3;                 // Histogram bars width
extern color           UpHistoColor          = clrLimeGreen;      // SpanA > SpanB histogram color
extern color           DnHistoColor          = clrRed;            // SpanA < SpanB histogram color
extern color           NuHistoColor          = clrOrange;         // SpanA = SpanB histogram color
extern bool            alertsOn              = true;              // Turn alerts on?
extern bool            alertsOnCurrent       = false;             // Alerts on still opened bar?
extern bool            alertsMessage         = true;              // Alerts should show popup message?
extern bool            alertsSound           = false;             // Alerts should play a sound?
extern bool            alertsNotify          = false;             // Alerts should send notification?
extern bool            alertsEmail           = false;             // Alerts should send email?
extern bool            verticalLinesVisible  = false;             // Show vertical lines
extern bool            linesOnNewest         = false;             // Vertical lines drawn on newest bar of higher time frame bar?
extern string          verticalLinesID       = "kumo Lines";      // Lines ID
extern color           verticalLinesUpColor  = clrDeepSkyBlue;    // Lines up color 
extern color           verticalLinesDnColor  = clrPaleVioletRed;  // Lines down color
extern color           verticalLinesNuColor  = clrGold;           // Lines neutral color
extern ENUM_LINE_STYLE verticalLinesStyle    = STYLE_DOT;         // Lines style
extern int             verticalLinesWidth    = 0;                 // lines width

//
//
//
//
//


double UpH[];
double DnH[]; 
double NuH[];   
double value[];
string indicatorFileName;
bool   returnBars;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
    IndicatorBuffers(4);
      SetIndexBuffer(0,UpH); SetIndexStyle(0, DRAW_HISTOGRAM,EMPTY,HistoWidth,UpHistoColor);
      SetIndexBuffer(1,DnH); SetIndexStyle(1, DRAW_HISTOGRAM,EMPTY,HistoWidth,DnHistoColor);   
      SetIndexBuffer(2,NuH); SetIndexStyle(2, DRAW_HISTOGRAM,EMPTY,HistoWidth,NuHistoColor); 
      SetIndexBuffer(3,value); 
    
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99; 
         if (TimeFrameCustom==0) TimeFrameCustom = MathMax(TimeFrameCustom,_Period);
         if (TimeFrame!=tf_cus)
               TimeFrame = MathMax(TimeFrame,_Period);
         else  TimeFrame = (enTimeFrames)TimeFrameCustom;
         SetIndexShift(0,KijunShift * TimeFrame/Period());
         SetIndexShift(1,KijunShift * TimeFrame/Period());  
         SetIndexShift(2,KijunShift * TimeFrame/Period());    
    IndicatorShortName(timeFrameToString(TimeFrame)+" Kumo Breakout Histo");
return(0);
}  
int deinit() 
{ 
   string tlookFor       = verticalLinesID+":";
   int    tlookForLength = StringLen(tlookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,tlookForLength) == tlookFor) ObjectDelete(objectName);
   }
return(0); 
}  

//
//
//
//                           
//
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int start()
{
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1); 
           if (returnBars) { UpH[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
     for(i=limit; i>=0; i--) 
     { 
        if(i>=Bars-Tenkan) continue;
        if(i>=Bars-Kijun)  continue;
        if(i>=Bars-Senkou) continue;
        iKumo(Tenkan,Kijun,Senkou,i);
     }
     
     //
     //
     //
     //
     //
     
     if (alertsOn)
      {
        int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
        if (value[whichBar] != value[whichBar+1])
        {
           if (value[whichBar] == 1)                          doAlert(whichBar,"crossing up");
           if (value[whichBar] ==-1)                          doAlert(whichBar,"crossing down");
           if (value[whichBar] == 0 && value[whichBar+1]== 1) doAlert(whichBar,"was up, now neutral");
           if (value[whichBar] ==-0 && value[whichBar+1]==-1) doAlert(whichBar,"was down, now neutral");
         }         
      }
   return(0);
   }       
   
   //
   //
   //
   //
   //
   
   limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for (i=limit;i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         UpH[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,Tenkan,Kijun,Senkou,0,0,UpHistoColor,DnHistoColor,NuHistoColor,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,verticalLinesVisible,linesOnNewest,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesNuColor,verticalLinesStyle,verticalLinesWidth,0,y);
         DnH[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,Tenkan,Kijun,Senkou,0,0,UpHistoColor,DnHistoColor,NuHistoColor,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,verticalLinesVisible,linesOnNewest,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesNuColor,verticalLinesStyle,verticalLinesWidth,1,y);
         NuH[i] = iCustom(NULL,TimeFrame,indicatorFileName,tf_cu,0,Tenkan,Kijun,Senkou,0,0,UpHistoColor,DnHistoColor,NuHistoColor,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,verticalLinesVisible,linesOnNewest,verticalLinesID,verticalLinesUpColor,verticalLinesDnColor,verticalLinesNuColor,verticalLinesStyle,verticalLinesWidth,2,y);
   }
return(0); 
}

//
//
//
//
//

double workKumo[][8];
#define ts    0 
#define ks    1 
#define sa    2 
#define sb    3 
#define trend 4 
#define up    5 
#define dn    6 
#define nu    7 
void iKumo(int _Tenkan,int _Kijun,int _Senkou,int i)
{
     
    if(ArrayRange(workKumo,0)!= Bars) ArrayResize(workKumo,Bars); 
    int r = Bars-i-1;
    int k;
    
    double thi = High[i];
    double tlo = Low[i];
    for (k=1; k<_Tenkan; k++)
    {
        if(thi < High[i+k]) thi = High[i+k];
        if(tlo >  Low[i+k]) tlo =  Low[i+k];
    } 
    
    if ((thi+tlo) > 0.0) 
         workKumo[r][ts] = (thi+tlo)*0.5; 
    else workKumo[r][ts] = 0;
      
    double khi = High[i];
    double klo = Low[i];
    for (k=1; k<_Kijun; k++)
    {
        if(khi < High[i+k]) khi = High[i+k];
        if(klo >  Low[i+k]) klo =  Low[i+k];
    } 
    
    if ((thi+tlo) > 0.0) 
         workKumo[r][ks] = (khi+klo)*0.5; 
    else workKumo[r][ks] = 0;
    workKumo[r][sa] = (workKumo[r][ts]+workKumo[r][ks])*0.5; 
    
    double shi = High[i];
    double slo = Low[i];
    for (k = 1; k < _Senkou; k++)
    {
       if(shi < High[i+k]) shi = High[i+k];
       if(slo >  Low[i+k]) slo =  Low[i+k];
    }
    if ((shi+slo) > 0.0) 
         workKumo[r][sb] = (shi+slo)*0.5;  
    else workKumo[r][sb] = 0; 
    
    //
    //
    //
    //
    //
    
    workKumo[r][trend] = workKumo[r-1][trend];    
    workKumo[r][up] = EMPTY_VALUE; 
    workKumo[r][dn] = EMPTY_VALUE;   
    workKumo[r][nu] = EMPTY_VALUE; 
    
    if (workKumo[r][sa]  > workKumo[r][sb])  workKumo[r][trend] = 1; 
    if (workKumo[r][sa]  < workKumo[r][sb])  workKumo[r][trend] =-1; 
    if (workKumo[r][sa] == workKumo[r][sb])  workKumo[r][trend] = 0; 
    if (workKumo[r][trend] == 1) workKumo[r][up] = 1;
    if (workKumo[r][trend] ==-1) workKumo[r][dn] = 1;
    if (workKumo[r][trend] == 0) workKumo[r][nu] = 1;
    
    UpH[Bars-r-1]   = workKumo[r][up];
    DnH[Bars-r-1]   = workKumo[r][dn];
    NuH[Bars-r-1]   = workKumo[r][nu];
    value[Bars-r-1] = workKumo[r][trend];
    
    //
    //
    //
    //
    //
         
    if (verticalLinesVisible)
    {
       string tlookFor = verticalLinesID+":"+(string)Time[i]; ObjectDelete(tlookFor);  
       if (workKumo[r][trend] != workKumo[r-1][trend])
       {
          if (workKumo[r][trend] == 1)                              drawLine(i,verticalLinesUpColor);
          if (workKumo[r][trend] ==-1)                              drawLine(i,verticalLinesDnColor);
          if (workKumo[r][trend] == 0 && workKumo[r-1][trend] == 1) drawLine(i,verticalLinesNuColor);
          if (workKumo[r][trend] ==-0 && workKumo[r-1][trend] ==-1) drawLine(i,verticalLinesNuColor);
       }
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

           message =  StringConcatenate(Symbol()," ",timeFrameToString(_Period)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," spanA - spanB cross ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(), Period(), " spanA - spanB cross "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//
//
//
//
//

void drawLine(int i,color theColor)
{
      string name = verticalLinesID+":"+(string)Time[i];
   
      //
      //
      //
      //
      //
         
      datetime time = Time[i]; if (linesOnNewest) time += _Period*60-1;    
      ObjectCreate(name,OBJ_VLINE,0,time,0);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         ObjectSet(name,OBJPROP_STYLE,verticalLinesStyle);
         ObjectSet(name,OBJPROP_WIDTH,verticalLinesWidth);
         ObjectSet(name,OBJPROP_BACK,true);
}


               
     
  
  
