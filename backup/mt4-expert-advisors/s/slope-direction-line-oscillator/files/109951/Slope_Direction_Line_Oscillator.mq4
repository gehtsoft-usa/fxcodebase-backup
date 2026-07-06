//+------------------------------------------------------------------+
//|                              Slope_Direction_Line_Oscillator.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+


#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 3
#property indicator_color2 clrRed
#property indicator_width2 3
#property indicator_color3 clrOrange
#property indicator_width3 3

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string   Comment1       = "- 1st SDL Parameters -";
extern int      MA1_Period     = 40;
extern e_method MA1_Method     = SMA;
extern e_price  MA1_Price_Type = CLOSE;
extern string   Comment2       = "- 2nd SDL Parameters -";
extern int      MA2_Period     = 80;
extern e_method MA2_Method     = SMA;
extern e_price  MA2_Price_Type = CLOSE;
extern string   Comment3       = "- Optimization. Leave 0 for All -";
extern int      Limit_Bars     = 500;

double Trend1[];
double MAa1[];
double MAb1[];
double Vect1[];

double Trend2[];
double MAa2[];
double MAb2[];
double Vect2[];

double Up[];
double Down[];
double Neutral[];

int init(){
   
   IndicatorShortName("Slope Direction Line Oscillator");
   IndicatorBuffers(11);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"Up");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Down);
   SetIndexLabel(1,"Down");
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Neutral);
   SetIndexLabel(2,"Neutral");
   
   SetIndexBuffer(3,Trend1);
   SetIndexBuffer(4,MAa1);
   SetIndexBuffer(5,MAb1);
   SetIndexBuffer(6,Vect1);
   
   SetIndexBuffer(7,Trend2);
   SetIndexBuffer(8,MAa2);
   SetIndexBuffer(9,MAb2);
   SetIndexBuffer(10,Vect2);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars>0) limit = Limit_Bars;
   
   for(i=limit; i>=0; i--){
      
      MAa1[i]   = iMA(NULL,0,MA1_Period,0,ENUM_MA_METHOD(MA1_Method),ENUM_APPLIED_PRICE(MA1_Price_Type),i);
      MAb1[i]  = iMA(NULL,0,MathFloor(MA1_Period/2),0,ENUM_MA_METHOD(MA1_Method),ENUM_APPLIED_PRICE(MA1_Price_Type),i);
      Vect1[i] = 2*MAb1[i]-MAa1[i];
      Trend1[i] = iMAOnArray(Vect1,0,MathFloor(MathSqrt(MA1_Period)),0,ENUM_MA_METHOD(MA1_Method),i);
      
      MAa2[i]   = iMA(NULL,0,MA2_Period,0,ENUM_MA_METHOD(MA2_Method),ENUM_APPLIED_PRICE(MA2_Price_Type),i);
      MAb2[i]  = iMA(NULL,0,MathFloor(MA2_Period/2),0,ENUM_MA_METHOD(MA2_Method),ENUM_APPLIED_PRICE(MA2_Price_Type),i);
      Vect2[i] = 2*MAb2[i]-MAa2[i];
      Trend2[i] = iMAOnArray(Vect2,0,MathFloor(MathSqrt(MA2_Period)),0,ENUM_MA_METHOD(MA2_Method),i);
      
      if (Trend1[i] > Trend1[i+1] && Trend2[i] > Trend2[i+1]){
         Up[i]      = 100;
         Down[i]    = 0;
         Neutral[i] = 0;
      }else if (Trend1[i] < Trend1[i+1] && Trend2[i] < Trend2[i+1]){
         Up[i]      = 0;
         Down[i]    = 100;
         Neutral[i] = 0;
      }else{
         Up[i]      = 0;
         Down[i]    = 0;
         Neutral[i] = 100;
      }
      
   }
   
//----
   return(0);
}
  
