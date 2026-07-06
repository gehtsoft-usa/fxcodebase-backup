//+------------------------------------------------------------------+
//|                                                          RWI.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=2;

double RWIH[], RWIL[];
double TR[];

int init()
  {
   IndicatorShortName("Random Walk Index");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RWIH);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,RWIL);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,TR);

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
 int pos;
 int i;
 double ATR;
 double H, L;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  TR[pos]=MathMax(High[pos]-Low[pos],MathMax(MathAbs(High[pos]-Close[pos+1]),MathAbs(Close[pos+1]-Low[pos])));
  pos--;
 } 

 pos=limit;
 
 while(pos>=0)
 {
  H=0;
  L=0;
  for (i=1;i<=Length;i++)
  {
   ATR=iMAOnArray(TR, 0, i, 0, MODE_SMA, pos)/MathSqrt(i+1);
   if (ATR!=0)
   {
    H=MathMax(H, (High[pos]-Low[pos+i])/ATR);
    L=MathMax(L, (High[pos+i]-Low[pos])/ATR);
   }
  } 
  RWIH[pos]=H;
  RWIL[pos]=L;
  pos--;
 } 

 return(0);
}

