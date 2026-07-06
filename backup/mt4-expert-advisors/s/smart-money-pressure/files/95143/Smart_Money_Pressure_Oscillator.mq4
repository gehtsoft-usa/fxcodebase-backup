//+------------------------------------------------------------------+
//|                              Smart_Money_Pressure_Oscillator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=14;

double SMP[];
double Vol[], SM[];

int init()
{
 IndicatorShortName("Smart Money Pressure Oscillator");
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
   SM[pos]=Close[pos];
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
  
   SMP[pos]=(Close[First]-SM[pos])/(Point*Point);
  }
  
  pos--;
 } 
 return(0);
}

