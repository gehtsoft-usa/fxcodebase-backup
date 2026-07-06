//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+


#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Blue

#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID

extern int PriceMethod=0;  // 0 - Open/Close
                           // 1 - Close/Close
                           
extern int PeriodMethod=0; // 0 - Use period
                           // 1 - Do not use period
                           
extern int Length=10;      // Period         

extern int OB=5;                       
extern int OS=-5;      


double TrendScore[], PM[];

int init()
{
 IndicatorShortName("Trend score");
 
 IndicatorBuffers(2);   
  
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TrendScore);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,PM);
 
SetLevelValue(0,OB);
SetLevelValue(1,OS);

 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=2) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double PrevPrice;
 while(pos>=0)
 {
  if (PeriodMethod==0)
  {
   if (PriceMethod==0)
   {
    PrevPrice=Open[pos];
   }
   else
   {
    PrevPrice=Close[pos+1];
   }
   if (Close[pos]>PrevPrice)
   {
    PM[pos]=1;
   }
   else
   {
    if (Close[pos]<PrevPrice)
    {
     PM[pos]=-1;
    }
    else
    {
     PM[pos]=0;
    }
   }
   if (pos<Bars-Length) 
   {
    double Sum=0;
    int i;
    for (i=0;i<Length;i++)
    {
     Sum=Sum+PM[pos+i];
    }
   }
   TrendScore[pos]=Sum;
  }
  else
  {
   if (PriceMethod==0)
   {
    PrevPrice=Open[pos];
   }
   else
   {
    PrevPrice=Close[pos+1];
   }
   if (Close[pos]>PrevPrice)
   {
    if (TrendScore[pos+1]>=0)
    {
     TrendScore[pos]=TrendScore[pos+1]+1;
    }
    else
    {
     TrendScore[pos]=1;
    }
   }
   else
   {
    if (Close[pos]<PrevPrice)
    {
     if (TrendScore[pos+1]<0)
     {
      TrendScore[pos]=TrendScore[pos+1]-1;
     }
     else
     {
      TrendScore[pos]=-1;
     }
    }
    else
    {
     TrendScore[pos]=TrendScore[pos+1];
    }
   }
  }
  pos--;
 } 

 return(0);
}

