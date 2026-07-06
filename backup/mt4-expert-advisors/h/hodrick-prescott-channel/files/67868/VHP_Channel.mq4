//+------------------------------------------------------------------+
//|                                                  VHP_Channel.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define pi 3.1415926535

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Yellow
#property indicator_color2 Gray
#property indicator_style2 3
#property indicator_color3 Red
#property indicator_color4 Red

extern int Fast_Length=21;
extern int Slow_Length=144;

double HP[], HPS[], Upper[], Lower[];
double Lambda_F, Lambda_S;

int init()
{
 IndicatorShortName("VHP channel");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,HP);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,HPS);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Upper);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,Lower);
 
 Lambda_F = 0.0625/MathPow(MathSin(pi/Fast_Length), 4);
 Lambda_S = 0.0625/MathPow(MathSin(pi/Slow_Length), 4);
 return(0);
}

int deinit()
{

 return(0);
}

void CalcHP(int Count, double Lambda, double& Buff[])
{
 double a[], b[], c[];
 double H1=0, H2=0, H3=0, H4=0, H5=0, HH1=0, HH2=0, HH3=0, HH5=0, HB=0, HC=0, Z=0;
 int i;
 
 ArrayResize(a, Count);
 ArrayResize(b, Count);
 ArrayResize(c, Count);
 
 a[0]=1+Lambda;
 b[0]=-2*Lambda;
 c[0]=Lambda;
 
 for (i=1;i<Count-2;i++)
 {
  a[i]=6*Lambda+1;
  b[i]=-4*Lambda;
  c[i]=Lambda;
 }
 
 a[1]=5*Lambda+1;
 a[Count-1]=1+Lambda;
 a[Count-2]=5*Lambda+1;
 b[Count-2]=-2*Lambda;
 b[Count-1]=0;
 c[Count-2]=0;
 c[Count-1]=0;
 
 for (i=0;i<Count;i++)
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
  a[i]=(Close[i]-HH3*HH5-H3*H4)/Z;
  HH3=H3;
  H3=a[i];
  H4=HB-H5*HH1;
  HH5=H5;
  H5=HC;
 }
 
 H2=0;
 H1=a[Count-1];
 Buff[Count-1]=H1;
 for (i=Count-2;i>=0;i--)
 {
  Buff[i]=a[i]-b[i]*H1-c[i]*H2;
  H2=H1;
  H1=Buff[i];
 }
 
 return;
}

int start()
{
 if (Bars>Slow_Length)
 {
  CalcHP(Slow_Length, Lambda_F, HP);
  CalcHP(Slow_Length, Lambda_S, HPS);
  
  double disp=0;
  int i;
  for (i=0;i<Slow_Length;i++)
  {
   disp=disp+(HP[i]-HPS[i])*(HP[i]-HPS[i]);
  }
  disp=disp/(Slow_Length-1);
  double dev=2*MathSqrt(disp);
  
  for (i=0;i<Slow_Length;i++)
  {
   Upper[i]=HPS[i]+dev;
   Lower[i]=HPS[i]-dev;
  }
 
 }
 return(0);
}

