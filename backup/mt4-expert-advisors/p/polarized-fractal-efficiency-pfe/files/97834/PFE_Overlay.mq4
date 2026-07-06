//+------------------------------------------------------------------+
//|                                                  PFE_Overlay.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Red

extern int ROC_Long_Length=9;
extern int ROC_Short_Length=1;
extern int MA_Length=5;
extern int PDS=10;
extern int Average_Length=20;
extern double Number_Of_StdDev=2.;
extern bool Show_Deviation_Band=true;

double PFE[], TL[], BL[];
double Buffer[];

int init()
{
 IndicatorShortName("Polarized Fractal Efficiency Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PFE);
 if (Show_Deviation_Band)
 {
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_NONE);
 } 
 SetIndexBuffer(1,TL);
 SetIndexBuffer(2,BL);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Buffer);

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
 double ml, d;
 double Scale;
 pos=limit;
 while(pos>=0)
 {
  ml=iMA(NULL, 0, Average_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  d=iStdDev(NULL, 0, Average_Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  TL[pos]=ml+Number_Of_StdDev*d;
  BL[pos]=ml-Number_Of_StdDev*d;
  
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
  if (TL[pos]!=BL[pos])
  {
   Scale=200./(TL[pos]-BL[pos]);
  } 

  if (Scale!=0.)
  {
   PFE[pos]=BL[pos]+(100.+iMAOnArray(Buffer, 0, MA_Length, 0, MODE_EMA, pos))/Scale;
  } 

  pos--;
 }
   
 return(0);
}

