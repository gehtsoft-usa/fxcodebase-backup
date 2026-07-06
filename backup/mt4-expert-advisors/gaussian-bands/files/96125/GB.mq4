//+------------------------------------------------------------------+
//|                                                           GB.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Red
#property indicator_color4 Green
#property indicator_color5 Green

extern int Central_Line_Length=12;
extern int Deviation_Length=12;
extern double Multiplier1=2.;
extern double Multiplier2=4.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double Central[], Top1[], Top2[], Bottom1[], Bottom2[];
double var[], var1[], Pr[];
double A_C, A_D;

double Alpha(int P)
{
 double A, B, w;
 w=2.*Pi/P;
 B=(1.-MathCos(w))/(MathPow(1.414, 2./3.)-1.);
 A=-B+MathSqrt(B*B+2.*B);
 return (A);
}

int init()
{
 IndicatorShortName("Gaussian Bands");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Central);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Top1);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Top2);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Bottom1);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,Bottom2);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,var);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,var1);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,Pr);
 
 A_C=Alpha(Central_Line_Length);
 A_D=Alpha(Deviation_Length);
 
 return(0);
}

double Smooth(double Arr[], double _Alpha, int index, double _Res[])
{
 return (MathPow(_Alpha,4)*Arr[index]+4.*(1.-_Alpha)*_Res[index+1]-6.*MathPow(1.-_Alpha,2)*_Res[index+2]+4.*MathPow(1.-_Alpha,3)*_Res[index+3]-MathPow(1.-_Alpha,4)*_Res[index+4]);

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
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }
  
 pos=limit;
 while(pos>=0)
 {
  Central[pos]=Smooth(Pr, A_C, pos, Central);
  var[pos]=MathAbs(Pr[pos]-Central[pos]);

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  var1[pos]=Smooth(var, A_D, pos, var1);
  Top1[pos]=Central[pos]+var1[pos]*Multiplier1;
  Top2[pos]=Central[pos]+var1[pos]*Multiplier2;
  Bottom1[pos]=Central[pos]-var1[pos]*Multiplier1;
  Bottom2[pos]=Central[pos]-var1[pos]*Multiplier2;

  pos--;
 }
   
 return(0);
}

