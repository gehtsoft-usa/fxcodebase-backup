//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&t=75203

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  |
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |
//|                                                                         mario.jemic@gmail.com  |
//|                                                        https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0
//--- plot Linea1
#property indicator_label1 "Linea1"
#property indicator_type1  DRAW_LINE
#property indicator_color1 clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
//--- indicator buffers
double Linea1Buffer[];

input string          T1             = "== Line 1 setup =="; // === Line 1 ===
input bool            line1on        = true;                 // Draw Line 1?
input double          line1_priceini = 1.040;                // Price reference
input double          line1_pricegap = 0.010;                // Price Gap
input color           line1_color    = Black;                // Line Color:
input ENUM_LINE_STYLE line1_style    = STYLE_SOLID;          // Style:
input string          line1_text     = "line1";              // Txt:
input string          T2             = "== Line 2 setup =="; // === Line 2 ===
input bool            line2on        = true;                 // Draw Line 2?
input double          line2_priceini = 1.039;                // Price reference
input double          line2_pricegap = 0.010;                // Price Gap
input color           line2_color    = Gray;                // Line Color:
input ENUM_LINE_STYLE line2_style    = STYLE_DOT;            // Style:
input string          line2_text     = "line2";              // Txt:

int deinit()
{
    eraseLines();
    return 0;
}

void DrawLines()
{
   eraseLines();
   
   int qnt = 100;
    if (line1on) {
        for (double i = 0; i <= qnt; i++) {
            double m = i;
            if (i >= 50) m = -1 * (i - 49);
            double price = line1_priceini + (line1_pricegap * m);
            string txt   = line1_text + "_" + (string)price;

            if (ObjectFind(txt) != 0) // HLine not in main chartwindow
            {
                ObjectCreate(txt, OBJ_HLINE, 0, 0, price);
                ObjectSet(txt, OBJPROP_STYLE, line1_style);
                ObjectSet(txt, OBJPROP_COLOR, line1_color);
            } else // Adjustments
            {
                ObjectSet(txt, OBJPROP_PRICE1, price);
                ObjectSet(txt, OBJPROP_STYLE, line1_style);
                ObjectSet(txt, OBJPROP_COLOR, line1_color);
            }
        }
    }

    if (line2on) {
        for (double i = 0; i <= qnt; i++) {
            double m = i;
            if (i >= 50) m = -1 * (i - 49);
            double price = line2_priceini + (line2_pricegap * m);
            string txt   = line2_text + "_" + (string)price;

            if (ObjectFind(txt) != 0) // HLine not in main chartwindow
            {
                ObjectCreate(txt, OBJ_HLINE, 0, 0, price);
                ObjectSet(txt, OBJPROP_STYLE, line2_style);
                ObjectSet(txt, OBJPROP_COLOR, line2_color);
            } else // Adjustments
            {
                ObjectSet(txt, OBJPROP_PRICE1, price);
                ObjectSet(txt, OBJPROP_STYLE, line2_style);
                ObjectSet(txt, OBJPROP_COLOR, line2_color);
            }
        }
    }
    WindowRedraw();
}

void eraseLines()
{
   ObjectsDeleteAll(0, line1_text);
   ObjectsDeleteAll(0, line2_text);
}

int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0, Linea1Buffer, INDICATOR_DATA);

    DrawLines();
    //---
    return (INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total, const int prev_calculated, const datetime &time[], const double &open[], const double &high[], const double &low[], const double &close[],
                const long &tick_volume[], const long &volume[], const int &spread[])
{
    //---
    //--- return value of prev_calculated for next call
    return (rates_total);
}
//+------------------------------------------------------------------+
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