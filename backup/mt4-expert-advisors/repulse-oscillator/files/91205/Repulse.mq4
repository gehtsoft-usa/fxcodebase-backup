//+------------------------------------------------------------------+
//|                                                      Repulse.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Green
#property indicator_color2 Red

extern int Length1=5;
extern int Length2=15;

double Repulse1[], Repulse2[];
double PosSt1[], NegSt1[], PosSt2[], NegSt2[];

int init()
{
 IndicatorShortName("Repulse oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Repulse1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Repulse2);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,PosSt1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,NegSt1);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,PosSt2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,NegSt2);

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
 double MinPrice, MaxPrice;
 pos=limit;
 while(pos>=0)
 {
  MinPrice=Low[iLowest(NULL, 0, MODE_LOW, Length1, pos)];
  MaxPrice=High[iHighest(NULL, 0, MODE_HIGH, Length1, pos)];
  PosSt1[pos]=100.*(3.*Close[pos]-2.*MinPrice-Open[pos])/Close[pos];
  NegSt1[pos]=100.*(Open[pos]+2.*MaxPrice-3.*Close[pos])/Close[pos];

  MinPrice=Low[iLowest(NULL, 0, MODE_LOW, Length2, pos)];
  MaxPrice=High[iHighest(NULL, 0, MODE_HIGH, Length2, pos)];
  PosSt2[pos]=100.*(3.*Close[pos]-2.*MinPrice-Open[pos+Length2])/Close[pos];
  NegSt2[pos]=100.*(Open[pos+Length2]+2.*MaxPrice-3.*Close[pos])/Close[pos];
  pos--;
 }
 
 double Pos_MA, Neg_MA;
 pos=limit;
 while(pos>=0)
 {
  Pos_MA=iMAOnArray(PosSt1, 0, 5*Length1, 0, MODE_EMA, pos);
  Neg_MA=iMAOnArray(NegSt1, 0, 5*Length1, 0, MODE_EMA, pos);
  Repulse1[pos]=(Pos_MA-Neg_MA)/Point;

  Pos_MA=iMAOnArray(PosSt2, 0, 5*Length2, 0, MODE_EMA, pos);
  Neg_MA=iMAOnArray(NegSt2, 0, 5*Length2, 0, MODE_EMA, pos);
  Repulse2[pos]=(Pos_MA-Neg_MA)/Point;
  pos--;
 }
    
 return(0);
}

