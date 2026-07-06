// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=64951

//+------------------------------------------------------------------+
//|                                              MTF_MCP_Scanner.mq4 |
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property indicator_separate_window

extern int      ADX_Period               = 14;
extern int      Stoch_K                  = 5;
extern int      Stoch_D                  = 3;
extern int      Stoch_Slowing            = 3;
extern double   Stoch_OB_Level           = 80;
extern double   Stoch_OS_Level           = 20;
extern int      StochRSI_RSI_Periods     = 14;
extern int      StochRSI_K               = 5;
extern int      StochRSI_D               = 3;
extern int      StochRSI_Slowing         = 3;
extern double   StochRSI_OB_Level        = 90;
extern double   StochRSI_OS_Level        = 10;
extern int      Williams_Percent_Periods = 14;
extern double   Williams_Percent_OB_Level= -20;
extern double   Williams_Percent_OS_Level= -80;
extern string   Comment1                 = "- Comma Separated Pairs - Ex: EURUSD,EURJPY,GBPUSD - ";
extern string   Pairs                    = "EURUSD,EURJPY,USDJPY,GBPUSD,GBPJPY,EURGBP,AUDUSD,NZDUSD";
extern bool     Include_M5               = true;
extern bool     Include_M15              = true;
extern bool     Include_M30              = true;
extern bool     Include_H1               = true;
extern bool     Include_H4               = true;
extern bool     Include_D1               = true;
extern bool     Include_W1               = true;
extern bool     Include_MN1              = true;
extern color    Labels_Color             = clrWhite;
extern color    Up_Color                 = clrLime;
extern color    Dn_Color                 = clrRed;
extern color    Neutral_Color            = clrDarkGray;

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
   
       double temp = iCustom(NULL, 0, "Stochastic_RSI_MTF_basic", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Stochastic_RSI_MTF_basic' indicator");
       return INIT_FAILED;
   }
   WindowName = "MTF_MCP_Scanner";
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
      
   string arrow;
   color  diff_color;
   
   double dmip, dmim, stochk, stochd, stochrsid, rlw;
   
   for (i=0; i < Sym_count; i++) {
   
      if (MarketInfo(Sym_arr[i],MODE_DIGITS)==3||MarketInfo(Sym_arr[i],MODE_DIGITS)==5)
         divisor = 10;
      else
         divisor = 1;
      
      ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+80, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12 );
      if (Include_M5){
         dmip = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M5,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_M5,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_M5,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_M5,"Stochastic_RSI_MTF_basic",5,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_M5,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M15){
         dmip = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M15,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_M15,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_M15,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_M15,"Stochastic_RSI_MTF_basic",15,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_M15,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_M30){
         dmip = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_M30,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_M30,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_M30,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_M30,"Stochastic_RSI_MTF_basic",30,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_M30,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H1){
         dmip = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_H1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_H1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_H1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_H1,"Stochastic_RSI_MTF_basic",60,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_H1,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_H4){
         dmip = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_H4,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_H4,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_H4,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_H4,"Stochastic_RSI_MTF_basic",240,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_H4,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_D1){
         dmip = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_D1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_D1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_D1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_D1,"Stochastic_RSI_MTF_basic",1440,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_D1,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_W1){
         dmip = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_W1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_W1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_W1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_W1,"Stochastic_RSI_MTF_basic",10080,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_W1,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
      }
      if (Include_MN1){
         dmip = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_PLUSDI,0);
         dmim = iADX(Sym_arr[i],PERIOD_MN1,ADX_Period,PRICE_CLOSE,MODE_MINUSDI,0);
         stochk = iStochastic(Sym_arr[i],PERIOD_MN1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_MAIN,0);
         stochd = iStochastic(Sym_arr[i],PERIOD_MN1,Stoch_K,Stoch_D,Stoch_Slowing,MODE_SMA,0,MODE_SIGNAL,0);
         stochrsid = iCustom(Sym_arr[i],PERIOD_MN1,"Stochastic_RSI_MTF_basic",43200,14,5,3,3,1,0);
         rlw = iWPR(Sym_arr[i],PERIOD_MN1,Williams_Percent_Periods,0);
         if (dmip > dmim && stochk > stochd && stochd < Stoch_OB_Level && stochrsid < StochRSI_OB_Level && rlw < Williams_Percent_OB_Level){
            diff_color = Up_Color;
            arrow = "é";
         }else if (dmim > dmip && stochk < stochd && stochd > Stoch_OS_Level && stochrsid > StochRSI_OS_Level && rlw > Williams_Percent_OS_Level){
            diff_color = Dn_Color;
            arrow = "ê";
         }else{
            diff_color = Neutral_Color;
            arrow = "û";
         }
         ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
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