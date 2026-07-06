// Id: 23665
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67277

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property description "ZigZag with Indicator Value Overlay"
#property description "ZigZag-Integer.mq4 required:"
#property description "http://fxcodebase.com/code/viewtopic.php?f=38&t=66415"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 clrRed
#property indicator_color2 clrLime

string indi_name = "ZigZagOverlay";

enum e_indicator{ Stochastic=1, RSI=2,CCI=3,WPR=4,MACD=5,ADX=6,MovingAverage=7 };
enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern string      Comment0                 = "- ZigZag Parameters -";
extern int         Depth                    = 12;
extern int         Deviation                = 5;
extern int         Backstep                 = 3;
extern int         HistoryLimit             = 1000;
input  e_indicator Indicator_Value          = RSI;
extern string      Comment1                 = "- Stochastic Parameters -";
extern int         stoch_k                  = 5;
extern int         stoch_d                  = 3;
extern int         stoch_slowing            = 3;
extern string      Comment2                 = "- RSI Parameters -";
extern int         RSI_periods              = 14;
extern string      Comment3                 = "- CCI Parameters -";
extern int         CCI_periods              = 12;
extern string      Comment4                 = "- WPR Parameters -";
extern int         WPR_periods              = 14;
extern string      Comment5                 = "- Bulls and Bears Impulse Parameters -";
extern int         Bull_Beal_Impulse_Lenght = 13;
extern string      Comment6                 = "- MACD Parameters -";
extern int         MACD_fast_ema_period     = 12;
extern int         MACD_slow_ema_period     = 26;
extern int         MACD_signal_period       = 9;
extern string      Comment7                 = "- ADX Parameters -";
extern int         ADX_periods              = 14;
extern string      Comment8                 = "- SMA Parameters -";
input  e_method    MA_Method                = EMA;
input  e_price     MA_Price                 = CLOSE;
extern int         MA_Period                = 20;

double Zig[];
double Zag[];
double pipSize;

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

int init()
{
        double temp = iCustom(NULL, 0, "ZigZag-Integer", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ZigZag-Integer' indicator");
       return INIT_FAILED;
   }
   int mult = SymbolInfoInteger(_Symbol, SYMBOL_DIGITS) % 2 == 1 ? 10 : 1;
    pipSize = SymbolInfoDouble(_Symbol, SYMBOL_POINT) * mult;
    IndicatorName = GenerateIndicatorName("ZigZag Indicator Value Overlay");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    
    SetIndexStyle(0, DRAW_LINE);
    SetIndexBuffer(0, Zig);
    SetIndexLabel(0, "ZZ_down");
    SetIndexStyle(1, DRAW_LINE);
    SetIndexBuffer(1, Zag);
    SetIndexLabel(1, "ZZ_up");
        
    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

int start()
{

   int i;
   double zt, zb, value,price_lbl;
   
   for (i=0;i<HistoryLimit;i++)
   {
      zt=zb=0;
      zt = iCustom(NULL,0,"ZigZag-Integer",12,5,3,500,false,1,i);
      zb = iCustom(NULL,0,"ZigZag-Integer",12,5,3,500,false,0,i);
      
      if (zt>0)
      {
         Zag[i] = zt;
      }
      if (zb>0)
      {
         Zig[i] = zb;
      }
      
   }
   
   for (i=0;i<HistoryLimit;i++)
   {
      if ((Zag[i]!=EMPTY_VALUE && Zag[i-1]==EMPTY_VALUE)||(Zig[i]!=EMPTY_VALUE && Zig[i-1]==EMPTY_VALUE))
      {
      
         if (Indicator_Value==1)
         {
            value = iStochastic(NULL,0,stoch_k,stoch_d,stoch_slowing,MODE_SMA,0,MODE_MAIN,i);
         }
         if (Indicator_Value==2)
         {
            value = iRSI(NULL,0,RSI_periods,PRICE_CLOSE,i);
         }
         if (Indicator_Value==3)
         {
            value = iCCI(NULL,0,CCI_periods,PRICE_TYPICAL,i);
         }
         if (Indicator_Value==4)
         {
            value = iWPR(NULL,0,WPR_periods,i);
         }
         if (Indicator_Value==5)
         {
            value = iMACD(NULL,0,MACD_fast_ema_period,MACD_slow_ema_period,MACD_signal_period,PRICE_CLOSE,MODE_MAIN,i);
         }
         if (Indicator_Value==6)
         {
            value = iADX(NULL,0,ADX_periods,PRICE_CLOSE,MODE_MAIN,i);
         }
         if (Indicator_Value==7)
         {
            value = iMA(NULL,0,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price),i);
         }
         
         if (Zag[i]!=EMPTY_VALUE && Zag[i-1]==EMPTY_VALUE)
         {
            price_lbl = Zag[i]+(5*pipSize);
         }
         if (Zig[i]!=EMPTY_VALUE && Zig[i-1]==EMPTY_VALUE)
         {
            price_lbl = Zig[i]-(5*pipSize);
         }
         
         CreateLabel(indi_name+i, Time[i], price_lbl, value, clrDarkGray, 10);   
         
      }
      
   }
   
   return(0);

}

void CreateLabel(string name, datetime time, double price, string text, color col, int fontSize)
{
    ObjectCreate(0, IndicatorObjPrefix + name, OBJ_TEXT, 0, time, price);
    ObjectSetString(0, IndicatorObjPrefix + name, OBJPROP_TEXT, text); 
    ObjectSetString(0, IndicatorObjPrefix + name, OBJPROP_FONT, "Arial"); 
    ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_FONTSIZE, fontSize); 
    ObjectSetInteger(0, IndicatorObjPrefix + name, OBJPROP_COLOR, col); 
}

