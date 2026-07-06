//+------------------------------------------------------------------+
//|                                                          PGC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Yellow

extern int Length1=9;
extern int Length2=19;
extern int Length3=6;
extern int RSI_Length=8;
extern double OverBoughtLevel=70;
extern double OverSoldLevel=30;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double PGC[];
double z3[], e[], hausse[], baisse[], AVG1[], AVG2[], AVG3[];

int init()
{
 IndicatorShortName("PG Cycle");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,PGC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,z3);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,e);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,hausse);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,baisse);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,AVG1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,AVG2);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,AVG3);

 SetLevelValue(0, 50);
 SetLevelValue(1, OverBoughtLevel);
 SetLevelValue(2, OverSoldLevel);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

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
  AVG1[pos]=iMA(NULL, 0, Length1, 0, MODE_EMA, Price, pos);
  AVG2[pos]=iMA(NULL, 0, Length2, 0, MODE_EMA, Price, pos);

  pos--;
 } 

 double z1, z2;
 double AVGAVG1, AVGAVG2;
 pos=limit;
 while(pos>=0)
 {
  AVGAVG1=iMAOnArray(AVG1, 0, Length1, 0, MODE_EMA, pos);
  AVGAVG2=iMAOnArray(AVG2, 0, Length2, 0, MODE_EMA, pos);
  z1=2.*AVG1[pos]-AVGAVG1;
  z2=2.*AVG2[pos]-AVGAVG2;
  e[pos]=z1-z2;

  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  AVG3[pos]=iMAOnArray(e, 0, Length3, 0, MODE_EMA, pos);

  pos--;
 }  

 double AVGAVG3; 
 pos=limit;
 while(pos>=0)
 {
  AVGAVG3=iMAOnArray(AVG3, 0, Length3, 0, MODE_EMA, pos);
  z3[pos]=2.*AVG3[pos]-AVGAVG3;
  if (z3[pos]>z3[pos+1])
  {
   hausse[pos]=z3[pos]-z3[pos+1];
   baisse[pos]=0.;
  }
  else
  {
   if (z3[pos]<z3[pos+1])
   {
    hausse[pos]=0.;
    baisse[pos]=z3[pos+1]-z3[pos];
   }
   else
   {
    hausse[pos]=0.;
    baisse[pos]=0.;
   }
  }

  pos--;
 }  
 
 double AVG_Hausse, AVG_Baisse;
 double RS;
 pos=limit;
 while(pos>=0)
 {
  AVG_Hausse=iMAOnArray(hausse, 0, RSI_Length, 0, MODE_EMA, pos);
  AVG_Baisse=iMAOnArray(baisse, 0, RSI_Length, 0, MODE_EMA, pos);
  if (AVG_Baisse!=0.)
  {
   RS=AVG_Hausse/AVG_Baisse;
  }
  else
  {
   RS=0.;
  } 
  
  PGC[pos]=100.-100./(1.+RS);

  pos--;
 }  
 
 return(0);
}


