//+------------------------------------------------------------------+
//|                                                         Buff.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=20;

double Buff[];
double VC[], Vol[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Buff);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,VC);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Vol);

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
  Vol[pos]=Volume[pos];
  VC[pos]=Volume[pos]*Close[pos];

  pos--;
 } 
 
 double AvgVC, AvgVol;
 pos=limit;
 while(pos>=0)
 {
  AvgVC=iMAOnArray(VC, 0, Length, 0, MODE_SMA, pos);
  AvgVol=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  
  if (AvgVol!=0.)
  {
   Buff[pos]=AvgVC/AvgVol;
  }

  pos--;
 }
   
 return(0);
}

