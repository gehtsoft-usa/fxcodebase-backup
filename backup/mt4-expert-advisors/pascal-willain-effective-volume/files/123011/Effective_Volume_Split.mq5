//Available @ http://fxcodebase.com

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property indicator_separate_window

#property indicator_buffers 6
#property indicator_plots 2
#property indicator_type1  DRAW_LINE
#property indicator_color1 LightSeaGreen
#property indicator_style1 STYLE_SOLID
#property indicator_width1 1
#property indicator_label1 "Large"
#property indicator_type2  DRAW_LINE
#property indicator_color2 Crimson
#property indicator_style2 STYLE_SOLID
#property indicator_width2 1
#property indicator_label2 "Small"

#define MODE_ASCEND 0
#define MODE_DESCEND 1

//--- indicator buffers
double lineLarge [];
double lineSmall [];
double Raw [];
double Median [];
double Plot1 [];
double Plot2 [];

int Length=0;
int    mid;
double Array [];

//--- indicator input
input double PI = 0; // PI
input int Period = 14;  // Periods
input bool Cumulative = true; // Cumulative:
input int bars = 200; // Bars:

// ------------------------------------------------------------------
void OnInit()
{
    //--- indicator short name
    string short_name = "Effective volume Split";
    IndicatorSetString(INDICATOR_SHORTNAME, short_name);
    PlotIndexSetString(0, PLOT_LABEL, short_name);
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

    //--- Buffers 
    SetIndexBuffer(0, lineLarge);
    SetIndexBuffer(1, lineSmall);

    SetIndexBuffer(2, Raw);
    SetIndexBuffer(3, Median);

    SetIndexBuffer(4, Plot1);
    SetIndexBuffer(5, Plot2);

    Length = MathMax(Period, 2);

    ArrayResize(Array, Length);
    mid = (int)MathFloor(Length / 2);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime& time [],
                const double& open [],
                const double& high [],
                const double& low [],
                const double& close [],
                const long& tick_volume [],
                const long& volume [],
                const int& spread [])
{

    int start;
    if(prev_calculated > 1) start = prev_calculated - 1; else { start = Period + 1; }

    for(int i = start; i < rates_total && !IsStopped(); i++)
    {

        double HighPrice = MathMax(high[i], close[i - 1]);
        double LowPrice = MathMin(low[i], close[i - 1]);

        if((HighPrice - LowPrice) != 0)
            Raw[i] = ((close[i] - close[i - 1] + PI) / (HighPrice - LowPrice + PI)) * tick_volume[i];
        else
            Raw[i] = 0;

        for(int k = 0; k < Length; k++)
        {
            Array[k] = iMAOnArrayMQL4(Raw, 0, 1, 0, MODE_SMA, i - k);
        }

        Median[i] = Array[mid];
        ArraySortMQL4(Array);

        if(Raw[i] > Median[i])
        {
            Plot1[i] = Raw[i];
            Plot2[i] = 0;
        }
        else
        {
            Plot1[i] = 0;
            Plot2[i] = Raw[i];
        }

        if(Cumulative)
        {
            double sumLarge = 0;
            double sumSmall = 0;
            for(int n = i; n > i - Length; n--)
            {
                sumLarge += Plot1[n];
                sumSmall += Plot2[n];
            }

            lineLarge[i] = sumLarge;
            lineSmall[i] = sumSmall;            
        }
        else
        {
            lineLarge[i] = Plot1[i];
            lineSmall[i] = Plot2[i];
        }

    }

    return (rates_total);
}
//+------------------------------------------------------------------+


// //+------------------------------------------------------------------+
// //| Simple moving average on price array                             |
// //+------------------------------------------------------------------+
// int SimpleMAOnBuffer(const int rates_total,const int prev_calculated,const int begin,const int period,const double& price[],double& buffer[])
//   {
// //--- check period
//    if(period<=1 || period>(rates_total-begin))
//       return(0);
// //--- save as_series flags
//    bool as_series_price=ArrayGetAsSeries(price);
//    bool as_series_buffer=ArrayGetAsSeries(buffer);

//    ArraySetAsSeries(price,false);
//    ArraySetAsSeries(buffer,false);
// //--- calculate start position
//    int start_position;

