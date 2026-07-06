//+------------------------------------------------------------------+
//|                                            Internal_Strength.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow

extern int RSI_Length=14;
extern string Method_Str="Method: 0 - Raw, 1 - RSI";
extern int Method=1;  // 0 - Raw, 1 - RSI
extern string Type_Str="Type: 0 - Line, 1 - Bar";
extern int Type=0;

double IS[];
double Raw[];

int init()
{
 IndicatorShortName("Internal Strength");
 IndicatorDigits(Digits);
 if (Type==0)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_HISTOGRAM);
 } 
 SetIndexBuffer(0,IS);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Raw);

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
  if (High[pos]!=Low[pos])
  {
   Raw[pos]=(Close[pos]-Low[pos])/(High[pos]-Low[pos]);
  } 

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  if (Method==1)
  {
   IS[pos]=iRSIOnArray(Raw, 0, RSI_Length, pos);
  }
  else
  {
   IS[pos]=Raw[pos];
  }

  pos--;
 }
   
 return(0);
}

