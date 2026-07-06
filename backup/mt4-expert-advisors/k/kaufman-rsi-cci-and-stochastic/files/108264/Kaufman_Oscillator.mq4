//+------------------------------------------------------------------+
//|                                           Kaufman_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//+------------------------------------------------------------------+

#property indicator_buffers 4
#property indicator_separate_window
#property indicator_levelcolor clrYellow

enum e_method{ CCI=1, RSI=2, Stochastic=3 };

extern e_method Oscillator         = CCI;
extern int      periodAMA          = 10;
extern double   nfast              = 2;
extern string   Comment0           = "- Suggested nslow: CCI=15, RSI=10, Stochastic=15 -";
extern double   nslow              = 15;
extern string   Comment1           = "- Suggested G: CCI=6, RSI=4, Stochastic=3 -";
extern double   G                  = 6;
extern string   Comment2           = "- Suggested dK: CCI=10000, RSI=450, Stochastic=10000 -";
extern double   dK                 = 10000;
extern string   Comment3           = "- Suggested Periods: CCI=250, RSI=200, Stochastic=500 -";
extern int      Indicator_periods  = 250;
extern int      Stochastic_Slowing = 1;
extern color    Indicator_K_color  = clrLime;
extern color    Indicator_color    = clrRed;
extern color    Up_color           = clrDodgerBlue;
extern color    Dn_color           = clrYellow;

double Indicator_K[];
double Indicator[];
double Up[];
double Dn[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Kaufman_Indicator");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,Indicator_K_color);
   SetIndexBuffer(0,Indicator_K);
   SetIndexLabel(0,"Indicator_K");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,Indicator_color);
   SetIndexBuffer(1,Indicator);
   SetIndexLabel(1,"Indicator");
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Up_color);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Up);
   SetIndexLabel(2,"Up");
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Dn_color);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,Dn);
   SetIndexLabel(3,"Dn");
   
   if (Oscillator==1) int Level=0; else Level=50;
   SetLevelValue(0,Level);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double slowSC, fastSC, signal, noise, ER, dSC, ERSC, SSC, AMA, AMA0, ddK, pipSize;
   
   for(i=limit+periodAMA+Indicator_periods+2; i>=0; i--){
      if (Oscillator==1)
         Indicator[i] = iCCI(NULL,0,Indicator_periods,PRICE_TYPICAL,i);
      if (Oscillator==2)
         Indicator[i] = iRSI(NULL,0,Indicator_periods,PRICE_CLOSE,i);
      if (Oscillator==3)
         Indicator[i] = iStochastic(NULL,0,Indicator_periods,1,Stochastic_Slowing,MODE_SMA,0,MODE_MAIN,i);
   }
   
   pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for(i=limit+periodAMA+Indicator_periods+2; i>=0; i--){
      
      slowSC=2/(nslow+1);
      fastSC=2/(nfast+1);
      signal=MathAbs(Indicator[i]-Indicator[i+periodAMA]);
      noise=0.000000001;
      for (j=(i+periodAMA-1); j>=i; j--){
         noise=noise+MathAbs(Indicator[j]-Indicator[j+1]);
      }
      ER=signal/noise;
      dSC=fastSC-slowSC;
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA0+MathPow(SSC,G)*(Indicator[i]-AMA0);
      Indicator_K[i]=AMA;
      ddK=AMA-AMA0;
      if (MathAbs(ddK)>dK*pipSize && ddK>0){
         Up[i]=AMA;
      }
      if (MathAbs(ddK)>dK*pipSize && ddK<0){
         Dn[i]=AMA;
      }
      AMA0=AMA;
      if (i==0) Comment(ddK+" "+dK+" "+pipSize);
   }
   
//----
   return(0);
}
