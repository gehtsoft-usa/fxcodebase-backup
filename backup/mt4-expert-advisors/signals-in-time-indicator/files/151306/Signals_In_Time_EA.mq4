//+------------------------------------------------------------------+
//|                                                Expert Advisor by |
//|                                                 Carlos Valloggia |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022. Carlos Valloggia"
#property link "https://www.mql5.com/en/users/cvalloggia"
#property version "1.00"
#property strict
// Includes

// Gobal Variables
input string file = "Signals_in_time_Indicator"; // Indicator File:
input int buyBuffer = 0; // Buy Buffer:
input int sellBuffer = 1; // Sell Buffer:
//////////////////////////////////////////////////////////////////////

int OnInit()
{
    double temp = iCustom(NULL, 0, file, 0, 0);
    if(GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
    {
        string txt = "THIS EA NEED AN INDICATOR\ninstall the file:\n" + file + "\ninto the folder:\nMQL4/Indicators.";
        MessageBox(txt, "Important Information", MB_ICONINFORMATION);
        Alert(txt);
        return INIT_FAILED;
    }
    return(INIT_SUCCEEDED);
}


void OnTick()
{
    // NOTE: take the values from indicator:    
    double indicator_buy_buffer = iCustom(NULL, 0, file, buyBuffer, 1);
    double indicator_sell_buffer = iCustom(NULL, 0, file, sellBuffer, 1);

    // print alert if have signal:
    if(indicator_buy_buffer != EMPTY_VALUE) Print("Buy Signal at: ", indicator_buy_buffer);
    if( indicator_sell_buffer != EMPTY_VALUE) Print("Sell Signal at: ", indicator_sell_buffer);
}


//////////////////////////////////////////////////////////////////////