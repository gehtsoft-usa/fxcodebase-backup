//+------------------------------------------------------------------+
//|                                      Linear_Regression_Slope.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;

double LRS[];

int init()
{
 IndicatorShortName("Simple slope");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LRS);

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
 int pos, i;
 double ii, y, xy, x, x2, c, b;
 pos=limit;
 while(pos>=0)
 {
  ii=0.;
  y=0.;
  xy=0.;
  x=0.;
  x2=0.;
  for (i=pos+Length;i>=pos;i--)
  {
   ii++;
   y+=Close[i];
   xy+=Close[i]*ii;
   x+=ii;
   x2+=ii*ii;
  }
  c=x2*ii-x*x;
  b=(xy*ii-x*y)/c;
  
  LRS[pos]=b;

  pos--;
 } 
 return(0);
}

