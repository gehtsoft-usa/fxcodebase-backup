//+------------------------------------------------------------------+
//|                                               Wave_Indicator.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Blue
#property indicator_color4 Yellow
#property indicator_color5 Red

extern string Method_Str="Method: 0 - All, 1, 2, 3, 4 - Modes, 5 - Average";
extern int Method=0;   // 0 - All, 1, 2, 3, 4 - Modes, 5 - Average
extern int Length1=12;
extern int Length2=24;
extern int Length3=12;
extern int Length4=12;
extern int Length5=12;
extern int Price=0;    // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted

double B1[], B2[], B3[], B4[], All[];
double D[], F[], H[];

int init()
{
 IndicatorShortName("Wave Indicator");
 IndicatorDigits(Digits);
 if (Method==0 || Method==1)
 {
  SetIndexStyle(0,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
 } 
 SetIndexBuffer(0,B1);
 if (Method==0 || Method==2)
 {
  SetIndexStyle(1,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(1,DRAW_NONE);
 }
 SetIndexBuffer(1,B2);
 if (Method==0 || Method==3)
 {
  SetIndexStyle(2,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(2,DRAW_NONE);
 }
 SetIndexBuffer(2,B3);
 if (Method==0 || Method==4)
 {
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(3,DRAW_NONE);
 }
 SetIndexBuffer(3,B4);
 if (Method>4)
 {
  SetIndexStyle(4,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(4,DRAW_NONE);
 }
 SetIndexBuffer(4,All);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,D);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,F);
 SetIndexStyle(7,DRAW_NONE);
 SetIndexBuffer(7,H);

 return(0);
}

int deinit()
{

 return(0);
}

double Calculate(int _Price, double _Source[], int _Length, int _index)
{
 int Len;
 int ind;
 ind=MathMax(0, _index-_Length+1);
 Len=_index+_Length-ind+1;
 
 double res;
 if (_Price>=0)
 {
  res=iMA(NULL, 0, Len, 0, MODE_SMA, _Price, ind);
 }
 else
 {
  res=iMAOnArray(_Source, 0, Len, 0, MODE_SMA, ind);
 }
 return (res);
}

int start()
{
 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double B, C;
 pos=limit;
 while(pos>=0)
 {
  B=Calculate(Price, D, Length1, pos);
  C=Calculate(Price, D, Length2, pos);
//  B=iMA(NULL, 0, Length1, 0, MODE_SMA, Price, pos);
//  C=iMA(NULL, 0, Length2, 0, MODE_SMA, Price, pos);
  D[pos]=B-C;

  pos--;
 } 
 
 double E0, E1;
 pos=limit;
 while(pos>=0)
 {
  E0=Calculate(-1, D, Length3, pos);
  E1=Calculate(-1, D, Length3, pos+1);
//  E0=iMAOnArray(D, 0, Length3, 0, MODE_SMA, pos);
//  E1=iMAOnArray(D, 0, Length3, 0, MODE_SMA, pos+1);
  F[pos]=E0-E1;
  B1[pos]=E0;

  pos--;
 }
 
 double G0, G1;
 pos=limit;
 while(pos>=0)
 {
  G0=Calculate(-1, F, Length4, pos);
  G1=Calculate(-1, F, Length4, pos+1);
//  G0=iMAOnArray(F, 0, Length4, 0, MODE_SMA, pos);
//  G1=iMAOnArray(F, 0, Length4, 0, MODE_SMA, pos+1);
  H[pos]=-100.*(G0-G1);
  B2[pos]=H[pos];

  pos--;
 }  
 
 double I0, I1;
 double J;
 pos=limit;
 while(pos>=0)
 {
  I0=Calculate(-1, H, Length5, pos);
  I1=Calculate(-1, H, Length5, pos+1);
//  I0=iMAOnArray(H, 0, Length5, 0, MODE_SMA, pos);
//  I1=iMAOnArray(H, 0, Length5, 0, MODE_SMA, pos+1);
  J=10.*(I0-I1);
  
  B3[pos]=I0;
  B4[pos]=J;
  All[pos]=(B1[pos]+B2[pos]+B3[pos]+B4[pos])/4.;

  pos--;
 }  
   
 return(0);
}


