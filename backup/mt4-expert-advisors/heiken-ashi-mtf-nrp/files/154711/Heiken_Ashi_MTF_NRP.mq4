//Available @  https://fxcodebase.com/ 

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
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1  LimeGreen
#property indicator_color2  Red
#property indicator_color3  LimeGreen
#property indicator_color4  Red
#property indicator_color5  LimeGreen
#property indicator_color6  Red
#property indicator_color7  LimeGreen
#property indicator_color8  Red
#property indicator_minimum 0
#property indicator_maximum 5

//
//
//
//
//

extern string TimeFrame1            = "Current Time Frame";
extern string TimeFrame2            = "next1";
extern string TimeFrame3            = "next2";
extern string TimeFrame4            = "next3";
extern ENUM_MA_METHOD  MaMethod1    = MODE_SMA;
extern int    MaPeriod1             = 1;
extern ENUM_MA_METHOD  MaMethod2    = MODE_SMA;
extern int    MaPeriod2             = 1;
extern bool   UseHAHighLow          = true;
extern string UniqueID              = "4 Time Frame HA";
extern int    LinesWidth            =  0;
extern color  LabelsColor           = clrDarkGray;
extern int    LabelsHorizontalShift = 5;
extern double LabelsVerticalShift   = 1.5;
extern bool   alertsOn              = false;
extern int    alertsLevel           = 3;
extern bool   alertsMessage         = true;
extern bool   alertsSound           = true;
extern bool   alertsEmail           = false;

extern bool   All_Sig_Arrows        = true;
extern int    Arr_otstup            = 0; 
extern int    Arr_width             = 1;
extern color  Arr_Up_col            = clrLime;
extern color  Arr_Dn_col            = clrRed;
extern int    History               = 1000;

