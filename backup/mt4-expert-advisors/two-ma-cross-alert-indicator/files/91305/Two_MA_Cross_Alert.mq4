//+------------------------------------------------------------------+
//|                                           Two_MA_Cross_Alert.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Green

extern bool New_Bar_Only=false;
extern int Fast_MA_Price=0;      // Applied price
                                 // 0 - Close
                                 // 1 - Open
                                 // 2 - High
                                 // 3 - Low
                                 // 4 - Median
                                 // 5 - Typical
                                 // 6 - Weighted  
extern int Fast_MA_Length=50;
extern int Fast_MA_Method=0;     // 0 - SMA
                                 // 1 - EMA
                                 // 2 - SMMA
                                 // 3 - LWMA
extern int Slow_MA_Price=0;      // Applied price
                                 // 0 - Close
                                 // 1 - Open
                                 // 2 - High
                                 // 3 - Low
                                 // 4 - Median
                                 // 5 - Typical
                                 // 6 - Weighted  
extern int Slow_MA_Length=200;
extern int Slow_MA_Method=0;     // 0 - SMA
                                 // 1 - EMA
                                 // 2 - SMMA
                                 // 3 - LWMA
extern bool Play_Sound=false;
extern string MA_Cross_Over_Sound="";
extern string MA_Cross_Under_Sound="";
extern bool Send_Email=false;
extern bool Snow_Alert=true;
extern string Additional_Text="Message from Two MA Cross: ";

double SlowMA[], FastMA[];
datetime LastTime;
int LastCross;

int init()
{
 IndicatorShortName("Two MA Cross Alert");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,SlowMA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,FastMA);
 LastTime=Time[0];
 LastCross=0;
 return(0);
}

int deinit()
{

 return(0);
}

void Cross(bool Over, string Message)
{
 if (Send_Email)
 {
  SendMail(Additional_Text, Message);
 }
 if (Play_Sound)
 {
  if (Over)
  {
   PlaySound(MA_Cross_Over_Sound);
  }
  else
  {
   PlaySound(MA_Cross_Under_Sound);
  }
 }
 if (Snow_Alert)
 {
  Alert(Message);
 }
 return;
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
  SlowMA[pos]=iMA(NULL, 0, Slow_MA_Length, 0, Slow_MA_Method, Slow_MA_Price, pos);
  FastMA[pos]=iMA(NULL, 0, Fast_MA_Length, 0, Fast_MA_Method, Fast_MA_Price, pos);
  pos--;
 } 
 
 bool CheckCross=true;
 if (New_Bar_Only)
 {
  if (LastTime!=Time[0])
  {
   LastTime=Time[0];
  }
  else
  {
   CheckCross=false;
  }
 }
 
 if (CheckCross)
 {
  if (SlowMA[1]<=FastMA[1] && SlowMA[0]>FastMA[0] && LastCross!=1)
  {
   LastCross=1;
   Cross(true, Additional_Text+" Cross over");
  }
  if (SlowMA[1]>=FastMA[1] && SlowMA[0]<FastMA[0] && LastCross!=-1)
  {
   LastCross=-1;
   Cross(false, Additional_Text+" Cross under");
  }
 }
 
 return(0);
}

