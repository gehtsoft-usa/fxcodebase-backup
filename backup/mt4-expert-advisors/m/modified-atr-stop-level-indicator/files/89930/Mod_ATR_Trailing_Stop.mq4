//+------------------------------------------------------------------+
//|                                        Mod_ATR_Trailing_Stop.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=10;
extern double Coeff=4;

double TS[], TSDn[];
double HL[], Diff[], WMA[];
double k;

int init()
{
 IndicatorShortName("Modified ATR Trailing Stop indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TS);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,TSDn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HL);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Diff);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,WMA);
 
 double n1=2.*Length-1.;
 k=2./(n1+1);

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
 pos=limit;
 while(pos>=0)
 {
  HL[pos]=High[pos]-Low[pos];
  pos--;
 } 
 
 double SMA, HiLo;
 double Href, Lref;
 pos=limit;
 while(pos>=0)
 {
  SMA=iMAOnArray(HL, 0, Length, 0, MODE_SMA, pos);
  HiLo=MathMin(HL[pos], SMA);
  if (Low[pos]<=High[pos+1])
  {
   Href=High[pos]-Close[pos+1];
  }
  else
  {
   Href=(HL[pos]-Close[pos+1]+High[pos+1])/2;
  }
  
  if (High[pos]>=Low[pos+1])
  {
   Lref=Close[pos+1]-Low[pos];
  }
  else
  {
   Lref=(Close[pos+1]-Low[pos+1]+HL[pos])/2;
  }
  Diff[pos]=MathMax(HiLo, MathMax(Href, Lref));
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   WMA[pos]=iMAOnArray(Diff, 0, Length, 0, MODE_SMA, pos);
  }
  else
  {
   WMA[pos]=(Diff[pos]-WMA[pos+1])*k+WMA[pos+1];
  }
  pos--;
 } 
 
 double loss;
 pos=limit;
 while(pos>=0)
 {
  loss=WMA[pos]*Coeff;
  if (Close[pos]>TS[pos+1] && Close[pos+1]>TS[pos+1])
  {
   TS[pos]=MathMax(TS[pos+1], Close[pos]-loss);
   TSDn[pos]=TS[pos];
   TSDn[pos+1]=TS[pos+1];
  }
  else
  {
   if (Close[pos]<TS[pos+1] && Close[pos+1]<TS[pos+1])
   {
    TS[pos]=MathMin(TS[pos+1], Close[pos]+loss);
   }
   else
   {
    if (Close[pos]>TS[pos+1])
    {
     TS[pos]=Close[pos]-loss;
     TSDn[pos]=TS[pos];
     TSDn[pos+1]=TS[pos+1];
    }
    else
    {
     TS[pos]=Close[pos]+loss;
    }
   }
  }
  pos--;
 }  
 
 return(0);
}

