//+------------------------------------------------------------------+
//|                                                  Lyapunov_HP.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow

#define PI 3.141592653589793

extern int Length=4;
extern int Filter=7;
extern int L_Length=525;
extern int L_Time=20;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  

double L_HP[];
double hpf[], a[], b[], c[], Pr[];
double Lambda;

int init()
{
 IndicatorShortName("Lyapunov HP oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,L_HP);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,hpf);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,a);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,b);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,c);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,Pr);
 Lambda=0.0625/MathPow(MathSin(PI/Filter),4);
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
 int pos=limit;
 
 if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
 while(pos>=0)
 {
  Pr[pos]=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  pos--;
 } 

 
 a[0]=1+Lambda;
 b[0]=-2*Lambda;
 c[0]=Lambda;
 
 int i;
 for (i=limit;i>0;i--)
 {
  a[i]=6*Lambda+1;
  b[i]=-4*Lambda;
  c[i]=Lambda;
 }
 a[1]=5*Lambda+1;
 a[limit]=1+Lambda;
 a[limit-1]=5*Lambda+1;
 b[limit-1]=-2*Lambda;
 b[limit]=0;
 c[limit-1]=0;
 c[limit]=0;
 
 double H1=0;
 double H2=0;
 double H3=0;
 double H4=0;
 double H5=0;
 double HH1=0;
 double HH2=0;
 double HH3=0;
 double HH4=0;
 double HH5=0;
 double HB=0;
 double HC=0;
 double Z=0;
 
 for (i=0;i<=limit;i++)
 {
  Z=a[i]-H4*H1-HH5*HH2;
  HB=b[i];
  HH1=H1;
  H1=(HB-H4*H2)/Z;
  b[i]=H1;
  HC=c[i];
  HH2=H2;
  H2=HC/Z;
  c[i]=H2;
  a[i]=(Pr[i]-HH3*HH5-H3*H4)/Z;
  HH3=H3;
  H3=a[i];
  H4=HB-H5*HH1;
  HH5=H5;
  H5=HC;
 }
 H2=0;
 H1=a[limit-1];
 hpf[limit-1]=H1;
 
 for (i=limit-2;i>=0;i--)
 {
  hpf[i]=a[i]-b[i]*H1-c[i]*H2;
  H2=H1;
  H1=hpf[i];
 } 
 
 for (i=0;i<limit-2;i++)
 {
  L_HP[i]=MathLog(MathAbs(hpf[i]/hpf[i+1]))*100000;
 }
 
 return(0);
}

