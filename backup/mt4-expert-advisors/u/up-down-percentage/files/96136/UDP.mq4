//+------------------------------------------------------------------+
//|                                                          UDP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=14;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double UP[], DN[];
double UpF[], DnF[], Pr[];

int init()
{
 IndicatorShortName("Up/Down Percentage");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,DN);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,UpF);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,DnF);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Pr);

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)/100.;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  UpF[pos]=0.;
  DnF[pos]=0.;
  if (Pr[pos]>Pr[pos+1])
  {
   UpF[pos]=1.;
  }
  else
  {
   if (Pr[pos]<Pr[pos+1])
   {
    DnF[pos]=1.;
   }
  }

  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  UP[pos]=100.*iMAOnArray(UpF, 0, Length, 0, MODE_SMA, pos);
  DN[pos]=100.*iMAOnArray(DnF, 0, Length, 0, MODE_SMA, pos);

  pos--;
 }
     
 return(0);
}

