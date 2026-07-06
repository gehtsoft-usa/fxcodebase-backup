//+------------------------------------------------------------------+
//|                                                          ASO.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red

extern int Range_Length=10;
extern int Smoothing_Length=10;
extern string ModeStr="Mode: 1 - Combined, 2 - Intra-bar, 3 - Group algorithm";
extern int Mode=1;  // 1 - Combined, 2 - Intra-bar, 3 - Group algorithm
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

double Bulls[], Bears[];
double Bu[], Be[];

int init()
{
 IndicatorShortName("Average Sentiment Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Bulls);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Bears);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Bu);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Be);

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
 double intrahigh, intralow, intraopen, close, intrarange, grouplow, grouphigh, groupopen, grouprange;
 double intrabarbulls, groupbulls, intrabarbears, groupbears;
 pos=limit;
 while(pos>=0)
 {
  intrahigh=High[pos];
  intralow=Low[pos];
  intraopen=Open[pos];
  close=Close[pos];
  intrarange=intrahigh-intralow;
  grouplow=High[iLowest(NULL, 0, MODE_HIGH, Range_Length, pos)];
  grouphigh=Low[iHighest(NULL, 0, MODE_LOW, Range_Length, pos)];
  groupopen=Open[pos+Range_Length];
  grouprange=grouphigh-grouplow;
  
  if (intrarange==0.) intrarange=1.;
  if (grouprange==0.) grouprange=1.;
  
  intrabarbulls=((((close-intralow)+(intrahigh-intraopen))/2.)*100.)/intrarange;
  groupbulls=((((close-grouplow)+(grouphigh-groupopen))/2.)*100.)/grouprange;
  intrabarbears=((((intrahigh-close)+(intraopen-intralow))/2.)*100.)/intrarange;
  groupbears=((((grouphigh-close)+(groupopen-grouplow))/2.)*100.)/grouprange;
  
  if (Mode==1)
  {
   Bu[pos]=(intrabarbulls+groupbulls)/2.;
   Be[pos]=(intrabarbears+groupbears)/2.;
  }
  else
  {
   if (Mode==2)
   {
    Bu[pos]=intrabarbulls;
    Be[pos]=intrabarbears;
   }
   else
   {
    Bu[pos]=groupbulls;
    Be[pos]=groupbears;
   }
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Bulls[pos]=iMAOnArray(Bu, 0, Smoothing_Length, 0, MA_Method, pos)/Point;
  Bears[pos]=iMAOnArray(Be, 0, Smoothing_Length, 0, MA_Method, pos)/Point;

  pos--;
 }
   
 return(0);
}

