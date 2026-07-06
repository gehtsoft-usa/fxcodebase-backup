//+------------------------------------------------------------------+
//|                                               TimeScreenShot.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

extern string ScreenShotTime="15:00";
extern int ScreenShotWidth=1024;
extern int ScreenShotHeight=768;

datetime LastTime;

string GetFileName()
{
 string Str=Symbol()+"_"+TimeToStr(Time[0],TIME_DATE)+"_"+StringSetChar(ScreenShotTime,StringFind(ScreenShotTime,":"),'.')+".gif";
 return (Str);
}

int init()
  {
   LastTime=TimeCurrent();
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   string FileName;
   datetime SS_Time=StrToTime(ScreenShotTime);
   if (TimeCurrent()>=SS_Time && LastTime<SS_Time)
   {
    LastTime=TimeCurrent();
    FileName=GetFileName();
    WindowScreenShot(FileName,ScreenShotWidth,ScreenShotHeight);
   }
   return(0);
  }


