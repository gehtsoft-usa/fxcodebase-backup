//+------------------------------------------------------------------+
//|                                                          ZLS.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2014, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Green
#property indicator_color2 Red

extern int Smoothing=15;
extern int K_Length1=18;
extern int D_Slowing1=3;
extern int D_Length1=3;
extern int Method1=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int PriceField1=0;  // 0 - Low/High, 1 - Close/Close
extern double Weight1=0.05;

extern int K_Length2=21;
extern int D_Slowing2=5;
extern int D_Length2=3;
extern int Method2=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int PriceField2=0;  // 0 - Low/High, 1 - Close/Close
extern double Weight2=0.1;

extern int K_Length3=34;
extern int D_Slowing3=8;
extern int D_Length3=3;
extern int Method3=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int PriceField3=0;  // 0 - Low/High, 1 - Close/Close
extern double Weight3=0.16;

extern int K_Length4=55;
extern int D_Slowing4=13;
extern int D_Length4=3;
extern int Method4=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int PriceField4=0;  // 0 - Low/High, 1 - Close/Close
extern double Weight4=0.26;

extern int K_Length5=89;
extern int D_Slowing5=21;
extern int D_Length5=3;
extern int Method5=0;  // 0 - SMA
                       // 1 - EMA
                       // 2 - SMMA
                       // 3 - LWMA
extern int PriceField5=0;  // 0 - Low/High, 1 - Close/Close
extern double Weight5=0.43;

double K[], D[];
double SmoothConst;
double SumWeight;

int init()
{
 IndicatorShortName("Zero Lag Stochastic");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,K);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,D);
 
 SmoothConst=(Smoothing-1.)/Smoothing;
 SumWeight=Weight1+Weight2+Weight3+Weight4+Weight5;

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
 double Stoch1, Stoch2, Stoch3, Stoch4, Stoch5;
 pos=limit;
 while(pos>=0)
 {
  Stoch1=Weight1*iStochastic(NULL, 0, K_Length1, D_Length1, D_Slowing1, Method1, PriceField1, MODE_MAIN, pos);
  Stoch2=Weight1*iStochastic(NULL, 0, K_Length2, D_Length2, D_Slowing2, Method2, PriceField2, MODE_MAIN, pos);
  Stoch3=Weight1*iStochastic(NULL, 0, K_Length3, D_Length3, D_Slowing3, Method3, PriceField3, MODE_MAIN, pos);
  Stoch4=Weight1*iStochastic(NULL, 0, K_Length4, D_Length4, D_Slowing4, Method4, PriceField4, MODE_MAIN, pos);
  Stoch5=Weight1*iStochastic(NULL, 0, K_Length5, D_Length5, D_Slowing5, Method5, PriceField5, MODE_MAIN, pos);
  
  K[pos]=(Stoch1+Stoch2+Stoch3+Stoch4+Stoch5)/SumWeight;
  
  D[pos]=K[pos]/Smoothing+D[pos+1]*SmoothConst;

  pos--;
 } 
 return(0);
}

