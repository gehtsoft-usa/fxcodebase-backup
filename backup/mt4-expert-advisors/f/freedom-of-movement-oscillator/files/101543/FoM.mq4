//+------------------------------------------------------------------+
//|                                                          FoM.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Length=10;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double FoM[];
double RV[];
double Vol[];
double aMove[], vByM[];
double K;

int init()
{
 IndicatorShortName("Freedom of Movement oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,FoM);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Vol);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,RV);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,aMove);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,vByM);

 K=MathCeil(100.*Volume[0]);
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
 double MA;
 double StdDev;
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos]/K;
  pos--;
 } 

 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(Vol, 0, Length, 0, Method, pos);
  StdDev=iStdDevOnArray(Vol, 0, Length, 0, Method, pos);
  if (StdDev!=0.)
  {
   RV[pos]=(Vol[pos]-MA)/StdDev;
  }
  else
  {
   RV[pos]=EMPTY_VALUE;
  }
  
  aMove[pos]=MathAbs(Close[pos]-Close[pos+1])/Close[pos+1];
  
  pos--;
 } 

 double Min, Max;
 double MinV, MaxV;
 double denom, denomV;
 double Move, V;
 double avF, sdF;
 
 pos=limit;
 while(pos>=0)
 {
  Min=aMove[ArrayMinimum(aMove, Length, pos)];
  Max=aMove[ArrayMaximum(aMove, Length, pos)];
  if (Max-Min==0.)
  {
   denom=-1.;
  }
  else
  {
   denom=Max-Min;
  }
  Move=1.+9.*(aMove[pos]-Min)/MathAbs(denom);

  MinV=RV[ArrayMinimum(RV, Length, pos)];
  MaxV=RV[ArrayMaximum(RV, Length, pos)];
  if (MaxV-MinV==0.)
  {
   denomV=-1.;
  }
  else
  {
   denomV=MaxV-MinV;
  }
  V=1.+9.*(RV[pos]-MinV)/MathAbs(denomV);
  vByM[pos]=V/(10.*Move);
  
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  avF=iMAOnArray(vByM, 0, Length, 0, Method, pos);
  sdF=iStdDevOnArray(vByM, 0, Length, 0, Method, pos);
  if (sdF!=0.)
  {
   FoM[pos]=(vByM[pos]-avF)/sdF;
  }
  else
  {
   FoM[pos]=EMPTY_VALUE;
  }
  
  pos--;
 }
   
 return(0);
}

