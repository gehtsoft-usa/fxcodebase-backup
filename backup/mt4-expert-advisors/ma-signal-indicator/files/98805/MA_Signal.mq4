//+------------------------------------------------------------------+
//|                                                    MA_Signal.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern bool Only_Change=true;
extern int Price1=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length1=10;                        
extern int Method1=1;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price2=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length2=50;                        
extern int Method2=1;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price3=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length3=20;                        
extern int Method3=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int Price4=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length4=40;                        
extern int Method4=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int ArrowSize=3;                       


double Up[], Dn[];
double Last[];

int init()
{
 IndicatorShortName("MA signal indicator");
 IndicatorDigits(Digits);
 SetIndexBuffer(0, Up);
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,233);
 SetIndexEmptyValue(0,0.0);
 SetIndexBuffer(1, Dn);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,234);
 SetIndexEmptyValue(1,0.0);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Last);

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
 double MA1, MA2, MA3, MA4;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMA(NULL, 0, Length1, 0, Method1, Price1, pos);
  MA2=iMA(NULL, 0, Length2, 0, Method2, Price2, pos);
  MA3=iMA(NULL, 0, Length3, 0, Method3, Price3, pos);
  MA4=iMA(NULL, 0, Length4, 0, Method4, Price4, pos);
  
  Last[pos]=Last[pos+1];
  if (MA1>MA2 && MA3>MA4 && (Last[pos+1]!=1. || !Only_Change))
  {
   Up[pos]=Low[pos];
   Last[pos]=1.;
  }

  if (MA1<MA2 && MA3<MA4 && (Last[pos+1]!=-1. || !Only_Change))
  {
   Dn[pos]=High[pos];
   Last[pos]=-1.;
  }

  pos--;
 } 
 return(0);
}

