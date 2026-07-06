//+------------------------------------------------------------------+
//|                                 Blau_Directional_Trend_Index.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 7
#property indicator_color1 Yellow

extern int Length=2;
extern int First_Smooth_Length=20;
extern int Second_Smooth_Length=5;
extern int Third_Smooth_Length=3;
extern double Up_Level=25;
extern double Dn_Level=-25;                         

double DTI[];
double UDM[], UDM_MA1[], UDM_MA2[], ADM[], ADM_MA1[], ADM_MA2[];

int init()
{
 IndicatorShortName("William Blau Directional Trend Index");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,DTI);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,UDM);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,UDM_MA1);
 SetIndexStyle(3,DRAW_NONE);
 SetIndexBuffer(3,UDM_MA2);
 SetIndexStyle(4,DRAW_NONE);
 SetIndexBuffer(4,ADM);
 SetIndexStyle(5,DRAW_NONE);
 SetIndexBuffer(5,ADM_MA1);
 SetIndexStyle(6,DRAW_NONE);
 SetIndexBuffer(6,ADM_MA2);
 
 SetLevelValue(0, Up_Level);
 SetLevelValue(1, Dn_Level);
 return(0);
}

int deinit()
{

 return(0);
}

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;

 double H, L;
 pos=limit;
 while(pos>=0)
 {
  H=High[pos]-High[pos+Length];
  if (H<0) H=0;
  L=Low[pos+Length]-Low[pos];
  if (L<0) L=0;
  UDM[pos]=H-L;
  ADM[pos]=MathAbs(UDM[pos]);
  pos--;
 }
 
 pos=limit;
 while(pos>=0)
 {
  UDM_MA1[pos]=iMAOnArray(UDM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  ADM_MA1[pos]=iMAOnArray(ADM, 0, First_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  
   
 pos=limit;
 while(pos>=0)
 {
  UDM_MA2[pos]=iMAOnArray(UDM_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  ADM_MA2[pos]=iMAOnArray(ADM_MA1, 0, Second_Smooth_Length, 0, MODE_EMA, pos);
  pos--;
 }  

 double UDM_MA3, ADM_MA3; 
 pos=limit;
 while(pos>=0)
 {
  UDM_MA3=iMAOnArray(UDM_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
  ADM_MA3=iMAOnArray(ADM_MA2, 0, Third_Smooth_Length, 0, MODE_EMA, pos);
  if (ADM_MA3!=0)
  {
   DTI[pos]=100.*UDM_MA3/ADM_MA3;
  }
  else
  {
   DTI[pos]=EMPTY_VALUE;
  } 
  pos--;
 }  
 
 
   
 return(0);
}

