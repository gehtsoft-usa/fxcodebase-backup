//+------------------------------------------------------------------+
//|                                           Wide_Narrow_Spread.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=4;
extern bool Show_Wide_Spread_Bar=true;
extern bool Show_Narrow_Spread_Bar=true;
extern int ArrowSize=2;

double WS[], NS[];
double HL[];

int init()
{
 IndicatorShortName("Wide/Narrow Spread");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,234);
 SetIndexBuffer(0,WS);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,NS);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,HL);

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
  HL[pos]=High[pos]-Low[pos];

  pos--;
 } 

 double Min, Max; 
 pos=limit;
 while(pos>=0)
 {
  Min=HL[ArrayMinimum(HL, Length, pos)];
  Max=HL[ArrayMaximum(HL, Length, pos)];
  
  if (Show_Wide_Spread_Bar)
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
  
  if (Show_Narrow_Spread_Bar)
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

  pos--;
 }
   
 return(0);
}

