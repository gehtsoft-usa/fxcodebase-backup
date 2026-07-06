//+------------------------------------------------------------------+
//|                                    Simple_Support_Resistance.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=15;
extern int BarsBefore=30;

double Support[], Resistance[];

int init()
{
 IndicatorShortName("Simple Support/Resistance indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Support);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Resistance);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);

 double Min=Low[iLowest(NULL,0,MODE_LOW,Length,1)]; 
 double Max=High[iHighest(NULL,0,MODE_HIGH,Length,1)]; 
 double S=2*Min-Max;
 double R=2*Max-Min;
 
 int i;
 for (i=0;i<BarsBefore;i++)
 {
  Support[i]=S;
  Resistance[i]=R;
 }
 
 Support[BarsBefore]=EMPTY_VALUE;
 Resistance[BarsBefore]=EMPTY_VALUE;
 
 return(0);
}

