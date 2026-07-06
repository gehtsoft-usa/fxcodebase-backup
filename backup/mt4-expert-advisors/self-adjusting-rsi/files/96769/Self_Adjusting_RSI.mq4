//+------------------------------------------------------------------+
//|                                           Self_Adjusting_RSI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=14;
extern double Deviation=1.8;
extern double MVA_Constant=2.;
extern string Method_Str="Method: 0 - Standard deviation, 1 - MVA";
extern int Method=0;   // 0 - Standard deviation, 1 - MVA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double RSI[], OB[], OS[];
double Raw[];

int init()
{
 IndicatorShortName("Self-Adjusting RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RSI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,OB);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,OS);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Raw);

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
  RSI[pos]=iRSI(NULL, 0, Length, Price, pos);

  pos--;
 } 
 
 double StdDev, MA;
 pos=limit;
 while(pos>=0)
 {
  if (Method==0)
  {
   StdDev=iStdDevOnArray(RSI, 0, Length, 0, MODE_SMA, pos);
   OB[pos]=50.+Deviation*StdDev;
   OS[pos]=50.-Deviation*StdDev;
  }
  else
  {
   MA=iMAOnArray(RSI, 0, Length, 0, MODE_SMA, pos);
   Raw[pos]=MathAbs(RSI[pos]-MA);
  } 

  pos--;
 }
 
 if (Method==1)
 {
  pos=limit;
  while(pos>=0)
  {
   MA=iMAOnArray(Raw, 0, Length, 0, MODE_SMA, pos);
   OB[pos]=50.+MVA_Constant*MA;
   OS[pos]=50.-MVA_Constant*MA;
   pos--;
  } 
 } 
   
 return(0);
}

