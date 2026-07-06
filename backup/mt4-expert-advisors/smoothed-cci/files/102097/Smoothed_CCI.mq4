//+------------------------------------------------------------------+
//|                                                 Smoothed_CCI.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern bool Use_Pre_Smoothing=false;
extern int Pre_Length=14;
extern int Pre_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int CCI_Length=14;
extern bool Use_Post_Smoothing=false;
extern int Post_Length=14;                          
extern int Post_Method=0;  // 0 - SMA
                           // 1 - EMA
                           // 2 - SMMA
                           // 3 - LWMA
extern double Overbought_Level=100.;
extern double Oversold_Level=-100.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
                           

double SCCI[];
double Source[], Res[];

int init()
{
 IndicatorShortName("Smoothed CCI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SCCI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Source);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Res);
 
 SetLevelValue(0, Overbought_Level);
 SetLevelValue(1, Oversold_Level);

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
  if (Use_Pre_Smoothing)
  {
   Source[pos]=iMA(NULL, 0, Pre_Length, 0, Pre_Method, Price, pos);
  }
  else
  {
   Source[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Res[pos]=iCCIOnArray(Source, 0, CCI_Length, pos);
  
  pos--;
 }

 pos=limit;
 while(pos>=0)
 {
  if (Use_Post_Smoothing)
  {
   SCCI[pos]=iMAOnArray(Res, 0, Post_Length, 0, Post_Method, pos);
  }
  else
  {
   SCCI[pos]=Res[pos];
  }

  pos--;
 }
     
 return(0);
}

