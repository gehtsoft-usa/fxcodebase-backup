//+------------------------------------------------------------------+
//|                                                    Ehlers_CG.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1  clrLime
#property indicator_width1  2
#property indicator_color2  clrOliveDrab
#property indicator_width2  2

extern int    Lenght   = 10;

double CG0[];
double CG1[];
double Price[];

//+****************************************************************+

int init(){
   
   IndicatorShortName("Ehler's Center of Gravity");
   
   IndicatorBuffers(3);
      
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,CG0);
   SetIndexLabel(0,"CG0");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,CG1);
   SetIndexLabel(1,"CG1");
   
   SetIndexBuffer(2,Price);
   
   return(0);
   
  }
  
//+****************************************************************+

  
int start(){
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double Num, Demon;
   
   for(i=limit; i>=0; i--){
      
      Num = Demon = 0;
      
      Price[i] = (High[i] + Low[i]) / 2;
      
      for (j=0; j<Lenght-1; j++){
         Num   = Num + (j+1)*Price[i+j];
         Demon = Demon + Price[i+j];
      }
      
      CG0[i] = -Num/Demon + (Lenght+1)/2;
      CG1[i] = CG0[i+1];
      
   }
   
   return(0);
   
}
  
