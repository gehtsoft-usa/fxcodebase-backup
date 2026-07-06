//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75260

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
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrPaleVioletRed
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrPaleVioletRed
#property indicator_color5  clrLimeGreen
#property indicator_color6  clrPaleVioletRed
#property indicator_color7  clrLimeGreen
#property indicator_color8  clrPaleVioletRed
#property indicator_minimum 0
#property indicator_maximum 5

//
//
//
//
//

enum enTimeFrames
{
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_d1  = PERIOD_D1,      // Daily
   tf_w1  = PERIOD_W1,      // Weekly
   tf_mn1 = PERIOD_MN1,     // Monthly
   tf_n1  = -1,             // First higher time frame
   tf_n2  = -2,             // Second higher time frame
   tf_n3  = -3              // Third higher time frame
};
extern enTimeFrames    TimeFrame1            = tf_cu;  // First time frame
extern enTimeFrames    TimeFrame2            = tf_n1;
extern enTimeFrames    TimeFrame3            = tf_n2;
extern enTimeFrames    TimeFrame4            = tf_n3;
extern int             MaPeriod              = 6;
extern ENUM_MA_METHOD  MaMethod              = MODE_EMA;
extern string          UniqueID              = "4 Time Gann HiLo Ha";
extern int             LinesWidth            =  0;
extern color           LabelsColor           = clrDarkGray;
extern int             LabelsHorizontalShift = 5;
extern double          LabelsVerticalShift   = 1.25;
extern bool            alertsOn              = false;
extern int             alertsLevel           = 3;
extern bool            alertsMessage         = true;
extern bool            alertsSound           = false;
extern bool            alertsEmail           = false;
input bool             alertsNotify          = false;
extern string note4="----------------------------------------------";
extern bool   DisplayArrows                       = true;
extern int    DrawArrowsWhenTimeFrameAligned      = 4;
extern int    ArrowGap                            = 0; 
extern int    ArrowWidth                          = 1;
extern int    UpArrowWingDingsFontCode            = 241;
extern int    DownArrowWingDingsFontCode          = 242;
extern color  UpArrowColor                        = clrLime;
extern color  DownArrowColor                      = clrRed;
extern string note5="----------------------------------------------";
extern int    TimeFrame1WingdingsFontCode         = 110;
extern int    TimeFrame2WingdingsFontCode         = 110;
extern int    TimeFrame3WingdingsFontCode         = 108;
extern int    TimeFrame4WingdingsFontCode         = 108;
extern int    MaximumCandlesToDisplay             = 500;
//
//
//
//
//

double gannHiLo1u[];
double gannHiLo1d[];
double gannHiLo2u[];
double gannHiLo2d[];
double gannHiLo3u[];
double gannHiLo3d[];
double gannHiLo4u[];
double gannHiLo4d[],trends[];

