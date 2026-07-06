-- More information about this indicator can be found at:
-- http://fxcodebase.com/code/viewtopic.php?f=38&t=70942

--+------------------------------------------------------------------+
--|                               Copyright © 2021, Gehtsoft USA LLC | 
--|                                            http://fxcodebase.com |
--+------------------------------------------------------------------+
--|                                 Support our efforts by donating  | 
--|                                    Paypal: https://goo.gl/9Rj74e |
--+------------------------------------------------------------------+
--|                                      Developed by : Mario Jemic  |                    
--|                                          mario.jemic@gmail.com   |
--|                           https://AppliedMachineLearning.systems |
--|                                Patreon :  https://goo.gl/GdXWeN  |
--+------------------------------------------------------------------+
--|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
--|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
--+------------------------------------------------------------------+

#property indicator_separate_window

#property  indicator_buffers 36
#property indicator_color1  clrLime
#property indicator_color2  clrRed
#property indicator_color3  clrLime
#property indicator_color4  clrRed
#property indicator_color5  clrDarkGray
#property indicator_color6  clrLime
#property indicator_color7  clrRed
#property indicator_color8  clrDarkGray
#property indicator_color9  clrLime
#property indicator_color10 clrRed
#property indicator_color11 clrDarkGray

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      Short_MA_Period    = 5;
input  e_method Short_MA_Method    = SMA;
input  e_price  Short_MA_Price     = CLOSE;
extern int      Long_MA_Period     = 20;
input  e_method Long_MA_Method     = SMA;
input  e_price  Long_MA_Price      = CLOSE;
extern int      MACD_Fast_EMA      = 12;
extern int      MACD_Slow_EMA      = 26;
extern int      MACD_Signal        = 9;
extern int      RSI_Period         = 14;
extern int      ADX_Period         = 14;
extern int      DeMarker_Period    = 14;
extern int      Momentum_Period    = 14;
extern int      Force_Index_Period = 13;

//---- indicator buffers
double F1_Up[], F1_Dn[];
double F2_Up[], F2_Dn[], F2_Nt[];
double F3_Up[], F3_Dn[], F3_Nt[];
double F4_Up[], F4_Dn[], F4_Nt[];

string IndName;

string IndicatorName;
string IndicatorObjPrefix;

