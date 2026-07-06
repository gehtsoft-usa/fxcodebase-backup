//+------------------------------------------------------------------+
//|                                                       Pro_Go.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length=7;

double Prof[], Public[];
double Raw1[], Raw2[], Raw3[], Raw4[], MA1[], MA2[];

int init()
{
 IndicatorShortName("Pro go oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Prof);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Public);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Raw1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Raw2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,Raw3);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Raw4);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,MA1);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,MA2);

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
 double MA_O, MA_C, MA_C1;
 pos=limit;
 while(pos>=0)
 {
  MA_O=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_OPEN, pos);
  MA_C=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE, pos);
  MA_C1=iMA(NULL, 0, Length, 0, MODE_SMA, PRICE_CLOSE, pos+1);
  
  MA1[pos]=MA_O-MA_C;
  MA2[pos]=MA_O-MA_C1;

  pos--;
 } 
 
 double LLV, HHV;
 pos=limit;
 while(pos>=0)
 {
  LLV=MA1[ArrayMinimum(MA1, Length, pos)];
  HHV=MA1[ArrayMaximum(MA1, Length, pos)];
  
  Raw1[pos]=MA1[pos]-LLV;
  Raw2[pos]=HHV-LLV;

  LLV=MA2[ArrayMinimum(MA2, Length, pos)];
  HHV=MA2[ArrayMaximum(MA2, Length, pos)];
  
  Raw3[pos]=MA2[pos]-LLV;
  Raw4[pos]=HHV-LLV;

  pos--;
 }
 
 double Avg1, Avg2, Avg3, Avg4;
 pos=limit;
 while(pos>=0)
 {
  Avg1=iMAOnArray(Raw1, 0, Length, 0, MODE_SMA, pos);
  Avg2=iMAOnArray(Raw2, 0, Length, 0, MODE_SMA, pos);
  
  if (Avg2!=0.)
  {
   Prof[pos]=100.*Avg1/Avg2;
  }

  Avg3=iMAOnArray(Raw3, 0, Length, 0, MODE_SMA, pos);
  Avg4=iMAOnArray(Raw4, 0, Length, 0, MODE_SMA, pos);
  
  if (Avg4!=0.)
  {
   Public[pos]=100.*Avg3/Avg4;
  }

  pos--;
 }  
   
 return(0);
}