input bool NRP = false; // NRP mode:
//
//
//
//
//
double trends[];
double ha1u[];
double ha1d[];
double ha2u[];
double ha2d[];
double ha3u[];
double ha3d[];
double ha4u[];
double ha4d[];

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
{
   IndicatorBuffers(9);
   
   SetIndexBuffer(0,ha1u);
   SetIndexBuffer(1,ha1d);
   SetIndexBuffer(2,ha2u);
   SetIndexBuffer(3,ha2d);
   SetIndexBuffer(4,ha3u);
   SetIndexBuffer(5,ha3d);
   SetIndexBuffer(6,ha4u);
   SetIndexBuffer(7,ha4d);
   SetIndexBuffer(8,trends);
   
      indicatorFileName = WindowExpertName();
      returnBars        = (TimeFrame1=="returnBars");     if (returnBars)     return(0);
      calculateValue    = (TimeFrame1=="calculateValue"); if (calculateValue) return(0);
      
      //
      //
      //
      //
      //
      
      for (int i=0; i<8; i++) 
      {
         SetIndexStyle(i,DRAW_ARROW,EMPTY,LinesWidth); SetIndexArrow(i,110); 
      }
      timeFrames[0] = stringToTimeFrame(TimeFrame1);
      timeFrames[1] = stringToTimeFrame(TimeFrame2);
      timeFrames[2] = stringToTimeFrame(TimeFrame3);
      timeFrames[3] = stringToTimeFrame(TimeFrame4);
      IndicatorShortName(UniqueID);
   return(0);
}
int deinit()
{
   //for (int t=0; t<4; t++) ObjectDelete(UniqueID+t);
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
         if (limit>History) limit = History;
         if (returnBars)     { ha1u[0] = limit+1;  return(0); }
         if (calculateValue) { calculateHA(limit); return(0); }

         if (timeFrames[0] != Period()) limit = MathMax(limit,MathMin(History,iCustom(NULL,timeFrames[0],indicatorFileName,"returnBars",0,0)*timeFrames[0]/Period()));
         if (timeFrames[1] != Period()) limit = MathMax(limit,MathMin(History,iCustom(NULL,timeFrames[1],indicatorFileName,"returnBars",0,0)*timeFrames[1]/Period()));
         if (timeFrames[2] != Period()) limit = MathMax(limit,MathMin(History,iCustom(NULL,timeFrames[2],indicatorFileName,"returnBars",0,0)*timeFrames[2]/Period()));
         if (timeFrames[3] != Period()) limit = MathMax(limit,MathMin(History,iCustom(NULL,timeFrames[3],indicatorFileName,"returnBars",0,0)*timeFrames[3]/Period()));
         if (ArrayRange(trend,0)!=Bars) ArrayResize(trend,Bars);

         //
         //
         //
         //
         //
         
         static bool initialized = false;
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
         if (UseHAHighLow)
         {
            double halo = iCustom(NULL,timeFrames[k],indicatorFileName,"calculateValue","","","",MaMethod1,MaPeriod1,MaMethod2,MaPeriod2,0,y);
            double hahi = iCustom(NULL,timeFrames[k],indicatorFileName,"calculateValue","","","",MaMethod1,MaPeriod1,MaMethod2,MaPeriod2,1,y);
            bool   isUp = (hahi>halo);
         }            
         else            
         {
            double hacl = iCustom(NULL,timeFrames[k],indicatorFileName,"calculateValue","","","",MaMethod1,MaPeriod1,MaMethod2,MaPeriod2,2,y);
            double haop = iCustom(NULL,timeFrames[k],indicatorFileName,"calculateValue","","","",MaMethod1,MaPeriod1,MaMethod2,MaPeriod2,3,y);
                   isUp = (haop>hacl);
         }
         
         //
         //
         //
         //
         //
                     
         switch (k)
         {
            case 0 : if (isUp) { ha1u[i] = k+1; ha1d[i] = EMPTY_VALUE;}  else { ha1d[i] = k+1; ha1u[i] = EMPTY_VALUE; } break;
            case 1 : if (isUp) { ha2u[i] = k+1; ha2d[i] = EMPTY_VALUE;}  else { ha2d[i] = k+1; ha2u[i] = EMPTY_VALUE; } break;
            case 2 : if (isUp) { ha3u[i] = k+1; ha3d[i] = EMPTY_VALUE;}  else { ha3d[i] = k+1; ha3u[i] = EMPTY_VALUE; } break;
            case 3 : if (isUp) { ha4u[i] = k+1; ha4d[i] = EMPTY_VALUE;}  else { ha4d[i] = k+1; ha4u[i] = EMPTY_VALUE; } break;
         }
         if (isUp)
                  trend[r][_up] += 1;
            else  trend[r][_dn] += 1;
      }
     
     trends[i]=trends[i+1];
     
    if(NRP==true && (i!=1 || i!=0)){
     if(trends[i]!=1 && ha1u[i]!=EMPTY_VALUE && ha2u[i]!=EMPTY_VALUE && ha3u[i]!=EMPTY_VALUE && ha4u[i]!=EMPTY_VALUE) 
      {
        trends[i] = 1;
        arrows_wind(i,"Up",Arr_otstup ,233,Arr_Up_col,Arr_width,false);   
      }else{
        ObjectDelete(UniqueID+"Up"+TimeToStr(Time[i]));
      } 
    }
    if(NRP==true && (i!=1 || i!=0)){
     if(trends[i]!=-1 && ha1d[i]!=EMPTY_VALUE && ha2d[i]!=EMPTY_VALUE && ha3d[i]!=EMPTY_VALUE && ha4d[i]!=EMPTY_VALUE) 
      {
        trends[i] =-1;
        arrows_wind(i,"Dn",Arr_otstup ,234,Arr_Dn_col,Arr_width,true);
      }else{
       ObjectDelete(UniqueID + "Dn" + TimeToStr(Time[i],TIME_DATE|TIME_SECONDS));
      } 
    }

     if(All_Sig_Arrows)
      {  
        if(trends[i]== 1 && (ha1u[i]==EMPTY_VALUE || ha2u[i]==EMPTY_VALUE || ha3u[i]==EMPTY_VALUE || ha4u[i]==EMPTY_VALUE)) trends[i] = 0;
        if(trends[i]==-1 && (ha1d[i]==EMPTY_VALUE || ha2d[i]==EMPTY_VALUE || ha3d[i]==EMPTY_VALUE || ha4d[i]==EMPTY_VALUE)) trends[i] = 0;
      }
   }   
   manageAlerts();
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//
//
//
//
//

