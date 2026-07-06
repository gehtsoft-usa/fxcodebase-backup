//+------------------------------------------------------------------+
//|                                                 KDJ_Averages.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

extern int Length=9;
extern int MA1_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA1_Length=3;                          
extern int MA2_Method=0;  // 0 - SMA
                          // 1 - EMA
                          // 2 - SMMA
                          // 3 - LWMA
extern int MA2_Length=3;                          

double K[], D[], J[];
double RSV[];

int init()
{
 IndicatorShortName("KDJ averages oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,J);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,RSV);

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
 double Cn, Ln, Hn;
 pos=limit;
 while(pos>=0)
 {
  Cn=Close[pos];
  Ln=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  Hn=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  
  Ln=MathMin(Cn, Ln);
  Hn=MathMax(Cn, Hn);
  
  if (Hn!=Ln)
  {
   RSV[pos]=100.*(Cn-Ln)/(Hn-Ln);
  }
  else
  {
   RSV[pos]=50.;
  }
  
  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  K[pos]=iMAOnArray(RSV, 0, MA1_Length, 0, MA1_Method, pos);

  pos--;
 }
   
 pos=limit;
 while(pos>=0)
 {
  D[pos]=iMAOnArray(K, 0, MA2_Length, 0, MA2_Method, pos);
  J[pos]=3.*D[pos]-2.*K[pos];

  pos--;
 }
   
 return(0);
}

