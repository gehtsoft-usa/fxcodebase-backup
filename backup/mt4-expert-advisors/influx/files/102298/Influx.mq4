//+------------------------------------------------------------------+
//|                                                       Influx.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Fast_Duration=60;    // in seconds
extern int Slow_Duration=2500;  // in seconds
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double Influx[];
double RawFast[], RawSlow[];
bool Fast_Enable, Slow_Enable;

int init()
{
 IndicatorShortName("Influx");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Influx);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,RawFast);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RawSlow);
 
 if (Fast_Duration*60<Period())
 {
  Print("The chosen Fast MA Duration must be equal to or bigger than "+60*Period());
  Fast_Enable=false;
 }
 else
 {
  Fast_Enable=true;
 }

 if (Slow_Duration*60<Period())
 {
  Print("The chosen Slow MA Duration must be equal to or bigger than "+60*Period());
  Slow_Enable=false;
 }
 else
 {
  Slow_Enable=true;
 }

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
 int indexS, indexF, LenS, LenF;
 pos=limit;
 while(pos>=0)
 {
  if (Fast_Enable && Slow_Enable)
  {
   indexS=iBarShift(NULL, 0, Time[pos]-Slow_Duration, false);
   indexF=iBarShift(NULL, 0, Time[pos]-Fast_Duration, false);
   
   if (indexS>-1 && indexF>-1)
   {
    LenS=indexS-pos+1;
    LenF=indexF-pos+1;
    
    RawFast[pos]=iMA(NULL, 0, LenF, 0, Method, Price, pos);
    RawSlow[pos]=iMA(NULL, 0, LenS, 0, Method, Price, pos);
   }
  } 

  pos--;
 } 
 
 double Fast, Slow;
 pos=limit;
 while(pos>=0)
 {
  if (Fast_Enable && Slow_Enable)
  {
   indexS=iBarShift(NULL, 0, Time[pos]-Slow_Duration, false);
   indexF=iBarShift(NULL, 0, Time[pos]-Fast_Duration, false);
   
   if (indexS>-1 && indexF>-1)
   {
    LenS=indexS-pos+1;
    LenF=indexF-pos+1;
    
    Fast=2.*RawFast[pos]-iMAOnArray(RawFast, 0, LenF, 0, Method, pos);
    Slow=2.*RawSlow[pos]-iMAOnArray(RawSlow, 0, LenS, 0, Method, pos);
    
    Influx[pos]=(Fast-Slow)/Point;
   }
  } 

  pos--;
 }
   
 return(0);
}

