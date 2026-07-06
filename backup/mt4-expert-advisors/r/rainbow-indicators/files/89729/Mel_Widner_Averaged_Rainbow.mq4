// Id: 10101
//+------------------------------------------------------------------+
//|                                  Mel_Widner_Averaged_Rainbow.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=5;
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

double AR[];
double MA8[], MA9[];

int init()
{
     double temp = iCustom(NULL, 0, "MA_Rainbow", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'MA_Rainbow' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Mel Widner Averaged Rainbow");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,AR);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MA8);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,MA9);

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
 pos=limit;
 while(pos>=0)
 {
  MA8[pos]=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 7, pos);
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA9[pos]=iMAOnArray(MA8, 0, Length, 0, Method, pos);
  pos--;
 }  

 double MA10;
 double MA1, MA2, MA3, MA4, MA5, MA6, MA7; 
 double res;
 pos=limit;
 while(pos>=0)
 {
  MA1=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 0, pos);
  MA2=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 1, pos);
  MA3=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 2, pos);
  MA4=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 3, pos);
  MA5=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 4, pos);
  MA6=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 5, pos);
  MA7=iCustom(NULL, 0, "MA_Rainbow", Length, Price, Method, 6, pos);
  MA10=iMAOnArray(MA9, 0, Length, 0, Method, pos);
  res=(5*MA1+4*MA2+3*MA3+2*MA4+MA5+MA6+MA7+MA8[pos]+MA9[pos]+MA10)/20;
  AR[pos]=res;
  pos--;
 }
   
 return(0);
}

