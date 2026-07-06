//+------------------------------------------------------------------+
//|                                                          ATP.mq4 |
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

extern int UpLength=14;
extern int DnLength=10;
extern int Length=24;
extern bool ShowUpDn=false;

double ATP[], Up[], Dn[];

int init()
  {
   IndicatorShortName("Asymmetric Trend Pressure");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ATP);
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
 int UpCount, DnCount;
 while(pos>=0)
 {
  SumUp=0;
  SumDn=0;
  i=0;
  UpCount=0;
  DnCount=0;
  while (i<Length)
  {
   if (Close[pos+i]>Open[pos+i] && UpCount<UpLength)
   {
    UpCount++;
    SumUp=SumUp+Close[pos+i]-Open[pos+i];
   }
   else
   {
    if (Close[pos+i]<Open[pos+i] && DnCount<DnLength)
    {
     DnCount++;
     SumDn=SumDn+Open[pos+i]-Close[pos+i];
    }
   }
   i++;
  } 
  if (ShowUpDn)
  {
   Up[pos]=SumUp/UpLength;
   Dn[pos]=SumDn/DnLength;
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
   Dn[pos]=EMPTY_VALUE;
  } 
  ATP[pos]=SumUp/UpLength-SumDn/DnLength;
  pos--;
 } 

 return(0);
}

