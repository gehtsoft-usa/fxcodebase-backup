//More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=61628

//+------------------------------------------------------------------+
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
#property indicator_buffers 1
#property indicator_color1 Yellow
#property indicator_separate_window

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
extern string TypeStr="Type: 1 - One, 2 - Two";
extern int Type=1; // 1 - One, 2 - Two
extern int One_Percentage=10;
extern int Two_Percentage=90;

double PPF[];
string Sym_arr[]; // Pairs symbols
int    Sym_count; // Number of symbols
string _windowName = "Percentage Price Follower";
int      WindowNumber;

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
        double temp = iCustom(NULL, 0, "Percentage_Price_Follower", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'Percentage_Price_Follower' indicator");
       return INIT_FAILED;
   }
   IndicatorName = GenerateIndicatorName(_windowName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);
    SetIndexStyle(0,DRAW_LINE);
    SetIndexBuffer(0,PPF);

    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

int start()
{
    WindowNumber = WindowFind(IndicatorName);
   
    int Pair_y = 50;
    int TF_x   =  1000;
    int Original_x = TF_x;

    if (Include_M5)
    {
        int M5_x  = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("M5_Label", M5_x, 20, "M5", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_M15)
    {
        int M15_x = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("M15_Label", M15_x, 20, "M15", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_M30)
    {
        int M30_x = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("M30_Label", M30_x, 20, "M30", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_H1)
    {
        int H1_x  = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("H1_Label", H1_x, 20, "H1", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_H4)
    {
        int H4_x  = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("H4_Label", H4_x, 20, "H4", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_D1)
    {
        int D1_x  = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("D1_Label", D1_x, 20, "D1", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_W1)
    {
        int W1_x  = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("W1_Label", W1_x, 20, "W1", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }
    if (Include_MN1)
    {
        int MN1_x = TF_x;
        TF_x = TF_x-120;
        ObjectMakeLabel("MN1_Label", MN1_x, 20, "MN1", Labels_Color, 1, WindowNumber, "Arial", 12 );
    }

    split(Sym_arr, Pairs, ",");
    Sym_count = ArraySize(Sym_arr);

    string arrow;
    color  diff_color;
    double rsi0, rsi1;

    for (int i=0; i < Sym_count; i++)
    {
        ObjectMakeLabel(Sym_arr[i]+"_Name", Original_x+80, Pair_y, Sym_arr[i], Labels_Color, 1, WindowNumber, "Arial", 12);
        if (Include_M5)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_M5,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_M5,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
              diff_color = Neutral_Color;
              arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_M5", M5_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_M5_label", M5_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_M15)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_M15,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_M15,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_M15", M15_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_M15_label", M15_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_M30)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_M30,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_M30,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_M30", M30_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_M30_label", M30_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_H1)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_H1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_H1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_H1", H1_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_H1_label", H1_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_H4)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_H4,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_H4,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_H4", H4_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_H4_label", H4_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_D1)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_D1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_D1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_D1", D1_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_D1_label", D1_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_W1)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_W1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_W1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_W1", W1_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_W1_label", W1_x-10, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }
        if (Include_MN1)
        {
            rsi0 = iCustom(Sym_arr[i],PERIOD_MN1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 0);
            rsi1 = iCustom(Sym_arr[i],PERIOD_MN1,"Percentage_Price_Follower", TypeStr, Type, One_Percentage, Two_Percentage, 0, 1);
            if (rsi0 > rsi1)
            {
                diff_color = Up_Color;
                arrow = "é";
            }
            else if (rsi0 < rsi1)
            {
                diff_color = Dn_Color;
                arrow = "ê";
            }
            else
            {
                diff_color = Neutral_Color;
                arrow = "û";
            }
            ObjectMakeLabel(Sym_arr[i]+"_MN1", MN1_x-30, Pair_y, arrow, diff_color, 1, WindowNumber, "Wingdings", 10 );
            ObjectMakeLabel(Sym_arr[i]+"_MN1_label", MN1_x-7, Pair_y, DoubleToStr(rsi0,2), diff_color, 1, WindowNumber, "Arial", 9 );
        }

        Pair_y = Pair_y+30;
    }
    return 0;
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