//+------------------------------------------------------------------+
//|                                                   USDX_Slope.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 4
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 3
#property indicator_color2 clrYellow
#property indicator_width2 3
#property indicator_color3 clrRed
#property indicator_width3 3
#property indicator_color4 clrMagenta
#property indicator_width4 3

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      Shift         = 1;
extern int      MA_Period     = 80;
extern e_method MA_Method     = SMA;
extern e_price  MA_Price_Type = CLOSE;

// USDX Slope
double UpUp[];
double DnUp[];
double UpDn[];
double DnDn[];

// US Index
double USDX[];

// Slope
double Trend[];
double MA[];
double MA2[];
double Vect[];

int init(){
   
   IndicatorShortName("USDX Slope");
   IndicatorBuffers(9);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,UpUp);
   SetIndexLabel(0,"UpUp");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,DnUp);
   SetIndexLabel(1,"DnUp");
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,UpDn);
   SetIndexLabel(2,"UpDn");
   
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,DnDn);
   SetIndexLabel(3,"DnDn");
   
   SetIndexBuffer(4,Trend);
   SetIndexBuffer(5,MA);
   SetIndexBuffer(6,MA2);
   SetIndexBuffer(7,Vect);
   SetIndexBuffer(8,USDX);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double EU, UJ, GU, UC, US, UCH, USDX_Diff;
   
   for(i=limit; i>=0; i--){
      
      MA[i]   = iMA(NULL,0,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),i);
      MA2[i]  = iMA(NULL,0,MathFloor(MA_Period/2),0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),i);
      Vect[i] = 2*MA2[i]-MA[i];
      Trend[i] = iMAOnArray(Vect,0,MathFloor(MathSqrt(MA_Period)),0,ENUM_MA_METHOD(MA_Method),i);
      
      EU  = MathPow(iClose("EURUSD",0,i),-0.576);
      UJ  = MathPow(iClose("USDJPY",0,i),0.136);
      GU  = MathPow(iClose("GBPUSD",0,i),-0.119);
      UC  = MathPow(iClose("USDCAD",0,i),0.091);
      US  = MathPow(iClose("USDSEK",0,i),0.042);
      UCH = MathPow(iClose("USDCHF",0,i),0.036);
      
      USDX[i]=50.14348112*EU*UJ*GU*UC*US*UCH;
      
      USDX_Diff=USDX[i]-USDX[i+Shift];
     
      if (Trend[i] > Trend[i+1]){
         
         if (USDX_Diff>0){
            
            UpUp[i]=100;
            DnUp[i]=0;
            UpDn[i]=0;
            DnDn[i]=0;
            
         }
         else if (USDX_Diff<0){
            UpDn[i]=100;
            UpUp[i]=0;
            DnUp[i]=0;
            DnDn[i]=0;
         }
      }
      else if (Trend[i] < Trend[i+1]){
            
         if (USDX_Diff>0){
         
            DnUp[i]=100;
            UpUp[i]=0;
            UpDn[i]=0;
            DnDn[i]=0;
         }
         else if (USDX_Diff<0){
            
            DnDn[i]=100;
            UpUp[i]=0;
            DnUp[i]=0;
            UpDn[i]=0;
            
         }
         
      }
      
   }
   
//----
   return(0);
}
  
