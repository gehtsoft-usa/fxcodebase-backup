// Id: 10629
//+------------------------------------------------------------------+
//|                                                         MASO.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Gray
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length1=50;
extern int Method1=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern double Slope1=0;
extern int Slope_Length1=1;
extern int Price1=0;      // Applied price
                          // 0 - Close
                          // 1 - Open
                          // 2 - High
                          // 3 - Low
                          // 4 - Median
                          // 5 - Typical
                          // 6 - Weighted  

extern int Length2=10;
extern int Method2=1;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern double Slope2=0;
extern int Slope_Length2=1;
extern int Price2=0;      // Applied price
                          // 0 - Close
                          // 1 - Open
                          // 2 - High
                          // 3 - Low
                          // 4 - Median
                          // 5 - Typical
                          // 6 - Weighted  


double MASO[], MASO_Up[], MASO_Dn[];

int init()
{
     double temp = iCustom(NULL, 0, "MA_Slope", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'MA_Slope' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("MA Slope Oscilator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,MASO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,MASO_Up);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,MASO_Dn);

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
 double MA_Slope1, MA_Slope1_Up, MA_Slope1_Dn, MA_Slope2, MA_Slope2_Up, MA_Slope2_Dn;
 pos=limit;
 while(pos>=0)
 {
  MA_Slope1=iCustom(NULL, 0, "MA_Slope", Length1, Method1, Slope1, Slope_Length1, Price1, 0, pos);
  MA_Slope1_Up=iCustom(NULL, 0, "MA_Slope", Length1, Method1, Slope1, Slope_Length1, Price1, 1, pos);
  MA_Slope1_Dn=iCustom(NULL, 0, "MA_Slope", Length1, Method1, Slope1, Slope_Length1, Price1, 2, pos);
  MA_Slope2=iCustom(NULL, 0, "MA_Slope", Length2, Method2, Slope2, Slope_Length2, Price2, 0, pos);
  MA_Slope2_Up=iCustom(NULL, 0, "MA_Slope", Length2, Method2, Slope2, Slope_Length2, Price2, 1, pos);
  MA_Slope2_Dn=iCustom(NULL, 0, "MA_Slope", Length2, Method2, Slope2, Slope_Length2, Price2, 2, pos);
  
  MASO[pos]=0;
  MASO_Up[pos]=0;
  MASO_Dn[pos]=0;
  
  if (MA_Slope1==MA_Slope1_Up && MA_Slope2==MA_Slope2_Up)
  {
   MASO_Up[pos]=1;
  }
  else
  {
   if (MA_Slope1==MA_Slope1_Dn && MA_Slope2==MA_Slope2_Dn)
   {
    MASO_Dn[pos]=1;
   }
   else
   {
    MASO[pos]=1;
   }
  }
  
  pos--;
 } 
 return(0);
}

