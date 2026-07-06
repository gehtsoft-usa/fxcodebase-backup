// Id: 9302
//+------------------------------------------------------------------+
//|                                                  NonLag_MACD.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 Blue
#property indicator_color3 Magenta
#property indicator_color4 Red
#property indicator_color5 Gray
#property indicator_color6 DodgerBlue
#property indicator_color7 DarkOrange

extern int Filter=0;
extern double Deviation=0;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int Fast_Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Fast_Length=12;
extern int Slow_Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Slow_Length=26;
extern int Signal_Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Signal_Length=9;

double MACD[], MACD_PUP[], MACD_PDN[], MACD_NUP[], MACD_NDN[], Signal[], Signal_UP[], Signal_DN[];
int MaxLength;

int init()
  {
       double temp = iCustom(NULL, 0, "NonLag", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'NonLag' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Non lag MACD");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,MACD_PUP);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,MACD_PDN);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,MACD_NUP);
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,MACD_NDN);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,Signal);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,Signal_UP);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,Signal_DN);
   SetIndexStyle(7,DRAW_NONE);
   SetIndexBuffer(7,MACD);
   MaxLength=MathMax(Fast_Length, MathMax(Slow_Length, Signal_Length));
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  double Fast=iCustom(NULL, 0, "NonLag", Fast_Method, Fast_Length, Price, Filter, Deviation, 0, pos);
  double Slow=iCustom(NULL, 0, "NonLag", Slow_Method, Slow_Length, Price, Filter, Deviation, 0, pos);
  MACD[pos]=Fast-Slow;
  if (MACD[pos]>0)
  {
   if (MACD[pos]>=MACD[pos+1])
   {
    MACD_PUP[pos]=MACD[pos];
   }
   else
   {
    MACD_PDN[pos]=MACD[pos];
   }
  }
  else
  {
   if (MACD[pos]>=MACD[pos+1])
   {
    MACD_NUP[pos]=MACD[pos];
   }
   else
   {
    MACD_NDN[pos]=MACD[pos];
   }
  }
  pos--;
 }
 
 pos=limit;
 while (pos>=0)
 {
  Signal[pos]=iMAOnArray(MACD, 0, Signal_Length, 0, Signal_Method, pos);
  if (Signal[pos]>=Signal[pos+1])
  {
   Signal_UP[pos]=Signal[pos];
  }
  else
  {
   Signal_DN[pos]=Signal[pos];
  }
  pos--;
 }
 return(0);
}

