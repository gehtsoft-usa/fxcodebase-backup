//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=75161

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

#property indicator_separate_window
#property indicator_maximum 200
#property indicator_minimum 0
#property indicator_buffers 6
#property indicator_color1 DarkGreen
#property indicator_color2 DarkGreen
#property indicator_color3 Maroon
#property indicator_color4 Maroon
#property indicator_color5 DarkSlateGray
#property indicator_color6 DarkSlateGray
#property indicator_levelstyle 0;
#property indicator_level1 150
#property indicator_level2 50
#property indicator_levelcolor 2631703


double arrowUp[];
double arrowDn[];

enum St { Orig, Hi, Lo };
enum Ma { Off, mHi, mLo };



input double   ratio_prise = 50;
input St       st_method   = Hi;
input Ma       ma_method   = mHi;
int            w55         = 55;
int            w20         = 20;
int            w10         = 10;
int            Slowing     = 1;
int            s55         = 44;
int            s20         = 16;
int            s10         = 8;
int            ma_period_1 = 7;
ENUM_MA_METHOD ma_method_1 = MODE_EMA;
int            ma_period_2 = 9;
ENUM_MA_METHOD ma_method_2 = MODE_SMA;
int            ma_period_3 = 12;
ENUM_MA_METHOD ma_method_3 = MODE_LWMA;

int    i, k, j, mpr1_20, mpr2_20, mpr3_20, mpr1_55, mpr2_55, mpr3_55;
double price, min, max, sumlow, sumhigh, ratio_p;

double B0[], B1[], B2[], B3[], B4[], B5[], Bpu[], Buh[], Bul[], Bpd[], Bdh[], Bdl[], Bsu55[], Bsd55[], Bsu20[], Bsd20[], Bsu10[], Bsd10[], Bl[], Bh[], Bmu55[], Bmu20[], Bmu10[], Bmd10[], Bmd20[],
    Bmd55[], Bhu55[], Bhu20[], Bhu10[], Bhd10[], Bhd20[], Bhd55[], Blu55[], Blu20[], Blu10[], Bld10[], Bld20[], Bld55[], Bmeu55[], Bmed55[], Bmeu20[], Bmed20[], Bmeu10[], Bmed10[], Bmeu55n[],
    Bmed55n[], Bmeu20n[], Bmed20n[], Bmeu10n[], Bmed10n[], Bmsu55[], Bmsd55[], Bmsu20[], Bmsd20[], Bmsu10[], Bmsd10[], Bmsu55n[], Bmsd55n[], Bmsu20n[], Bmsd20n[], Bmsu10n[], Bmsd10n[], Bmlu55[],
    Bmld55[], Bmlu20[], Bmld20[], Bmlu10[], Bmld10[], Bmlu55n[], Bmld55n[], Bmlu20n[], Bmld20n[], Bmlu10n[], Bmld10n[], B0m[], B1m[], B2m[], B3m[], B4m[], B5m[];



input string       T1                    = "== Notifications ==";  // ————————————
input bool         notifications         = false;                  // Notifications On?
input bool         desktop_notifications = false;                  // Desktop MT4 Notifications
input bool         email_notifications   = false;                  // Email Notifications
input bool         push_notifications    = false;                  // Push Mobile Notifications

class CNewCandle
{
 private:
  int    _initialCandles;
  string _symbol;
  int    _tf;

 public:
  CNewCandle(string symbol, int tf) : _symbol(symbol), _tf(tf), _initialCandles(iBars(symbol, tf)) {}
  CNewCandle()
  {
    // toma los valores del chart actual
    _initialCandles = iBars(Symbol(), Period());
    _symbol         = Symbol();
    _tf             = Period();
  }
  ~CNewCandle() { ; }

  bool IsNewCandle()
  {
    int _currentCandles = iBars(_symbol, _tf);
    if (_currentCandles > _initialCandles)
    {
      _initialCandles = _currentCandles;
      return true;
    }

    return false;
  }
};
CNewCandle newCandle();

