//+------------------------------------------------------------------+
//|                                                   Trend_Lord.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=50;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double TL[], TL_Dn[];
double Array1[], Array2[], MA[];

int SqLength;

int init()
{
 IndicatorShortName("Trend Lord");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,TL);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,TL_Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Array1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Array2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MA);
 
 SqLength=MathSqrt(0.+Length);

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
  MA[pos]=iMA(NULL, 0, Length, 0, MODE_LWMA, Price, pos);

  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  Array1[pos]=iMAOnArray(MA, 0, SqLength, 0, MODE_LWMA, pos);
  
  Array2[pos]=Array2[pos+1];
  
  if (Array1[pos]>Array1[pos+1])
  {
   Array2[pos]=1.;
  }
  else
  {
   if (Array1[pos]<Array1[pos+1])
   {
    Array2[pos]=-1.;
   }
  }
  
  if (Array2[pos]>0.)
  {
   TL[pos]=Array1[pos];
   TL_Dn[pos]=0.;
   if (Array2[pos+1]<0.)
   {
    TL[pos+1]=Array1[pos+1];
    TL_Dn[pos+1]=0.;
   }
  }
  else
  {
   if (Array2[pos]<0.)
   {
    TL[pos]=0.;
    TL_Dn[pos]=Array1[pos];
    if (Array2[pos+1]>0.)
    {
     TL[pos+1]=0.;
     TL_Dn[pos+1]=Array1[pos+1];
    }
   }
  }

  pos--;
 } 
 return(0);
}

