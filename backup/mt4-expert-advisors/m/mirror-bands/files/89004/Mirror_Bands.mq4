//+------------------------------------------------------------------+
//|                                                 Mirror_Bands.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Blue
#property indicator_color3 Green
#property indicator_color4 Red

extern int Length=9;
extern int MA_Length=2;
extern double Deviation=2;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Top[], Bottom[], MA[], Mirror[];
double MA_Ind[], Pr[];

int init()
{
 IndicatorShortName("Mirror bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bottom);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,MA);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Mirror);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MA_Ind);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Pr);

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
 int i;
 pos=limit;
 while(pos>=0)
 {
  MA_Ind[pos]=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 pos=limit;
 double new;
 double sum;
 double Dev;
 while(pos>=0)
 {
  sum=0;
  for (i=0;i<Length;i++)
  {
   new=Pr[pos+i]-MA_Ind[pos];
   sum=sum+new*new;
  }
  Dev=Deviation*MathSqrt(sum/Length);
  Top[pos]=MA_Ind[pos]+Dev;
  Bottom[pos]=MA_Ind[pos]-Dev;
  MA[pos]=iMA(NULL, 0, MA_Length, 0, MODE_SMA, Price, pos);
  Mirror[pos]=2*MA_Ind[pos]-MA[pos];
  pos--;
 }  
 return(0);
}

