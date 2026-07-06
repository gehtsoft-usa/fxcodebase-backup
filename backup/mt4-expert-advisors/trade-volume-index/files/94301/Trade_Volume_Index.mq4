//+------------------------------------------------------------------+
//|                                           Trade_Volume_Index.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Minimum_Tick_Value=10;

double TVI[];
double Direction[], ExtremePrice[];

int init()
{
 IndicatorShortName("Trade Volume Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,TVI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Direction);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,ExtremePrice);

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
 double Change;
 int pos;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Direction[pos]=0.;
   ExtremePrice[pos]=Close[pos];
   TVI[pos]=0.;
  }
  else
  {
   Change=(Close[pos]-ExtremePrice[pos+1])/Point;
   if (Change>Minimum_Tick_Value)
   {
    Direction[pos]=1.;
    ExtremePrice[pos]=Close[pos];
   }
   else
   {
    if (Change<-Minimum_Tick_Value)
    {
     Direction[pos]=-1.;
     ExtremePrice[pos]=Close[pos];
    }
    else
    {
     Direction[pos]=Direction[pos+1];
     ExtremePrice[pos]=ExtremePrice[pos+1];
    }
   }
   
   if (Direction[pos]>0.)
   {
    TVI[pos]=TVI[pos+1]+Volume[pos];
   }
   else
   {
    if (Direction[pos]<0.)
    {
     TVI[pos]=TVI[pos+1]-Volume[pos];
    }
    else
    {
     TVI[pos]=TVI[pos+1];
    }
   }
  } 
  
  pos--;
 } 
 return(0);
}

