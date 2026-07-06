//+------------------------------------------------------------------+
//|                                         Slope_Direction_Line.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+


#property indicator_buffers 3
#property indicator_chart_window
#property indicator_color1 clrYellow
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 clrLime
#property indicator_style2 STYLE_SOLID
#property indicator_width2 2
#property indicator_color3 clrRed
#property indicator_style3 STYLE_SOLID
#property indicator_width3 2

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      MA_Period     = 80;
extern e_method MA_Method     = SMA;
extern e_price  MA_Price_Type = CLOSE;
extern int      Limit_Bars    = 500;

double Trend[];
double Up[];
double Dn[];
double MA[];
double MA2[];
double Vect[];

int init(){
   
   IndicatorShortName("Slope Direction Line");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Trend);
   SetIndexLabel(0,"Slope Trend");
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,Up);
   SetIndexLabel(1,"Up Trend");
   
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,Dn);
   SetIndexLabel(2,"Dn Trend");
   
   SetIndexBuffer(3,MA);
   SetIndexBuffer(4,MA2);
   SetIndexBuffer(5,Vect);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars>0) limit = Limit_Bars;
   
   for(i=limit; i>=0; i--){
      
      MA[i]   = iMA(NULL,0,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),i);
      MA2[i]  = iMA(NULL,0,MathFloor(MA_Period/2),0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),i);
      Vect[i] = 2*MA2[i]-MA[i];
      Trend[i] = iMAOnArray(Vect,0,MathFloor(MathSqrt(MA_Period)),0,ENUM_MA_METHOD(MA_Method),i);
      
      if (Trend[i] > Trend[i+1]){
         Up[i] = Trend[i];
         Dn[i] = EMPTY_VALUE;
      }
      
      if (Trend[i] < Trend[i+1]){
         Dn[i] = Trend[i];
         Up[i] = EMPTY_VALUE;
      }
      
   }
   
//----
   return(0);
}
  
