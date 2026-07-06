//+------------------------------------------------------------------+
//|                                    Tom_Demark_Moving_Average.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Trend_Length=12;
extern int MA_Length=5;

double TDMA[], TDMA_Dn[];
double Trend[];

int init()
{
 IndicatorShortName("Tom Demark moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TDMA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,TDMA_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Trend);

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
 double Min, Max;
 double MA_L, MA_H;
 pos=limit;
 while(pos>=0)
 {
  Min=High[iLowest(NULL, 0, MODE_HIGH, Trend_Length, pos+1)];
  Max=Low[iHighest(NULL, 0, MODE_LOW, Trend_Length, pos+1)];
  
  MA_L=iMA(NULL, 0, MA_Length, 0, MODE_SMA, PRICE_LOW, pos);
  MA_H=iMA(NULL, 0, MA_Length, 0, MODE_SMA, PRICE_HIGH, pos);
  
  if (Trend[pos+1]==1. || Trend[pos+1]==-1.)
  {
   Trend[pos]=0.;
  }
  else
  {
   if (Trend[pos+1]>1.)
   {
    Trend[pos]=Trend[pos+1]-1.;
   }
   else
   {
    if (Trend[pos+1]<-1.)
    {
     Trend[pos]=Trend[pos+1]+1.;
    }
   }
  }
  
  if (Low[pos]>Max)
  {
   Trend[pos]=0.+MA_Length;
  }
  else
  {
   if (High[pos]<Min)
   {
    Trend[pos]=0.-MA_Length;
   }
  }
  
  if (Trend[pos]==MA_Length)
  {
   TDMA[pos]=MA_L;
  }
  else
  {
   if (Trend[pos]==-MA_Length)
   {
    TDMA[pos]=MA_H;
   }
   else
   {
    if (Trend[pos]!=0.)
    {
     TDMA[pos]=TDMA[pos+1];
    }
    else
    {
     TDMA[pos]=EMPTY_VALUE;
    }
   }
  }
  
  if (Trend[pos]<0.)
  {
   TDMA_Dn[pos]=TDMA[pos];
  }
  else
  {
   TDMA_Dn[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

