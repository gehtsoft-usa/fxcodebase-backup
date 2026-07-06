//+------------------------------------------------------------------+
//|                                                          PDI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern double Difference=100;
extern int LabelSize=3;

double Up[], Dn[];
double Pr[];
double DiffP;

int init()
{
 IndicatorShortName("Price Difference Indicator");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Up);
 SetIndexStyle(0,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(0,119);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(1,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Pr);
 
 DiffP=Difference*Point;

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  if (Difference>0)
  {
   if (Pr[pos]-Pr[pos+1]>DiffP)
   {
    Up[pos]=High[pos];
   }
   else
   {
    if (Pr[pos]-Pr[pos+1]<-DiffP)
    {
     Dn[pos]=Low[pos];
    }
   }
  }

  pos--;
 } 
 return(0);
}

