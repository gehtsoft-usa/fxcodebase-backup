//+------------------------------------------------------------------+
//|                                                      OBV_Mod.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Gate=5;

double OBV[];
double GatePips;

int init()
{
 IndicatorShortName("On Balance Volume modified");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,OBV);

 GatePips=Gate*Point;
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   OBV[pos]=Volume[pos];
  }
  else
  {
   if (Close[pos]>Close[pos+1]+GatePips)
   {
    OBV[pos]=OBV[pos+1]+Volume[pos];
   }
   else
   {
    if (Close[pos]<Close[pos+1]-GatePips)
    {
     OBV[pos]=OBV[pos+1]-Volume[pos];
    }
    else
    {
     OBV[pos]=OBV[pos+1];
    } 
   }
  }
  
  pos--;
 } 
 return(0);
}

