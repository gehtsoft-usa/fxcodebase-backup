//+------------------------------------------------------------------+
//|                                                         Dots.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Red
#property indicator_color2 Green

extern int Length=6;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA


double Up[], Dn[];
double MA[], UpSt[], DnSt[];

int init()
{
 IndicatorShortName("Dots");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,4);
 SetIndexBuffer(0,Up);
 SetIndexArrow(0,119);
 SetIndexStyle(1,DRAW_ARROW,0,4);
 SetIndexBuffer(1,Dn);
 SetIndexArrow(1,119);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MA);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,UpSt);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,DnSt);

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
  MA[pos]=iMA(NULL, 0, Length, 0, Method, PRICE_CLOSE, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  UpSt[pos]=MA[pos];
  DnSt[pos]=MA[pos];
  if (MA[pos]>MA[pos+1] && MA[pos+1]>MA[pos+2])
  {
   DnSt[pos]=EMPTY_VALUE;
  }
  if (MA[pos]<MA[pos+1] && MA[pos+1]<MA[pos+2])
  {
   UpSt[pos]=EMPTY_VALUE;
  }
  pos--;
 }  

 double Range; 
 pos=limit;
 while(pos>=0)
 {
  Range=High[pos]-Low[pos];
  if (UpSt[pos+1]==EMPTY_VALUE && UpSt[pos]!=EMPTY_VALUE)
  {
   Up[pos]=Low[pos]-Range/2;
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
  }
  if (DnSt[pos+1]==EMPTY_VALUE && DnSt[pos]!=EMPTY_VALUE)
  {
   Dn[pos]=High[pos]+Range/2;
  }
  else
  {
   Dn[pos]=EMPTY_VALUE;
  }
  pos--;
 }  
 
 return(0);
}

