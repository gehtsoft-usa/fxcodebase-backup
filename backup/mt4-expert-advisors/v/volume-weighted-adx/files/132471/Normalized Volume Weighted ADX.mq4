// More information about this indicator can be found at:
//http://fxcodebase.com/code/viewtopic.php?f=38&t=69604

//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                           mario.jemic@gmail.com  |
//|                          https://AppliedMachineLearning.systems  |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//|                                 Patreon : https://goo.gl/GdXWeN  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

input int TP = 14; // Time Periods
input int Normalization_Period = 14; // Time Periods

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_color3 Green

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

double vadx[], vdmip[], vdmim[];
double raw_vadx[], raw_vdmip[], raw_vdmim[];
int init()
{
   IndicatorName = GenerateIndicatorName("Volume Weighted ADX");
   IndicatorObjPrefix = "__" + IndicatorName + "__";
   IndicatorShortName(IndicatorName);

   IndicatorBuffers(6);
   

   SetIndexStyle(0, DRAW_LINE);
   SetIndexBuffer(0, vadx);
   SetIndexLabel(0, "VADX");

   SetIndexStyle(1, DRAW_LINE);
   SetIndexBuffer(1, vdmip);
   SetIndexLabel(1, "VDMI+");

   SetIndexStyle(2, DRAW_LINE);
   SetIndexBuffer(2, vdmim);
   SetIndexLabel(2, "VDMI-");
   
    SetIndexStyle(3, DRAW_NONE);
	SetIndexBuffer(3, raw_vadx);
	   
	SetIndexStyle(4, DRAW_NONE);
	SetIndexBuffer(4, raw_vdmip);
		
	SetIndexStyle(5, DRAW_NONE);
	SetIndexBuffer(5, raw_vdmim);
   


   return 0;
}

int deinit()
{
   ObjectsDeleteAll(ChartID(), IndicatorObjPrefix);
   return 0;
}

int start()
{
   int minBars = TP;
   int limit = MathMin(Bars - 1 - minBars, Bars - IndicatorCounted() - 1);
   for (int i = limit; i >= 0; i--)
   {
      double adx = 0;
      double dmip = 0;
      double dmim = 0;
      double vol = 0;
      for (int ii = 0; ii < TP; ++ii)
      {
         adx += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_MAIN, i + ii) * Volume[i + ii];
         dmip += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_PLUSDI, i+ ii) * Volume[i + ii];
         dmim += iADX(_Symbol, _Period, TP, PRICE_CLOSE, MODE_MINUSDI, i + ii) * Volume[i + ii];
         vol += Volume[i + ii];
      }
      raw_vadx[i] = adx / vol;
      raw_vdmip[i] = dmip / vol;
      raw_vdmim[i] = dmim / vol;
   }
   
   
    for (int i = limit; i >= 0; i--)
   {
   
   
    double vadx_max=  raw_vadx[ArrayMaximum(raw_vadx,Normalization_Period,i)];
    double vdmip_max= raw_vdmip[ArrayMaximum(raw_vdmip,Normalization_Period ,i)];
    double vdmim_max= raw_vdmim[ArrayMaximum(raw_vdmim,Normalization_Period ,i)];	 
	
	
	double vadx_min=  raw_vadx[ArrayMinimum(raw_vadx,Normalization_Period,i)];
    double vdmip_min= raw_vdmip[ArrayMinimum(raw_vdmip,Normalization_Period ,i)];
    double vdmim_min= raw_vdmim[ArrayMinimum(raw_vdmim,Normalization_Period ,i)];	 
 
	
	if (vadx_max!=0.)
    {
	vadx[i] = (raw_vadx[i]- vadx_min)/((vadx_max -vadx_min )/100);
	}
	if (vdmip_max!=0.)
    {
    vdmip[i] = (raw_vdmip[i] -vdmip_min )/((vdmip_max - vdmip_min )/100);
	}
	if (vdmim_max!=0.)
    {
    vdmim[i] = (raw_vdmim[i] -vdmim_min )/((vdmim_max -vdmim_min )/100);
	}
	
	
   }
   
   
   
   
   return 0;
}


