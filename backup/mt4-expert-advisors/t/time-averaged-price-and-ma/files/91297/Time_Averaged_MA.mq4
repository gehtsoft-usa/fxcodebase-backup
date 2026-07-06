//+------------------------------------------------------------------+
//|                                             Time_Averaged_MA.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int Length=10;
extern int Price=0;      // Applied price
                         // 0 - Close
                         // 1 - Open
                         // 2 - High
                         // 3 - Low
                         // 4 - Median
                         // 5 - Typical
                         // 6 - Weighted  
extern int MA_Length=15;                         
extern int MA_Method=0;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

double TAMA[];
double TAP[];

int init()
{
 IndicatorShortName("Time Averaged moving average");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TAMA);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,TAP);

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
 double Max, Min;
 pos=limit;
 while(pos>=0)
 {
  Max=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Min=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  if (Price==0) //Close
  {
   TAP[pos]=Close[pos];
  }
  else
  {
   if (Price==1) // Open
   {
    TAP[pos]=Open[pos+Length-1];
   }
   else
   {
    if (Price==2) // High
    {
     TAP[pos]=Max;
    }
    else
    {
     if (Price==3) // Low
     {
      TAP[pos]=Min;
     }
     else
     {
      if (Price==4) // Median
      {
       TAP[pos]=(Max+Min)/2.;
      }
      else
      {
       if (Price==5) // Typical
       {
        TAP[pos]=(Max+Min+Close[pos])/3.;
       }
       else // Weighted
       {
        TAP[pos]=(Max+Min+2.*Close[pos])/4.;
       }
      }
     }
    }
   }
  }
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  TAMA[pos]=iMAOnArray(TAP, 0, MA_Length, 0, MA_Method, pos);
  pos--;
 }
   
 return(0);
}

