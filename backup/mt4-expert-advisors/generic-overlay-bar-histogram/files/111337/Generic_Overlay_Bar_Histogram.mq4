// Id: 17768
//+------------------------------------------------------------------+
//|                                Generic_Overlay_Bar_Histogram.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "Bar Histogram according to Indicators Behaviors"

#property indicator_buffers 3
#property indicator_separate_window
#property indicator_color1 clrLime
#property indicator_width1 3
#property indicator_color2 clrRed
#property indicator_width2 3
#property indicator_color3 clrDarkGray
#property indicator_width3 3

enum behaviors  { Slope=1, Level=2, OBOS=3, Signal_MA=4  };
enum indicators { RSI=1, Stochastic=2, CCI=3, Ultimate_Oscillator=4, MACD=5, Williams_Percent=6 };
enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string     Comment0             = "- Indicator to use: -";
input  indicators Indicator            = CCI;
extern string     Comment1             = "- Behavior to analyze: -";
input  behaviors  Comparison_Mode      = OBOS;
extern string     Comment2             = "- Signal MA Parameters: -";
extern e_method   Signal_MA_Method     = SMA;
extern int        Signal_MA_Periods    = 20;
extern e_price    Signal_MA_Price      = CLOSE;
extern string     Comment3             = "- RSI Parameters: -";
extern int        RSI_Periods          = 14;
extern double     RSI_Main_Level       = 50;
extern double     RSI_OB_Level         = 70;
extern double     RSI_OS_Level         = 30;
extern string     Comment4             = "- Stochastic: -";
extern int        Stochastic_K_Periods = 9;
extern int        Stochastic_D_Periods = 6;
extern int        Stochastic_Slowing   = 3;
extern double     Stochastic_Main_Level = 50;
extern double     Stochastic_OB_Level  = 80;
extern double     Stochastic_OS_Level  = 20;
extern string     Comment5             = "- CCI: -";
extern int        CCI_Periods          = 14;
extern double     CCI_Main_Level       = 0;
extern double     CCI_OB_Level         = 150;
extern double     CCI_OS_Level         = -150;
extern string     Comment6             = "- Ultimate Oscillator: -";
extern int        UO_Average1          = 7;
extern int        UO_Average2          = 14;
extern int        UO_Average3          = 28;
extern double     UO_Main_Level        = 50;
extern double     UO_OB_Level          = 70;
extern double     UO_OS_Level          = 30;
extern string     Comment8             = "- MACD: -";
extern int        MACD_Fast_EMA_Period = 12;
extern int        MACD_Slow_EMA_Period = 26;
extern int        MACD_Signal_Period   = 9;
extern double     MACD_Main_Level      = 0;
extern string     Comment9             = "- Williams Percent: -";
extern int        WPR_Periods          = 14;
extern double     WPR_Main_Level       = -50;
extern double     WPR_OB_Level         = -20;
extern double     WPR_OS_Level         = -80;

double Up[];
double Down[];
double Neutral[];

double Value[];
double MA[];
double Price[];