int init()
{
    IndicatorBuffers(118);
    SetIndexBuffer(0, B0);
    SetIndexBuffer(1, B1);
    SetIndexBuffer(2, B2);
    SetIndexBuffer(3, B3);
    SetIndexBuffer(4, B4);
    SetIndexBuffer(5, B5);
    SetIndexBuffer(10, Bpu);
    SetIndexBuffer(11, Bpd);

    SetIndexBuffer(12, Buh);
    SetIndexBuffer(13, Bul);
    SetIndexBuffer(14, Bdh);
    SetIndexBuffer(15, Bdl);

    SetIndexBuffer(20, Bsu55);
    SetIndexBuffer(21, Bsd55);
    SetIndexBuffer(22, Bsu20);
    SetIndexBuffer(23, Bsd20);
    SetIndexBuffer(24, Bsu10);
    SetIndexBuffer(25, Bsd10);
    SetIndexBuffer(26, Bl);
    SetIndexBuffer(27, Bh);

    SetIndexBuffer(28, Bmu55);
    SetIndexBuffer(29, Bmu20);
    SetIndexBuffer(30, Bmu10);
    SetIndexBuffer(31, Bmd10);
    SetIndexBuffer(32, Bmd20);
    SetIndexBuffer(33, Bmd55);

    SetIndexBuffer(34, Bhu55);
    SetIndexBuffer(35, Bhu20);
    SetIndexBuffer(36, Bhu10);
    SetIndexBuffer(37, Bhd10);
    SetIndexBuffer(38, Bhd20);
    SetIndexBuffer(39, Bhd55);

    SetIndexBuffer(40, Blu55);
    SetIndexBuffer(41, Blu20);
    SetIndexBuffer(42, Blu10);
    SetIndexBuffer(43, Bld10);
    SetIndexBuffer(44, Bld20);
    SetIndexBuffer(45, Bld55);

    SetIndexBuffer(50, Bmeu55);
    SetIndexBuffer(51, Bmed55);
    SetIndexBuffer(52, Bmeu20);
    SetIndexBuffer(53, Bmed20);
    SetIndexBuffer(54, Bmeu10);
    SetIndexBuffer(55, Bmed10);

    SetIndexBuffer(60, Bmsu55);
    SetIndexBuffer(61, Bmsd55);
    SetIndexBuffer(62, Bmsu20);
    SetIndexBuffer(63, Bmsd20);
    SetIndexBuffer(64, Bmsu10);
    SetIndexBuffer(65, Bmsd10);

    SetIndexBuffer(70, Bmlu55);
    SetIndexBuffer(71, Bmld55);
    SetIndexBuffer(72, Bmlu20);
    SetIndexBuffer(73, Bmld20);
    SetIndexBuffer(74, Bmlu10);
    SetIndexBuffer(75, Bmld10);

    SetIndexBuffer(80, Bmeu55n);
    SetIndexBuffer(81, Bmed55n);
    SetIndexBuffer(82, Bmeu20n);
    SetIndexBuffer(83, Bmed20n);
    SetIndexBuffer(84, Bmeu10n);
    SetIndexBuffer(85, Bmed10n);

    SetIndexBuffer(90, Bmsu55n);
    SetIndexBuffer(91, Bmsd55n);
    SetIndexBuffer(92, Bmsu20n);
    SetIndexBuffer(93, Bmsd20n);
    SetIndexBuffer(94, Bmsu10n);
    SetIndexBuffer(95, Bmsd10n);

    SetIndexBuffer(100, Bmlu55n);
    SetIndexBuffer(101, Bmld55n);
    SetIndexBuffer(102, Bmlu20n);
    SetIndexBuffer(103, Bmld20n);
    SetIndexBuffer(104, Bmlu10n);
    SetIndexBuffer(105, Bmld10n);

    SetIndexBuffer(110, B0m);
    SetIndexBuffer(111, B1m);
    SetIndexBuffer(112, B2m);
    SetIndexBuffer(113, B3m);
    SetIndexBuffer(114, B4m);
    SetIndexBuffer(115, B5m);
    
    SetIndexBuffer(116, arrowUp);
    SetIndexBuffer(117, arrowDn);
    
    IndicatorShortName(NULL);

    mpr1_20 = ma_period_1 * 2;
    mpr2_20 = ma_period_2 * 2;
    mpr3_20 = ma_period_3 * 2;
    mpr1_55 = ma_period_1 * 5.5;
    mpr2_55 = ma_period_2 * 5.5;
    mpr3_55 = ma_period_3 * 5.5;
    ratio_p = ratio_prise * 0.01;
    return (0);
}

