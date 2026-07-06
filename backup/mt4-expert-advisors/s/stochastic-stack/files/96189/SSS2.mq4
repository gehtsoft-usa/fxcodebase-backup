//+------------------------------------------------------------------+
//|                                                         SSS2.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Stoch_Length=34;
extern double Increment=1.2;
extern int Stoch_Method=0;  // 0 - SMA
                            // 1 - EMA
                            // 2 - SMMA
                            // 3 - LWMA
extern int Stoch_Price_Field=0;  // 0 - Low/High, 1 - Close/Close                             

double SS[], SS_Dn[];

int init()
{
 IndicatorShortName("Simple Stochastic Stack");
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
 int K_Length, D_Length, Slowing;
 double Stoch1, Stoch2, Stoch3, Stoch4, Stoch5, Stoch6, Stoch7, Stoch8;
 pos=limit;
 while(pos>=0)
 {
  K_Length=Stoch_Length;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch1=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch2=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch3=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch4=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch5=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch6=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch7=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
  K_Length=K_Length*Increment;
  D_Length=K_Length/2;
  Slowing=D_Length/2;
  Stoch8=iStochastic(NULL, 0, K_Length, D_Length, Slowing, Stoch_Method, Stoch_Price_Field, MODE_MAIN, pos);
  
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

