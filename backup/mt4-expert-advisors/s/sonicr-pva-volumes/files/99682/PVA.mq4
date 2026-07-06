//+------------------------------------------------------------------+
//|                                                          PVA.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Gray
#property indicator_color2 clrLightGreen
#property indicator_color3 clrDeepPink
#property indicator_color4 Green
#property indicator_color5 Red

extern int Climax_Period=10;
extern int Rising_Period=10;
extern double Rising_Factor=1.;
extern double Extreme_Factor=2.;

double V[], V1[], V2[], V3[], V4[];
double Range[];

int init()
{
 IndicatorShortName("SonicR PVA Volumes");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,V);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,V1);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,V2);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,V3);
 SetIndexStyle(4,DRAW_HISTOGRAM);
 SetIndexBuffer(4,V4);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Range);

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
  V[pos]=Volume[pos];
  Range[pos]=(High[pos]-Low[pos])*Volume[pos];

  pos--;
 } 
 
 double MA;
 double Max;
 pos=limit;
 while(pos>=0)
 {
  MA=iMAOnArray(V, 0, Rising_Period, 0, MODE_SMA, pos);
  Max=Range[ArrayMaximum(Range, Climax_Period, pos+1)];
  
  V1[pos]=EMPTY_VALUE;
  V2[pos]=EMPTY_VALUE;
  V3[pos]=EMPTY_VALUE;
  V4[pos]=EMPTY_VALUE;
  
  if (V[pos]>=MA*Rising_Factor)
  {
   if (Close[pos]>Open[pos])
   {
    V1[pos]=V[pos];
   }
   else
   {
    V2[pos]=V[pos];
   }
  }
  
  if (Range[pos]>=Max || Volume[pos]>=MA*Extreme_Factor)
  {
   if (Close[pos]>Open[pos])
   {
    V3[pos]=V[pos];
   }
   else
   {
    V4[pos]=V[pos];
   }
  }

  pos--;
 }
   
 return(0);
}

