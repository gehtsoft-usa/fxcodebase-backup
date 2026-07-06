//+------------------------------------------------------------------+
//|                                                        MaDev.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Length=20;
extern int Frame=3;
extern int Arrow_Size=4;

double MA[], Up[], Dn[];
double Dev[];
int Shift;

int init()
{
 IndicatorShortName("MaDev oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MA);
 SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(2,233);
 SetIndexBuffer(2,Dn);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Dev);
 
 Shift=MathFloor((Frame-1.)/2.);

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
 double Pr;
 bool Min, Max;
 int i;
 
 pos=limit;
 while(pos>=0)
 {
  Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  MA[pos]=iMA(NULL, 0, Length, 0, Method, Price, pos);
  
  Dev[pos]=Pr-MA[pos];
  
  Min=true;
  Max=true;
  
  for (i=1;i<=Shift;i++)
  {
   if (Dev[pos+Shift+1]>=Dev[pos+i+Shift+1] || Dev[pos+Shift+1]>=Dev[pos-i+Shift+1])
   {
    Min=false;
   }
   if (Dev[pos+Shift+1]<=Dev[pos+i+Shift+1] || Dev[pos+Shift+1]<=Dev[pos-i+Shift+1])
   {
    Max=false;
   }
  }
  
  if (Min && Dev[pos+Shift+1]<0.)
  {
   Dn[pos+Shift+1]=Low[pos+Shift+1];
  }
  else
  {
   Dn[pos+Shift+1]=EMPTY_VALUE;
  }

  if (Max && Dev[pos+Shift+1]>0.)
  {
   Up[pos+Shift+1]=High[pos+Shift+1];
  }
  else
  {
   Up[pos+Shift+1]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

