//+------------------------------------------------------------------+
//|                                          XBarClearCloseTrend.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 DarkBlue
#property indicator_color2 DarkSlateBlue
#property indicator_color3 Aqua
#property indicator_color4 Red
#property indicator_color5 OrangeRed
#property indicator_color6 Yellow
#property indicator_minimum 0

extern int Length=5;

double Buff1[], Buff2[], Buff3[], Buff4[], Buff5[], Buff6[];
double Trend[];

int init()
  {
   IndicatorShortName("XBarClearCloseTrend");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Buff1);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Buff2);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Buff3);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,Buff4);
   SetIndexStyle(4,DRAW_HISTOGRAM);
   SetIndexBuffer(4,Buff5);
   SetIndexStyle(5,DRAW_HISTOGRAM);
   SetIndexBuffer(5,Buff6);
   SetIndexStyle(6,DRAW_NONE);
   SetIndexBuffer(6,Trend);

   return(0);
  }

int deinit()
  {

   return(0);
  }
  
bool IsBarUp(int bar)  
{
 int i;
 for (i=1;i<Length;i++)
 {
  if (High[bar+i]>=Close[bar]) return (false);
 }
 return (true);
}

bool IsBarDn(int bar)
{
 int i;
 for (i=1;i<Length;i++)
 {
  if (Low[bar+i]<=Close[bar]) return (false);
 }
 return (true);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  Trend[pos]=Trend[pos+1];
  Buff1[pos]=0;
  Buff2[pos]=0;
  Buff3[pos]=0;
  Buff4[pos]=0;
  Buff5[pos]=0;
  Buff6[pos]=0;
  
  if (Trend[pos+1]==1)
  {
   if (IsBarUp(pos))
   {
    Buff1[pos]=1;
   }
   else
   {
    if (IsBarDn(pos))
    {
     Buff4[pos]=1;
    }
    else
    {
     if (Close[pos]>=Close[pos+1])
     {
      Buff2[pos]=1;
      Trend[pos]=-1;
     }
     else
     {
      Buff3[pos]=1;
     }
    }
   }
  }
  else
  {
   if (IsBarDn(pos))
   {
    Buff4[pos]=1;
   }
   else
   {
    if (IsBarUp(pos))
    {
     Buff1[pos]=1;
     Trend[pos]=1;
    }
    else
    {
     if (Close[pos]<=Close[pos+1])
     {
      Buff5[pos]=1;
     }
     else
     {
      Buff6[pos]=1;
     }
    }
   }
  }
  pos--;
 }

 return(0);
}

