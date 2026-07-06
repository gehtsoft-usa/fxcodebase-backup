//+------------------------------------------------------------------+
//|                                                          RMO.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Length1=30;
extern int Length2=30;
extern int Price=0;      // Applied price
                         // 0 - Open
                         // 1 - Low
                         // 2 - High
                         // 3 - Close

double RMO[], FirstSignal[], SecondSignal[];
double Pr[];
int MaxLength;
int MPrice;

int ConvertPrice(int Pr1)
{
 if (Pr1==PRICE_CLOSE) return (MODE_CLOSE);
 if (Pr1==PRICE_OPEN) return (MODE_OPEN);
 if (Pr1==PRICE_HIGH) return (MODE_HIGH);
 return (MODE_LOW);
}

int init()
{
 IndicatorShortName("Rahul Mohindar Oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RMO);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,FirstSignal);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,SecondSignal);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Pr);
 MaxLength=MathMax(10, MathMax(Length1, Length2));
 MPrice=ConvertPrice(Price);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=MaxLength) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double x;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 
 
 double MinPr, MaxPr;
 pos=limit;
 while(pos>=0)
 {
  x=Pr[pos]-(10*Pr[pos]+55*Pr[pos+1]+165*Pr[pos+2]+330*Pr[pos+3]+462*Pr[pos+4]+462*Pr[pos+5]+330*Pr[pos+6]+165*Pr[pos+7]+55*Pr[pos+8]+11*Pr[pos+9]+Pr[pos+10])/2046;
  MinPr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, iLowest(NULL, 0, MPrice, 10, pos));
  MaxPr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, iHighest(NULL, 0, MPrice, 10, pos));
  if (MinPr!=MaxPr)
  {
   RMO[pos]=100*x/(MaxPr-MinPr);
  }
  else
  {
   Print(1);
   RMO[pos]=0;
  } 
  pos--;
 }  
 
 pos=limit;
 while(pos>=0)
 {
  FirstSignal[pos]=iMAOnArray(RMO, 0, Length1, 0, MODE_EMA, pos);
  pos--;
 }  

 pos=limit;
 while(pos>=0)
 {
  SecondSignal[pos]=iMAOnArray(FirstSignal, 0, Length2, 0, MODE_EMA, pos);
  pos--;
 }  
 return(0);
}

