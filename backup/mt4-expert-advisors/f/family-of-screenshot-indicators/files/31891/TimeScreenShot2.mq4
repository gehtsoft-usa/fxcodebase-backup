//+------------------------------------------------------------------+
//|                                              TimeScreenShot2.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern int ScreenShotTimePeriod=1;
extern int ScreenShotWidth=1024;
extern int ScreenShotHeight=768;

datetime LastTime;

string GetFileName()
{
 string T=TimeToStr(TimeCurrent(),TIME_DATE|TIME_MINUTES);
 string Str=Symbol()+"_"+StringSetChar(T,StringFind(T,":"),'.')+".gif";
 return (Str);
}

int init()
  {
   LastTime=TimeCurrent()/(60*ScreenShotTimePeriod);
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int start()
  {
   string FileName;
   int CurTime_=TimeCurrent()/(60*ScreenShotTimePeriod);
   if (LastTime!=CurTime_)
   {
    LastTime=CurTime_;
    FileName=GetFileName();
    WindowScreenShot(FileName,ScreenShotWidth,ScreenShotHeight);
   } 
   return(0);
  }


