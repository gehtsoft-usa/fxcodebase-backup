//+------------------------------------------------------------------+
//|                                                Onisuk_Filter.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern bool Scenario1=true;
extern bool Scenario2=true;
extern bool Scenario3=true;
extern string _Scenario1="Scenario 1";
extern int Length1_1=3;
extern int Method1_1=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Length1_2=7;
extern int Method1_2=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Length1_3=50;
extern int Method1_3=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

extern string _Scenario2="Scenario 2";
extern int Length2_1=20;
extern int Method2_1=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Length2_2=50;
extern int Method2_2=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA

extern string _Scenario3="Scenario 3";
extern int Length3_1=20;
extern int Method3_1=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Length3_2=50;
extern int Method3_2=1;  // 0 - SMA
                         // 1 - EMA
                         // 2 - SMMA
                         // 3 - LWMA
extern int Arrow_Size=1;                         

double UP[], DN[];

int init()
{
 IndicatorShortName("Onisuk Filter Helper");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(0,233);
 SetIndexBuffer(0,UP);
 SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
 SetIndexArrow(1,234);
 SetIndexBuffer(1,DN);

 return(0);
}

int deinit()
{

 return(0);
}

int Calc1(int index)
{
 if (Scenario1)
 {
  double MA1, MA2, MA3;
  MA1=iMA(NULL, 0, Length1_1, 0, Method1_1, PRICE_CLOSE, index);
  MA2=iMA(NULL, 0, Length1_2, 0, Method1_2, PRICE_CLOSE, index);
  MA3=iMA(NULL, 0, Length1_3, 0, Method1_3, PRICE_CLOSE, index);
  if (MA1>MA2 && MA2>MA3 && Close[index]<Open[index])
  {
   return (1);
  }
  else
  {
   if (MA1<MA2 && MA2<MA3 && Close[index]<Open[index])
   {
    return (-1);
   }
  }
 }
 return (0);
}

int Calc2(int index)
{
 if (Scenario2)
 {
  double MA1, MA2;
  MA1=iMA(NULL, 0, Length2_1, 0, Method2_1, PRICE_CLOSE, index);
  MA2=iMA(NULL, 0, Length2_2, 0, Method2_2, PRICE_CLOSE, index);
  if (MA1>MA2 && Low[index]<MA1 && Open[index]>MA1 && Close[index]>MA1)
  {
   return (1);
  }
  else
  {
   if (MA1<MA2 && High[index]>MA1 && Open[index]<MA1 && Close[index]<MA1)
   {
    return (-1);
   }
  }
 }
 return (0);
}

int Calc3(int index)
{
 if (Scenario3)
 {
  double MA1, MA2;
  MA1=iMA(NULL, 0, Length3_1, 0, Method3_1, PRICE_CLOSE, index);
  MA2=iMA(NULL, 0, Length3_2, 0, Method3_2, PRICE_CLOSE, index);
  if (MA1>MA2 && Low[index]<MA2 && Open[index]>MA2 && Close[index]>MA2)
  {
   return (1);
  }
  else
  {
   if (MA1<MA2 && High[index]>MA2 && Open[index]<MA2 && Close[index]<MA2)
   {
    return (-1);
   }
  }
 }
 return (0);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 int res1, res2, res3;
 pos=limit;
 while(pos>=0)
 {
  res1=Calc1(pos);
  res2=Calc2(pos);
  res3=Calc3(pos);
  if (res1==1 || res2==1 || res3==1)
  {
   UP[pos]=Low[pos];
  }
  else
  {
   if (res1==-1 || res2==-1 || res3==-1)
   {
    DN[pos]=High[pos];
   }
  }

  pos--;
 } 
 return(0);
}

