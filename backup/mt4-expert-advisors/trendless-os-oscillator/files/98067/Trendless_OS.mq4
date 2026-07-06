//+------------------------------------------------------------------+
//|                                                 Trendless_OS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 clrChartreuse
#property indicator_color2 clrDarkGreen
#property indicator_color3 clrYellow
#property indicator_color4 clrSandyBrown
#property indicator_color5 clrRed

extern int Length=7;
extern double OB_Level=0.0047;
extern double OS_Level=-0.00473;
extern bool Show_Histogram=true;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double B1[], B2[], B3[], B4[], B5[];

int init()
{
 IndicatorShortName("Trendless OS");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,B1);
 SetIndexBuffer(1,B2);
 SetIndexBuffer(2,B3);
 SetIndexBuffer(3,B4);
 SetIndexBuffer(4,B5);
 
 if (Show_Histogram)
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_HISTOGRAM);
  SetIndexStyle(2,DRAW_HISTOGRAM);
  SetIndexStyle(3,DRAW_HISTOGRAM);
  SetIndexStyle(4,DRAW_HISTOGRAM);
 }
 else
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
  SetIndexStyle(4,DRAW_NONE);
 }
 
 SetLevelValue(0, OB_Level);
 SetLevelValue(1, OB_Level*0.8);
 SetLevelValue(2, OB_Level*0.6);
 SetLevelValue(3, OS_Level);
 SetLevelValue(4, OS_Level*0.8);
 SetLevelValue(5, OS_Level*0.6);

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
 double Pr, MA;
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA=iMA(NULL, 0, Length, 0, MODE_SMA, Price, pos);
  
  B1[pos]=Pr-MA;
  
  B2[pos]=0.;
  B3[pos]=0.;
  B4[pos]=0.;
  B5[pos]=0.;
  
  if (B1[pos]>0.6*OS_Level && B1[pos]<0.6*OB_Level)
  {
   B2[pos]=B1[pos];
  }
  else
  {
   if ((B1[pos]>0.8*OS_Level && B1[pos]<=0.6*OS_Level) || (B1[pos]>=0.6*OB_Level && B1[pos]<0.8*OB_Level))
   {
    B3[pos]=B1[pos];
   }
   else
   {
    if ((B1[pos]>OS_Level && B1[pos]<=0.8*OS_Level) || (B1[pos]>=0.8*OB_Level && B1[pos]<OB_Level))
    {
     B4[pos]=B1[pos];
    }
    else
    {
     B5[pos]=B1[pos];
    }
   }
  }

  pos--;
 } 
 return(0);
}