int deinit() { DeleteArrows(); }

int start()
{
    int limit = Bars - IndicatorCounted() - 1;

    for (i = limit; i >= 0; i--) {
        if (Close[i + 1] > Close[i]) {
            Bpu[i] = Bpu[i + 1] - (Close[i + 1] - Close[i]) * ratio_p;
        } else if (Close[i + 1] < Close[i]) {
            Bpu[i] = Bpu[i + 1] + (Close[i] - Close[i + 1]);
        } else {
            Bpu[i] = Bpu[i + 1];
        }
        if (Close[i + 1] < Close[i]) {
            Bpd[i] = Bpd[i + 1] + (Close[i] - Close[i + 1]) * ratio_p;
        } else if (Close[i + 1] > Close[i]) {
            Bpd[i] = Bpd[i + 1] - (Close[i + 1] - Close[i]);
        } else {
            Bpd[i] = Bpd[i + 1];
        }
        Buh[i] = Bpu[i] + (High[i] - Close[i]);
        Bdh[i] = Bpd[i] + (High[i] - Close[i]);
        Bul[i] = Bpu[i] + (Low[i] - Close[i]);
        Bdl[i] = Bpd[i] + (Low[i] - Close[i]);
    
    }

    sw(limit, w55, Bpu, Bsu55);
    sw(limit, w55, Bpd, Bsd55);
    sw(limit, w20, Bpu, Bsu20);
    sw(limit, w20, Bpd, Bsd20);
    sw(limit, w10, Bpu, Bsu10);
    sw(limit, w10, Bpd, Bsd10);
    st(limit, s55, Bpu, Buh, Bul, Bmu55, Bhu55, Blu55);
    st(limit, s20, Bpu, Buh, Bul, Bmu20, Bhu20, Blu20);
    st(limit, s10, Bpu, Buh, Bul, Bmu10, Bhu10, Blu10);
    st(limit, s10, Bpd, Bdh, Bdl, Bmd10, Bhd10, Bld10);
    st(limit, s20, Bpd, Bdh, Bdl, Bmd20, Bhd20, Bld20);
    st(limit, s55, Bpd, Bdh, Bdl, Bmd55, Bhd55, Bld55);

    for (i = limit; i >= 0; i--) {
        if (st_method == Hi) {
            B0[i] = MathMax(Bmu55[i], Bsu55[i]) + 100;
            B1[i] = MathMin(Bmd55[i], Bsd55[i]);
            B2[i] = MathMax(Bmu20[i], Bsu20[i]) + 100;
            B3[i] = MathMin(Bmd20[i], Bsd20[i]);
            B4[i] = MathMax(Bmu10[i], Bsu10[i]) + 100;
            B5[i] = MathMin(Bmd10[i], Bsd10[i]);
        }
        if (st_method == Lo) {
            B0[i] = MathMin(Bmu55[i], Bsu55[i]) + 100;
            B1[i] = MathMax(Bmd55[i], Bsd55[i]);
            B2[i] = MathMin(Bmu20[i], Bsu20[i]) + 100;
            B3[i] = MathMax(Bmd20[i], Bsd20[i]);
            B4[i] = MathMin(Bmu10[i], Bsu10[i]) + 100;
            B5[i] = MathMax(Bmd10[i], Bsd10[i]);
        }
        if (st_method == Orig) {
            B0[i] = Bsu55[i] + 100;
            B1[i] = Bsd55[i];
            B2[i] = Bsu20[i] + 100;
            B3[i] = Bsd20[i];
            B4[i] = Bsu10[i] + 100;
            B5[i] = Bsd10[i];
        }
    }

    for (i = limit; i >= 0; i--) {
        Bmeu55[i] = iMAOnArray(Bpu, 0, mpr1_55, 0, ma_method_1, i);
        Bmed55[i] = iMAOnArray(Bpd, 0, mpr1_55, 0, ma_method_1, i);
        Bmeu20[i] = iMAOnArray(Bpu, 0, mpr1_20, 0, ma_method_1, i);
        Bmed20[i] = iMAOnArray(Bpd, 0, mpr1_20, 0, ma_method_1, i);
        Bmeu10[i] = iMAOnArray(Bpu, 0, ma_period_1, 0, ma_method_1, i);
        Bmed10[i] = iMAOnArray(Bpd, 0, ma_period_1, 0, ma_method_1, i);

        Bmsu55[i] = iMAOnArray(Bpu, 0, mpr2_55, 0, ma_method_2, i);
        Bmsd55[i] = iMAOnArray(Bpd, 0, mpr2_55, 0, ma_method_2, i);
        Bmsu20[i] = iMAOnArray(Bpu, 0, mpr2_20, 0, ma_method_2, i);
        Bmsd20[i] = iMAOnArray(Bpd, 0, mpr2_20, 0, ma_method_2, i);
        Bmsu10[i] = iMAOnArray(Bpu, 0, ma_period_2, 0, ma_method_2, i);
        Bmsd10[i] = iMAOnArray(Bpd, 0, ma_period_2, 0, ma_method_2, i);

        Bmlu55[i] = iMAOnArray(Bpu, 0, mpr3_55, 0, ma_method_3, i);
        Bmld55[i] = iMAOnArray(Bpd, 0, mpr3_55, 0, ma_method_3, i);
        Bmlu20[i] = iMAOnArray(Bpu, 0, mpr3_20, 0, ma_method_3, i);
        Bmld20[i] = iMAOnArray(Bpd, 0, mpr3_20, 0, ma_method_3, i);
        Bmlu10[i] = iMAOnArray(Bpu, 0, ma_period_3, 0, ma_method_3, i);
        Bmld10[i] = iMAOnArray(Bpd, 0, ma_period_3, 0, ma_method_3, i);
    }

    for (i = limit; i >= 0; i--) {
        Bmeu55n[i] = Bpu[i] - Bmeu55[i];
        Bmed55n[i] = Bpd[i] - Bmed55[i];
        Bmeu20n[i] = Bpu[i] - Bmeu20[i];
        Bmed20n[i] = Bpd[i] - Bmed20[i];
        Bmeu10n[i] = Bpu[i] - Bmeu10[i];
        Bmed10n[i] = Bpd[i] - Bmed10[i];

        Bmsu55n[i] = Bpu[i] - Bmsu55[i];
        Bmsd55n[i] = Bpd[i] - Bmsd55[i];
        Bmsu20n[i] = Bpu[i] - Bmsu20[i];
        Bmsd20n[i] = Bpd[i] - Bmsd20[i];
        Bmsu10n[i] = Bpu[i] - Bmsu10[i];
        Bmsd10n[i] = Bpd[i] - Bmsd10[i];

        Bmlu55n[i] = Bpu[i] - Bmlu55[i];
        Bmld55n[i] = Bpd[i] - Bmld55[i];
        Bmlu20n[i] = Bpu[i] - Bmlu20[i];
        Bmld20n[i] = Bpd[i] - Bmld20[i];
        Bmlu10n[i] = Bpu[i] - Bmlu10[i];
        Bmld10n[i] = Bpd[i] - Bmld10[i];

        if (ma_method == mHi) {
            B0m[i] = MathMax(MathMax(Bmeu55n[i], Bmsu55n[i]), Bmlu55n[i]);
            B1m[i] = MathMin(MathMin(Bmed55n[i], Bmsd55n[i]), Bmld55n[i]);
            B2m[i] = MathMax(MathMax(Bmeu20n[i], Bmsu20n[i]), Bmlu20n[i]);
            B3m[i] = MathMin(MathMin(Bmed20n[i], Bmsd20n[i]), Bmld20n[i]);
            B4m[i] = MathMax(MathMax(Bmeu10n[i], Bmsu10n[i]), Bmlu10n[i]);
            B5m[i] = MathMin(MathMin(Bmed10n[i], Bmsd10n[i]), Bmld10n[i]);
        }
        if (ma_method == mLo) {
            B0m[i] = MathMin(MathMin(Bmeu55n[i], Bmsu55n[i]), Bmlu55n[i]);
            B1m[i] = MathMax(MathMax(Bmed55n[i], Bmsd55n[i]), Bmld55n[i]);
            B2m[i] = MathMin(MathMin(Bmeu20n[i], Bmsu20n[i]), Bmlu20n[i]);
            B3m[i] = MathMax(MathMax(Bmed20n[i], Bmsd20n[i]), Bmld20n[i]);
            B4m[i] = MathMin(MathMin(Bmeu10n[i], Bmsu10n[i]), Bmlu10n[i]);
            B5m[i] = MathMax(MathMax(Bmed10n[i], Bmsd10n[i]), Bmld10n[i]);
        }

        if (ma_method == mHi) {
            if (B0[i] < 150 && B0m[i] > 0) {
                B0[i] = 155;
            }
            if (B1[i] > 50 && B1m[i] < 0) {
                B1[i] = 45;
            }
            if (B2[i] < 150 && B2m[i] > 0) {
                B2[i] = 155;
            }
            if (B3[i] > 50 && B3m[i] < 0) {
                B3[i] = 45;
            }
            if (B4[i] < 150 && B4m[i] > 0) {
                B4[i] = 155;
            }
            if (B5[i] > 50 && B5m[i] < 0) {
                B5[i] = 45;

            }
        }
        if (ma_method == mLo) {
            if (B0[i] > 150 && B0m[i] < 0) {
                B0[i] = 145;
            }
            if (B1[i] < 50 && B1m[i] > 0) {
                B1[i] = 55;
            }
            if (B2[i] > 150 && B2m[i] < 0) {
                B2[i] = 145;
            }
            if (B3[i] < 50 && B3m[i] > 0) {
                B3[i] = 55;
            }
            if (B4[i] > 150 && B4m[i] < 0) {
                B4[i] = 145;
            }
            if (B5[i] < 50 && B5m[i] > 0) {
                B5[i] = 55;
            }
        }

        if (B0[i] > 150 && B0[i] < 155) {
            B0[i] = 155;
        } else if (B0[i] < 150 && B0[i] > 145) {
            B0[i] = 145;
        }
        if (B1[i] < 50 && B1[i] > 45) {
            B1[i] = 45;
        } else if (B1[i] > 50 && B1[i] < 45) {
            B1[i] = 45;
        }
        if (B2[i] > 150 && B2[i] < 155) {
            B2[i] = 155;
        } else if (B2[i] < 150 && B2[i] > 145) {
            B2[i] = 145;
        }
        if (B3[i] < 50 && B3[i] > 45) {
            B3[i] = 45;
        } else if (B3[i] > 50 && B3[i] < 45) {
            B3[i] = 45;
        }
        if (B4[i] > 150 && B4[i] < 155) {
            B4[i] = 155;
        } else if (B4[i] < 150 && B4[i] > 145) {
            B4[i] = 145;
        }
        if (B5[i] < 50 && B5[i] > 45) {
            B5[i] = 45;
        } else if (B5[i] > 50 && B5[i] < 45) {
            B5[i] = 45;
        }

        if (B0[i + 1] > B0[i] && Close[i + 1] < Close[i]) {
            B0[i] = B0[i + 1];
        }
        if (B1[i + 1] < B1[i] && Close[i + 1] > Close[i]) {
            B1[i] = B1[i + 1];
        }
        if (B2[i + 1] > B2[i] && Close[i + 1] < Close[i]) {
            B2[i] = B2[i + 1];
        }
        if (B3[i + 1] < B3[i] && Close[i + 1] > Close[i]) {
            B3[i] = B3[i + 1];
        }
        if (B4[i + 1] > B4[i] && Close[i + 1] < Close[i]) {
            B4[i] = B4[i + 1];
        }
        if (B5[i + 1] < B5[i] && Close[i + 1] > Close[i]) {
            B5[i] = B5[i + 1];
        }
    
    }

    for (i = limit; i >= 0; i--) {
        if (B2[i] < 150 && B2[i+1] >= 150 ) { 
            DrawArrow("sell", i); 
            arrowDn[i] = High[i];
            if(newCandle.IsNewCandle())
            {
                Notifications(1);
            }
        }
        if (B3[i] > 50 && B3[i+1] <= 50 ) { 
            DrawArrow("buy", i); 
            arrowUp[i] = Low[i];
            if (newCandle.IsNewCandle())
            {
                Notifications(0);
            }
        }    
    }
    
    return (0);
}

