// Id: 16123
// More information about this indicator can be found at:
// http://fxcodebase.com/

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

// Indicator analyze 3 simple MVA values (Short, Medium, Long)
// and displays dashboard for specified set of currency pairs and periods. The dashboard legenda is the following.
// - Red arrow displayed if ShortMVA < MediumMVA < LongMVA
// - Green arrow displayed if ShortMVA > MediumMVA > LongMVA
// The bell sign is displayed next to the arrow if current price is between Short and Medium MVAs.

#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window

extern string  Comment0         = "- Methods: 0=SMA 1=EMA 2=SMMA 3=LWMA 4=DEMA 5=TEMA -";
extern int     MA_Method        = 0;
extern string  Comment1         = "- Price: 0=Close 1=Open 2=High 3=Low 4=Median 5=Typical 6=Weighted -";
extern int     MA_Price         = 0;
extern int     MA_Period_Long   = 100;
extern int     MA_Period_Medium = 50;
extern int     MA_Period_Short  = 20;
extern string  Comment2         = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string  Pairs            = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

string up_arrow = "5"; // Webdings
string dn_arrow = "6"; // Webdings
string bell     = "%"; // Wingdings
color  up_color = clrLime;
color  dn_color = clrRed;
color  neutral_color = C'33,33,33';

int window;
string IndicatorName = "";
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
//+------------------------------------------------------------------+
int init()
   {
       double temp = iCustom(NULL, 0, "DEMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'DEMA' indicator");
       return INIT_FAILED;
   }
       
temp = iCustom(NULL, 0, "TEMA", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'TEMA' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName("MVA_Dashboard");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
   return(0);
  }
  
//+------------------------------------------------------------------+
int deinit()
   {
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
  }
  
//+------------------------------------------------------------------+
int start()
  {
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   int firstline = 20;
   int firstarrow = 650;
   
   int window = WindowFind(IndicatorName);
   
   ObjectMakeLabel("Pair_lb", 630, firstline, "Pair", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("M5_lb", 580, firstline, "M5", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("M15_lb", 510, firstline, "M15", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("M30_lb", 440, firstline, "M30", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("H1_lb", 370, firstline, "H1", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("H4_lb", 300, firstline, "H4", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("D1_lb", 230, firstline, "D1", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("W1_lb", 160, firstline, "W1", clrYellow, 1, window, "Arial", 10 );
   ObjectMakeLabel("MN_lb", 90, firstline, "MN", clrYellow, 1, window, "Arial", 10 );
   
   int breakline = firstline;
   int steparrow = firstarrow;
   
   double m5_long, m15_long, m30_long, h1_long, h4_long, d1_long, w1_long, mn_long;
   double m5_medium, m15_medium, m30_medium, h1_medium, h4_medium, d1_medium, w1_medium, mn_medium;
   double m5_short, m15_short, m30_short, h1_short, h4_short, d1_short, w1_short, mn_short;
   
   string m5_arrow, m15_arrow, m30_arrow, h1_arrow, h4_arrow, d1_arrow, w1_arrow, mn_arrow;
   string m5_bell, m15_bell, m30_bell, h1_bell, h4_bell, d1_bell, w1_bell, mn_bell;
   color  m5_color, m15_color, m30_color, h1_color, h4_color, d1_color, w1_color, mn_color;
   
   double temp_short, temp_medium, temp_long;
   string temp_arrow, temp_bell;
   color temp_color;
   
   int Periods[8] = {PERIOD_M5, PERIOD_M15, PERIOD_M30, PERIOD_H1, PERIOD_H4, PERIOD_D1, PERIOD_W1, PERIOD_MN1};
   string Period_Labels[8] = {"m5", "m15", "m30", "h1", "h4", "d1", "w1", "mn1"};
   
   string comentario = "";
   
   for (int i=0; i < Sym_count; i++) {
      
      breakline = breakline+20;
      steparrow = firstarrow;
      
      ObjectMakeLabel(Sym_arr[i]+"_lb", 630, breakline, Sym_arr[i], clrWhite, 1, window, "Arial", 10 );
      
      for (int j=0; j < ArraySize(Periods); j++){
         
         steparrow = steparrow-70;
         
         if (MA_Method==4){
         temp_long = iCustom(Sym_arr[i],Periods[j],"DEMA",MA_Period_Long,0,0);
         temp_medium = iCustom(Sym_arr[i],Periods[j],"DEMA",MA_Period_Medium,0,0);
         temp_short = iCustom(Sym_arr[i],Periods[j],"DEMA",MA_Period_Short,0,0);
         }
         else if (MA_Method==5){
            temp_long = iCustom(Sym_arr[i],Periods[j],"TEMA",MA_Period_Long,0,0);
            temp_medium = iCustom(Sym_arr[i],Periods[j],"TEMA",MA_Period_Medium,0,0);
            temp_short = iCustom(Sym_arr[i],Periods[j],"TEMA",MA_Period_Short,0,0);
         }
         else{
            temp_long = iMA(Sym_arr[i],Periods[j],MA_Period_Long,0,MA_Method,MA_Price,0);
            temp_medium = iMA(Sym_arr[i],Periods[j],MA_Period_Medium,0,MA_Method,MA_Price,0);
            temp_short = iMA(Sym_arr[i],Periods[j],MA_Period_Short,0,MA_Method,MA_Price,0);
         }
         
         if (temp_short < temp_medium && temp_medium < temp_long){
            temp_color = dn_color; temp_arrow = dn_arrow;
            if (iClose(Sym_arr[i],Periods[j],0) > temp_short && iClose(Sym_arr[i],Periods[j],0) < temp_medium) temp_bell = bell; else temp_bell = "";
         }
         else if (temp_short > temp_medium && temp_medium > temp_long){
            temp_color = up_color; temp_arrow = up_arrow;
            if (iClose(Sym_arr[i],Periods[j],0) < temp_short && iClose(Sym_arr[i],Periods[j],0) > temp_medium) temp_bell = bell; else temp_bell = "";
         }
         else{
            temp_color = neutral_color; temp_arrow = "r"; temp_bell = "";
         }
         ObjectMakeLabel(Sym_arr[i]+"_"+Period_Labels[j]+"_arrow", steparrow, breakline-5, temp_arrow, temp_color, 1, window, "Webdings", 15 );
         ObjectMakeLabel(Sym_arr[i]+"_"+Period_Labels[j]+"_bell", steparrow-15, breakline-2, temp_bell, temp_color, 1, window, "Wingdings", 13 );

      }
      
   }
   
   return(0);
  }
//+------------------------------------------------------------------+

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

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
}
