//+------------------------------------------------------------------+
//|                                                           SS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Stoch1_K_Length=36;
extern int Stoch1_D_Length=18;
extern int Stoch1_Slowing=9;
extern int Stoch1_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch1_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch2_K_Length=40;
extern int Stoch2_D_Length=20;
extern int Stoch2_Slowing=10;
extern int Stoch2_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch2_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch3_K_Length=52;
extern int Stoch3_D_Length=26;
extern int Stoch3_Slowing=13;
extern int Stoch3_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch3_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch4_K_Length=60;
extern int Stoch4_D_Length=30;
extern int Stoch4_Slowing=15;
extern int Stoch4_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch4_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch5_K_Length=70;
extern int Stoch5_D_Length=17;
extern int Stoch5_Slowing=8;
extern int Stoch5_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch5_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch6_K_Length=84;
extern int Stoch6_D_Length=42;
extern int Stoch6_Slowing=21;
extern int Stoch6_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch6_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch7_K_Length=100;
extern int Stoch7_D_Length=50;
extern int Stoch7_Slowing=25;
extern int Stoch7_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch7_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

extern int Stoch8_K_Length=120;
extern int Stoch8_D_Length=60;
extern int Stoch8_Slowing=30;
extern int Stoch8_Method=0;  // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
extern int Stoch8_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

double SS[], SS_Dn[];

int init()
{
 IndicatorShortName("Stochastic Stack");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,SS);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,SS_Dn);

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
 double Stoch1, Stoch2, Stoch3, Stoch4, Stoch5, Stoch6, Stoch7, Stoch8;
 pos=limit;
 while(pos>=0)
 {
  Stoch1=iStochastic(NULL, 0, Stoch1_K_Length, Stoch1_D_Length, Stoch1_Slowing, Stoch1_Method, Stoch1_Price_Field, MODE_MAIN, pos);
  Stoch2=iStochastic(NULL, 0, Stoch2_K_Length, Stoch2_D_Length, Stoch2_Slowing, Stoch2_Method, Stoch2_Price_Field, MODE_MAIN, pos);
  Stoch3=iStochastic(NULL, 0, Stoch3_K_Length, Stoch3_D_Length, Stoch3_Slowing, Stoch3_Method, Stoch3_Price_Field, MODE_MAIN, pos);
  Stoch4=iStochastic(NULL, 0, Stoch4_K_Length, Stoch4_D_Length, Stoch4_Slowing, Stoch4_Method, Stoch4_Price_Field, MODE_MAIN, pos);
  Stoch5=iStochastic(NULL, 0, Stoch5_K_Length, Stoch5_D_Length, Stoch5_Slowing, Stoch5_Method, Stoch5_Price_Field, MODE_MAIN, pos);
  Stoch6=iStochastic(NULL, 0, Stoch6_K_Length, Stoch6_D_Length, Stoch6_Slowing, Stoch6_Method, Stoch6_Price_Field, MODE_MAIN, pos);
  Stoch7=iStochastic(NULL, 0, Stoch7_K_Length, Stoch7_D_Length, Stoch7_Slowing, Stoch7_Method, Stoch7_Price_Field, MODE_MAIN, pos);
  Stoch8=iStochastic(NULL, 0, Stoch8_K_Length, Stoch8_D_Length, Stoch8_Slowing, Stoch8_Method, Stoch8_Price_Field, MODE_MAIN, pos);
  
  SS[pos]=Stoch1-Stoch2+Stoch3-Stoch4+Stoch5-Stoch6+Stoch7-Stoch8;
  
  if (SS[pos]<0.)
  {
   SS_Dn[pos]=SS[pos];
  }
  else
  {
   SS_Dn[pos]=EMPTY_VALUE;
  }

  pos--;
 } 
 return(0);
}

