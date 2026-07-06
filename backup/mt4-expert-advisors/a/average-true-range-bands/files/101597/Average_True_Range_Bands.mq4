//+------------------------------------------------------------------+
//|                                     Average_True_Range_Bands.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue

extern int Length=14;
extern double Deviation=2.;
extern string Method_Str="Method: 0 - Close, 1 - High/Low";
extern int Method=0;
extern bool Show_Deviation_Lines=false;

double Top[], Bottom[], Top2[], Bottom2[];
double Trend[];

int init()
{
 IndicatorShortName("Average True Range Bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 if (Show_Deviation_Lines)
 {
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 } 
 SetIndexBuffer(2,Top2);
 SetIndexBuffer(3,Bottom2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Trend);

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
 double ATR;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, Length, pos);
  
  if (Close[pos]>Top[pos+1])
  {
   Trend[pos]=1.;
  }
  else
  {
   if (Close[pos]<Bottom[pos+1])
   {
    Trend[pos]=-1.;
   }
   else
   {
    Trend[pos]=Trend[pos+1];
   }
  }
  
  if (Trend[pos]==1.)
  {
   if (Method==0)
   {
    Bottom[pos]=Close[pos]-ATR*Deviation;
    Top[pos]=Close[pos]+ATR*Deviation;
   }
   else
   {
    Top[pos]=Low[pos]+ATR*Deviation;
    Bottom[pos]=High[pos]-ATR*Deviation;
   }
   if (Bottom[pos]<Bottom[pos+1])
   {
    Bottom[pos]=Bottom[pos+1];
   }
  }
  else
  {
   if (Trend[pos]==-1.)
   {
    if (Method==0)
    {
     Bottom[pos]=Close[pos]-ATR*Deviation;
     Top[pos]=Close[pos]+ATR*Deviation;
    }
    else
    {
     Bottom[pos]=High[pos]-ATR*Deviation;
     Top[pos]=Low[pos]+ATR*Deviation;
    }
    if (Top[pos]>Top[pos+1])
    {
     Top[pos]=Top[pos+1];
    }
   }
  }
  
  if (Method==0)
  {
   Bottom2[pos]=Close[pos]+ATR*Deviation;
   Top2[pos]=Close[pos]-ATR*Deviation;
  }
  else
  {
   Bottom2[pos]=Low[pos]+ATR*Deviation;
   Top2[pos]=High[pos]-ATR*Deviation;
  }

  pos--;
 } 
 return(0);
}

