//+------------------------------------------------------------------+
//|                                                        VA_MA.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=15;
extern bool Use_Double_Smooth=true;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double VAMA[];
double Raw[];

int init()
{
 IndicatorShortName("Velocity and Accerlation Moving Average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,VAMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);

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
 double vel, acc, aaa;
 double MA0, MA4, MA8, MA12;
 pos=limit;
 while(pos>=0)
 {
  MA0=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos);
  MA4=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos+Length/4);
  MA8=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos+Length/8);
  MA12=iMA(NULL, 0, Length, 0, MODE_EMA, Price, pos+Length/12);
  vel=MA0-MA4;
  acc=MA0-2.*MA4+MA8;
  aaa=MA0-3.*MA4+3.*MA8-MA12;
  Raw[pos]=MA0+vel+acc/2.+aaa/6.;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Use_Double_Smooth)
  {
   VAMA[pos]=iMAOnArray(Raw, 0, Length/4, 0, MODE_EMA, pos);
  }
  else
  {
   VAMA[pos]=Raw[pos];
  }

  pos--;
 }
   
 return(0);
}

