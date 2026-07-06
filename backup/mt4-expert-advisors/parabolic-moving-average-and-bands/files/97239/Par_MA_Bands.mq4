//+------------------------------------------------------------------+
//|                                                 Par_MA_Bands.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Red

extern int Length=20;
extern double Deviation=1.;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double ParMA[], UpBand[], DnBand[];
double Pr[];
double sum_x, sum_x2, sum_x3, sum_x4;

int init()
{
 IndicatorShortName("Parabolic moving average indicator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,ParMA);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,UpBand);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,DnBand);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,Pr);
 
 sum_x=(1.+Length)*Length/2.;
 sum_x2=(1.+Length)*(2.*Length+1.)*Length/6.;
 sum_x3=sum_x*sum_x;
 sum_x4=(1.+Length)*Length*(2.*Length+1.)*(3.*Length*Length+3.*Length-1.)/30.;

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
 double sum_y, sum_xy, sum_x2y;
 int i;
 double Temp_Pr;
 pos=limit;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
 
  pos--;
 }

 double A, B, C, F, M, P, R, S, D, E, K, L, Q, B0, B1, B2;  
 pos=limit;
 while(pos>=0)
 {
  sum_y=0.;
  sum_xy=0.;
  sum_x2y=0.;
  
  for (i=1;i<=Length;i++)
  {
   Temp_Pr=Pr[pos+Length-i];
   sum_y=sum_y+Temp_Pr;
   sum_xy=sum_xy+Temp_Pr*i;
   sum_x2y=sum_x2y+Temp_Pr*i*i;
  }
  
  A=Length;
  B=sum_x;
  C=sum_x2;
  F=sum_x3;
  M=sum_x4;
  P=sum_y;
  R=sum_xy;
  S=sum_x2y;
  D=B;
  E=C;
  K=C;
  L=F;
  Q=D/A;
  
  E=E-Q*B;
  F=F-Q*C;
  R=R-Q*P;
  Q=K/A;
  L=L-Q*B;
  M=M-Q*C;
  S=S-Q*P;
  Q=L/E;
  
  B2=(S-R*Q)/(M-F*Q);
  B1=(R-F*B2)/E;
  B0=(P-B*B1-C*B2)/A;
  
  ParMA[pos]=B0+(B1+B2*A)*A;

  pos--;
 } 
 
 double StdDev;
 pos=limit;
 while(pos>=0)
 {
  StdDev=iStdDevOnArray(ParMA, 0, Length, 0, MODE_SMA, pos);
  UpBand[pos]=ParMA[pos]+StdDev*Deviation;
  DnBand[pos]=ParMA[pos]-StdDev*Deviation;

  pos--;
 }
  
 return(0);
}

