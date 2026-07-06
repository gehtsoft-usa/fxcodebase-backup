//+------------------------------------------------------------------+
//|                                               WMA_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+



#property indicator_buffers 2
#property indicator_separate_window

enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int     WMA1_Period =  5;
extern int     WMA2_Period = 20;
extern e_price Price_Type  = CLOSE;
extern color   Up_Color    = clrLime;
extern color   Dn_Color    = clrRed;
extern int     Bars_Width  = 3;

double UP[];
double DOWN[];
double DATA[];
double Price[];
double WMA1[];
double WMA2[];

int init(){
   
   IndicatorShortName("WMA Oscillator");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Up_Color);
   SetIndexBuffer(0,UP);
   SetIndexLabel(0,"UP");
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Dn_Color);
   SetIndexBuffer(1,DOWN);
   SetIndexLabel(1,"DOWN");
   
   SetIndexBuffer(2,DATA); 
   SetIndexBuffer(3,Price);
   SetIndexBuffer(4,WMA1);
   SetIndexBuffer(5,WMA2);
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for (i=limit; i>=0; i--){
      Price[i] = iMA(NULL,0,1,0,0,ENUM_APPLIED_PRICE(Price_Type),i);
   }
      
   for(i=limit-WMA2_Period; i>=0; i--){

      WMA1[i] = Wilder(Price[i],WMA1[i+1],WMA1_Period,i);
      WMA2[i] = Wilder(Price[i],WMA2[i+1],WMA2_Period,i);
      DATA[i] = WMA1[i] - WMA2[i];
      
   }
   
   for(i=limit-WMA2_Period; i>=0; i--){
      
      if (DATA[i] > DATA[i+1])
         UP[i] = DATA[i];
      else
         DOWN[i] = DATA[i];

   }
   
   
   
//----
   return(0);
}
  
double Wilder(double price,double prev,int per,int bar){
   if(bar >= Bars - 2)
      double wilder = price;
   else 
      wilder = prev + (price - prev)/per; 
   return(wilder);
}