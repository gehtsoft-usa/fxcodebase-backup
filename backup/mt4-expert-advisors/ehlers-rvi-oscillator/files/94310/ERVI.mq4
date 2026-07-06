//+------------------------------------------------------------------+
//|                                                         ERVI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;

double RVI[], Signal[];
double Value1[], Value2[];

int init()
{
 IndicatorShortName("Ehlers RVI oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RVI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Value1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Value2);

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
  Value1[pos]=((Close[pos]-Open[pos])+2.*(Close[pos+1]-Open[pos+1])+2.*(Close[pos+2]-Open[pos+2])+(Close[pos+3]-Open[pos+3]))/6.;
  Value2[pos]=((High[pos]-Low[pos])+2.*(High[pos+1]-Low[pos+1])+2.*(High[pos+2]-Low[pos+2])+(High[pos+3]-Low[pos+3]))/6.;
  
  pos--;
 } 

 double Num, Denom;
 pos=limit;
 while(pos>=0)
 {
  Num=iMAOnArray(Value1, 0, Length, 0, MODE_SMA, pos);
  Denom=iMAOnArray(Value2, 0, Length, 0, MODE_SMA, pos);
  if (Denom!=0.)
  {
   RVI[pos]=Num/Denom;
  }
  else
  {
   RVI[pos]=0.;
  }
  
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=(RVI[pos]+2.*RVI[pos+1]+2.*RVI[pos+2]+RVI[pos+3])/6.;
  
  pos--;
 }  
 
 return(0);
}