void sw(int limit2, double pr, double Bpr[], double Bst[])
{

    j = limit2;
    while (j >= 0) {
        sumlow  = 0;
        sumhigh = 0;
        Bl[j]   = Bpr[ArrayMinimum(Bpr, pr, j)];
        Bh[j]   = Bpr[ArrayMaximum(Bpr, pr, j)];
        for (k = (j + Slowing - 1); k >= j; k--) {
            sumlow += Bpr[k] - Bl[k];
            sumhigh += Bh[k] - Bl[k];
        }
        if (sumhigh == 0) {
            Bst[j] = 100;
        } else {
            Bst[j] = sumlow / sumhigh * 100;
        }
        j--;
    }
}

void st(int limit2, double Kpr, double Bp[], double Bph[], double Bpl[], double Bs[], double Bsh[], double Bsl[])
{

    j = limit2;
    while (j >= 0) {
        min = 1000000;
        k   = j + Kpr - 1;
        while (k >= j) {
            price = Bpl[k];
            if (min > price) min = price;
            k--;
        }
        Bsl[j] = min;
        j--;
    }

    j = limit2;
    while (j >= 0) {
        max = -1000000;
        k   = j + Kpr - 1;
        while (k >= j) {
            price = Bph[k];
            if (max < price) max = price;
            k--;
        }
        Bsh[j] = max;
        j--;
    }

    j = limit2;
    while (j >= 0) {
        sumlow  = 0.0;
        sumhigh = 0.0;
        for (k = (j + Slowing - 1); k >= j; k--) {
            sumlow += Bp[k] - Bsl[k];
            sumhigh += Bsh[k] - Bsl[k];
        }
        if (sumhigh == 0.0)
            Bs[j] = 100.0;
        else
            Bs[j] = sumlow / sumhigh * 100;
        j--;
    }
}