int init(){
   
       double temp = iCustom(NULL, 0, "Ultimate_Oscillator", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Ultimate_Oscillator' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Slope Direction Line Oscillator");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexDrawBegin(0,Signal_MA_Periods*2);
   SetIndexLabel(0,"Up");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Down);
   SetIndexDrawBegin(1,Signal_MA_Periods*2);
   SetIndexLabel(1,"Down");
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,Neutral);
   SetIndexDrawBegin(2,Signal_MA_Periods*2);
   SetIndexLabel(2,"Neutral");
   
   SetIndexBuffer(3,Value);
   SetIndexBuffer(4,MA);
   SetIndexBuffer(5,Price);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   Comment("");
   
   double Main_Level, OB_Level, OS_Level;
   switch(Indicator){
      case 1 :
         Main_Level = RSI_Main_Level;
         OB_Level   = RSI_OB_Level;
         OS_Level   = RSI_OS_Level;
         break;
      case 2 :
         Main_Level = Stochastic_Main_Level;
         OB_Level   = Stochastic_OB_Level;
         OS_Level   = Stochastic_OS_Level;
         break;
      case 3 :
         Main_Level = CCI_Main_Level;
         OB_Level   = CCI_OB_Level;
         OS_Level   = CCI_OS_Level;
         break;
      case 4 :
         Main_Level = UO_Main_Level;
         OB_Level   = UO_OB_Level;
         OS_Level   = UO_OS_Level;
         break;
      case 5 :
         Main_Level = MACD_Main_Level;
         OB_Level   = -1;
         OS_Level   = -1;
         break;
      case 6 :
         Main_Level = WPR_Main_Level;
         OB_Level   = WPR_OB_Level;
         OS_Level   = WPR_OS_Level;
         break;
      default:
         Main_Level = 0;
         OB_Level   = -1;
         OS_Level   = -1;
         break;
   }
   
   for(i=limit; i>=0; i--){
   
      switch(Indicator){
         case 1 : Value[i] = iRSI(NULL,0,RSI_Periods,PRICE_CLOSE,i); break;
         case 2 : Value[i] = iStochastic(NULL,0,Stochastic_K_Periods,Stochastic_D_Periods,Stochastic_Slowing,MODE_SMA,0,MODE_MAIN,i); break;
         case 3 : Value[i] = iCCI(NULL,0,CCI_Periods,PRICE_TYPICAL,i); break;  
         case 4 : Value[i] = iCustom(NULL,0,"Ultimate_Oscillator",UO_Average1,UO_Average2,UO_Average3,0,i); break;
         case 5 : Value[i] = iMACD(NULL,0,MACD_Fast_EMA_Period,MACD_Slow_EMA_Period,MACD_Signal_Period,PRICE_CLOSE,MODE_MAIN,i); break;
         case 6 : Value[i] = iWPR(NULL,0,WPR_Periods,i); break;
         default: Value[i] = iRSI(NULL,0,RSI_Periods,PRICE_CLOSE,i); break;
      }
   
   }
   
   for(i=limit; i>=0; i--){
   
      Price[i] = iMA(NULL,0,1,0,MODE_SMA,ENUM_APPLIED_PRICE(Signal_MA_Price),i);
      MA[i] = iMAOnArray(Value,WHOLE_ARRAY,Signal_MA_Periods,0,ENUM_MA_METHOD(Signal_MA_Method),i);
   
   }
   
   for(i=limit; i>=0; i--){
      
      // Slope
      if (Comparison_Mode==1){
            if (Value[i] > Value[i+1]){
               Up[i]      = 100;
               Down[i]    = 0;
               Neutral[i] = 0;
            }else if (Value[i] < Value[i+1]){
               Up[i]      = 0;
               Down[i]    = 100;
               Neutral[i] = 0;
            }else{
               Up[i]      = 0;
               Down[i]    = 0;
               Neutral[i] = 100;
            }
      }
      
      // Level
      if (Comparison_Mode==2){
            if (Value[i] > Main_Level){
               Up[i]      = 100;
               Down[i]    = 0;
               Neutral[i] = 0;
            }else if (Value[i] < Main_Level){
               Up[i]      = 0;
               Down[i]    = 100;
               Neutral[i] = 0;
            }else{
               Up[i]      = 0;
               Down[i]    = 0;
               Neutral[i] = 100;
            }
      }
      
      // OBOS
      if (Comparison_Mode==3){
            if (Value[i] > OB_Level){
               Up[i]      = 100;
               Down[i]    = 0;
               Neutral[i] = 0;
            }else if (Value[i] < OS_Level){
               Up[i]      = 0;
               Down[i]    = 100;
               Neutral[i] = 0;
            }else{
               Up[i]      = 0;
               Down[i]    = 0;
               Neutral[i] = 100;
            }
      }
      
      // MA Signal
      if (Comparison_Mode==4){
            if (Value[i] > MA[i]){
               Up[i]      = 100;
               Down[i]    = 0;
               Neutral[i] = 0;
            }else if (Value[i] < MA[i]){
               Up[i]      = 0;
               Down[i]    = 100;
               Neutral[i] = 0;
            }else{
               Up[i]      = 0;
               Down[i]    = 0;
               Neutral[i] = 100;
            }
      }
      
   }
   
//----
   return(0);
}
  
