//+------------------------------------------------------------------+
//|                                                Effort_Result.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=14;

double ER[];
double Vol[];

int init()
{
 IndicatorShortName("Effort result");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ER);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Vol);

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

  pos--;
 } 
 
 double MaxVol, ROC;
 double Pr0, Pr1;
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, PRICE_CLOSE, pos+Length);
  
  if (Pr1!=0.)
  {
   ROC=100.*(Pr0/Pr1-1.);
  } 
  
  MaxVol=Vol[ArrayMaximum(Vol, Length, pos)];
  
  if (MaxVol!=0.)
  {
   ER[pos]=ROC/(MaxVol*Point*Point);
  }

  pos--;
 }
   
 return(0);
}

