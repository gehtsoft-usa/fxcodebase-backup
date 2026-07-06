//+------------------------------------------------------------------+
//|                                                          BMP.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Gray
#property indicator_color2 Red

extern int Length=14;

double BMP[], Signal[];

int init()
{
 IndicatorShortName("Balance of Market Power");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,BMP);
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
 double BuO, BeO, BuC, BeC;
 double BuOC, BeOC;
 double THL;
 pos=limit;
 while(pos>=0)
 {
  THL=High[pos]-Low[pos];
  THL=MathMax(THL, 0.00001);
  
  BuO=(High[pos]-Low[pos])/THL;
  BeO=(Open[pos]-Low[pos])/THL;
  
  BuC=(Close[pos]-Low[pos])/THL;
  BeC=(High[pos]-Close[pos])/THL;
  
  if (Close[pos]>Open[pos])
  {
   BuOC=(Close[pos]-Open[pos])/THL;
   BeOC=0.;
  }
  else
  {
   BuOC=0.;
   BeOC=(Open[pos]-Close[pos])/THL;
  }
  
  BMP[pos]=(BuO+BuC+BuOC)/3.-(BeO+BeC+BeOC)/3.;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  Signal[pos]=iMAOnArray(BMP, 0, Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

