//+------------------------------------------------------------------+
//|                                               SuperTrend_Dot.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern double Multiplier=1.5;
extern int DotSize=3;

double TrUP[], TrDN[];
double UP[], DN[], TR[];

int init()
{
 IndicatorShortName("SuperTrend Dot");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW, 0, DotSize);
 SetIndexBuffer(0,TrUP);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW, 0, DotSize);
 SetIndexBuffer(1,TrDN);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,UP);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,DN);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,TR);

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
 double Median;
 double ATR;
 bool flag, flagh;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, Length, pos);
  Median=(High[pos]+Low[pos])/2.;
  
  UP[pos]=Median+ATR*Multiplier;
  DN[pos]=Median-ATR*Multiplier;
  
  if (Close[pos]>UP[pos+1])
  {
   TR[pos]=1.;
  }
  else
  {
   if (Close[pos]<DN[pos+1])
   {
    TR[pos]=-1.;
   }
   else
   {
    TR[pos]=TR[pos+1];
   }
  }
  
  if (TR[pos]<0. && TR[pos+1]>0.)
  {
   flag=true;
  }
  else
  {
   flag=false;
  }
  
  if (TR[pos]>0. && TR[pos+1]<0.)
  {
   flagh=true;
  }
  else
  {
   flagh=false;
  }
  
  if (TR[pos]>0. && DN[pos]<DN[pos+1])
  {
   DN[pos]=DN[pos+1];
  }
  
  if (TR[pos]<0. && UP[pos]>UP[pos+1])
  {
   UP[pos]=UP[pos+1];
  }
  
  if (flag)
  {
   UP[pos]=Median+ATR*Multiplier;
  }
  
  if (flagh)
  {
   DN[pos]=Median-ATR*Multiplier;
  }
  
  if (TR[pos]==1.)
  {
   TrUP[pos]=DN[pos];
   TrDN[pos]=EMPTY_VALUE;
  }
  else
  {
   TrDN[pos]=UP[pos];
   TrUP[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

