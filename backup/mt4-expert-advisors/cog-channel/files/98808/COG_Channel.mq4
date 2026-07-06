//+------------------------------------------------------------------+
//|                                                  COG_Channel.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_style1 STYLE_SOLID
#property indicator_color2 Green
#property indicator_style2 STYLE_SOLID
#property indicator_color3 LightBlue
#property indicator_style3 STYLE_DASH
#property indicator_color4 LightBlue
#property indicator_style4 STYLE_DASH
#property indicator_color5 Green
#property indicator_style5 STYLE_SOLID
#property indicator_color6 Blue

extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Length=34;
extern double StdDev_Mult=2.5;
extern double ATR_Mult=2.;
extern int Dot_Size=3;

double ul[], ll[], uls[], lls[], basis[], al[];
double TR[], Pr[];

int init()
{
 IndicatorShortName("COG Channel");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ul);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,ll);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,uls);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,lls);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,basis);
 SetIndexStyle(5,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(5,119);
 SetIndexBuffer(5,al);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,TR);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,Pr);

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
 double x1, x2, x3;
 pos=limit;
 while(pos>=0)
 {
  x1=High[pos]-Low[pos];
  x2=MathAbs(High[pos]-Close[pos+1]);
  x3=MathAbs(Low[pos]-Close[pos+1]);
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  
  TR[pos]=MathMax(x1, MathMax(x2, x3));

  pos--;
 } 
 
 double x, y, xy;
 int i;
 double Temp, m, yint;
 double StdDev, dev, acustom, ATR_Custom;
 
 pos=limit;
 while(pos>=0)
 {
  x=0; y=0; xy=0; x2=0;
  for (i=0;i<Length;i++)
  {
   y=y+Pr[pos+i];
   xy=xy+Pr[pos+i]*i;
   x=x+i;
   x2=x2+i*i;
  }
  Temp=Length*x2-x*x;
  m=(Length*xy-x*y)/Temp;
  yint=(y+m*x)/Length;
  basis[pos]=yint-m*Length;
  
  StdDev=iStdDev(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  dev=StdDev*StdDev_Mult;
  
  ul[pos]=basis[pos]+dev;
  ll[pos]=basis[pos]-dev;
  
  ATR_Custom=iMAOnArray(TR, 0, Length, 0, MODE_SMA, pos);
  acustom=ATR_Mult*ATR_Custom;
  
  uls[pos]=basis[pos]+acustom;
  lls[pos]=basis[pos]-acustom;
  
  if (uls[pos]>ul[pos] && lls[pos]<ll[pos])
  {
   al[pos]=basis[pos];
  }
  else
  {
   al[pos]=EMPTY_VALUE;
  }

  pos--;
 }
  
 return(0);
}

