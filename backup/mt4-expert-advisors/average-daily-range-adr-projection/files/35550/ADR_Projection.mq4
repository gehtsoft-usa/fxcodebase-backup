//+------------------------------------------------------------------+
//|                                               ADR_Projection.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Yellow

double Line1[], Line2[], R[];

extern int Length=14;
extern int Type=0;     // Projection Type
                       // 0 - ADR
                       // 1 - ATR
extern int BarsForLine=50;                       

int init()
  {
   IndicatorShortName("ADR Projection");
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Line1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Line2);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,R);

   return(0);
  }

int deinit()
  {
   Comment("");
   return(0);
  }
  
double TrueRange(int shift)
{
 double hl=MathAbs(High[shift]-Low[shift]);
 double hc=MathAbs(High[shift]-Close[shift+1]);
 double lc=MathAbs(Low[shift]-Close[shift+1]);
 return (MathMax(MathMax(hl,hc),lc));
}  

int start()
{
 double ADR, ADR1;
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int    limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars;
 int pos=limit;
 while(pos>=0)
 {
  if (Type==0)
  {
   R[pos]=High[pos]-Low[pos];
  }
  else
  {
   R[pos]=TrueRange(pos);
  }
  pos--;
 } 
 if (Type==0)
 {
  ADR=iMAOnArray(R,0,Length,0,MODE_SMA,0);
  ADR1=iMAOnArray(R,0,Length,0,MODE_SMA,1);
 }
 else
 {
  ADR=iATR(NULL, 0, Length, 0);
  ADR1=iATR(NULL, 0, Length, 1);
 }
 double Max=Low[0]+ADR;
 double Min=High[0]-ADR;
 pos=MathMin(limit, BarsForLine);
 while (pos>=0)
 {
  Line1[pos]=Max;
  Line2[pos]=Min;
  pos--;
 }
 string Str="";
 if (Type==0)
 {
  Str=Str+"DR "+DoubleToStr(R[0]/Point,0);
  if (R[0]>R[1])
  {
   Str=Str+"(+)";
  }
  else
  {
   if (R[0]<R[1])
   {
    Str=Str+"(-)";
   }
   else
   {
    Str=Str+"(0)";
   }
  }
  Str=Str+CharToStr(10)+"ADR "+DoubleToStr(ADR/Point,0);
  if (ADR>ADR1)
  {
   Str=Str+"(+)";
  }
  else
  {
   if (ADR<ADR1)
   {
    Str=Str+"(-)";
   }
   else
   {
    Str=Str+"(0)";
   }
  }
 }
 else
 {
  Str=Str+"TR "+DoubleToStr(R[0]/Point,0);
  if (R[0]>R[1])
  {
   Str=Str+"(+)";
  }
  else
  {
   if (R[0]<R[1])
   {
    Str=Str+"(-)";
   }
   else
   {
    Str=Str+"(0)";
   }
  }
  Str=Str+CharToStr(10)+"ATR "+DoubleToStr(ADR/Point,0);
  if (ADR>ADR1)
  {
   Str=Str+"(+)";
  }
  else
  {
   if (ADR<ADR1)
   {
    Str=Str+"(-)";
   }
   else
   {
    Str=Str+"(0)";
   }
  }
  
 }
 Str=Str+CharToStr(10)+"ATR Projections Up "+DoubleToStr(Max,Digits);
 Str=Str+CharToStr(10)+"ATR Projections Down "+DoubleToStr(Min,Digits);
 Comment(Str);
 
 return(0);
}

