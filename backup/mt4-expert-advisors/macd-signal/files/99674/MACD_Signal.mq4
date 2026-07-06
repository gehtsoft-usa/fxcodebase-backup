//+------------------------------------------------------------------+
//|                                                  MACD_Signal.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 Green
#property indicator_color2 Red

extern int Short_EMA=12;
extern int Long_EMA=26;
extern int Signal=9;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern string Type_Str="Type: 0 - MACD/Signal, 1 - MACD/Zero, 2 - Histogram/Zero";
extern int Type=0;
extern int ArrowSize=3;

double Up[], Dn[];
double MACD[], SignalL[], Histogram[];

int init()
{
 IndicatorShortName("MACD Signal indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(0,233);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_ARROW,0,ArrowSize);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,Dn);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MACD);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,SignalL);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Histogram);

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
 double EMA_S, EMA_L;
 pos=limit;
 while(pos>=0)
 {
  EMA_S=iMA(NULL, 0, Short_EMA, 0, MODE_EMA, Price, pos);
  EMA_L=iMA(NULL, 0, Long_EMA, 0, MODE_EMA, Price, pos);
  
  MACD[pos]=EMA_S-EMA_L;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  SignalL[pos]=iMAOnArray(MACD, 0, Signal, 0, MODE_SMA, pos);
  
  Histogram[pos]=MACD[pos]-SignalL[pos];
  
  if (Type==0)
  {
   if (MACD[pos+1]<=SignalL[pos+1] && MACD[pos]>SignalL[pos])
   {
    Up[pos]=High[pos];
   }
   if (MACD[pos+1]>=SignalL[pos+1] && MACD[pos]<SignalL[pos])
   {
    Dn[pos]=Low[pos];
   }
  }
  else
  {
   if (Type==1)
   {
    if (MACD[pos+1]<=0. && MACD[pos]>0.)
    {
     Up[pos]=High[pos];
    }
    if (MACD[pos+1]>=0. && MACD[pos]<0.)
    {
     Dn[pos]=Low[pos];
    }
   }
   else
   {
    if (Histogram[pos+1]<=0. && Histogram[pos]>0.)
    {
     Up[pos]=High[pos];
    }
    if (Histogram[pos+1]>=0. && Histogram[pos]<0.)
    {
     Dn[pos]=Low[pos];
    }
   }
  }

  pos--;
 }
   
 return(0);
}

