// Id: 9679
//+------------------------------------------------------------------+
//|                                                     LR_Ratio.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length1=10;
extern int Length2=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double LR_Ratio[];

int init()
{
     double temp = iCustom(NULL, 0, "LRL", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'LRL' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Linear regression ratio");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,LR_Ratio);
 SetLevelValue(0, 1);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length1 || Bars<=Length2) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double LR1, LR2;
 while(pos>=0)
 {
  LR1=iCustom(NULL, 0, "LRL", Length1, Price, 0, pos);
  LR2=iCustom(NULL, 0, "LRL", Length2, Price, 0, pos);
  if (LR2>0)
  {
   LR_Ratio[pos]=LR1/LR2;
  }
  pos--;
 }

 return(0);
}

