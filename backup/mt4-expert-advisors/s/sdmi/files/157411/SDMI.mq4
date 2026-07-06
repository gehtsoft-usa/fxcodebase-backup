// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75389

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
#property indicator_buffers 3
#property indicator_minimum 0
#property indicator_color1 Gray
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
#property indicator_width3 2
#property indicator_levelcolor DimGray

extern string TimeFrame     = "Current time frame";
extern int    AdxPeriod     = 13;
extern double Level         = 0;
extern bool   Show_Dmi_Only = false;

double DIplus[];
double DIminus[];
double ADX[];

string indicatorFileName;
int    timeFrame;
bool   returnBars;
bool   calculateValue;

int init()
{
    SetIndexBuffer(0, DIplus);
    SetIndexLabel(0, "DI+");
    SetIndexBuffer(1, DIminus);
    SetIndexLabel(1, "DI-");
    SetIndexBuffer(2, ADX);
    SetIndexLabel(2, "ADX");
    SetLevelValue(0, Level);

    if (Show_Dmi_Only) {
        SetIndexStyle(2, DRAW_NONE);
    } else {
        SetIndexStyle(2, DRAW_LINE);
    }

    for (int i = 0; i < 8; i++)
        SetIndexEmptyValue(i, 0.00);

    indicatorFileName = WindowExpertName();
    calculateValue    = (TimeFrame == "calculateValue");
    if (calculateValue) return (0);
    returnBars = (TimeFrame == "returnBars");
    if (returnBars) return (0);
    timeFrame = stringToTimeFrame(TimeFrame);

    return (0);
}

int deinit() { return (0); }

double work[][3];
#define _DIp 0
#define _DIm 1
#define _TR 2

int start()
{
    int i, r, counted_bars = IndicatorCounted();
    if (counted_bars < 0) return (-1);
    if (counted_bars > 0) counted_bars--;
    int limit = MathMin(Bars - counted_bars, Bars - 2);
    if (returnBars) {
        DIplus[0] = limit + 1;
        return (0);
    }

    if (calculateValue || timeFrame == Period()) {
        if (ArrayRange(work, 0) != Bars) ArrayResize(work, Bars);
        double sf = (AdxPeriod - 1.0) / AdxPeriod;
        for (i = limit, r = Bars - i - 1; i >= 0; i--, r++) {
            double currTR  = MathMax(High[i], Close[i + 1]) - MathMin(Low[i], Close[i + 1]);
            double DeltaHi = High[i] - High[i + 1];
            double DeltaLo = Low[i + 1] - Low[i];
            double plusDM  = 0.00;
            double minusDM = 0.00;

            if ((DeltaHi > DeltaLo) && (DeltaHi > 0)) plusDM = DeltaHi;
            if ((DeltaLo > DeltaHi) && (DeltaLo > 0)) minusDM = DeltaLo;

            work[r][_DIp] = sf * work[r - 1][_DIp] + plusDM;
            work[r][_DIm] = sf * work[r - 1][_DIm] + minusDM;
            work[r][_TR]  = sf * work[r - 1][_TR] + currTR;

            DIplus[i] = 0.00;
            DIminus[i] = 0.00;
            if (work[r][_TR] > 0) {
                DIplus[i] = 100.00 * work[r][_DIp] / work[r][_TR];
                DIminus[i] = 100.00 * work[r][_DIm] / work[r][_TR];
            }
            double DX;
            if ((DIplus[i] + DIminus[i]) > 0)
                DX = 100 * MathAbs(DIplus[i] - DIminus[i]) / (DIplus[i] + DIminus[i]);
            else
                DX = 0.00;
            ADX[i] = sf * ADX[i + 1] + DX / AdxPeriod;
        }
        return (0);
    }


    limit = MathMax(limit, MathMin(Bars - 1, iCustom(NULL, timeFrame, indicatorFileName, "returnBars", 0, 0) * timeFrame / Period()));
    for (i = limit; i >= 0; i--) {
        int y  = iBarShift(NULL, timeFrame, Time[i]);
        DIplus[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", AdxPeriod, 0, y);
        DIminus[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", AdxPeriod, 1, y);
        ADX[i] = iCustom(NULL, timeFrame, indicatorFileName, "calculateValue", AdxPeriod, 2, y);
    }
    return (0);
}

string sTfTable[] = {"M1", "M5", "M15", "M30", "H1", "H4", "D1", "W1", "MN"};
int    iTfTable[] = {1, 5, 15, 30, 60, 240, 1440, 10080, 43200};

int stringToTimeFrame(string tfs)
{
    tfs = stringUpperCase(tfs);
    for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
        if (tfs == sTfTable[i] || tfs == "" + iTfTable[i]) return (MathMax(iTfTable[i], Period()));
    return (Period());
}

string timeFrameToString(int tf)
{
    for (int i = ArraySize(iTfTable) - 1; i >= 0; i--)
        if (tf == iTfTable[i]) return (sTfTable[i]);
    return ("");
}

string stringUpperCase(string str)
{
    string s = str;

    for (int length = StringLen(str) - 1; length >= 0; length--) {
        int tchar = StringGetChar(s, length);
        if ((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
            s = StringSetChar(s, length, tchar - 32);
        else if (tchar > -33 && tchar < 0)
            s = StringSetChar(s, length, tchar + 224);
    }
    return (s);
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