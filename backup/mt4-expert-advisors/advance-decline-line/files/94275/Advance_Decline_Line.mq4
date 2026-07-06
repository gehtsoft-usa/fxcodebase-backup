//+------------------------------------------------------------------+
//|                                         Advance_Decline_Line.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;
extern bool Cumulative=true;

double ADL[];

int init()
{
 IndicatorShortName("Advance Decline Line");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ADL);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int i;
 int rs, fs;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   ADL[pos]=0.;
  }
  else
  {
   rs=0;
   fs=0;
   for (i=0;i<Length;i++)
   {
    if (Close[pos+i]>Open[pos+i])
    {
     rs++;
    }
    else
    {
     if (Close[pos+i]<Open[pos+i])
     {
      fs++;
     }
    }
    if (Cumulative)
    {
     ADL[pos]=rs-fs+ADL[pos+1];
    }
    else
    {
     ADL[pos]=rs-fs;
    }
   }

  } 
  pos--;
 } 
 return(0);
}

