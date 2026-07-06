// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=70308

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict
#property indicator_separate_window
#property indicator_minimum -25
#property indicator_maximum 200
#property indicator_buffers 11
#property indicator_plots   4
//--- plot RSI
#property indicator_label1  "RSI"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot RSI_Momentum
#property indicator_label2  "RSI_Momentum"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkViolet
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot RSI_MA
#property indicator_label3  "RSI_MA"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot RSI_SMA
#property indicator_label4  "RSI_SMA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrMediumSeaGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- plot Lines
#property indicator_level1     30.0
#property indicator_level2     50.0
#property indicator_level3     70.0
#property indicator_level4     100.0
#property indicator_levelcolor clrSilver
#property indicator_levelstyle STYLE_DOT
#property indicator_levelwidth 1


//--- indicator buffers
double         RSIBuffer[];
double         RSI_MomentumBuffer[];
double         RSI_MABuffer[];
double         RSI_SMABuffer[];


//--- input parameters
input int rsi_length=14; // RSI Length
input int rsi_mom_length=9; // RSI Momentum Length
input int rsi_ma_length=3; // RSI MA Length
input int ma_length=3; // SMA Length
input int fastLength=13; // Fast Length
input int slowLength=33; // Slow Length
double r[], r_sma[], rsidelta[], rsisma[], s[], sma_fastLength[], sma_slowLength[];  
double i1 = 120;
string short_name;
int StartBar;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorBuffers(4);
//--- indicator buffers mapping
   SetIndexBuffer(0,RSIBuffer);
   SetIndexBuffer(1,RSI_MomentumBuffer);
   SetIndexBuffer(2,RSI_MABuffer);
   SetIndexBuffer(3,RSI_SMABuffer);
   SetIndexBuffer(4,r);
   SetIndexStyle(4, DRAW_NONE);
   SetIndexBuffer(5,rsidelta);
   SetIndexStyle(5, DRAW_NONE);
   SetIndexBuffer(6,r_sma);   
   SetIndexStyle(6, DRAW_NONE);
   SetIndexBuffer(7,rsisma);
   SetIndexStyle(7, DRAW_NONE);
   SetIndexBuffer(8,s);
   SetIndexStyle(8, DRAW_NONE);
   SetIndexBuffer(9,sma_fastLength);
   SetIndexStyle(9, DRAW_NONE);
   SetIndexBuffer(10,sma_slowLength);
   SetIndexStyle(10, DRAW_NONE);
   //---

   
   short_name="RSI + Composite Index("+string(rsi_length)+","+
                                       string(rsi_mom_length)+","+
                                       string(rsi_ma_length)+","+
                                       string(ma_length)+","+
                                       string(fastLength)+","+
                                       string(slowLength)+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
   return(INIT_SUCCEEDED);
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
 int counted, i;    
    if(Bars <= StartBar)
        return (0);

    counted = IndicatorCounted();
    if(counted < 1)
        for(i = Bars - StartBar; i < Bars; i++)
        {
            RSI_SMABuffer[i] = 0.0;
        }
    
    counted = Bars - counted - 1;
        
    for (i = counted; i >= 0; i--)
        r[i] = rsi(i, rsi_length, PRICE_CLOSE);     
        
    for (i = counted; i >= 0; i--)
        rsidelta[i] = mom(i);    
        
    for (i = counted; i >= 0; i--)
       r_sma[i] = rsi(i, rsi_ma_length, PRICE_CLOSE);  
           
    for (i = counted; i >= 0; i--)
        rsisma[i] = sma(i,r_sma, ma_length); 
        
    for (i = counted; i >= 0; i--)
        s[i] = rsisma[i] + rsidelta[i];  
        
    for (i = counted; i >= 0; i--)
        sma_fastLength[i] = sma(i,s, fastLength);
        
    for (i = counted; i >= 0; i--)
        sma_slowLength[i] = sma(i,s, slowLength); 
           
    for (i = counted; i >= 0; i--)
    {       
        RSI_SMABuffer[i] = s[i]/2 + i1;
        RSI_MomentumBuffer[i] = sma_fastLength[i]/2 + i1;
        RSI_MABuffer[i] = sma_slowLength[i]/2 + i1;
        RSIBuffer[i] = r[i];
    }



  
    
    return(0);
  }
  

double rsi(int i, int period, ENUM_APPLIED_PRICE price)
{
   return iRSI(NULL,NULL,period,price,i);   
}  

//+------------------------------------------------------------------+
double sma(int i, double &array[], int period, ENUM_MA_METHOD method = MODE_SMA)
{
   return iMAOnArray(array,0,period,0,method,i); 
}


double mom(int i)
{  
   double rsi_current = rsi(i, rsi_length, PRICE_CLOSE); 
   double rsi_preview = rsi(i+rsi_mom_length, rsi_length, PRICE_CLOSE);
   return rsi_current-rsi_preview;
}