string GenerateIndicatorName(const string target)
{
   string name = target;
   int try = 2;
   while (WindowFind(name) != -1)
   {
      name = target + " #" + IntegerToString(try++);
   }
   return name;
}
//---- variables

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init(){
   
   int arrow = 110;
   
   SetIndexBuffer(0,F1_Up);
   SetIndexStyle (0,DRAW_ARROW);
   SetIndexArrow (0,233);
   SetIndexBuffer(1,F1_Dn);
   SetIndexStyle (1,DRAW_ARROW);
   SetIndexArrow (1,234);
   
   SetIndexBuffer(2,F2_Up);
   SetIndexBuffer(3,F2_Dn);
   SetIndexBuffer(4,F2_Nt);
   SetIndexBuffer(5,F3_Up);
   SetIndexBuffer(6,F3_Dn);
   SetIndexBuffer(7,F3_Nt);
   SetIndexBuffer(8,F4_Up);
   SetIndexBuffer(9,F4_Dn);
   SetIndexBuffer(10,F4_Nt);
   
   for (int i = 2; i < 11; i++) {
      SetIndexStyle(i,DRAW_ARROW);
      SetIndexArrow(i,arrow);
   }
   
   IndName = "Golden Filter";
   IndicatorName = GenerateIndicatorName(IndName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   IndicatorSetDouble(INDICATOR_MINIMUM,0);
   IndicatorSetDouble(INDICATOR_MAXIMUM,2.5);
   
//---- initialization done
   return(0);
  }

  
int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
//+------------------------------------------------------------------+
//| Moving Averages Convergence/Divergence                           |
//+------------------------------------------------------------------+
int start()
  {
   int limit, i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
   
   //if (limit_bars>0) limit = limit_bars;
   
   double short_ma, long_ma, short_ma1, long_ma1;
   double macd, macd_signal;
   double rsi;
   double dip, dim;
   double momentum;
   double demark;
   double force;
   
   Limpiar();
   
   for (i=limit; i>=0; i--){
      
      
      // Line 1
      // Long: ShortMA / LongMA CrossOver
      // Short: ShortMA / LongMA CrossUnder
      short_ma  = iMA(NULL,0,Short_MA_Period, 0, ENUM_MA_METHOD(Short_MA_Method), ENUM_APPLIED_PRICE(Short_MA_Price), i);
      long_ma   = iMA(NULL,0,Long_MA_Period, 0, ENUM_MA_METHOD(Long_MA_Method), ENUM_APPLIED_PRICE(Long_MA_Price), i);
      short_ma1 = iMA(NULL,0,Short_MA_Period, 0, ENUM_MA_METHOD(Short_MA_Method), ENUM_APPLIED_PRICE(Short_MA_Price), i+1);
      long_ma1  = iMA(NULL,0,Long_MA_Period, 0, ENUM_MA_METHOD(Long_MA_Method), ENUM_APPLIED_PRICE(Long_MA_Price), i+1);
      if (short_ma > long_ma && short_ma1 < long_ma1) F1_Up[i] = 2.0;
      if (short_ma < long_ma && short_ma1 > long_ma1) F1_Dn[i] = 2.0;
      Etiqueta("HeatLbl_F1"," - Filter 1",2.0, Time[0]+(Period()*60*3));
      
      //Line 2
      // Long: MACD > SIGNAL; DIP > DIM; RSI > 50
      // Short: MACD < SIGNAL; DIP < DIM; RSI < 50
      macd        = iMACD(NULL,0,MACD_Fast_EMA,MACD_Slow_EMA,MACD_Signal,PRICE_CLOSE,MODE_MAIN,i);
      macd_signal = iMACD(NULL,0,MACD_Fast_EMA,MACD_Slow_EMA,MACD_Signal,PRICE_CLOSE,MODE_SIGNAL,i);
      rsi         = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
      dip         = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,i);
      dim         = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,i);
      if (macd > macd_signal && dip > dim && rsi > 50)
         F2_Up[i] = 1.5;
      else if (macd < macd_signal && dip < dim && rsi < 50)
         F2_Dn[i] = 1.5;
      else
         F2_Nt[i] = 1.5;
      Etiqueta("HeatLbl_F2"," - Filter 2",1.6, Time[0]+(Period()*60*3));
      
      //Line 3 
      //Long: Force Index > 0; DeMarker > 0.5
      //Short: Force Index < 0; DeMarker < 0.5
      force = iForce(NULL,0,Force_Index_Period,MODE_SMA,PRICE_CLOSE,i);
      demark = iDeMarker(NULL,0,DeMarker_Period,i);
      if (force > 0 && demark > 0.5)
         F3_Up[i] = 1.0;
      else if (force < 0 && demark < 0.5)
         F3_Dn[i] = 1.0;
      else
         F3_Nt[i] = 1.0;
      Etiqueta("HeatLbl_F3"," - Filter 3",1.1, Time[0]+(Period()*60*3));
      
      // Line 4
      // Long: Momentum > 100; Short: Momentum < 100
      momentum = iMomentum(NULL,0,Momentum_Period,PRICE_CLOSE,i);
      if (momentum > 100)
         F4_Up[i] = 0.5;
      else if (momentum < 100)
         F4_Dn[i] = 0.5;
      else
         F4_Nt[i] = 0.5;
      Etiqueta("HeatLbl_F4"," - Filter 4",0.6, Time[0]+(Period()*60*3));
      
   }
   
      
//---- done
   return(0);
}

int Etiqueta(string sName, string sLabel,double dPrice, datetime tTime) {
  ObjectCreate(IndicatorObjPrefix + sName, OBJ_TEXT, WindowFind(IndName), tTime+Period()*60*2, dPrice);
  ObjectSetText(IndicatorObjPrefix + sName, " "+sLabel, 8, "Lucida Console", clrWhite);
  ObjectMove(IndicatorObjPrefix + sName,0,tTime+Period()*60*2, dPrice);
  return(0);
}

void Limpiar(){
}