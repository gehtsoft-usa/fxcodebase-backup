// Id: 6927
//+------------------------------------------------------------------+
//|                                                        VARMA.mq4 |
//|                               Copyright � 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=9;
extern int Smoothing=2;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double VMA[];

double SC;

int init()
  {
       double temp = iCustom(NULL, 0, "CMO", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'CMO' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("VARMA");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,VMA);
   
   SC=2./(Smoothing+1.);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Smoothing+3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 double AbsCMO;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  if (pos==limit)
  {
   VMA[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  }
  else
  {
   AbsCMO=MathAbs(iCustom(NULL, 0, "CMO", Length, Price, 0, pos))/100;
   VMA[pos]=(SC*AbsCMO*iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos))+(1-(SC*AbsCMO))*VMA[pos+1];
  } 
  
  pos--;
 } 

 return(0);
}

