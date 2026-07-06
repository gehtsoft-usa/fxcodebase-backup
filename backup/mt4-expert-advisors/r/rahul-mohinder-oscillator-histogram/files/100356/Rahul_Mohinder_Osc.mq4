//+------------------------------------------------------------------+
//|                                           Rahul_Mohinder_Osc.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Green
#property indicator_color2 LightGreen
#property indicator_color3 Red
#property indicator_color4 Pink
#property indicator_color5 Yellow
#property indicator_color6 Yellow

extern int Length1=30;
extern int Length2=30;
extern int Length3=81;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
extern int ArrowSize=2;                       

double RMO[], RMO2[], RMO3[], RMO4[];
double SwingTrd[], EMA1[], Up[], Dn[];

int init()
{
 IndicatorShortName("Rahul Mohinder oscillator");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,RMO);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,RMO2);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,RMO3);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,RMO4);
 SetIndexStyle(4,DRAW_ARROW, 0, ArrowSize);
 SetIndexBuffer(4,Up);
 SetIndexArrow(4,241);
 SetIndexStyle(5,DRAW_ARROW, 0, ArrowSize);
 SetIndexBuffer(5,Dn);
 SetIndexArrow(5,242);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,SwingTrd);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,EMA1);

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
 double MA1, MA2, MA3, MA4, MA5, MA6, MA7, MA8, MA9, MA10;
 double Pr0, Pr1, Pr2, Pr3, Pr4, Pr5, Pr6, Pr7, Pr8, Pr9, Pr10;
 double Min, Max;
 
 pos=limit;
 while(pos>=0)
 {
  Pr0=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos);
  Pr1=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+1);
  Pr2=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+2);
  Pr3=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+3);
  Pr4=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+4);
  Pr5=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+5);
  Pr6=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+6);
  Pr7=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+7);
  Pr8=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+8);
  Pr9=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+9);
  Pr10=iMA(NULL, 0, 1, 0, MODE_SMA, Price, pos+10);
 
  MA1=(Pr0+Pr1)/2.;
  MA2=(Pr0+2.*Pr1+Pr2)/4.;
  MA3=(Pr0+3.*Pr1+3.*Pr2+Pr3)/8.;
  MA4=(Pr0+4.*Pr1+6.*Pr2+4.*Pr3+Pr4)/16.;
  MA5=(Pr0+5.*Pr1+10.*Pr2+10.*Pr3+5.*Pr4+Pr5)/32.;
  MA6=(Pr0+6.*Pr1+15.*Pr2+20.*Pr3+15.*Pr4+6.*Pr5+Pr6)/64.;
  MA7=(Pr0+7.*Pr1+21.*Pr2+35.*Pr3+35.*Pr4+21.*Pr5+7.*Pr6+Pr7)/128.;
  MA8=(Pr0+8.*Pr1+28.*Pr2+56.*Pr3+70.*Pr4+56.*Pr5+28.*Pr6+8.*Pr7+Pr8)/256.;
  MA9=(Pr0+9.*Pr1+36.*Pr2+84.*Pr3+126.*Pr4+126.*Pr5+84.*Pr6+36.*Pr7+9.*Pr8+Pr9)/512.;
  MA10=(Pr0+10.*Pr1+45.*Pr2+120.*Pr3+210.*Pr4+252.*Pr5+210.*Pr6+120.*Pr7+45.*Pr8+10.*Pr9+Pr10)/1024.;
  
  Max=MathMax(Pr0, MathMax(Pr1, MathMax(Pr2, MathMax(Pr3, MathMax(Pr4, MathMax(Pr5, MathMax(Pr6, MathMax(Pr7, MathMax(Pr8, Pr9)))))))));
  Min=MathMin(Pr0, MathMin(Pr1, MathMin(Pr2, MathMin(Pr3, MathMin(Pr4, MathMin(Pr5, MathMin(Pr6, MathMin(Pr7, MathMin(Pr8, Pr9)))))))));
  
  if (Max!=Min)
  {
   SwingTrd[pos]=100.*(Pr0-(MA1+MA2+MA3+MA4+MA5+MA6+MA7+MA8+MA9+MA10)/10.)/(Max-Min);
  } 

  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  EMA1[pos]=iMAOnArray(SwingTrd, 0, Length1, 0, MODE_EMA, pos);

  pos--;
 }  
 
 double EMA2_0, EMA2_1, EMA3;
 pos=limit;
 while(pos>=0)
 {
  EMA2_0=iMAOnArray(EMA1, 0, Length2, 0, MODE_EMA, pos);
  EMA2_1=iMAOnArray(EMA1, 0, Length2, 0, MODE_EMA, pos+1);
  EMA3=iMAOnArray(SwingTrd, 0, Length3, 0, MODE_EMA, pos);
  
  RMO[pos]=EMA3/Point;
  
  if (EMA1[pos+1]<EMA2_1 && EMA1[pos]>EMA2_0)
  {
   Up[pos]=RMO[pos];
  }
  else
  {
   Up[pos]=EMPTY_VALUE;
  }
  
  if (EMA1[pos+1]>EMA2_1 && EMA1[pos]<EMA2_0)
  {
   Dn[pos]=RMO[pos];
  }
  else
  {
   Dn[pos]=EMPTY_VALUE;
  }
  
  RMO2[pos]=0.;
  RMO3[pos]=0.;
  RMO4[pos]=0.;
  
  if (RMO[pos]>0.)
  {
   if (EMA1[pos]>0.)
   {
   }
   else
   {
    RMO2[pos]=RMO[pos];
   }
  }
  else
  {
   if (EMA1[pos]>0.)
   {
    RMO4[pos]=RMO[pos];
   }
   else
   {
    RMO3[pos]=RMO[pos];
   }
  }

  pos--;
 }  
   
 return(0);
}

