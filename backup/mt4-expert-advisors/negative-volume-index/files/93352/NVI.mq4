//+------------------------------------------------------------------+
//|                                                          NVI.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=21;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA

double Main[], Signal[];

int init()
{
 IndicatorShortName("Negative Volume Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Main);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Signal);

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
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2)
  {
   Main[pos]=1.;
  }
  else
  {
   if (Volume[pos]<Volume[pos+1])
   {
    Main[pos]=Main[pos+1]*(1.+(Close[pos]-Close[pos+1])/Close[pos+1]);
   }
   else
   {
    Main[pos]=Main[pos+1];
   }
  } 
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(Main, 0, Length, 0, Method, pos);

  pos--;
 }
   
 return(0);
}

