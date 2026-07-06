//+------------------------------------------------------------------+
//|                                          Trailing_Stop_Level.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern double Percent=2;

double TSL[], TSLDn[];

int init()
{
 IndicatorShortName("Trailing Stop level indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TSL);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,TSLDn);

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
 double loss;
 pos=limit;
 while(pos>=0)
 {
  loss=Close[pos]*Percent/100;
  if (Close[pos]>TSL[pos+1] && Close[pos+1]>TSL[pos+1])
  {
   TSL[pos]=MathMax(TSL[pos+1], Close[pos]-loss);
   TSLDn[pos]=TSL[pos];
   TSLDn[pos+1]=TSL[pos+1];
  }
  else
  {
   if (Close[pos]<TSL[pos+1] && Close[pos+1]<TSL[pos+1])
   {
    TSL[pos]=MathMin(TSL[pos+1], Close[pos]+loss);
   }
   else
   {
    if (Close[pos]>TSL[pos+1])
    {
     TSL[pos]=Close[pos]-loss;
     TSLDn[pos]=TSL[pos];
     TSLDn[pos+1]=TSL[pos+1];
    }
    else
    {
     TSL[pos]=Close[pos]+loss;
    }
   }
  }
  pos--;
 } 
 return(0);
}

