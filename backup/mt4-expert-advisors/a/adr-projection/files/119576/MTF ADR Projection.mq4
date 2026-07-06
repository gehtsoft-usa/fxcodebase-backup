// Id: 21553
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=66195
// Id: 

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

string IndicatorName = "ADR Projection";

#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Green

double DR[];

enum ADRType
{
    ADR,
    ATR
};

extern int N = 14; // ADR poss
extern ADRType Type = ADR; // Projection Type
extern bool SHOW = true; // Show Projection
extern bool Label = true; // Show Label
extern color    Labels_Color             = clrWhite;
extern ENUM_TIMEFRAMES TF = PERIOD_CURRENT;
int M;
int D;

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
    if (Digits == 5)
    {
        M = 10000;
        D = 4;
    }
    else
    {
        M = 100;
        D = 2;
    }
    IndicatorName = GenerateIndicatorName(IndicatorName);
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);
    IndicatorDigits(Digits);
    SetIndexStyle(0, DRAW_NONE);
    SetIndexBuffer(0, DR);
    
    return(0);
}

int deinit()
{
    ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
    return(0);
}

int start()
{
    if (iBars(_Symbol, TF) <= 1) return(0);
    int pos = iBars(_Symbol, TF) - 1;
    while (pos >= 0)
    {
        if (Type == ADR)
            DR[pos] = iHigh(_Symbol, TF, pos) - iLow(_Symbol, TF, pos);
        else
            DR[pos] = TrueRange(pos);
        pos--;
    }
    double adr = iMAOnArray(DR, 0, N, 0, MODE_SMA, 0);
    double adr_prev = iMAOnArray(DR, 0, N, 0, MODE_SMA, 1);
    double MAX = iLow(_Symbol, TF, 0) + adr;
    double MIN = iHigh(_Symbol, TF, 0) - adr;
    if (Label)
    {
        if (Type == ADR)
        {
            if (DR[0] > DR[1])
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
                    "DR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
            }
            else if (DR[0] < DR[1])
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
                    "DR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
            }
            else
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5, 
                    "DR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
            }

            if (adr > adr_prev)
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ADR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
            }
            else if (adr < adr_prev)
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ADR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
            }
            else
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ADR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
            }

            ObjectMakeLabel("Label_3", Time[3], MAX,
                "ADR Projections Up " + DoubleToString(MAX, D), Labels_Color);
            ObjectMakeLabel("Label_4", Time[3], MIN,
                "ADR Projections Down " + DoubleToString(MIN, D), Labels_Color);
        }
        else
        {
            if (DR[0] > DR[1])
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
                    "TR " + DoubleToString(DR[0] * M, 0) + " (+)", Labels_Color);
            }
            else if (DR[0] < DR[1])
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
                    "TR " + DoubleToString(DR[0] * M, 0) + " (-)", Labels_Color);
            }
            else
            {
                ObjectMakeLabel("Label_1", Time[3], MAX + 2 * (MAX - MIN) / 5,
                    "TR " + DoubleToString(DR[0] * M, 0) + " (0)", Labels_Color);
            }

            if (adr > adr_prev)
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ATR " + DoubleToString(adr * M, 0) + " (+)", Labels_Color);
            }
            else if (adr < adr_prev)
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ATR " + DoubleToString(adr * M, 0) + " (-)", Labels_Color);
            }
            else
            {
                ObjectMakeLabel("Label_2", Time[3], MAX + (MAX - MIN) / 5,
                    "ATR " + DoubleToString(adr * M, 0) + " (0)", Labels_Color);
            }

            ObjectMakeLabel("Label_3", Time[3], MAX,
                "ATR Projections Up " + DoubleToString(MAX, D), Labels_Color);
            ObjectMakeLabel("Label_4", Time[3], MIN,
                "ATR Projections Down " + DoubleToString(MIN, D), Labels_Color);
        }
    }
    if (SHOW)
    {
        ObjectDelete(IndicatorObjPrefix + "Line_1");
        ObjectCreate(IndicatorObjPrefix + "Line_1", OBJ_TREND, 0, Time[N], MAX, Time[3], MAX);
        ObjectDelete(IndicatorObjPrefix + "Line_2");
        ObjectCreate(IndicatorObjPrefix + "Line_2", OBJ_TREND, 0, Time[N], MIN, Time[3], MIN);
    }
    return(0);
}

double TrueRange(const int p)
{
    double hl = MathAbs(iHigh(_Symbol, TF, p) - iLow(_Symbol, TF, p));
    double hc = MathAbs(iHigh(_Symbol, TF, p) - iClose(_Symbol, TF, p + 1));
    double lc = MathAbs(iLow(_Symbol, TF, p) - iClose(_Symbol, TF, p + 1));

    double tr = hl;
    if (tr < hc)
        tr = hc;
    if (tr < lc)
        tr = lc;
    return tr;
}

void ObjectMakeLabel(string nm, datetime date, double price, string LabelTexto, color labelColor, int LabelCorner = 1, int Window = 0, string Font = "Arial", int FSize = 12)
{
    ObjectDelete(IndicatorObjPrefix + nm);
    ObjectCreate(IndicatorObjPrefix + nm, OBJ_TEXT, 0, date, price);
    ObjectSetString(0, IndicatorObjPrefix + nm, OBJPROP_TEXT, LabelTexto); 
    ObjectSet(IndicatorObjPrefix + nm, OBJPROP_BACK, false);
    ObjectSetText(IndicatorObjPrefix + nm, LabelTexto, FSize, Font, labelColor);
}