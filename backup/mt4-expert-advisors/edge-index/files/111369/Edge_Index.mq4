// Id: 17780
//+------------------------------------------------------------------+
//|                                                   Edge_Index.mq4 |
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

#property indicator_buffers 8
#property indicator_separate_window
#property indicator_levelcolor clrDimGray
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_SOLID

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

input  e_method Fast_MA_Method   = EMA;
input  e_price  Fast_MA_Price    = CLOSE;
extern int      Fast_MA_Period   = 8;
input  e_method Medium_MA_Method = EMA;
input  e_price  Medium_MA_Price  = CLOSE;
extern int      Medium_MA_Period = 21;
input  e_method Slow_MA_Method   = EMA;
input  e_price  Slow_MA_Price    = CLOSE;
extern int      Slow_MA_Period   = 55;
extern color    AUD_Color        = clrDodgerBlue;
extern color    CAD_Color        = clrDimGray;
extern color    CHF_Color        = clrYellow;
extern color    EUR_Color        = clrOrange;
extern color    GBP_Color        = clrLime;
extern color    JPY_Color        = clrAqua;
extern color    NZD_Color        = clrBlue;
extern color    USD_Color        = clrRed;
extern int      Limit_Bars       = 200;

string Pairs = "AUDCAD,AUDNZD,EURAUD,GBPAUD,AUDUSD,AUDCHF,AUDJPY,EURNZD,GBPNZD,NZDUSD,NZDCAD,NZDCHF,NZDJPY,EURGBP,EURUSD,EURCAD,EURCHF,EURJPY,GBPUSD,GBPCAD,GBPCHF,GBPJPY,USDCAD,USDCHF,USDJPY,CADCHF,CADJPY,CHFJPY";

double AUD[];
double CAD[];
double CHF[];
double EUR[];
double GBP[];
double JPY[];
double NZD[];
double USD[];

string Sym_arr[]; // Market_Watch symbols
int Sym_count; // Number of symbols

datetime Last_Update;

int init(){
   
       double temp = iCustom(NULL, 0, "ROC_with_Signal_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ROC_with_Signal_MA' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("Edge Index");
   
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1,AUD_Color);
   SetIndexBuffer(0,AUD);
   SetIndexLabel(0,"AUD");
   
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1,CAD_Color);
   SetIndexBuffer(1,CAD);
   SetIndexLabel(1,"CAD");
   
   SetIndexStyle(2,DRAW_LINE,STYLE_SOLID,1,CHF_Color);
   SetIndexBuffer(2,CHF);
   SetIndexLabel(2,"CHF");
   
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,1,EUR_Color);
   SetIndexBuffer(3,EUR);
   SetIndexLabel(3,"EUR");
   
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,1,GBP_Color);
   SetIndexBuffer(4,GBP);
   SetIndexLabel(4,"GBP");
   
   SetIndexStyle(5,DRAW_LINE,STYLE_SOLID,1,JPY_Color);
   SetIndexBuffer(5,JPY);
   SetIndexLabel(5,"JPY");
   
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,1,NZD_Color);
   SetIndexBuffer(6,NZD);
   SetIndexLabel(6,"NZD");
   
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,1,USD_Color);
   SetIndexBuffer(7,USD);
   SetIndexLabel(7,"USD");
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i, j;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   if (Limit_Bars) limit = Limit_Bars;
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double F, M, S, R, RS;
   double pair1, pair2;
   double sum_aud, sum_cad, sum_chf, sum_eur, sum_gbp, sum_jpy, sum_nzd, sum_usd;
   string First_Symbol, Second_Symbol;
   
   if (Time[0] > Last_Update){
   
      for (i=limit; i>=0; i--){
         
         sum_aud = sum_cad = sum_chf = sum_eur = sum_gbp = sum_jpy = sum_nzd = sum_usd = 0;
         
         for (j=0; j < Sym_count; j++) {
            
            pair1 = pair2 = 0;
            
            F  = iMA(Sym_arr[j],0,Fast_MA_Period,0,ENUM_MA_METHOD(Fast_MA_Method),ENUM_APPLIED_PRICE(Fast_MA_Price),i);
            M  = iMA(Sym_arr[j],0,Medium_MA_Period,0,ENUM_MA_METHOD(Medium_MA_Method),ENUM_APPLIED_PRICE(Medium_MA_Price),i);
            S  = iMA(Sym_arr[j],0,Slow_MA_Period,0,ENUM_MA_METHOD(Slow_MA_Method),ENUM_APPLIED_PRICE(Slow_MA_Price),i);
            R  = iCustom(Sym_arr[j],0,"ROC_with_Signal_MA",8,2,8,0,i);
            RS = iCustom(Sym_arr[j],0,"ROC_with_Signal_MA",8,2,8,1,i);
            
            if (F > M && M > S){ pair1+=3; pair2-=3; }
            if (F < M && M > S){ pair1+=2; pair2-=1; }
            if (F < M && M < S){ pair1-=3; pair2+=3; }
            if (F > M && M < S){ pair1-=1; pair2+=2; }
            
            if (R > RS && RS > 0){ pair1+=3; pair2-=3; }
            if (R < RS && RS > 0){ pair1+=2; pair2-=1; }
            if (R < RS && RS < 0){ pair1-=3; pair2+=3; }
            if (R > RS && RS < 0){ pair1-=1; pair2+=2; }
            
            First_Symbol  = StringSubstr(Sym_arr[j],0,3);
            Second_Symbol = StringSubstr(Sym_arr[j],3,3);
            
            if (First_Symbol=="AUD") sum_aud+=pair1;
            if (First_Symbol=="CAD") sum_cad+=pair1;
            if (First_Symbol=="CHF") sum_chf+=pair1;
            if (First_Symbol=="EUR") sum_eur+=pair1;
            if (First_Symbol=="GBP") sum_gbp+=pair1;
            if (First_Symbol=="JPY") sum_jpy+=pair1;
            if (First_Symbol=="NZD") sum_nzd+=pair1;
            if (First_Symbol=="USD") sum_usd+=pair1;
            
            if (Second_Symbol=="AUD") sum_aud+=pair2;
            if (Second_Symbol=="CAD") sum_cad+=pair2;
            if (Second_Symbol=="CHF") sum_chf+=pair2;
            if (Second_Symbol=="EUR") sum_eur+=pair2;
            if (Second_Symbol=="GBP") sum_gbp+=pair2;
            if (Second_Symbol=="JPY") sum_jpy+=pair2;
            if (Second_Symbol=="NZD") sum_nzd+=pair2;
            if (Second_Symbol=="USD") sum_usd+=pair2;
         
         }
         
         AUD[i] = sum_aud;
         CAD[i] = sum_cad;
         CHF[i] = sum_chf;
         EUR[i] = sum_eur;
         GBP[i] = sum_gbp;
         JPY[i] = sum_jpy;
         NZD[i] = sum_nzd;
         USD[i] = sum_usd;
      
      }
      
      Last_Update = TimeCurrent();
      
   }
   
//----
   return(0);
}
  
// Split array
void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (int i=0; i < len;) {
    pos = StringFind(str, sym, i);
    if (pos == -1) pos = len;
    
    item = StringSubstr(str, i, pos-i);
    item = StringTrimLeft(item);
    item = StringTrimRight(item);
    
    size = ArraySize(arr);
    ArrayResize(arr, size+1);
    arr[size] = item;
    
    i = pos+1;
  }
}