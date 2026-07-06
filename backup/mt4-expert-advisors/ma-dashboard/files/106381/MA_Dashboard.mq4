// Id: 16088
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

#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_chart_window

extern string  Comment0       = "- Methods: 0=SMA, 1=EMA, 2=SMMA, 3=LWMA -";
extern int     MA_Method      = 0;
extern string  Comment1       = "- Price: 0=Close 1=Open 2=High 3=Low 4=Median 5=Typical 6=Weighted -";
extern int     MA_Price       = 0;
extern int     MA_Period_Slow = 50;
extern int     MA_Period_Fast = 20;
extern string  Comment2       = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string  Pairs          = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

string    up_arrow = "5";
string    dn_arrow = "6";
color  up_color = clrLime;
color  dn_color = clrRed;

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

//+------------------------------------------------------------------+
int init()
   {
    IndicatorName = GenerateIndicatorName("#MA_Dashboard");
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
   
   ObjectMakeLabel("Pair_lb", 300, firstline, "Pair", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("M5_lb", 250, firstline, "M5", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("M15_lb", 220, firstline, "M15", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("M30_lb", 190, firstline, "M30", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("H1_lb", 160, firstline, "H1", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("H4_lb", 130, firstline, "H4", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("D1_lb", 100, firstline, "D1", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("W1_lb", 70, firstline, "W1", clrYellow, 1, 0, "Arial", 10 );
   ObjectMakeLabel("MN_lb", 40, firstline, "MN", clrYellow, 1, 0, "Arial", 10 );
   
   int breakline = firstline;
   
   double m5_slow, m15_slow, m30_slow, h1_slow, h4_slow, d1_slow, w1_slow, mn_slow;
   double m5_fast, m15_fast, m30_fast, h1_fast, h4_fast, d1_fast, w1_fast, mn_fast;
   
   string    m5_arrow, m15_arrow, m30_arrow, h1_arrow, h4_arrow, d1_arrow, w1_arrow, mn_arrow;
   color  m5_color, m15_color, m30_color, h1_color, h4_color, d1_color, w1_color, mn_color;
   
   for (int i=0; i < Sym_count; i++) {
      
      breakline = breakline+20;
      
      m5_slow = iMA(Sym_arr[i],PERIOD_M5,MA_Period_Slow,0,MA_Method,MA_Price,0);
      m5_fast = iMA(Sym_arr[i],PERIOD_M5,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (m5_fast > m5_slow){ m5_color = up_color; m5_arrow = up_arrow; }else{ m5_color = dn_color; m5_arrow = dn_arrow; }
      
      m15_slow = iMA(Sym_arr[i],PERIOD_M15,MA_Period_Slow,0,MA_Method,MA_Price,0);
      m15_fast = iMA(Sym_arr[i],PERIOD_M15,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (m15_fast > m15_slow){ m15_color = up_color; m15_arrow = up_arrow; }else{ m15_color = dn_color; m15_arrow = dn_arrow; }
      
      m30_slow = iMA(Sym_arr[i],PERIOD_M30,MA_Period_Slow,0,MA_Method,MA_Price,0);
      m30_fast = iMA(Sym_arr[i],PERIOD_M30,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (m30_fast > m30_slow){ m30_color = up_color; m30_arrow = up_arrow; }else{ m30_color = dn_color; m30_arrow = dn_arrow; }
      
      h1_slow = iMA(Sym_arr[i],PERIOD_H1,MA_Period_Slow,0,MA_Method,MA_Price,0);
      h1_fast = iMA(Sym_arr[i],PERIOD_H1,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (h1_fast > h1_slow){ h1_color = up_color; h1_arrow = up_arrow; }else{ h1_color = dn_color; h1_arrow = dn_arrow; }
      
      h4_slow = iMA(Sym_arr[i],PERIOD_H4,MA_Period_Slow,0,MA_Method,MA_Price,0);
      h4_fast = iMA(Sym_arr[i],PERIOD_H4,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (h4_fast > h4_slow){ h4_color = up_color; h4_arrow = up_arrow; }else{ h4_color = dn_color; h4_arrow = dn_arrow; }
      
      d1_slow = iMA(Sym_arr[i],PERIOD_D1,MA_Period_Slow,0,MA_Method,MA_Price,0);
      d1_fast = iMA(Sym_arr[i],PERIOD_D1,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (d1_fast > d1_slow){ d1_color = up_color; d1_arrow = up_arrow; }else{ d1_color = dn_color; d1_arrow = dn_arrow; }
      
      w1_slow = iMA(Sym_arr[i],PERIOD_W1,MA_Period_Slow,0,MA_Method,MA_Price,0);
      w1_fast = iMA(Sym_arr[i],PERIOD_W1,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (w1_fast > w1_slow){ w1_color = up_color; w1_arrow = up_arrow; }else{ w1_color = dn_color; w1_arrow = dn_arrow; }
      
      mn_slow = iMA(Sym_arr[i],PERIOD_MN1,MA_Period_Slow,0,MA_Method,MA_Price,0);
      mn_fast = iMA(Sym_arr[i],PERIOD_MN1,MA_Period_Fast,0,MA_Method,MA_Price,0);
      if (mn_fast > mn_slow){ mn_color = up_color; mn_arrow = up_arrow; }else{ mn_color = dn_color; mn_arrow = dn_arrow; }
      
      ObjectMakeLabel(Sym_arr[i]+"_lb", 300, breakline, Sym_arr[i], clrWhite, 1, 0, "Arial", 10 );
      ObjectMakeLabel(Sym_arr[i]+"_m5_lb", 250, breakline-5, m5_arrow, m5_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_m15_lb", 220, breakline-5, m15_arrow, m15_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_m30_lb", 190, breakline-5, m30_arrow, m30_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_h1_lb", 160, breakline-5, h1_arrow, h1_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_h4_lb", 130, breakline-5, h4_arrow, h4_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_d1_lb", 100, breakline-5, d1_arrow, d1_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_w1_lb", 70, breakline-5, w1_arrow, w1_color, 1, 0, "Webdings", 15 );
      ObjectMakeLabel(Sym_arr[i]+"_mn_lb", 40, breakline-5, mn_arrow, mn_color, 1, 0, "Webdings", 15 );
      
      
      //comentario+= Sym_arr[i] + ": " + iMA(Sym_arr[i],0,MA_Period_Slow,0,MA_Method,MA_Price,0) + " - " +iMA(Sym_arr[i],0,MA_Period_Fast,0,MA_Method,MA_Price,0) + "\n";
      
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



