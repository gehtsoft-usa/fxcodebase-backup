//+------------------------------------------------------------------+
//|                                                Normalized_AC.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Awesome_Fast_Length=5;
extern int Awesome_Slow_Length=35;
extern int MA_Length=5;
extern int Normalization_Level=50;
extern int Scale=100;
extern int Normalization_Period=0;

double Norm_AC[];
double RawAC[], AO[];

int init()
{
 IndicatorShortName("Normalized Acceleration/Deceleration");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Norm_AC);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,RawAC);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,AO);

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
 double FastMA, SlowMA;
 pos=limit;
 while(pos>=0)
 {
  FastMA=iMA(NULL, 0, Awesome_Fast_Length, 0, MODE_SMA, PRICE_MEDIAN, pos);
  SlowMA=iMA(NULL, 0, Awesome_Slow_Length, 0, MODE_SMA, PRICE_MEDIAN, pos);
  AO[pos]=FastMA-SlowMA;

  pos--;
 } 
 
 double MA;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(AO, 0, MA_Length, 0, MODE_SMA, pos);
  RawAC[pos]=AO[pos]-MA;

  pos--;
 }
 
 double Min, Max;
 double _Scale;
 double AbsMin;
 
 if (Normalization_Period==0)
 {
  Min=RawAC[ArrayMinimum(RawAC, Bars-4, 0)];
  Max=RawAC[ArrayMaximum(RawAC, Bars-4, 0)];
 
  if (Scale==0)
  {
   _Scale=Max-Min;
  }
  else
  {
   _Scale=Scale;
  }
  
  AbsMin=MathAbs(Max);
  
  if (AbsMin!=0.)
  {
   pos=Bars-2;
   while(pos>=0)
   {
    Norm_AC[pos]=Normalization_Level+RawAC[pos]*(_Scale/AbsMin);
  
    pos--;
   } 
  } 
 }
 else
 {
  pos=limit;
  while(pos>=0)
  {
   Min=RawAC[ArrayMinimum(RawAC, Normalization_Period, 0)];
   Max=RawAC[ArrayMaximum(RawAC, Normalization_Period, 0)];

   if (Scale==0)
   {
    _Scale=Max-Min;
   }
   else
   {
    _Scale=Scale;
   }
   
   AbsMin=MathAbs(Max);
   
   if (AbsMin!=0.)
   {
    Norm_AC[pos]=Normalization_Level+RawAC[pos]*(_Scale/AbsMin);   
   } 
  
   pos--;
  }
  
 } 
  
   
 return(0);
}


