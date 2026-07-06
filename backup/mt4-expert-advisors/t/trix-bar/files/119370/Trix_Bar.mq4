// Id: 21452
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66149

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
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |  
//|                BitCoin Cash: 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  | 
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |  
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |  
//+------------------------------------------------------------------+


#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrGreen
#property indicator_width1 2
#property indicator_color2 clrRed
#property indicator_width2 2
#property indicator_color3 clrYellow
#property indicator_width3 2

extern int Length=14;
extern int FirstMethod=0;
extern int SecondMethod=0;
extern int ThirdMethod=0;
extern int SignalLength=9;
extern int SignalMethod=0;
extern int Price=0;

double Up[];
double Down[];
double Neutral[];

int init(){
   
       double temp = iCustom(NULL, 0, "Trix", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Trix' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Trix_Bar");
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
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   double trix, Signal;
   
   for(i=limit; i>=0; i--){
      
      trix   = iCustom(NULL,0,"Trix",Length,FirstMethod,SecondMethod,ThirdMethod,SignalLength,SignalMethod,Price,0,i);
      Signal = iCustom(NULL,0,"Trix",Length,FirstMethod,SecondMethod,ThirdMethod,SignalLength,SignalMethod,Price,1,i);
      
      if (trix > Signal && Signal > 0){
         Up[i]      = 100;
         Down[i]    = 0;
         Neutral[i] = 0;
      }else if (trix < Signal && Signal < 0){
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
  
