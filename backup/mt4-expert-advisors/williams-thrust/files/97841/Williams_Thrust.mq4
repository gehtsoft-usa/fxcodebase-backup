//+------------------------------------------------------------------+
//|                                              Williams_Thrust.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Gray

extern int First_LW_Length=250;
extern int First_MA_Length=50;
extern int Second_LW_Length=50;
extern int Second_MA_Length=10;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Up[], Dn[], Ne[];
double RLW1[], RLW2[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Ne);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RLW1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,RLW2);

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
  RLW1[pos]=iWPR(NULL, 0, First_LW_Length, pos);
  RLW2[pos]=iWPR(NULL, 0, Second_LW_Length, pos);

  pos--;
 } 
 
 double MA1, MA2;
 pos=limit;
 while(pos>=0)
 {
  MA1=iMAOnArray(RLW1, 0, First_MA_Length, 0, Method, pos);
  MA2=iMAOnArray(RLW1, 0, Second_MA_Length, 0, Method, pos);
  
  Up[pos]=0.;
  Dn[pos]=0.;
  Ne[pos]=0.;
  
  if (RLW1[pos]>MA1 && RLW2[pos]>MA2)
  {
   Up[pos]=-1000.;
  }
  else
  {
   if (RLW1[pos]<MA1 && RLW2[pos]<MA2)
   {
    Dn[pos]=-1000.;
   }
   else
   {
    Ne[pos]=-1000.;
   } 
  }

  pos--;
 }
   
 return(0);
}