//    if(prev_calculated==0)  // first calculation or number of bars was changed
//      {
//       //--- set empty value for first bars
//       start_position=period+begin;

//       for(int i=0; i<start_position-1; i++)
//          buffer[i]=0.0;
//       //--- calculate first visible value
//       double first_value=0;

//       for(int i=begin; i<start_position; i++)
//          first_value+=price[i];

//       buffer[start_position-1]=first_value/period;
//      }
//    else
//       start_position=prev_calculated-1;
// //--- main loop
//    for(int i=start_position; i<rates_total; i++)
//       buffer[i]=buffer[i-1]+(price[i]-price[i-period])/period;
// //--- restore as_series flags
//    ArraySetAsSeries(price,as_series_price);
//    ArraySetAsSeries(buffer,as_series_buffer);
// //---
//    return(rates_total);
// }


double iMAOnArrayMQL4(double& array [],
                      int total,
                      int period,
                      int ma_shift,
                      int ma_method,
                      int shift)
{
    double buf [], arr [];
    if(total == 0) total = ArraySize(array);
    if(total > 0 && total <= period) return(0);
    if(shift > total - period - ma_shift) return(0);
    switch(ma_method)
    {
        case MODE_SMA:
        {
            total = ArrayCopy(arr, array, 0, shift + ma_shift, period);
            if(ArrayResize(buf, total) < 0) return(0);
            double sum = 0;
            int    i, pos = total - 1;
            for(i = 1;i < period;i++, pos--)
                sum += arr[pos];
            while(pos >= 0)
            {
                sum += arr[pos];
                buf[pos] = sum / period;
                sum -= arr[pos + period - 1];
                pos--;
            }
            return(buf[0]);
        }
        case MODE_EMA:
        {
            if(ArrayResize(buf, total) < 0) return(0);
            double pr = 2.0 / (period + 1);
            int    pos = total - 2;
            while(pos >= 0)
            {
                if(pos == total - 2) buf[pos + 1] = array[pos + 1];
                buf[pos] = array[pos] * pr + buf[pos + 1] * (1 - pr);
                pos--;
            }
            return(buf[shift + ma_shift]);
        }
        case MODE_SMMA:
        {
            if(ArrayResize(buf, total) < 0) return(0);
            double sum = 0;
            int    i, k, pos;
            pos = total - period;
            while(pos >= 0)
            {
                if(pos == total - period)
                {
                    for(i = 0, k = pos;i < period;i++, k++)
                    {
                        sum += array[k];
                        buf[k] = 0;
                    }
                }
                else sum = buf[pos + 1] * (period - 1) + array[pos];
                buf[pos] = sum / period;
                pos--;
            }
            return(buf[shift + ma_shift]);
        }
        case MODE_LWMA:
        {
            if(ArrayResize(buf, total) < 0) return(0);
            double sum = 0.0, lsum = 0.0;
            double price;
            int    i, weight = 0, pos = total - 1;
            for(i = 1;i <= period;i++, pos--)
            {
                price = array[pos];
                sum += price * i;
                lsum += price;
                weight += i;
            }
            pos++;
            i = pos + period;
            while(pos >= 0)
            {
                buf[pos] = sum / weight;
                if(pos == 0) break;
                pos--;
                i--;
                price = array[pos];
                sum = sum - lsum + price * period;
                lsum -= array[i];
                lsum += price;
            }
            return(buf[shift + ma_shift]);
        }
        default: return(0);
    }
    return(0);
}




int ArraySortMQL4(double& array [],
                  int count = WHOLE_ARRAY,
                  int start = 0,
                  int sort_dir = MODE_ASCEND)
{
    switch(sort_dir)
    {
        case MODE_ASCEND:
            ArraySetAsSeries(array, true);
        case MODE_DESCEND:
            ArraySetAsSeries(array, false);

        default: ArraySetAsSeries(array, true);
    }
    ArraySort(array);
    return(0);
}
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |   
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                                                    15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |  
//|Ethereum                                           0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D   |  
//|USDT addres  ERC-20 (Ethereum) address)            0x258C74Caac21c9535A0969F169FE0271d3cE56A0   | 
//+------------------------------------------------------------------------------------------------+