void calculateHA(int limit)
{
   for (int i=limit; i>=0; i--)
   {
      double maOpen  = iMA(NULL,0,MaPeriod1,0,MaMethod1,PRICE_OPEN ,i);
      double maClose = iMA(NULL,0,MaPeriod1,0,MaMethod1,PRICE_CLOSE,i);
      double maLow   = iMA(NULL,0,MaPeriod1,0,MaMethod1,PRICE_LOW  ,i);
      double maHigh  = iMA(NULL,0,MaPeriod1,0,MaMethod1,PRICE_HIGH ,i);
      double haOpen  = (ha3u[i+1]+ha3d[i+1])/2.0;
      double haClose = (maOpen+maHigh+maLow+maClose)/4;
      double haHigh  = MathMax(maHigh, MathMax(haOpen, haClose));
      double haLow   = MathMin(maLow,  MathMin(haOpen, haClose));

      if (haOpen<haClose) 
            { ha4u[i]=haLow; ha4d[i]=haHigh; } 
      else  { ha4d[i]=haLow; ha4u[i]=haHigh; } 
              ha3u[i]=haOpen;
              ha3d[i]=haClose;
   }
   for(i=limit; i>=0; i--)
   {
      ha1u[i]=iMAOnArray(ha4u,0,MaPeriod2,0,MaMethod2,i);
      ha1d[i]=iMAOnArray(ha4d,0,MaPeriod2,0,MaMethod2,i);
      ha2u[i]=iMAOnArray(ha3u,0,MaPeriod2,0,MaMethod2,i);
      ha2d[i]=iMAOnArray(ha3d,0,MaPeriod2,0,MaMethod2,i);
   }      
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
      int whichBar = Bars-1;
      if (trend[whichBar][_up] >= alertsLevel || trend[whichBar][_dn] >= alertsLevel)
      {
         if (trend[whichBar][_up] >= alertsLevel) doAlert("up"  ,trend[whichBar][_up]);
         if (trend[whichBar][_dn] >= alertsLevel) doAlert("down",trend[whichBar][_dn]);
      }
   }
}

//
//
//
//
//
void doAlert(string doWhat, int howMany)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
   if (previousAlert != doWhat || previousTime != Time[0]) {
       previousAlert  = doWhat;
       previousTime   = Time[0];

       //
       //
       //
       //
       //

       message =  Symbol()+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" "+howMany+" time frames of haDelta are aligned "+doWhat;
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(Symbol()+" 4 time frame haDelta",message);
          if (alertsSound)   PlaySound("alert2.wav");
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

//
//
//
//
//

int toInt(double value) { return(value); }
int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   int max = ArraySize(iTfTable)-1, add=0;
   int nxt = (StringFind(tfs,"NEXT1")>-1); if (nxt>0) { tfs = ""+Period(); add=1; }
       nxt = (StringFind(tfs,"NEXT2")>-1); if (nxt>0) { tfs = ""+Period(); add=2; }
       nxt = (StringFind(tfs,"NEXT3")>-1); if (nxt>0) { tfs = ""+Period(); add=3; }

      //
      //
      //
      //
      //
         
      for (int i=max; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[toInt(MathMin(max,i+add))],Period()));
                                                      return(Period());
}
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

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
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