//+------------------------------------------------------------------+
//|                                    Bollinger_Bandwidth_Delta.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=20;
extern double Deviation=2.;
extern int Delta_Length=20;
extern bool Show_Percentage=false;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double BBD[], BBD_Dn[];
double Bandwidth[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,BBD);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,BBD_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Bandwidth);

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
 double MA, StdDev;
 pos=limit;
 while(pos>=0)
 {
  MA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  
  if (MA!=0.)
  {
   Bandwidth[pos]=2.*Deviation*StdDev/MA;
   if (Show_Percentage)
   {
    if (Bandwidth[pos+Delta_Length-1]!=0.)
    {
     BBD[pos]=100.*(Bandwidth[pos]-Bandwidth[pos+Delta_Length-1])/Bandwidth[pos+Delta_Length-1];
    } 
   }
   else
   {
    BBD[pos]=(Bandwidth[pos]-Bandwidth[pos+Delta_Length-1])/Point;
   }
  } 
  
  if (BBD[pos]<BBD[pos+1])
  {
   BBD_Dn[pos]=BBD[pos];
  }
  else
  {
   BBD_Dn[pos]=0.;
  }

  pos--;
 } 
 return(0);
}