int    timeFrames[4];
bool   returnBars;
bool   calculateValue;
string indicatorFileName;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{  IndicatorBuffers(9);
   SetIndexBuffer(0,gannHiLo1u);
   SetIndexBuffer(1,gannHiLo1d);
   SetIndexBuffer(2,gannHiLo2u);
   SetIndexBuffer(3,gannHiLo2d);
   SetIndexBuffer(4,gannHiLo3u);
   SetIndexBuffer(5,gannHiLo3d);
   SetIndexBuffer(6,gannHiLo4u);
   SetIndexBuffer(7,gannHiLo4d);
   SetIndexBuffer(8,trends);  
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame1==-99); if (returnBars)     return(0);
      calculateValue    = (TimeFrame1==-98); if (calculateValue) return(0);
      
      //
      //
      //
      
      for (int i=0; i<8; i++) {   SetIndexStyle(i,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(i,110); }
      
      timeFrames[0] = timeFrameValue(TimeFrame1);
      timeFrames[1] = timeFrameValue(TimeFrame2);
      timeFrames[2] = timeFrameValue(TimeFrame3);
      timeFrames[3] = timeFrameValue(TimeFrame4);

      alertsLevel = MathMin(MathMax(alertsLevel,3),4);
      IndicatorShortName(UniqueID);
   return(0);
}
int deinit()
{
   for (int t=0; t<4; t++) ObjectDelete(UniqueID+t);
       for (int i = ObjectsTotal()-1; i >= 0; i--)   
   if (StringSubstr(ObjectName(i), 0, StringLen(UniqueID)) == UniqueID)
       ObjectDelete(ObjectName(i)); 
   
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

double trend[][2];
#define _up 0
#define _dn 1
int start()
{
   int i,r,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { gannHiLo1u[0] = limit+1; return(0); }
         if (calculateValue) { calculateGann(limit); return(0); }

         if (timeFrames[0] != _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[0],indicatorFileName,-99,0,0)*timeFrames[0]/_Period));
         if (timeFrames[1] != _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[1],indicatorFileName,-99,0,0)*timeFrames[1]/_Period));
         if (timeFrames[2] != _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[2],indicatorFileName,-99,0,0)*timeFrames[2]/_Period));
         if (timeFrames[3] != _Period) limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrames[3],indicatorFileName,-99,0,0)*timeFrames[3]/_Period));
         if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);

         //
         //
         //
         //
         //
         
         bool initialized = false;
         if (!initialized)
         {
            initialized = true;
            int window = WindowFind(UniqueID);
            for (int t=0; t<4; t++)
            {
               string label = timeFrameToString(timeFrames[t]);
               ObjectCreate(UniqueID+t,OBJ_TEXT,window,0,0);
                  ObjectSet(UniqueID+t,OBJPROP_COLOR,LabelsColor);
                  ObjectSet(UniqueID+t,OBJPROP_PRICE1,t+LabelsVerticalShift);
                  ObjectSetText(UniqueID+t,label,8,"Arial");
            }               
         }
         for (t=0; t<4; t++) ObjectSet(UniqueID+t,OBJPROP_TIME1,Time[0]+Period()*LabelsHorizontalShift*60);

   //
   //
   //
   //
   //
    
   for(i = limit, r=Bars-i-1; i >= 0; i--,r++)
   {
      trend[r][_up] = 0;
      trend[r][_dn] = 0;
      for (int k=0; k<4; k++)
      {
         int y = iBarShift(NULL,timeFrames[k],Time[i]);
            double gannHiLo = iCustom(NULL,timeFrames[k],indicatorFileName,-98,0,0,0,MaPeriod,MaMethod,0,y);
            bool isUp = (gannHiLo>0);
            switch (k)
            {
               case 0 : if (isUp) { gannHiLo1u[i] = k+1; gannHiLo1d[i] = EMPTY_VALUE;}  else { gannHiLo1d[i] = k+1; gannHiLo1u[i] = EMPTY_VALUE; } break;
               case 1 : if (isUp) { gannHiLo2u[i] = k+1; gannHiLo2d[i] = EMPTY_VALUE;}  else { gannHiLo2d[i] = k+1; gannHiLo2u[i] = EMPTY_VALUE; } break;
               case 2 : if (isUp) { gannHiLo3u[i] = k+1; gannHiLo3d[i] = EMPTY_VALUE;}  else { gannHiLo3d[i] = k+1; gannHiLo3u[i] = EMPTY_VALUE; } break;
               case 3 : if (isUp) { gannHiLo4u[i] = k+1; gannHiLo4d[i] = EMPTY_VALUE;}  else { gannHiLo4d[i] = k+1; gannHiLo4u[i] = EMPTY_VALUE; } break;
            }
            if (isUp)
                  trend[r][_up] += 1;
            else  trend[r][_dn] += 1;
      }
      
       trends[i]=trends[i+1];
     
     if (DrawArrowsWhenTimeFrameAligned == 4)
        {
         if(trends[i]!=1 && gannHiLo1u[i]!=EMPTY_VALUE && gannHiLo2u[i]!=EMPTY_VALUE && gannHiLo3u[i]!=EMPTY_VALUE && gannHiLo4u[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && gannHiLo1d[i]!=EMPTY_VALUE && gannHiLo2d[i]!=EMPTY_VALUE && gannHiLo3d[i]!=EMPTY_VALUE && gannHiLo4d[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (gannHiLo1u[i]  ==EMPTY_VALUE || gannHiLo2u[i]  ==EMPTY_VALUE || gannHiLo3u[i]  ==EMPTY_VALUE || gannHiLo4u[i]  ==EMPTY_VALUE)) trends[i] = 0;
           if(trends[i]==-1 && (gannHiLo1d[i]==EMPTY_VALUE || gannHiLo2d[i]==EMPTY_VALUE || gannHiLo3d[i]==EMPTY_VALUE || gannHiLo4d[i]==EMPTY_VALUE)) trends[i] = 0;
         }  //      if (alertsHowManyTimeFrameAligned == 4)
     else 
     if (DrawArrowsWhenTimeFrameAligned == 3)
        {
         if(trends[i]!=1 && gannHiLo1u[i]!=EMPTY_VALUE && gannHiLo2u[i]!=EMPTY_VALUE && gannHiLo3u[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && gannHiLo1d[i]!=EMPTY_VALUE && gannHiLo2d[i]!=EMPTY_VALUE && gannHiLo3d[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (gannHiLo1u[i]  ==EMPTY_VALUE || gannHiLo2u[i]  ==EMPTY_VALUE || gannHiLo3u[i]  ==EMPTY_VALUE )) trends[i] = 0;
           if(trends[i]==-1 && (gannHiLo1d[i]==EMPTY_VALUE || gannHiLo2d[i]==EMPTY_VALUE || gannHiLo3d[i]==EMPTY_VALUE )) trends[i] = 0;
         } //      else if (alertsHowManyTimeFrameAligned == 3)
     else 
     if (DrawArrowsWhenTimeFrameAligned == 2)
        {
         if(trends[i]!=1 && gannHiLo1u[i]!=EMPTY_VALUE && gannHiLo2u[i]!=EMPTY_VALUE) 
         {
           trends[i] = 1;
           if (DisplayArrows) arrows_wind(i,"Up",ArrowGap ,UpArrowWingDingsFontCode,UpArrowColor,ArrowWidth,false);   
           }else{
           ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
         } 
         if(trends[i]!=-1 && gannHiLo1d[i]!=EMPTY_VALUE && gannHiLo2d[i]!=EMPTY_VALUE) 
         {
           trends[i] =-1;
           if (DisplayArrows) arrows_wind(i,"Dn",ArrowGap ,DownArrowWingDingsFontCode,DownArrowColor,ArrowWidth,true);
           }else{
           ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
           }  
           if(trends[i]== 1 && (gannHiLo1u[i]  ==EMPTY_VALUE || gannHiLo2u[i]  ==EMPTY_VALUE )) trends[i] = 0;
           if(trends[i]==-1 && (gannHiLo1d[i]==EMPTY_VALUE || gannHiLo2d[i]==EMPTY_VALUE )) trends[i] = 0;
         } //      else if (alertsHowManyTimeFrameAligned == 2)
         
   }
   manageAlerts();
   return(0);
}
void arrows_wind(int k, string N,int ots,int Code,color clr, int ArrowSize,bool up)                 
{           
   string objName = UniqueID+N+TimeToStr(Time[k]);
   double gap = ots*Point;
   
   ObjectCreate(objName, OBJ_ARROW,0,Time[k],0);
   ObjectSet   (objName, OBJPROP_COLOR, clr);  
   ObjectSet   (objName, OBJPROP_ARROWCODE,Code);
   ObjectSet   (objName, OBJPROP_WIDTH,ArrowSize);  
  if (up)
    {
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      ObjectSet(objName,OBJPROP_PRICE1,High[k]+gap);
    }else{  
      ObjectSet(objName, OBJPROP_ANCHOR,ANCHOR_TOP);
      ObjectSet(objName,OBJPROP_PRICE1,Low[k]-gap);
    }
}
//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

double work[][4];
#define haClose 0
#define haOpen  1
#define haHigh  2
#define haLow   3
void calculateGann(int limit)
{
   if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars);
   for(int i=limit, r=Bars-i-1; i>=0; i--,r++)
   {
      if (r==0)
         {
            work[r][haOpen]  = (Open[i]+Close[i])/2.0;
            work[r][haClose] = (Open[i]+Close[i]+High[i]+Low[i])/4.0;
            work[r][haHigh]  = High[i];
            work[r][haLow]   = Low[i];
            continue;
         }
         
         double maOpen  = iMA(NULL,0,MaPeriod,0,MaMethod,PRICE_OPEN ,i);
         double maClose = iMA(NULL,0,MaPeriod,0,MaMethod,PRICE_CLOSE,i);
         double maLow   = iMA(NULL,0,MaPeriod,0,MaMethod,PRICE_LOW  ,i);
         double maHigh  = iMA(NULL,0,MaPeriod,0,MaMethod,PRICE_HIGH ,i);

         //
         //
         //
               
         work[r][haOpen]  = (work[r-1][haOpen]+work[r-1][haClose])/2.0;
         work[r][haClose] = (maOpen+maHigh+maLow+maClose)/4.0;
         work[r][haHigh]  = fmax(maHigh,fmax(work[r][haOpen],work[r][haClose]));
         work[r][haLow]   = fmin(maLow ,fmin(work[r][haOpen],work[r][haClose]));
         
         gannHiLo1u[i] = gannHiLo1u[i+1];
         if(Close[i]>work[r-1][haHigh]) gannHiLo1u[i] =  1;
         if(Close[i]<work[r-1][haLow] ) gannHiLo1u[i] = -1;
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

datetime lastAlert;
bool AllowAlert(datetime tm)
{
   if (lastAlert < iTime(NULL, 0, 0))
   {
      return true;
   }
   return false; 
}


void manageAlerts()
{
   if (alertsOn && AllowAlert(TimeCurrent()))
   {
      int whichBar = Bars-1; 
      static datetime time1 = 0;
      static string   mess1 = "";
      if (trend[whichBar][_up]>=alertsLevel || trend[whichBar][_dn]>=alertsLevel)
      {
         if (trend[whichBar][_up] >= alertsLevel && trend[whichBar-1][_up]<alertsLevel) doAlert(time1,mess1,whichBar,"up",trend[whichBar][_up]);
         if (trend[whichBar][_dn] >= alertsLevel && trend[whichBar-1][_dn]<alertsLevel) doAlert(time1,mess1,whichBar,"down",trend[whichBar][_dn]);
      }              
    }         
}

//
//
//

void doAlert(datetime& previousTime, string& previousAlert, int forBar, string doWhat, int howMany)
{
   string message;
   lastAlert = TimeCurrent();
   
   if (previousAlert != doWhat || previousTime != Time[forBar]) {
       previousAlert  = doWhat;
       previousTime   = Time[forBar];

       //
       //
       //
       //
       //

        message =  _Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" "+howMany+" time frames of gann hilo ha are aligned "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(_Symbol+" 4 time frame gann hilo ha",message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

//
//
//

int timeFrameValue(int _tf)
{
   int add  = (_tf>=0) ? 0 : MathAbs(_tf);
   if (add != 0) _tf = _Period;
   int size = ArraySize(iTfTable); 
      int i =0; for (;i<size; i++) if (iTfTable[i]==_tf) break;
                                   if (i==size) return(_Period);
                                                return(iTfTable[(int)MathMin(i+add,size-1)]);
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
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