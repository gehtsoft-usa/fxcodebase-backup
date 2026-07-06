//+------------------------------------------------------------------+
//|                                                           GR.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#define Pi 3.1415926

#property indicator_chart_window
#property indicator_buffers 8
#property indicator_color1 Lime
#property indicator_color2 LawnGreen
#property indicator_color3 GreenYellow
#property indicator_color4 Yellow
#property indicator_color5 Gold
#property indicator_color6 Goldenrod
#property indicator_color7 DarkOrange
#property indicator_color8 Red

extern int Rainbow_Length=10;
extern int Gaussian_Order=3;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted 

double GR1[], GR2[], GR3[], GR4[], GR5[], GR6[], GR7[], GR8[];
double Alpha, Alpha2, Alpha3, Alpha4;
double Alpha_1, Alpha_12, Alpha_13, Alpha_14;

int init()
{
 IndicatorShortName("Gaussian Rainbow");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,GR1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,GR2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,GR3);
 SetIndexStyle(3,DRAW_LINE);
 SetIndexBuffer(3,GR4);
 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,GR5);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,GR6);
 SetIndexStyle(6,DRAW_LINE);
 SetIndexBuffer(6,GR7);
 SetIndexStyle(7,DRAW_LINE);
 SetIndexBuffer(7,GR8);
 
 double w, Beta;
 w=2.*Pi/Rainbow_Length;
 Beta=(1.-MathCos(w))/(MathPow(1.414, 2./Gaussian_Order)-1.);
 Alpha=-Beta+MathSqrt(Beta*Beta+2.*Beta);
 Alpha2=Alpha*Alpha;
 Alpha3=Alpha2*Alpha;
 Alpha4=Alpha3*Alpha;
 Alpha_1=1.-Alpha;
 Alpha_12=Alpha_1*Alpha_1;
 Alpha_13=Alpha_12*Alpha_1;
 Alpha_14=Alpha_13*Alpha_1;

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
 double Pr;
 pos=limit;
 while(pos>=0)
 {
  if (Gaussian_Order==1)
  {
   Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
   GR1[pos]=Alpha*Pr+Alpha_1*GR1[pos+1];
   GR2[pos]=Alpha*GR1[pos]+Alpha_1*GR2[pos+1];
   GR3[pos]=Alpha*GR2[pos]+Alpha_1*GR3[pos+1];
   GR4[pos]=Alpha*GR3[pos]+Alpha_1*GR4[pos+1];
   GR5[pos]=Alpha*GR4[pos]+Alpha_1*GR5[pos+1];
   GR6[pos]=Alpha*GR5[pos]+Alpha_1*GR6[pos+1];
   GR7[pos]=Alpha*GR6[pos]+Alpha_1*GR7[pos+1];
   GR8[pos]=Alpha*GR7[pos]+Alpha_1*GR8[pos+1];
  }
  else
  {
   if (Gaussian_Order==2)
   {
    Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
    GR1[pos]=Alpha2*Pr+2.*Alpha_1*GR1[pos+1]-Alpha_12*GR1[pos+2];
    GR2[pos]=Alpha2*GR1[pos]+2.*Alpha_1*GR2[pos+1]-Alpha_12*GR2[pos+2];
    GR3[pos]=Alpha2*GR2[pos]+2.*Alpha_1*GR3[pos+1]-Alpha_12*GR3[pos+2];
    GR4[pos]=Alpha2*GR3[pos]+2.*Alpha_1*GR4[pos+1]-Alpha_12*GR4[pos+2];
    GR5[pos]=Alpha2*GR4[pos]+2.*Alpha_1*GR5[pos+1]-Alpha_12*GR5[pos+2];
    GR6[pos]=Alpha2*GR5[pos]+2.*Alpha_1*GR6[pos+1]-Alpha_12*GR6[pos+2];
    GR7[pos]=Alpha2*GR6[pos]+2.*Alpha_1*GR7[pos+1]-Alpha_12*GR7[pos+2];
    GR8[pos]=Alpha2*GR7[pos]+2.*Alpha_1*GR8[pos+1]-Alpha_12*GR8[pos+2];
   }
   else
   {
    if (Gaussian_Order==3)
    {
     Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
     GR1[pos]=Alpha3*Pr+3.*Alpha_1*GR1[pos+1]-3.*Alpha_12*GR1[pos+2]+Alpha_13*GR1[pos+3];
     GR2[pos]=Alpha3*GR1[pos]+3.*Alpha_1*GR2[pos+1]-3.*Alpha_12*GR2[pos+2]+Alpha_13*GR2[pos+3];
     GR3[pos]=Alpha3*GR2[pos]+3.*Alpha_1*GR3[pos+1]-3.*Alpha_12*GR3[pos+2]+Alpha_13*GR3[pos+3];
     GR4[pos]=Alpha3*GR3[pos]+3.*Alpha_1*GR4[pos+1]-3.*Alpha_12*GR4[pos+2]+Alpha_13*GR4[pos+3];
     GR5[pos]=Alpha3*GR4[pos]+3.*Alpha_1*GR5[pos+1]-3.*Alpha_12*GR5[pos+2]+Alpha_13*GR5[pos+3];
     GR6[pos]=Alpha3*GR5[pos]+3.*Alpha_1*GR6[pos+1]-3.*Alpha_12*GR6[pos+2]+Alpha_13*GR6[pos+3];
     GR7[pos]=Alpha3*GR6[pos]+3.*Alpha_1*GR7[pos+1]-3.*Alpha_12*GR7[pos+2]+Alpha_13*GR7[pos+3];
     GR8[pos]=Alpha3*GR7[pos]+3.*Alpha_1*GR8[pos+1]-3.*Alpha_12*GR8[pos+2]+Alpha_13*GR8[pos+3];
    }
    else
    {
     Pr=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
     GR1[pos]=Alpha4*Pr+4.*Alpha_1*GR1[pos+1]-6.*Alpha_12*GR1[pos+2]+4.*Alpha_13*GR1[pos+3]-Alpha_14*GR1[pos+3];
     GR2[pos]=Alpha4*GR1[pos]+4.*Alpha_1*GR2[pos+1]-6.*Alpha_12*GR2[pos+2]+4.*Alpha_13*GR2[pos+3]-Alpha_14*GR2[pos+3];
     GR3[pos]=Alpha4*GR2[pos]+4.*Alpha_1*GR3[pos+1]-6.*Alpha_12*GR3[pos+2]+4.*Alpha_13*GR3[pos+3]-Alpha_14*GR3[pos+3];
     GR4[pos]=Alpha4*GR3[pos]+4.*Alpha_1*GR4[pos+1]-6.*Alpha_12*GR4[pos+2]+4.*Alpha_13*GR4[pos+3]-Alpha_14*GR4[pos+3];
     GR5[pos]=Alpha4*GR4[pos]+4.*Alpha_1*GR5[pos+1]-6.*Alpha_12*GR5[pos+2]+4.*Alpha_13*GR5[pos+3]-Alpha_14*GR5[pos+3];
     GR6[pos]=Alpha4*GR5[pos]+4.*Alpha_1*GR6[pos+1]-6.*Alpha_12*GR6[pos+2]+4.*Alpha_13*GR6[pos+3]-Alpha_14*GR6[pos+3];
     GR7[pos]=Alpha4*GR6[pos]+4.*Alpha_1*GR7[pos+1]-6.*Alpha_12*GR7[pos+2]+4.*Alpha_13*GR7[pos+3]-Alpha_14*GR7[pos+3];
     GR8[pos]=Alpha4*GR7[pos]+4.*Alpha_1*GR8[pos+1]-6.*Alpha_12*GR8[pos+2]+4.*Alpha_13*GR8[pos+3]-Alpha_14*GR8[pos+3];
    }
   }
  }

  pos--;
 } 
 return(0);
}

