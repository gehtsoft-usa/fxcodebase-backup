//+------------------------------------------------------------------+
//|                                                          BBB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Yellow

extern int Length=20;
extern int Method=0;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
extern int Smooth_Length=30;
extern int Smooth_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA

double BBB[];
double Bull[], Bear[], Smooth[];

int init()
{
 IndicatorShortName("Bull And Bear Balance");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,BBB);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Bull);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Bear);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Smooth);

 return(0);
}

int deinit()
{

 return(0);
}

double BearPower(int index)
{
 double Value=0.;
 if (Close[index]<Open[index])
 {
  if (Close[index+1]>Open[index])
  {
   Value=MathMax(Close[index+1]-Open[index], High[index]-Low[index]);
  }
  else
  {
   Value=High[index]-Low[index];
  }
 }
 else
 {
  if (Close[index]>Open[index])
  {
   if (Close[index+1]>Open[index])
   {
    Value=MathMax(Close[index+1]-Low[index], High[index]-Close[index]);
   }
   else
   {
    Value=MathMax(Open[index]-Low[index], High[index]-Close[index]);
   }
  }
  else
  {
   if (High[index]-Close[index]>Close[index]-Low[index])
   {
    if (Close[index+1]>Open[index])
    {
     Value=MathMax(Close[index+1]-Open[index], High[index]-Low[index]);
    }
    else
    {
     Value=High[index]-Low[index];
    }
   }
   else
   {
    if (High[index]-Close[index]<Close[index]-Low[index])
    {
     if (Close[index+1]>Open[index])
     {
      Value=MathMax(Close[index+1]-Low[index], High[index]-Close[index]);
     }
     else
     {
      Value=Open[index]-Low[index];
     }
    }
    else
    {
     if (Close[index+1]>Open[index])
     {
      Value=MathMax(Close[index+1]-Open[index], High[index]-Low[index]);
     }
     else
     {
      if (Close[index+1]<Open[index])
      {
       Value=MathMax(Open[index]-Low[index], High[index]-Close[index]);
      }
      else
      {
       Value=High[index]-Low[index];
      }
     }
    }
   }
  }
 }
 return (Value);
}

double BullPower(int index)
{
 double Value=0.;
 if (Close[index]<Open[index])
 {
  if (Close[index+1]<Open[index])
  {
   Value=MathMax(High[index]-Close[index+1], Close[index]-Low[index]);
  }
  else
  {
   Value=MathMax(High[index]-Open[index], Close[index]-Low[index]);
  }
 }
 else
 {
  if (Close[index]>Open[index])
  {
   if (Close[index+1]>Open[index])
   {
    Value=High[index]-Low[index];
   }
   else
   {
    Value=MathMax(Open[index]-Close[index+1], High[index]-Low[index]);
   }
  }
  else
  {
   if (High[index]-Close[index]>Close[index]-Low[index])
   {
    if (Close[index+1]<Open[index])
    {
     Value=MathMax(High[index]-Close[index+1], Close[index]-Low[index]);
    }
    else
    {
     Value=High[index]-Open[index];
    }
   }
   else
   {
    if (High[index]-Close[index]<Close[index]-Low[index])
    {
     if (Close[index+1]>Open[index])
     {
      Value=High[index]-Low[index];
     }
     else
     {
      Value=MathMax(Open[index]-Close[index+1], High[index]-Low[index]);
     }
    }
    else
    {
     if (Close[index+1]>Open[index])
     {
      Value=MathMax(High[index]-Open[index], Close[index]-Low[index]);
     }
     else
     {
      if (Close[index+1]<Open[index])
      {
       Value=MathMax(Open[index]-Close[index+1], High[index]-Low[index]);
      }
      else
      {
       Value=High[index]-Low[index];
      }
     }
    }
   }
  }
 }
 
 return (Value);
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
  Bull[pos]=BullPower(pos);
  Bear[pos]=BearPower(pos);

  pos--;
 } 
 
 double MA_Bull, MA_Bear;
 pos=limit;
 while(pos>=0)
 {
  MA_Bull=iMAOnArray(Bull, 0, Length, 0, Method, pos);
  MA_Bear=iMAOnArray(Bear, 0, Length, 0, Method, pos);
  Smooth[pos]=MA_Bull-MA_Bear;

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  BBB[pos]=iMAOnArray(Smooth, 0, Smooth_Length, 0, Smooth_Method, pos)/Point;

  pos--;
 }  
   
 return(0);
}

