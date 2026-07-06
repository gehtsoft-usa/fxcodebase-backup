//+------------------------------------------------------------------+
//|                                       Directional_Volatility.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern double Deviation=3.;

double Long[], Short[];
double LongS[], ShortS[], LongMA[], ShortMA[];

int init()
{
 IndicatorShortName("Directional Volatility");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Long);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Short);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,LongS);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,ShortS);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,LongMA);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,ShortMA);

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
  LongS[pos]=Close[pos+1]-Low[pos];
  ShortS[pos]=High[pos]-Close[pos+1];

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  LongMA[pos]=iMAOnArray(LongS, 0, Length, 0, MODE_EMA, pos);
  ShortMA[pos]=iMAOnArray(ShortS, 0, Length, 0, MODE_EMA, pos);

  pos--;
 }

 double LongStdDev, ShortStdDev;
 pos=limit;
 while(pos>=0)
 {
  LongStdDev=iStdDevOnArray(LongMA, 0, Length, 0, MODE_SMA, pos);
  ShortStdDev=iStdDevOnArray(ShortMA, 0, Length, 0, MODE_SMA, pos);
  
  Long[pos]=(LongMA[pos]+Deviation*LongStdDev)/Point;
  Short[pos]=(ShortMA[pos]+Deviation*ShortStdDev)/Point;

  pos--;
 }
     
 return(0);
}

