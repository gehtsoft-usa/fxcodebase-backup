// Id: 17514
//+------------------------------------------------------------------+
//|                                       MCP_Since_Last_Fractal.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
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

extern string   Comment1         = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs            = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP";
extern color    Labels_Color     = clrWhite;
extern color    Up_Fractal_Color = clrLime;
extern color    Dn_Fractal_Color = clrRed;
extern int      X_Position       = 0;

int      i, j;
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
   
       double temp = iCustom(NULL, 0, "Since_Last_Fractal", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Since_Last_Fractal' indicator");
       return INIT_FAILED;
   }
   WindowName = "MCP_Since_Last_Fractal";
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
   
   WindowNumber = WindowFind(WindowName);
   
   int Pair_y = 20;
   
   split(Sym_arr, Pairs, ",");
   Sym_count = ArraySize(Sym_arr);
   
   int  TFs, Ups, Dns;
   string Ups_arrow, Dns_arrow;
   
   for (i=0; i < Sym_count; i++) {
   
      TFs = 0;
      Ups = 0;
      Dns = 0;
      
      Ups_arrow = "";
      Dns_arrow = "";
      
      Ups = iCustom(Sym_arr[i],0,"Since_Last_Fractal",Sym_arr[i],0,0);
      Dns = iCustom(Sym_arr[i],0,"Since_Last_Fractal",Sym_arr[i],1,0);
      
      
      
      for (j=Ups; j>0; j--) Ups_arrow = Ups_arrow+"n";
      for (j=Dns; j>0; j--) Dns_arrow = Dns_arrow+"n";
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", X_Position-80, Pair_y, Sym_arr[i], Labels_Color, 0, WindowNumber, "Arial", 12 );
      ObjectMakeLabel(Sym_arr[i]+"_Up", X_Position, Pair_y-6, Ups_arrow, Up_Fractal_Color, 0, WindowNumber, "Wingdings", 11 );
      ObjectMakeLabel(Sym_arr[i]+"_Dn", X_Position, Pair_y+6, Dns_arrow, Dn_Fractal_Color, 0, WindowNumber, "Wingdings", 11 );
      ObjectMakeLabel(Sym_arr[i]+"_Up_Lbl", X_Position+(11*Ups)+2, Pair_y-6, Ups, Labels_Color, 0, WindowNumber, "Arial", 9 );
      ObjectMakeLabel(Sym_arr[i]+"_Dn_Lbl", X_Position+(11*Dns)+2, Pair_y+6, Dns, Labels_Color, 0, WindowNumber, "Arial", 9 );
      
      Pair_y = Pair_y+30;
      
   }
   
//----
   return(0);
}

void ObjectMakeLabel( string nm, int xoff, int yoff, string LabelTexto, color LabelColor, int LabelCorner=1, int Window = 0, string Font = "Arial", int FSize = 8 ){   
   ObjectDelete(IndicatorObjPrefix+ nm);
   ObjectCreate(IndicatorObjPrefix+  nm, OBJ_LABEL, Window, 0, 0 );
   ObjectSet(IndicatorObjPrefix+  nm, OBJPROP_CORNER, LabelCorner );
   ObjectSet(IndicatorObjPrefix+  nm, OBJPROP_XDISTANCE, xoff );
   ObjectSet(IndicatorObjPrefix+  nm, OBJPROP_YDISTANCE, yoff );
   ObjectSet(IndicatorObjPrefix+  nm, OBJPROP_BACK, false );
   ObjectSetText(IndicatorObjPrefix+  nm, LabelTexto, FSize, Font, LabelColor );
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