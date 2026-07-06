//+------------------------------------------------------------------+
//|                                               Stochastic_Bar.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Chartreuse
#property indicator_color2 DarkGreen
#property indicator_color3 HotPink
#property indicator_color4 FireBrick
#property indicator_color5 LightSeaGreen
#property indicator_color6 Yellow

extern int Kperiod=5;
extern int Dperiod=3;
extern int slowing=3;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price_Field=0;  // 0 - Low/High, 1 - Close/Close 
extern double OverBoughtLevel=80;
extern double OverSoldLevel=20;                         

double H1[], H2[], H3[], H4[], K[], D[];

int init()
{
 IndicatorShortName("Stochastic Bar");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,H1);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,H2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,H3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,H4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,K);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,D);
 
 SetLevelValue(0, OverBoughtLevel);
 SetLevelValue(1, OverSoldLevel);

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
  K[pos]=iStochastic(NULL, 0, Kperiod, Dperiod, slowing, Method, Price_Field, MODE_MAIN, pos);
  D[pos]=iStochastic(NULL, 0, Kperiod, Dperiod, slowing, Method, Price_Field, MODE_SIGNAL, pos);
  
  H1[pos]=EMPTY_VALUE;
  H2[pos]=EMPTY_VALUE;
  H3[pos]=EMPTY_VALUE;
  H4[pos]=EMPTY_VALUE;
  
  if (K[pos]>D[pos])
  {
   if (K[pos]>OverBoughtLevel)
   {
    H1[pos]=100.;
   }
   else
   {
    H2[pos]=100.;
   }
  }
  else
  {
   if (K[pos]<OverSoldLevel)
   {
    H3[pos]=100.;
   }
   else
   {
    H4[pos]=100.;
   }
  }  

  pos--;
 } 
 return(0);
}

