//+------------------------------------------------------------------+
//|                                                         CADX.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=14;
extern int LevelWidth=1;
extern color LevelColor=Gray;                        
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double CADX[];

int init()
{
 IndicatorShortName("Comparative ADX");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,CADX);

 SetLevelValue(0, 1);
 SetLevelStyle(EMPTY, LevelWidth, LevelColor);

 return(0);
}

int deinit()
{

 return(0);
}

double GetADX(string Symb, int index)
{
 datetime T=Time[index];
 int index2=iBarShift(Symb, 0, T, false);
 if (index2==-1)
 {
  return (-1);
 }
 else
 { 
  double ADX2=iADX(Symb, 0, Length, Price, MODE_MAIN, index2);
  return (ADX2);
 } 
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double ADX, ADX2, SumADX;
 int Count;
 pos=limit;
 while(pos>=0)
 {
  ADX=iADX(NULL, 0, Length, Price, MODE_MAIN, pos);
  Count=0;
  SumADX=0.;
  ADX2=GetADX("EURUSD", pos);
  if (ADX2!=-1)
  {
   Count++;
   SumADX=SumADX+ADX2;
  }
  ADX2=GetADX("GBPUSD", pos);
  if (ADX2!=-1)
  {
   Count++;
   SumADX=SumADX+ADX2;
  }
  ADX2=GetADX("AUDUSD", pos);
  if (ADX2!=-1)
  {
   Count++;
   SumADX=SumADX+ADX2;
  }
  ADX2=GetADX("USDJPY", pos);
  if (ADX2!=-1)
  {
   Count++;
   SumADX=SumADX+ADX2;
  }
  ADX2=GetADX("USDCAD", pos);
  if (ADX2!=-1)
  {
   Count++;
   SumADX=SumADX+ADX2;
  }
  
  if (Count>0)
  {
   SumADX=SumADX/Count;
   CADX[pos]=ADX/SumADX;
  } 

  pos--;
 } 
 return(0);
}

