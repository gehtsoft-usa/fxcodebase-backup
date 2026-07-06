//+------------------------------------------------------------------+
//|                                        Trend_Trail_Indicator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern double ATR_Mult=2.8;
extern int ATR_Length=10;

double trends[];
double HL[], diff2[], support[], WMA[];
double k;

int init()
{
 IndicatorShortName("Trend Trail indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,trends);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HL);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,diff2);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,support);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,WMA);
 
 k=1./ATR_Length;

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
  HL[pos]=High[pos]-Low[pos];

  pos--;
 } 
 
 double Avg_HL, HiLo, Href, Lref, diff1;
 pos=limit;
 while(pos>=0)
 {
  Avg_HL=iMAOnArray(HL, 0, ATR_Length, 0, MODE_SMA, pos);
  HiLo=MathMin(HL[pos], 1.5*Avg_HL);
  
  if (Low[pos]<=High[pos+1])
  {
   Href=High[pos]-Close[pos+1];
  }
  else
  {
   Href=High[pos]-Close[pos+1]-(Low[pos]-High[pos+1])/2.;
  }
  
  if (High[pos]>=Low[pos+1])
  {
   Lref=Close[pos+1]-Low[pos];
  }
  else
  {
   Lref=Close[pos+1]-Low[pos]-(Low[pos+1]-High[pos])/2.;
  }
  
  diff1=MathMax(HiLo, Href);
  diff2[pos]=MathMax(diff1, Lref);
  
  pos--;
 }

 double loss, resistance; 
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   WMA[pos]=iMAOnArray(diff2, 0, ATR_Length, 0, MODE_SMA, pos);
   support[pos]=Close[pos];
   trends[pos]=Close[pos];
  }
  else
  {
   WMA[pos]=(diff2[pos]-WMA[pos+1])*k+WMA[pos+1];
  
   loss=ATR_Mult*WMA[pos];
   resistance=Close[pos]+loss;
  
   if (Low[pos]>=Low[pos+2] && Low[pos+1]>=Low[pos+2] && Low[pos+3]>=Low[pos+2] && Low[pos+4]>=Low[pos+2])
   {
    support[pos]=Low[pos+2];
   }
   else
   {
    if (Low[pos]>High[pos+1]*1.0013)
    {
     support[pos]=High[pos+1]*0.9945;
    }
    else
    {
     if (Low[pos]>support[pos+1]*1.1)
     {
      support[pos]=support[pos+1]*1.05;
     }
     else
     {
      support[pos]=support[pos+1];
     }
    }
   }
  
   if (High[pos]>trends[pos+1] && High[pos+1]>trends[pos+1])
   {
    trends[pos]=MathMax(trends[pos+1], support[pos]);
   }
   else
   {
    if (High[pos]<trends[pos+1] && High[pos+1]<trends[pos+1])
    {
     trends[pos]=MathMin(trends[pos+1], resistance);
    }
    else
    {
     if (High[pos]>trends[pos+1])
     {
      trends[pos]=support[pos];
     }
     else
     {
      trends[pos]=resistance;
     } 
    }
   }
  }

  pos--;
 }  
   
 return(0);
}