bool DrawArrow(string side = "buy", int shift = 0)
{
    int               chart      = 0;
    int               sub_window = 0;
    datetime          time       = iTime(NULL, 0, shift);
    int               arrow_code = side == "buy" ? 233 : 234;
    double            price      = side == "buy" ? iLow(NULL, 0, shift) - 20 * _Point : iHigh(NULL, 0, shift) + 20 * _Point;
    ENUM_ARROW_ANCHOR anchor     = side == "buy" ? ANCHOR_TOP : ANCHOR_BOTTOM;
    const color       clr        = side == "buy" ? clrBlue : clrRed;
    string            name       = "arrow_" + (string)time;

    if (!ObjectCreate(chart, name, OBJ_ARROW, sub_window, time, price)) return (false);
    ObjectSetInteger(chart, name, OBJPROP_ARROWCODE, arrow_code);
    ObjectSetInteger(chart, name, OBJPROP_ANCHOR, anchor);
    ObjectSetInteger(chart, name, OBJPROP_COLOR, clr);
    ObjectSetInteger(chart, name, OBJPROP_WIDTH, 1);
    ObjectSetInteger(chart, name, OBJPROP_BACK, false);
    ObjectSetInteger(chart, name, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(chart, name, OBJPROP_SELECTED, false);
    ObjectSetInteger(chart, name, OBJPROP_HIDDEN, false);
    //--- successful execution
    return (true);
}

void DeleteArrows() { ObjectsDeleteAll(0, "arrow"); }

void Notifications(int type)
{
  string text = "";
  if (type == 0)
    text += _Symbol + " " + GetTimeFrame(_Period) + " BUY ";
  else
    text += _Symbol + " " + GetTimeFrame(_Period) + " SELL ";

  text += " ";

  if (!notifications)
    return;
  if (desktop_notifications)
    Alert(text);
  if (push_notifications)
    SendNotification(text);
  if (email_notifications)
    SendMail("MetaTrader Notification", text);
}

string GetTimeFrame(int lPeriod)
{
  switch (lPeriod)
  {
    case PERIOD_M1:
      return ("M1");
    case PERIOD_M5:
      return ("M5");
    case PERIOD_M15:
      return ("M15");
    case PERIOD_M30:
      return ("M30");
    case PERIOD_H1:
      return ("H1");
    case PERIOD_H4:
      return ("H4");
    case PERIOD_D1:
      return ("D1");
    case PERIOD_W1:
      return ("W1");
    case PERIOD_MN1:
      return ("MN1");
  }
  return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+ 