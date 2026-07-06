//+------------------------------------------------------------------+
//|                                                          PFE.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int ROC_Long_Length=9;
extern int ROC_Short_Length=1;
extern int MA_Length=5;
extern int PDS=10;

double PFE[];
double Buffer[];

int init()
{
 IndicatorShortName("Polarized Fractal Efficiency Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PFE);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Buffer);

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
 double ROC_Long, ROC_Short;
 double x, y, z;
 pos=limit;
 while(pos>=0)
 {
  if (Close[pos+ROC_Long_Length]!=0.)
  {
   ROC_Long=100.*(Close[pos]/Close[pos+ROC_Long_Length]-1);
  }
  if (Close[pos+ROC_Short_Length]!=0.)
  {
   ROC_Short=100.*(Close[pos]/Close[pos+ROC_Short_Length]-1);
  }
  
  x=MathSqrt(ROC_Long*ROC_Long+100.);
  y=MathSqrt(ROC_Short*ROC_Short+1.)+PDS;
  z=x/y;
  
  if (Close[pos]>Close[pos+ROC_Long_Length])
  {
   Buffer[pos]=100.*z;
  }
  else
  {
   Buffer[pos]=-100.*z;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  PFE[pos]=iMAOnArray(Buffer, 0, MA_Length, 0, MODE_EMA, pos);

  pos--;
 }
   
 return(0);
}

