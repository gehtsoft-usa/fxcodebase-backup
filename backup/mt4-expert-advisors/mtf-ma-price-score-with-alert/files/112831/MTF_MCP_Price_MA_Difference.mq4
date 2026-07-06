//+------------------------------------------------------------------+
//|                                  MTF_MCP_Price_MA_Difference.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_separate_window

enum e_method{ SMA=MODE_SMA, EMA=MODE_EMA, SMMA=MODE_SMMA, LWMA=MODE_LWMA };
enum e_price{ CLOSE=PRICE_CLOSE, OPEN=PRICE_OPEN, LOW=PRICE_LOW, HIGH=PRICE_HIGH, MEDIAN=PRICE_MEDIAN, TYPICAL=PRICE_TYPICAL, WEIGHTED=PRICE_WEIGHTED };

extern int      MA_Period              = 50;
extern e_method MA_Method              = EMA;
extern e_price  MA_Price_Type          = CLOSE;
extern string   Comment1               = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                  = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5             = true;
extern bool     Include_M15            = true;
extern bool     Include_M30            = true;
extern bool     Include_H1             = true;
extern bool     Include_H4             = true;
extern bool     Include_D1             = true;
extern bool     Include_W1             = true;
extern bool     Include_MN1            = true;
extern color    Labels_Color           = clrWhite;
extern color    Up_MA_Color            = clrLime;
extern color    Dn_MA_Color            = clrRed;

int      i;
string   WindowName;
int      WindowNumber;

string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols

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
   
   WindowName = "MTF_MCP_Price_MA_Difference";
	IndicatorName = GenerateIndicatorName(WindowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   return(0);
}

int deinit(){
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return(0);
}

int start()
  {
   
   WindowNumber = WindowFind(IndicatorName);
   
   int Pair_y = 50;
   int TF_x   =  1000;
   int Original_x = TF_x;
   
   if (Include_M5){
      int M5_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M15){
      int M15_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_M30){
      int M30_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H1){
      int H1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_H4){
      int H4_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_D1){
      int D1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_W1){
      int W1_x  = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   if (Include_MN1){
      int MN1_x = TF_x;
      TF_x = TF_x-120;
      ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
   }
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   double divisor;
      
   double pips;
   color  diff_color;
   
   for (i=0; i < Sym_count; i++) {
   
      if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5)
         divisor = 10;
      else
         divisor = 1;
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+80, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_M5,0) - iMA(Sym_arr[i],PERIOD_M5,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_M15){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_M15,0) - iMA(Sym_arr[i],PERIOD_M15,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_M30){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_M30,0) - iMA(Sym_arr[i],PERIOD_M30,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_H1){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_H1,0) - iMA(Sym_arr[i],PERIOD_H1,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_H4){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_H4,0) - iMA(Sym_arr[i],PERIOD_H4,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_D1){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_D1,0) - iMA(Sym_arr[i],PERIOD_D1,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_W1){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_W1,0) - iMA(Sym_arr[i],PERIOD_W1,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      if (Include_MN1){
         pips = NormalizeDouble(((1/MarketInfo(Sym_arr[i],MODE_POINT))*(iClose(Sym_arr[i],PERIOD_MN1,0) - iMA(Sym_arr[i],PERIOD_MN1,MA_Period,0,ENUM_MA_METHOD(MA_Method),ENUM_APPLIED_PRICE(MA_Price_Type),0)))/divisor,1);
         if (pips > 0) diff_color = Up_MA_Color; else diff_color = Dn_MA_Color;
         ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, pips+" pips", diff_color, 1, WindowNumber, "Arial", 10 );
      }
      
      Pair_y = Pair_y+30;
      
   }
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix + nm);
   ObjectCreate(IndicatorObjPrefix +  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix +  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix +  nm, LabelTexto, FSize, Font, LabelColor );
   return;
}

void split(string& arr[], string str, string sym) 
{
  ArrayResize(arr, 0);
  string item;
  int pos, size;
  
  int len = StringLen(str);
  for (i=0; i < len;) {
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