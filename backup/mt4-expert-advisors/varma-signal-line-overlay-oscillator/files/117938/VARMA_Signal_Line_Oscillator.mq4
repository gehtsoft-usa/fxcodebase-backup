// Id: 20631
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=65778

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property description "Green/Red Oscillator colors according to:"
#property description "- Mode 1: VARMA Fast vs Slow"
#property description "- Mode 2: VARMA vs MA of that VARMA (Signal)"

#property indicator_separate_window
#property indicator_buffers 2

#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_width1  2
#property indicator_width2  2

enum e_mode{ VARMA_Fast_Slow=1, VARMA_Signal=2 };
enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern e_mode   Mode           = VARMA_Fast_Slow;
extern string   Comment0       = "- Mode 1 Parameter: Fast vs Slow VARMA-";
extern int      Fast_Length    = 9;
extern int      Fast_Smoothing = 2;
extern int      Slow_Length    = 27;
extern int      Slow_Smoothing = 5;
extern e_price  VARMA_Price    = CLOSE;
extern string   Comment1       = "- Mode 2 Additional Parameters: MA of VARMA-";
extern int      Signal_Period  = 27;
extern e_method Signal_Method  = EMA;
extern int      Limit_Bars     = 1000;

double Up[];
double Down[];

double fast[], slow[], signal[];

string   WindowName;

int Bullish = 1;
int Bearish = -1;
int Neutral = 0;

int init(){
 
       double temp = iCustom(NULL, 0, "VARMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'VARMA' indicator");
       return INIT_FAILED;
   }
   WindowName = "VARMA_Signal_Line_Oscillator";
	IndicatorShortName(WindowName);
	IndicatorBuffers(5);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"Up");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Down);
   SetIndexLabel(1,"Down");
   
   SetIndexBuffer(2,fast);
   SetIndexBuffer(3,slow);
   SetIndexBuffer(4,signal);
   
   return(0);
   
}

int start(){   

   int i, bias;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=Limit_Bars; i>=0; i--){
   
      ResetBuffers(i);
   
      fast[i] = iCustom(NULL, 0, "VARMA", Fast_Length, Fast_Smoothing, ENUM_APPLIED_PRICE(VARMA_Price), Limit_Bars, 0, i);
      slow[i] = iCustom(NULL, 0, "VARMA", Slow_Length, Slow_Smoothing, ENUM_APPLIED_PRICE(VARMA_Price), Limit_Bars, 0, i);
      
   }
   
   for(i=Limit_Bars; i>=0; i--){
   
      signal[i] = iMAOnArray(fast,WHOLE_ARRAY,Signal_Period,0,ENUM_MA_METHOD(Signal_Method),i);
      
   }
   
   for(i=Limit_Bars; i>=0; i--){
   
      ResetBuffers(i);
      
      if (Mode==1)
      
         bias=DetermineBias(fast[i], slow[i]);
         
      else
      
         bias=DetermineBias(fast[i], signal[i]);
   
      if(bias>0){
         
         Up[i]      = 100;
         Down[i]    = 0;
      
      }
      else{
         
         Up[i]      = 0;
         Down[i]    = 100;
      
      }

   }
 
   return(0);

}

void ResetBuffers(int shift){
   Up[shift]   = EMPTY_VALUE;
   Down[shift] = EMPTY_VALUE;
   return;
}

int DetermineBias(double line1, double line2){
   
   if (line1 > line2)
      return(Bullish);
   else
      return (Bearish);

}
