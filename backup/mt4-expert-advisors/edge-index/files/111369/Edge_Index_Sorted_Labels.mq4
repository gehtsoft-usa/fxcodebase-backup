// Id: 17781
//+------------------------------------------------------------------+
//|                                     Edge_Index_Sorted_Labels.mq4 |
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

#property indicator_chart_window

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

string Pairs = "AUDCAD,AUDNZD,EURAUD,GBPAUD,AUDUSD,AUDCHF,AUDJPY,EURNZD,GBPNZD,NZDUSD,NZDCAD,NZDCHF,NZDJPY,EURGBP,EURUSD,EURCAD,EURCHF,EURJPY,GBPUSD,GBPCAD,GBPCHF,GBPJPY,USDCAD,USDCHF,USDJPY,CADCHF,CADJPY,CHFJPY";

double AUD;
double CAD;
double CHF;
double EUR;
double GBP;
double JPY;
double NZD;
double USD;

string Sym_arr[]; // Market_Watch symbols
int Sym_count; // Number of symbols
double Sym_sum[];
color  Sym_color[];

datetime Last_Update;
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


int init(){
   
       double temp = iCustom(NULL, 0, "ROC_with_Signal_MA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'ROC_with_Signal_MA' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("Edge Index Labels");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   
   return(0);
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}
int start()
  {
   
   int i, j;
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double F, M, S, R, RS;
   double pair1, pair2;
   double sum_aud, sum_cad, sum_chf, sum_eur, sum_gbp, sum_jpy, sum_nzd, sum_usd;
   string First_Symbol, Second_Symbol;
         
   i=0;
   
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
   
   AUD = Sym_sum[0] = sum_aud;
   CAD = Sym_sum[1] = sum_cad;
   CHF = Sym_sum[2] = sum_chf;
   EUR = Sym_sum[3] = sum_eur;
   GBP = Sym_sum[4] = sum_gbp;
   JPY = Sym_sum[5] = sum_jpy;
   NZD = Sym_sum[6] = sum_nzd;
   USD = Sym_sum[7] = sum_usd;
   
   Sym_color[0] = clrGreen;
   Sym_color[1] = clrLime;
   Sym_color[2] = clrGreenYellow;
   Sym_color[3] = clrYellowGreen;
   Sym_color[4] = clrYellow;
   Sym_color[5] = clrOrange;
   Sym_color[6] = clrOrangeRed;
   Sym_color[7] = clrRed;
   
   ArrayResize(Sym_sum,8);
   ArrayResize(Sym_color,8);
   
   string Sorted_Pair;
   int y_pos=10;
   
   ArraySort(Sym_sum,WHOLE_ARRAY,0,MODE_DESCEND);
   for (j=0; j < 8; j++) {
      if (Sym_sum[j]==sum_aud) Sorted_Pair = "AUD";
      if (Sym_sum[j]==sum_cad) Sorted_Pair = "CAD";
      if (Sym_sum[j]==sum_chf) Sorted_Pair = "CHF";
      if (Sym_sum[j]==sum_eur) Sorted_Pair = "EUR";
      if (Sym_sum[j]==sum_gbp) Sorted_Pair = "GBP";
      if (Sym_sum[j]==sum_jpy) Sorted_Pair = "JPY";
      if (Sym_sum[j]==sum_nzd) Sorted_Pair = "NZD";
      if (Sym_sum[j]==sum_usd) Sorted_Pair = "USD";
      ObjectMakeLabel(IndicatorObjPrefix + "Sorted_Pair_"+j, 50, y_pos, Sorted_Pair+" "+DoubleToStr(Sym_sum[j],0), Sym_color[j], 1, 0, "Arial", 12 );
      y_pos+=20;
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

// Etiquetas del Box
void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(nm);
   ObjectCreate( nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet( nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet( nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet( nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet( nm, OBJPROP_BACK, false );
   ObjectSetText( nm, LabelTexto, FSize, Font, LabelColor );
   return;
}