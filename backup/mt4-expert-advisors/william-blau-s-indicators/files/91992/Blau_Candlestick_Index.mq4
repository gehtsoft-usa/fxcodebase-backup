//+------------------------------------------------------------------+
//|                                       Blau_Candlestick_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=1;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int First_Smooth_Length=20;
extern int Second_Smooth_Length=5;
extern int Third_Smooth_Length=3;
extern double Up_Level=25;
extern double Dn_Level=-25;                         

double CI[];
double CM[], CM_MA1[], CM_MA2[], MinMax[], MinMax_MA1[], MinMax_MA2[];

int init()
{
 IndicatorShortName("William Blau Candlestick Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,CM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,CM_MA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,CM_MA2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,MinMax);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,MinMax_MA1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,MinMax_MA2);
 
 SetLevelValue(0, Up_Level);
 SetLevelValue(1, Dn_Level);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;

 double Min, Max;
 pos=limit;
 while(pos>=0)
 {
  CM[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos)-iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+Length);
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  MinMax[pos]=Max-Min;
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  CM_MA1[pos]=iMAOnArray(CM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  MinMax_MA1[pos]=iMAOnArray(MinMax, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  
   
 pos=limit;
 while(pos>=0)
 {
  CM_MA2[pos]=iMAOnArray(CM_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  MinMax_MA2[pos]=iMAOnArray(MinMax_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  

 double CM_MA3, MinMax_MA3; 
 pos=limit;
 while(pos>=0)
 {
  CM_MA3=iMAOnArray(CM_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
  MinMax_MA3=iMAOnArray(MinMax_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
  if (MinMax_MA3!=0)
  {
   CI[pos]=100.*CM_MA3/MinMax_MA3;
  }
  else
  {
   CI[pos]=EMPTY_VALUE;
  } 
  pos--;
 }  
 
 
   
 return(0);
}

