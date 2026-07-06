//+------------------------------------------------------------------+
//|                                                           CI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=28;
extern double Delta=100;
extern int Level=14;
extern int LabelSize=3;

double CI[], Inc[], Dec[];
double DeltaP;

int init()
{
 IndicatorShortName("Congestion Identifier");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CI);
 SetIndexBuffer(1,Inc);
 SetIndexStyle(1,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(1,119);
 SetIndexBuffer(2,Dec);
 SetIndexStyle(2,DRAW_ARROW,0,LabelSize);
 SetIndexArrow(2,119);
 
 SetLevelValue(0, Level);
 
 DeltaP=Delta*Point;

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
 double Top, Bottom;
 int i;
 int Count;
 pos=limit;
 while(pos>=0)
 {
  Top=Close[pos]+DeltaP;
  Bottom=Close[pos]-DeltaP;
  Count=0;
  for (i=0;i<Length;i++)
  {
   if (Close[pos+i]<Top && Close[pos+i]>Bottom)
   {
    Count++;
   }
  }
  
  CI[pos]=Count;
  
  if (CI[pos+1]<Level && CI[pos]>Level)
  {
   Inc[pos]=Level;
  }
  else
  {
   Inc[pos]=EMPTY_VALUE;
  }
  
  if (CI[pos+1]>Level && CI[pos]<Level)
  {
   Dec[pos]=Level;
  }
  else
  {
   Dec[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

