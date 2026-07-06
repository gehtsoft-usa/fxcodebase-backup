//+------------------------------------------------------------------+
//|                                            Range_Contraction.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red

extern double Threshold=50;
extern bool Range_Contraction=true;
extern bool Previous_Period=false;
extern int Symbol_Size=3;

double RC[], C[];

int init()
{
 IndicatorShortName("Range Contraction");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,RC);
 SetIndexBuffer(1,C);
 SetIndexStyle(1,DRAW_ARROW,0,Symbol_Size);
 SetIndexArrow(1,119);
 
 SetLevelValue(0, Threshold);

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
  if (Previous_Period)
  {
   if (High[pos+2]!=Low[pos+2])
   {
    RC[pos]=100.*(High[pos+1]-Low[pos+1])/(High[pos+2]-Low[pos+2]);
   } 
  }
  else
  {
   if (High[pos+1]!=Low[pos+1])
   {
    RC[pos]=100.*(High[pos]-Low[pos])/(High[pos+1]-Low[pos+1]);
   } 
  }
  
  if (Range_Contraction && RC[pos]<Threshold)
  {
   C[pos]=RC[pos];
  }
  else
  {
   C[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

