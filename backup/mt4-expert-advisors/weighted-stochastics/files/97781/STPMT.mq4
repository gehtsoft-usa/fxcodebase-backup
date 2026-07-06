//+------------------------------------------------------------------+
//|                                                        STPMT.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Gray
#property indicator_color2 Gray
#property indicator_color3 Gray
#property indicator_color4 Gray
#property indicator_color5 Red
#property indicator_color6 Green
#property indicator_style1 STYLE_DASH
#property indicator_style2 STYLE_DASH
#property indicator_style3 STYLE_DASH
#property indicator_style4 STYLE_DASH
#property indicator_style5 STYLE_SOLID
#property indicator_style6 STYLE_SOLID

extern int Stoch1_Kperiod=5;
extern int Stoch1_Dperiod=3;
extern int Stoch1_Slowing=3;
extern int Stoch1_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch1_Price_Field=0;  // 0 - Low/High, 1 - Close/Close 
extern int Stoch1_Weight=4.1;

extern int Stoch2_Kperiod=14;
extern int Stoch2_Dperiod=3;
extern int Stoch2_Slowing=3;
extern int Stoch2_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch2_Price_Field=0;  // 0 - Low/High, 1 - Close/Close 
extern int Stoch2_Weight=2.5;

extern int Stoch3_Kperiod=45;
extern int Stoch3_Dperiod=14;
extern int Stoch3_Slowing=3;
extern int Stoch3_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch3_Price_Field=0;  // 0 - Low/High, 1 - Close/Close 
extern int Stoch3_Weight=1.;

extern int Stoch4_Kperiod=75;
extern int Stoch4_Dperiod=20;
extern int Stoch4_Slowing=3;
extern int Stoch4_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch4_Price_Field=0;  // 0 - Low/High, 1 - Close/Close 
extern int Stoch4_Weight=4.;
extern bool Show_Components=true;
extern int Signal_Length=9;

double Stoch1[], Stoch2[], Stoch3[], Stoch4[], STPMT[], MA[];
double Sum_Weight;

int init()
{
 IndicatorShortName("Medium Term Weighted Stochastics");
 IndicatorDigits(Digits);
 SetIndexBuffer(0,Stoch1);
 SetIndexBuffer(1,Stoch2);
 SetIndexBuffer(2,Stoch3);
 SetIndexBuffer(3,Stoch4);
 if (Show_Components)
 {
  SetIndexStyle(0,DRAW_LINE);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexStyle(3,DRAW_LINE);
 }
 else
 {
  SetIndexStyle(0,DRAW_NONE);
  SetIndexStyle(1,DRAW_NONE);
  SetIndexStyle(2,DRAW_NONE);
  SetIndexStyle(3,DRAW_NONE);
 } 

 SetIndexStyle(4,DRAW_LINE);
 SetIndexBuffer(4,STPMT);
 SetIndexStyle(5,DRAW_LINE);
 SetIndexBuffer(5,MA);
 
 Sum_Weight=Stoch1_Weight+Stoch2_Weight+Stoch3_Weight+Stoch4_Weight;

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
 pos=limit;
 while(pos>=0)
 {
  Stoch1[pos]=iStochastic(NULL, 0, Stoch1_Kperiod, Stoch1_Dperiod, Stoch1_Slowing, Stoch1_Method, Stoch1_Price_Field, MODE_MAIN, pos);
  Stoch2[pos]=iStochastic(NULL, 0, Stoch2_Kperiod, Stoch2_Dperiod, Stoch2_Slowing, Stoch2_Method, Stoch2_Price_Field, MODE_MAIN, pos);
  Stoch3[pos]=iStochastic(NULL, 0, Stoch3_Kperiod, Stoch3_Dperiod, Stoch3_Slowing, Stoch3_Method, Stoch3_Price_Field, MODE_MAIN, pos);
  Stoch4[pos]=iStochastic(NULL, 0, Stoch4_Kperiod, Stoch4_Dperiod, Stoch4_Slowing, Stoch4_Method, Stoch4_Price_Field, MODE_MAIN, pos);
  
  STPMT[pos]=(Stoch1_Weight*Stoch1[pos]+Stoch2_Weight*Stoch2[pos]+Stoch3_Weight*Stoch3[pos]+Stoch4_Weight*Stoch4[pos])/Sum_Weight;

  pos--;
 } 
 
 pos=limit;
 while(pos>=0)
 {
  MA[pos]=iMAOnArray(STPMT, 0, Signal_Length, 0, MODE_SMA, pos);

  pos--;
 }
   
 return(0);
}

