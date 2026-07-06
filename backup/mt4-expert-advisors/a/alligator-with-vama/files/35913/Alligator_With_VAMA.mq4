// Id: 6878
//+------------------------------------------------------------------+
//|                                          Alligator_With_VAMA.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Lime

extern int JawsPeriod=13;
extern int JawsShift=8;
extern int TeethPeriod=8;
extern int TeethShift=5;
extern int LipsPeriod=5;
extern int LipsShift=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double JawsBuffer[];
double TeethBuffer[];
double LipsBuffer[];

int init()
  {
       double temp = iCustom(NULL, 0, "VAMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'VAMA' indicator");
       return INIT_FAILED;
   }
   SetIndexShift(0,JawsShift);
   SetIndexShift(1,TeethShift);
   SetIndexShift(2,LipsShift);

   SetIndexDrawBegin(0,JawsPeriod-1);
   SetIndexDrawBegin(1,TeethPeriod-1);
   SetIndexDrawBegin(2,LipsPeriod-1);

   SetIndexBuffer(0,JawsBuffer);
   SetIndexBuffer(1,TeethBuffer);
   SetIndexBuffer(2,LipsBuffer);

   SetIndexStyle(0,DRAW_LINE);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexStyle(2,DRAW_LINE);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 int limit;
 int counted_bars=IndicatorCounted();

 if(counted_bars<0) return(-1);

 if(counted_bars>0) counted_bars--;
 limit=Bars-counted_bars;

 for(int i=0; i<limit; i++)
 {
  JawsBuffer[i]=iCustom(NULL, 0, "VAMA", JawsPeriod, Price, 0, i);
  TeethBuffer[i]=iCustom(NULL, 0, "VAMA", TeethPeriod, Price, 0, i);
  LipsBuffer[i]=iCustom(NULL, 0, "VAMA", LipsPeriod, Price, 0, i);
 }

return(0);
}

