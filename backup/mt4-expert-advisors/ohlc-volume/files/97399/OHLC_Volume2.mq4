//+------------------------------------------------------------------+
//|                                                 OHLC_Volume2.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_width1 4
#property indicator_width2 4

double Up[], Dn[];

int init()
{
 IndicatorShortName("OHLC Volume indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);

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
 double UpCoeff, DnCoeff;
 double UpV, DnV;
 pos=limit;
 while(pos>=0)
 {
  UpCoeff=High[pos]-Open[pos];
  DnCoeff=Close[pos]-Low[pos];
  
  if (UpCoeff+DnCoeff!=0.)
  {
   UpV=Volume[pos]*UpCoeff/(UpCoeff+DnCoeff);
   DnV=Volume[pos]*DnCoeff/(UpCoeff+DnCoeff);
   
   if (UpV>DnV)
   {
    Up[pos]=UpV-DnV;
    Dn[pos]=0.;
   }
   else
   {
    Up[pos]=0.;
    Dn[pos]=UpV-DnV;
   }
  } 

  pos--;
 } 
 
 return(0);
}

