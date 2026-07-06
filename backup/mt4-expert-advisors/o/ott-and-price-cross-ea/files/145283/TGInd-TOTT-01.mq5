// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71951

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+
 
#property indicator_chart_window
#property indicator_buffers 4 // How many data buffers are we using
#property indicator_plots 4   // How many indicators are being drawn on screen

#property indicator_type1 DRAW_LINE    // This type draws a simple line
#property indicator_label1 "OTT"       // label to show in the data window
#property indicator_color1 clrGray     // Line colour
#property indicator_style1 STYLE_SOLID // Solid, dotted etc
#property indicator_width1 1           // 4 because it's easier to see in the demo

#property indicator_type2 DRAW_LINE    // This type draws a simple line
#property indicator_label2 "OTTUp"     // label to show in the data window
#property indicator_color2 clrRed      // Line colour
#property indicator_style2 STYLE_SOLID // Solid, dotted etc
#property indicator_width2 1           // 4 because it's easier to see in the demo

#property indicator_type3 DRAW_LINE    // This type draws a simple line
#property indicator_label3 "OTTDown"   // label to show in the data window
#property indicator_color3 clrRed      // Line colour
#property indicator_style3 STYLE_SOLID // Solid, dotted etc
#property indicator_width3 1           // 4 because it's easier to see in the demo

#property indicator_type4 DRAW_LINE    // This type draws a simple line
#property indicator_label4 "Mav"       // label to show in the data window
#property indicator_color4 clrBlue    // Line colour
#property indicator_style4 STYLE_SOLID // Solid, dotted etc
#property indicator_width4 2           // 4 because it's easier to see in the demo

// Inputlari alalim...
input int InpMavPeriod = 30;           //Moving Average period
input double InpTakipYuzdesi = 0.5;    //Takip yuzdesi
input double InpOttCoeffUp = 0.0008;   // TOTT % coeff Up
input double InpOttCoeffDown = 0.0008; // TOTT % coeff Down
input int InpGecmisBarSay = 200000;    // Kac bar geriye gitsin

// dinamik array'leri tanimlayalim (indikatorumuzun buffer'i olarak kullanilacaklar)
double OTTBuffer[];     // OTT Up verilerinin saklanacagi buffer
double OTTUpBuffer[];   // OTT Up verilerinin saklanacagi buffer
double OTTDownBuffer[]; // OTT Down verilerinin saklanacagi buffer
double MavBuffer[];     // Moving Average verilerinin saklanaci buffer

int MavHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
    Print("tg..32 baslatildi indicator TGInd-TOTT-01", EnumToString(_Period), " periodda InpMavPeriod:", InpMavPeriod, " ve InpTakipYuzdesi: ", InpTakipYuzdesi, " InpGecmisBarSay:", InpGecmisBarSay, ".....");

    // assign the dynamic buffer arrays with 0th and 1st indicator's buffer
    SetIndexBuffer(0, OTTBuffer, INDICATOR_DATA);
    SetIndexBuffer(1, OTTUpBuffer, INDICATOR_DATA);
    SetIndexBuffer(2, OTTDownBuffer, INDICATOR_DATA);
    SetIndexBuffer(3, MavBuffer, INDICATOR_DATA);

    MavHandle = iVIDyA(_Symbol, PERIOD_CURRENT, 9, InpMavPeriod, 0, PRICE_CLOSE);

    //    PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, InpMavPeriod);

    return (INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])

{
    // Print("tg..i31 datetime:", time[0], " rates_total: ", rates_total, " prev_calculated:", prev_calculated);

    if (IsStopped())
        return (0); //  Must respect the stop flag

    if (rates_total < InpMavPeriod)
        return (0); //---- check for the presence of bars, sufficient for the calculation

    // TODO: bunu sonra kaldirabilirsin...
    //   Check that the moving averages have all been calculated on OnInit
    if (BarsCalculated(MavHandle) < rates_total)
        return (0);

    int copyBars = 0;
    int startBar = 0;
    // // Print("tgi..11 prev_calculated:", prev_calculated, " rates_total:", rates_total);

    //---- calculation of starting index first of the main loop
    if (prev_calculated > rates_total || prev_calculated <= 0) //--- first calculation
    {
        // Print("tg..i32 rates_total: ", rates_total);
        copyBars = rates_total;
        startBar = InpMavPeriod;
    }
    else
    {
        // Print("tg..i33 rates_total: ", rates_total, " copyBars: ", copyBars, " startBar:", startBar);

        copyBars = rates_total - prev_calculated;
        if (prev_calculated > 0)
        {
            copyBars++;
            startBar = prev_calculated - 1;
        }
        // Print("tg..i34 rates_total: ", rates_total, " prev_calculated: ", prev_calculated, " copyBars: ", copyBars, " startBar:", startBar);
    }
    // // Print("tgi..12 copyBars:", copyBars, " startBar:", startBar);

    // inputtan girilen InpGecmisBarSay kadar geriye gidelim...
    if (InpGecmisBarSay < rates_total)
    {
        copyBars = InpGecmisBarSay;

        if (startBar < (rates_total - InpGecmisBarSay))
            startBar = rates_total - InpGecmisBarSay;
    }

    // Buffer'a atilmis Mav'i alalim...
    if (CopyBuffer(MavHandle, 0, 0, copyBars, MavBuffer) <= 0)
    {
        Print("Getting Mav is failed! Error", GetLastError());
        return (0);
    }

    int loopSay = 0;

    //---- main loop of the calculation
    for (int i = startBar; i < rates_total && !IsStopped(); i++)
    {
        OTTBuffer[i] = calculateOTT(MavBuffer[i - 2], OTTBuffer[i - 1]);
        OTTUpBuffer[i] = OTTBuffer[i] * (1 + InpOttCoeffUp);
        OTTDownBuffer[i] = OTTBuffer[i] * (1 - InpOttCoeffDown);
        loopSay++;
        if (i > (rates_total - 1000))
        {
            Print("tg..i35 i:", i, " loopSay:", loopSay, " time[i]:", time[i], " startBar:", startBar, " size:", ArraySize(OTTBuffer), " rates_total:", rates_total, " prev_calculated: ", prev_calculated, " OTTBuffer[i]:", OTTBuffer[i], "  OTTBuffer[i-1]:", OTTBuffer[i - 1], "  OTTBuffer[i-2]:", OTTBuffer[i - 2]);
        };
    }
    return (rates_total);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateOTT(double MavPrev2, double OTTPrev1)
{
    double q1 = (MavPrev2) * (1 + (InpTakipYuzdesi / 200));
    double q2 = (MavPrev2) * (1 - (InpTakipYuzdesi / 200));
    double OTT;
    if (q1 < OTTPrev1)
    {
        OTT = q1;
    }
    else
    {
        if (q2 > OTTPrev1)
        {
            OTT = q2;
        }
        else
        {
            OTT = OTTPrev1;
        };
    };

    return NormalizeDouble(OTT, _Digits);
};

//+------------------------------------------------------------------+
