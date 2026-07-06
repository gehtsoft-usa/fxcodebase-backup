//+------------------------------------------------------------------+
//|                                                     Blau_HLM.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=2;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;

double Blau_HLM[];
double HLM[], EMA1[], EMA2[];

int init()
{
 IndicatorShortName("William Blau Composite High-Low Momentum");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Blau_HLM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,HLM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,EMA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,EMA2);

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
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double HM, LM;
 pos=limit;
 while(pos>=0)
 {
  HM=High[pos]-High[pos+Length-1];
  LM=Low[pos+Length-1]-Low[pos];
  if (HM<0.) HM=0.;
  if (LM<0.) LM=0.;
  HLM[pos]=HM-LM;
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(HLM, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  EMA2[pos]=iMAOnArray(EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  Blau_HLM[pos]=iMAOnArray(EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos)/Point;
  pos--;
 }  
 return(0);
}

