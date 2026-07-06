//+------------------------------------------------------------------+
//|                                       Toby_Crabel_NR_Pattern.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern string Method_Str="Method: 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable";
extern int Method=0;  // 0 - 2NR, 1 - 3NR, 2 - 4NR, 3 - 8NR, 4 - Customizable
extern bool Exclude_Current_Period=true;
extern int Sample=2;
extern int Length=20;
extern bool Show_Wide_Range_Bar=true;
extern bool Show_Narrow_Range_Bar=true;
extern int ArrowSize=2;

double WS[], NS[];
double HL[];
int _Sample, _Length;

int init()
{
 IndicatorShortName("Toby Crabel NR Pattern");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,234);
 SetIndexBuffer(0,WS);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,NS);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HL);
 
 if (Method==0)
 {
  _Sample=2;
  _Length=20;
 }
 if (Method==1)
 {
  _Sample=3;
  _Length=20;
 }
 if (Method==2)
 {
  _Sample=4;
  _Length=40;
 }
 if (Method==3)
 {
  _Sample=8;
  _Length=40;
 }
 if (Method>3)
 {
  _Sample=Sample;
  _Length=Length;
 }
 

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
 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  if (Exclude_Current_Period)
  {
   Min=Low[iLowest(NULL, 0, MODE_LOW, _Sample, pos+1)];
   Max=High[iHighest(NULL, 0, MODE_HIGH, _Sample, pos+1)];
   HL[pos+1]=Max-Min;
  }
  else
  {
   Min=Low[iLowest(NULL, 0, MODE_LOW, _Sample, pos)];
   Max=High[iHighest(NULL, 0, MODE_HIGH, _Sample, pos)];
   HL[pos]=Max-Min;
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Exclude_Current_Period)
  {
   Min=HL[ArrayMinimum(HL, _Length, pos+1)];
   Max=HL[ArrayMaximum(HL, _Length, pos+1)];
   if (Show_Wide_Range_Bar)
   {
    if (Max==HL[pos+1])
    {
     WS[pos+1]=High[pos+1];
    }
    else
    {
     WS[pos+1]=EMPTY_VALUE;
    }
   }
   if (Show_Narrow_Range_Bar)
   {
    if (Min==HL[pos+1])
    {
     NS[pos+1]=High[pos+1];
    }
    else
    {
     NS[pos+1]=EMPTY_VALUE;
    }
   }
  }
  else
  {
   Min=HL[ArrayMinimum(HL, _Length, pos)];
   Max=HL[ArrayMaximum(HL, _Length, pos)];
   if (Show_Wide_Range_Bar)
   {
    if (Max==HL[pos])
    {
     WS[pos]=High[pos];
    }
    else
    {
     WS[pos]=EMPTY_VALUE;
    }
   }
   if (Show_Narrow_Range_Bar)
   {
    if (Min==HL[pos])
    {
     NS[pos]=High[pos];
    }
    else
    {
     NS[pos]=EMPTY_VALUE;
    }
   }
  }

  pos--;
 }
   
 return(0);
}

