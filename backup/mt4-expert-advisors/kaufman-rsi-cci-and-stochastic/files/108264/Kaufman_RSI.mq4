//+------------------------------------------------------------------+
//|                                                  Kaufman_RSI.mq4 |
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

extern int periodAMA = 10;
extern double nfast = 2;
extern double nslow = 10;
extern double G = 4;
extern double dK = 450;
extern int RSI_periods = 200;
extern color RSI_K_color = clrLime;
extern color RSI_color = clrRed;
extern color Up_color = clrDodgerBlue;
extern color Dn_color = clrYellow;

double RSI_K[];
double RSI[];
double Up[];
double Dn[];

datetime LastAlert;

int init(){
   
   IndicatorShortName("Kaufman_RSI");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,RSI_K_color);
   SetIndexBuffer(0,RSI_K);
   SetIndexLabel(0,"RSI_K");
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,RSI_color);
   SetIndexBuffer(1,RSI);
   SetIndexLabel(1,"RSI");
   SetIndexStyle(2,DRAW_ARROW,STYLE_SOLID,1,Up_color);
   SetIndexArrow(2,159);
   SetIndexBuffer(2,Up);
   SetIndexLabel(2,"Up");
   SetIndexStyle(3,DRAW_ARROW,STYLE_SOLID,1,Dn_color);
   SetIndexArrow(3,159);
   SetIndexBuffer(3,Dn);
   SetIndexLabel(3,"Dn");
   
   SetLevelValue(0,50);
   SetLevelStyle(STYLE_SOLID,1);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double slowSC, fastSC, signal, noise, ER, dSC, ERSC, SSC, AMA, AMA0, ddK, pipSize;
   
   for(i=limit+periodAMA+RSI_periods+2; i>=0; i--){
      RSI[i] = iRSI(NULL,0,RSI_periods,PRICE_CLOSE,i);
   }
   
   //AMA0=RSI[1];
   pipSize = MarketInfo(Symbol(),MODE_POINT);
   if (MarketInfo("EURUSD",MODE_DIGITS)==5) pipSize=pipSize*10; // I take the EURUSD as an example to check if it is 5 digits instead of 4, if so, I multiply it by 10
   
   for(i=limit+periodAMA+RSI_periods+2; i>=0; i--){
      
      slowSC=2/(nslow+1);
      fastSC=2/(nfast+1);
      signal=MathAbs(RSI[i]-RSI[i+periodAMA]);
      noise=0.000000001;
      for (j=(i+periodAMA-1); j>=i; j--){
         noise=noise+MathAbs(RSI[j]-RSI[j+1]);
      }
      ER=signal/noise;
      dSC=fastSC-slowSC;
      ERSC=ER*dSC;
      SSC=ERSC+slowSC;
      AMA=AMA0+MathPow(SSC,G)*(RSI[i]-AMA0);
      RSI_K[i]=AMA;
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
