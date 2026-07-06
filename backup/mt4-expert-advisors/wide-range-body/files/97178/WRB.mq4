//+------------------------------------------------------------------+
//|                                                          WRB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Blue

extern int Length=3;
extern int LabelSize=3;

double Up[], Dn[], Neu[], Ned[];

int init()
{
 IndicatorShortName("Wide Range Body");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Up);
 SetIndexStyle(0,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(0,119);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(1,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(1,119);
 SetIndexBuffer(2,Neu);
 SetIndexStyle(2,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(2,119);
 SetIndexBuffer(3,Ned);
 SetIndexStyle(3,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(3,119);

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
 bool U, D, N;
 int i;
 pos=limit;
 while(pos>=0)
 {
  U=true;
  D=true;
  N=true;
  for (i=1;i<=Length;i++)
  {
   if (MathAbs(Open[pos]-Close[pos])<MathAbs(Open[pos+i]-Close[pos+i]))
   {
    N=false;
    U=false;
    D=false;
   }
   else
   { 
    if (Close[pos+i]<Open[pos+i] || Close[pos]<Open[pos])
    {
     U=false;
    }
    else
    {
     if (Close[pos+i]>Open[pos+i] || Close[pos]>Open[pos])
     {
      D=false;
     }
    } 
   }
  }
  
  if (U)
  {
   Up[pos]=High[pos];
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
  }
  
  if (D)
  {
   Dn[pos]=Low[pos];
  }
  else
  {
   Dn[pos]=EMPTY_VALUE;
  }
  
  if (N && !U && !D)
  {
   if (Open[pos]<Close[pos])
   {
    Neu[pos]=Low[pos];
    Ned[pos]=EMPTY_VALUE;
   }
   else
   {
    Ned[pos]=High[pos];
    Neu[pos]=EMPTY_VALUE;
   }
  }
  
  pos--;
 } 
 return(0);
}

