//+------------------------------------------------------------------+
//|                                                   Flat_Trend.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Blue
#property indicator_color3 LightBlue
#property indicator_color4 Red

extern double SAR_Step=0.02;
extern double SAR_Max=0.2;
extern int DMI_Length=14;
extern int DMI_Price=0;    // Applied price
                           // 0 - Close
                           // 1 - Open
                           // 2 - High
                           // 3 - Low
                           // 4 - Median
                           // 5 - Typical
                           // 6 - Weighted

double UpUp[], UpDn[], DnUp[], DnDn[];

int init()
{
 IndicatorShortName("Flat Trend");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,UpUp);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,UpDn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,DnUp);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,DnDn);

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
 bool One, Two;
 double DIP, DIM, SAR;
 pos=limit;
 while(pos>=0)
 {
  DIP=iADX(NULL, 0, DMI_Length, DMI_Price, MODE_PLUSDI, pos);
  DIM=iADX(NULL, 0, DMI_Length, DMI_Price, MODE_MINUSDI, pos);
  SAR=iSAR(NULL, 0, SAR_Step, SAR_Max, pos);
  
  if (DIP>DIM)
  {
   One=true;
  }
  else
  {
   One=false;
  }
  
  if (SAR<=Low[pos])
  {
   Two=true;
  }
  else
  {
   Two=false;
  }
  
  UpUp[pos]=0.;
  UpDn[pos]=0.;
  DnUp[pos]=0.;
  DnDn[pos]=0.;
  
  if (One)
  {
   if (Two)
   {
    UpUp[pos]=1.;
   }
   else
   {
    UpDn[pos]=1.;
   }
  }
  else
  {
   if (Two)
   {
    DnUp[pos]=1.;
   }
   else
   {
    DnDn[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

