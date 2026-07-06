//+------------------------------------------------------------------+
//|                                                Hurst_Channel.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Green
#property indicator_color3 Red
#property indicator_color4 Red

extern int Price1=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length1=10;
extern double ChanWid1=1; // Multiplier for ATR                        
extern int Price2=0;    // Applied price
                        // 0 - Close
                        // 1 - Open
                        // 2 - High
                        // 3 - Low
                        // 4 - Median
                        // 5 - Typical
                        // 6 - Weighted  
extern int Length2=60;
extern double ChanWid2=3; // Multiplier for ATR                        
extern int CompMode=0;    // 0 - CMA shortening, 1 - 2nd degree polynomial

double Upper1[], Upper2[], Lower1[], Lower2[];
double Ave1[], Ave2[];
int SetBack1, SetBack2;

int init()
  {
   IndicatorShortName("Hurst Channel indicator");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Upper1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Upper2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Lower1);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,Lower2);
   SetIndexStyle(4,DRAW_NONE);
   SetIndexBuffer(4,Ave1);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexBuffer(5,Ave2);
   
   SetBack1=MathFloor((Length1-1)/2)+1;
   SetBack2=MathFloor((Length2-1)/2)+1;
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 double Value3, Value4, Value5;
 int Value1, Value2;
 if(Bars<=MathMax(Length1, Length2)) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int i;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>0)
 {
  Ave1[pos]=iMA(NULL, 0, Length1, 0, MODE_SMA, Price1, pos);
  Upper1[pos]=Ave1[pos]+ChanWid1*iATR(NULL, 0, Length1, pos);
  Lower1[pos]=Ave1[pos]-ChanWid1*iATR(NULL, 0, Length1, pos);
  pos--;
 }
 Value5=(iMA(NULL, 0, Length1, 0, MODE_SMA, Price1, 0)-iMA(NULL, 0, Length1, 0, MODE_SMA, Price1, SetBack1))/SetBack1;
 for (Value1=SetBack1-1;Value1>0;Value1--)
 {
  Value3=0;
  Value4=Value1*2;
  for (Value2=0;Value2>=Value4;Value2++)
  {
   Value3=Value3+iMA(NULL, 0, 1, 0, MODE_SMA, Price1, Value2);
  }
  Ave1[0]=Value3/(Value4+1);
  if (CompMode!=0) Ave1[0]=Ave1[0]/3+(Ave1[1]+Value5*(SetBack1-Value1))*2/3;
  Upper1[Value1]=Ave1[Value1]+ChanWid1*iATR(NULL, 0, Length1, Value1);
  Lower1[Value1]=Ave1[Value1]-ChanWid1*iATR(NULL, 0, Length1, Value1);
 }
 
 pos=limit;
 while(pos>0)
 {
  Ave2[pos]=iMA(NULL, 0, Length2, 0, MODE_SMA, Price2, pos);
  Upper2[pos]=Ave2[pos]+ChanWid2*iATR(NULL, 0, Length2, pos);
  Lower2[pos]=Ave2[pos]-ChanWid2*iATR(NULL, 0, Length2, pos);
  pos--;
 }
 Value5=(iMA(NULL, 0, Length2, 0, MODE_SMA, Price2, 0)-iMA(NULL, 0, Length2, 0, MODE_SMA, Price2, SetBack2))/SetBack2;
 for (Value1=SetBack2-1;Value1>0;Value1--)
 {
  Value3=0;
  Value4=Value1*2;
  for (Value2=0;Value2>=Value4;Value2++)
  {
   Value3=Value3+iMA(NULL, 0, 1, 0, MODE_SMA, Price2, Value2);
  }
  Ave2[0]=Value3/(Value4+1);
  if (CompMode!=0) Ave2[0]=Ave2[0]/3+(Ave2[1]+Value5*(SetBack2-Value1))*2/3;
  Upper2[Value1]=Ave2[Value1]+ChanWid2*iATR(NULL, 0, Length2, Value1);
  Lower2[Value1]=Ave2[Value1]-ChanWid2*iATR(NULL, 0, Length2, Value1);
 }
 

 return(0);
}

