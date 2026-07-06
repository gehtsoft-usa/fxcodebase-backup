//+------------------------------------------------------------------+
//|                                             Blau_Ergodic_DTI.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Gray
#property indicator_color2 Yellow

extern int Length=2;
extern int Smooth_Length1=20;
extern int Smooth_Length2=5;
extern int Smooth_Length3=3;
extern int Signal_Length=3;

double Blau_DTI[], Signal[];
double HLM[], HLM_EMA1[], HLM_EMA2[];
double Abs[], Abs_EMA1[], Abs_EMA2[];

int init()
{
 IndicatorShortName("William Blau Ergodic DTI-Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Blau_DTI);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HLM);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,HLM_EMA1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,HLM_EMA2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Abs);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,Abs_EMA1);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Abs_EMA2);

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
  Abs[pos]=MathAbs(HLM[pos]);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  HLM_EMA1[pos]=iMAOnArray(HLM, 0, Smooth_Length1, 0, MODE_EMA, pos);
  Abs_EMA1[pos]=iMAOnArray(Abs, 0, Smooth_Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  HLM_EMA2[pos]=iMAOnArray(HLM_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  Abs_EMA2[pos]=iMAOnArray(Abs_EMA1, 0, Smooth_Length2, 0, MODE_EMA, pos);
  pos--;
 }  

 double HLM_EMA3, Abs_EMA3;
 pos=limit;
 while(pos>=0)
 {
  HLM_EMA3=iMAOnArray(HLM_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  Abs_EMA3=iMAOnArray(Abs_EMA2, 0, Smooth_Length3, 0, MODE_EMA, pos);
  if (Abs_EMA3>0)
  {
   Blau_DTI[pos]=100.*HLM_EMA3/Abs_EMA3;
  }
  else
  {
   Blau_DTI[pos]=0;
  } 
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Blau_DTI, 0, Signal_Length, 0, MODE_EMA, pos);
  pos--;
 }  

 return(0);
}

