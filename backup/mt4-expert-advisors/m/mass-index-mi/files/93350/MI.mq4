//+------------------------------------------------------------------+
//|                                                           MI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int MA1_Length=9;
extern int MA2_Length=9;
extern int Sum_Length=25;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double MI[];
double Res[], HL[], MA1[];

int init()
{
 IndicatorShortName("Mass Index (MI)");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Res);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HL);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,MA1);

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
 double MA2;
 pos=limit;
 while(pos>=0)
 {
  HL[pos]=High[pos]-Low[pos];
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA1[pos]=iMAOnArray(HL, 0, MA1_Length, 0, Method, pos);
  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  MA2=iMAOnArray(MA1, 0, MA2_Length, 0, Method, pos);
  if (MA2!=0.)
  {
   Res[pos]=MA1[pos]/MA2;
  }
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  MI[pos]=iMAOnArray(Res, 0, Sum_Length, 0, MODE_SMA, pos)*Sum_Length-25.;
  pos--;
 }
   
   
 return(0);
}

