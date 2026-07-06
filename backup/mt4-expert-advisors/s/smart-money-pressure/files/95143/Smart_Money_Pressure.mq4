//+------------------------------------------------------------------+
//|                                         Smart_Money_Pressure.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;
extern int LookBack=300;

double SMP[];
double Vol[], SM[];

int init()
{
 IndicatorShortName("Smart Money Pressure");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SMP);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Vol);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,SM);

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
 int pos;
 int First=Bars-2;
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos];
  
  pos--;
 } 

 double VolMA;
 double Change;
 pos=limit;
 while(pos>=0)
 {
  if (pos==First)
  {
   SM[pos]=0.;
  }
  else
  {
   VolMA=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
   Change=Close[pos]-Close[pos+1];
   if (Volume[pos]>VolMA)
   {
    SM[pos]=SM[pos+1]+Change;
   }
   else
   {
    SM[pos]=SM[pos+1];
   }
  
   if (LookBack==0)
   {
    SMP[pos]=Close[First]+SM[pos];
   }
   else
   {
    SMP[pos]=Close[MathMin(First, LookBack+1)]+SM[pos];
   } 
  }
  
  pos--;
 } 
 return(0);
}

