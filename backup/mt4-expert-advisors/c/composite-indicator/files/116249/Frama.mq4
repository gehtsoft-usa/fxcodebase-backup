//+------------------------------------------------------------------+
//|                                                        Frama.mq4 |
//|                               Copyright © 2016, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Yellow

extern int Length=10;

double Frama[];

int init()
{
 IndicatorShortName("");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Frama);

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
 int limit=Bars-2*Length;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double High1, Low1, High2, Low2, High3, Low3;
 double N1, N2, N3, D, ALFA;
 pos=limit;
 while(pos>=0)
 {
  if (pos==Bars-2*Length)
  {
   Frama[pos+1]=(High[pos+1]+Low[pos+1])/2.;
  }
  High1=High[iHighest(NULL, 0, MODE_HIGH, Length, pos)];
  Low1=Low[iLowest(NULL, 0, MODE_LOW, Length, pos)];
  High2=High[iHighest(NULL, 0, MODE_HIGH, Length, pos+Length)];
  Low2=Low[iLowest(NULL, 0, MODE_LOW, Length, pos+Length)];
  High3=High[iHighest(NULL, 0, MODE_HIGH, 2*Length, pos)];
  Low3=Low[iLowest(NULL, 0, MODE_LOW, 2*Length, pos)];
  
  N1=(High1-Low1)/Length;
  N2=(High2-Low2)/Length;
  N3=(High3-Low3)/(2*Length);
  
  D=(MathLog(N1+N2)-MathLog(N3))/MathLog(2.);
  ALFA=MathExp(-4.6*(D-1.));
  
  Frama[pos]=ALFA*(High[pos]+Low[pos])/2.+(1.-ALFA)*Frama[pos+1];

//  Frama[pos]=D;

  pos--;
 } 
 return(0);
}

