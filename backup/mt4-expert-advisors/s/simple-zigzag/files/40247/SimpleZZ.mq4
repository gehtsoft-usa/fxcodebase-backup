//+------------------------------------------------------------------+
//|                                                     SimpleZZ.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Yellow

extern int Method=0;      // 0 - Step in pips
                          // 1 - Step in percent
extern double Step=100;

double Direction[], MinBar[], MaxBar[];
double MinPrice[], MaxPrice[];
double StepPoint;

int init()
  {
   IndicatorShortName("Simple ZigZag");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ZIGZAG);
   SetIndexBuffer(0,MinPrice);
   SetIndexStyle(1,DRAW_ZIGZAG);
   SetIndexBuffer(1,MaxPrice);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexBuffer(2,Direction);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,MinBar);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,MaxBar);
   StepPoint=Step*Point;
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
void CalculateUp(int bar, double price)
{
 int LastBar=MaxBar[bar];
 if (MaxPrice[LastBar]==EMPTY_VALUE)
 {
  MaxPrice[LastBar]=High[LastBar];
 }
 if (price>MaxPrice[LastBar])
 {
  MaxPrice[LastBar]=EMPTY_VALUE;
  MaxPrice[bar]=price;
  MaxBar[bar]=bar;
  LastBar=bar;
 }
 if ((price+StepPoint<MaxPrice[LastBar] && Method==0) || (price*(1+Step/100)<MaxPrice[LastBar] && Method!=0))
 {
  Direction[bar]=-1;
  MinPrice[bar]=price;
  MinBar[bar]=bar;
 }
 return;
}  

void CalculateDn(int bar, double price)
{
 int LastBar=MinBar[bar];
 if (MinPrice[LastBar]==EMPTY_VALUE)
 {
  MinPrice[LastBar]=Low[LastBar];
 }
 if (price<MinPrice[LastBar])
 {
  MinPrice[LastBar]=EMPTY_VALUE;
  MinPrice[bar]=price;
  MinBar[bar]=bar;
  LastBar=bar;
 }
 if ((price-StepPoint>MinPrice[LastBar] && Method==0) || (price*(1-Step/100)>MinPrice[LastBar] && Method!=0))
 {
  Direction[bar]=1;
  MaxPrice[bar]=price;
  MaxBar[bar]=bar;
 }
 return;
}  

void Calculate(int bar, double price)
{
 if (Direction[bar]==1) CalculateUp(bar, price); else CalculateDn(bar, price);
 return;
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Direction[pos]=1;
   MinBar[pos]=pos;
   MaxBar[pos]=pos;
   if (Close[pos]>Open[pos])
   {
    MinPrice[pos]=High[pos];
    MaxPrice[pos]=High[pos];
   }
   else
   {
    MinPrice[pos]=Low[pos];
    MaxPrice[pos]=Low[pos];
   }
  }
  else
  {
   MinBar[pos]=MinBar[pos+1];
   MaxBar[pos]=MaxBar[pos+1];
   Direction[pos]=Direction[pos+1];
   MinPrice[pos]=EMPTY_VALUE;
   MaxPrice[pos]=EMPTY_VALUE;
   if (Close[pos]<Open[pos])
   {
    Calculate(pos, High[pos]);
    Calculate(pos, Low[pos]);
   }
   else
   {
    Calculate(pos, Low[pos]);
    Calculate(pos, High[pos]);
   }
  }
  pos--;
 } 

 return(0);
}

