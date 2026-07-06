//+------------------------------------------------------------------+
//|                                                          MFO.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Yellow

extern int Length=20;

double MFO[];
double MFV[], Vol[];

int init()
{
 IndicatorShortName("Money flow oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,MFO);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,MFV);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Vol);

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
 double Multiplier, Z;
 pos=limit;
 while(pos>=0)
 {
  Vol[pos]=Volume[pos]/1000000.;
  
  Z=(High[pos]-Low[pos+1])+(High[pos+1]-Low[pos]);
  if (Z!=0.)
  {  
   Multiplier=((High[pos]-Low[pos+1])-(High[pos+1]-Low[pos]))/Z/1000000.;
  }
  else
  {
   Multiplier=0.;
  } 
  
  MFV[pos]=Multiplier*Volume[pos];

  pos--;
 } 
 
 double MFV_MA, Vol_MA;
 pos=limit;
 while(pos>=0)
 {
  MFV_MA=iMAOnArray(MFV, 0, Length, 0, MODE_SMA, pos);
  Vol_MA=iMAOnArray(Vol, 0, Length, 0, MODE_SMA, pos);
  
  if (Vol_MA!=0.)
  {
   MFO[pos]=MFV_MA/Vol_MA;
  }
  else
  {
   MFO[pos]=EMPTY_VALUE;
  }

  pos--;
 }
   
 return(0);
}

