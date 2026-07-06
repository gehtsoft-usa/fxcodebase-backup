// Id: 11431
//+------------------------------------------------------------------+
//|                                                      Coppock.mq4 |
//|                               Copyright � 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Short_ROC_Length=14;
extern int Long_ROC_Length=11;
extern int LWMA_Length=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  

double Coppock[];
double ROC_Temp[];

int init()
{
     double temp = iCustom(NULL, 0, "ROC", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ROC' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Coppock Indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Coppock);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,ROC_Temp);

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
 double ShortROC, LongROC;
 pos=limit;
 while(pos>=0)
 {
  ShortROC=iCustom(NULL, 0, "ROC", Short_ROC_Length, Price, 0, pos);
  LongROC=iCustom(NULL, 0, "ROC", Long_ROC_Length, Price, 0, pos);
  ROC_Temp[pos]=ShortROC+LongROC;
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Coppock[pos]=iMAOnArray(ROC_Temp, 0, LWMA_Length, 0, MODE_LWMA, pos);
  
  pos--;
 }
   
 return(0);
}

