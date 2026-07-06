//+------------------------------------------------------------------+
//|                                                           TP.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=14;
extern bool ShowUpDn=false;

double TP[], Up[], Dn[];

int init()
  {
   IndicatorShortName("Advance Trend Pressure");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TP);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Up);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Dn);

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
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double SumUp, SumDn;
 int i;
 while(pos>=0)
 {
  SumUp=0;
  SumDn=0;
  for (i=0;i<Length;i++)
  {
   if (Close[pos+i]>Open[pos+i])
   {
    SumUp=SumUp+Close[pos+i]-Open[pos+i];
    SumUp=SumUp+Open[pos+i]-Low[pos+i];
    SumDn=SumDn+High[pos+i]-Close[pos+i];
   }
   else
   {
    if (Close[pos+i]<Open[pos+i])
    {
     SumDn=SumDn+Open[pos+i]-Close[pos+i];
     SumDn=SumDn+High[pos+i]-Open[pos+i];
     SumUp=SumUp+Close[pos+i]-Low[pos+i];
    }
   }
  } 
  if (ShowUpDn)
  {
   Up[pos]=SumUp;
   Dn[pos]=SumDn;
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
   Dn[pos]=EMPTY_VALUE;
  } 
  TP[pos]=SumUp-SumDn;
  pos--;
 } 

 return(0);
}

