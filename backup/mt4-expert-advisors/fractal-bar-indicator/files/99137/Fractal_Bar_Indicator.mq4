//+------------------------------------------------------------------+
//|                                        Fractal_Bar_Indicator.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

double Up[], Dn[], Ne[];
int UpFr, DnFr;

int init()
{
 IndicatorShortName("Fractal bar indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Ne);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Dn);
 
 UpFr=0; DnFr=0;

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
  if (High[pos+2]>High[pos+4] && High[pos+2]>High[pos+3] && High[pos+2]>High[pos+1] && High[pos+2]>High[pos])
  {
   UpFr=pos+2;
  }
  
  if (Low[pos+2]<Low[pos+4] && Low[pos+2]<Low[pos+3] && Low[pos+2]<Low[pos+1] && Low[pos+2]<Low[pos])
  {
   DnFr=pos+2;
  }
  
  Ne[pos]=1.;
  Up[pos]=0.;
  Dn[pos]=0.;
  
  
  if (UpFr>0 && DnFr>0)
  {
   if (Close[pos]>High[UpFr])
   {
    Up[pos]=1.;
   }
   if (Close[pos]<Low[DnFr])
   {
    Dn[pos]=1.;
   }
  }

  pos--;
 } 
 return(0);
}

