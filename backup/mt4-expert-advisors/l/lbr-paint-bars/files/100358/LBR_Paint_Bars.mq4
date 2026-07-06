//+------------------------------------------------------------------+
//|                                               LBR_Paint_Bars.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Gray
#property indicator_color4 Green
#property indicator_color5 Red

extern double Factor=2.5;
extern int ATR_Length=9;
extern int HL_Length=16;
extern bool Show_Overlay=true;
extern bool Show_Lines=true;
extern int Dot_Size=3;

double Band1[], Band2[], Ne[], Up[], Dn[];

int init()
{
 IndicatorShortName("LBR Paint Bars");
 IndicatorDigits(Digits);
 if (Show_Lines)
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
 } 
 SetIndexBuffer(0,Band1);
 SetIndexBuffer(1,Band2);
 SetIndexStyle(2,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(2,119);
 SetIndexBuffer(2,Ne);
 SetIndexStyle(3,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(3,119);
 SetIndexBuffer(3,Up);
 SetIndexStyle(4,DRAW_ARROW,0,Dot_Size);
 SetIndexArrow(4,119);
 SetIndexBuffer(4,Dn);

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
 double ATR, Delta;
 double Min, Max;
 bool UpperVolatility, LowerVolatility;
 pos=limit;
 while(pos>=0)
 {
  ATR=iATR(NULL, 0, ATR_Length, pos);
  Delta=Factor*ATR;
  Min=Low[iLowest(NULL, 0, MODE_LOW, HL_Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, HL_Length, pos)];
  
  Band1[pos]=Min+Delta;
  Band2[pos]=Max-Delta;
  
  if (Close[pos]>Band1[pos] && Close[pos]>Band2[pos])
  {
   UpperVolatility=true;
  }
  else
  {
   UpperVolatility=false;
  }
  
  if (Close[pos]<Band1[pos] && Close[pos]<Band2[pos])
  {
   LowerVolatility=true;
  }
  else
  {
   LowerVolatility=false;
  }
  
  if (Show_Overlay)
  {
   Ne[pos]=EMPTY_VALUE;
   Up[pos]=EMPTY_VALUE;
   Dn[pos]=EMPTY_VALUE;
   if (UpperVolatility) 
   {
    Up[pos]=High[pos];
   }
   else
   {
    if (LowerVolatility)
    {
     Dn[pos]=High[pos];
    }
    else
    {
     Ne[pos]=High[pos];
    }
   } 
  }

  pos--;
 } 
 return(0);
}

