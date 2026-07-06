//+------------------------------------------------------------------+
//|                                                   Double_Top.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 DarkGreen
#property indicator_color2 Green
#property indicator_color3 Maroon
#property indicator_color4 Red

extern int MinHeight=10;
extern int MaxDist=20;
extern int MinBars=3;

double Top[], DoubleTop[], Bottom[], DoubleBottom[];
double MinHeightPip;

int init()
{
 IndicatorShortName("Double top");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,2);
 SetIndexArrow(0,119);
 SetIndexBuffer(0,Top);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexArrow(1,119);
 SetIndexBuffer(1,DoubleTop);
 SetIndexStyle(2,DRAW_ARROW,0,2);
 SetIndexArrow(2,119);
 SetIndexBuffer(2,Bottom);
 SetIndexStyle(3,DRAW_ARROW,0,4);
 SetIndexArrow(3,119);
 SetIndexBuffer(3,DoubleBottom);
 MinHeightPip=MinHeight*Point;
 return(0);
}

int deinit()
{

 return(0);
}

bool IsTop(int index)
{
 int i;
 bool Fl=true;
 for (i=1;i<=MinBars;i++)
 {
  if (High[index-i]>=High[index]) Fl=false;
 }
 if (Fl)
 {
  i=index+1;
  while (i<Bars)
  {
   if (High[i]>=High[index]) return (false);
   if (High[index]-Low[i]>=MinHeightPip) return (true);
   i++;
  }
 }
 return (false);
}

bool IsBottom(int index)
{
 int i;
 bool Fl=true;
 for (i=1;i<=MinBars;i++)
 {
  if (Low[index-i]<=Low[index]) Fl=false;
 }
 if (Fl)
 {
  i=index+1;
  while (i<Bars)
  {
   if (Low[i]<=Low[index]) return (false);
   if (High[i]-Low[index]>=MinHeightPip) return (true);
   i++;
  }
 }
 return (false);
}

bool FindPrevTop(int index)
{
 int i=index+1;
 while (i<Bars && i<=index+MaxDist)
 {
  if (Top[i]==High[i]) return (true);
  i++;
 }
 return (false);
}

bool FindPrevBottom(int index)
{
 int i=index+1;
 while (i<Bars && i<=index+MaxDist)
 {
  if (Bottom[i]==Low[i]) return (true);
  i++;
 }
 return (false);
}

int start()
{
 if(Bars<=MinBars) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (IsTop(pos+MinBars))
  {
   Top[pos+MinBars]=High[pos+MinBars];
  }
  else
  {
   Top[pos+MinBars]=EMPTY_VALUE;
  }

  if (IsBottom(pos+MinBars))
  {
   Bottom[pos+MinBars]=Low[pos+MinBars];
  }
  else
  {
   Bottom[pos+MinBars]=EMPTY_VALUE;
  }
  
  if (Top[pos+MinBars]==High[pos+MinBars])
  {
   if (FindPrevTop(pos+MinBars))
   {
    DoubleTop[pos+MinBars]=High[pos+MinBars];
   }
   else
   {
    DoubleTop[pos+MinBars]=EMPTY_VALUE;
   }
  }
  
  if (Bottom[pos+MinBars]==Low[pos+MinBars])
  {
   if (FindPrevBottom(pos+MinBars))
   {
    DoubleBottom[pos+MinBars]=Low[pos+MinBars];
   }
   else
   {
    DoubleBottom[pos+MinBars]=EMPTY_VALUE;
   }
  }
  
  pos--;
 } 
 return(0);
}

