// Id: 10102
//+------------------------------------------------------------------+
//|                                             Zero_Lag_Rainbow.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=2;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Length2=7;
extern int Method2=1;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA

double ZL[];
double Rainbow[], EMA1[];

int init()
{
     double temp = iCustom(NULL, 0, "Mel_Widner_Averaged_Rainbow", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Mel_Widner_Averaged_Rainbow' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Zero lag rainbow indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ZL);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,EMA1);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Rainbow);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=10) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  Rainbow[pos]=iCustom(NULL, 0, "Mel_Widner_Averaged_Rainbow", Length, Price, Method, 0, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(Rainbow, 0, Length2, 0, Method2, pos);
  pos--; 
 } 

 double EMA2, diff;
 pos=limit;
 while(pos>=0)
 {
  EMA2=iMAOnArray(EMA1, 0, Length2, 0, Method2, pos);
  diff=EMA1[pos]-EMA2;
  ZL[pos]=EMA1[pos]+diff;
  pos--; 
 } 
 
 return(0);
}

