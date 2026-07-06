// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71408


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  | 
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |                                                  |   
//+------------------------------------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 8
#property indicator_color1 DeepSkyBlue
#property indicator_color2 DarkOrange
#property indicator_color3 Red
#property indicator_color4 White
#property indicator_color5 Green
#property indicator_color6 Olive
#property indicator_color7 WhiteSmoke
#property indicator_color8 DarkOrchid

//---- Paramètres
extern int Periode=14;


int TotalDevise=8;

//---- buffers
double BufferEUR[];
double BufferUSD[];
double BufferJPY[];
double BufferGBP[];
double BufferCHF[];
double BufferCAD[];
double BufferAUD[];
double BufferNZD[];

//+------------------------------------------------------------------+
//| Initialisation                                                   |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(8);

   string short_name;
   short_name="ROC-";
   IndicatorShortName(short_name);
   IndicatorDigits(0);
  
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,BufferEUR);
   SetIndexDrawBegin(0,0);
   
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BufferUSD);
   SetIndexDrawBegin(1,0);

   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,BufferJPY);
   SetIndexDrawBegin(2,0);

   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,BufferGBP);
   SetIndexDrawBegin(3,0);
   
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,BufferCHF);
   SetIndexDrawBegin(4,0);
   
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,BufferCAD);
   SetIndexDrawBegin(5,0);
   
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,BufferAUD);
   SetIndexDrawBegin(6,0);
   
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,BufferNZD);
   SetIndexDrawBegin(7,0);
   

   SetLevelStyle(STYLE_SOLID,1,Silver);
   SetLevelValue(0,0);
   
   return(0);
  }
  
int deinit()
  {
  if (ObjectFind("EUR")>=0)
     ObjectDelete("EUR");
  return(0);
  }
//+------------------------------------------------------------------+
//|  Main fonction                                                   |
//+------------------------------------------------------------------+
int start()
  {
   int limit,i,counted_bars=IndicatorCounted();
   int mEURUSD;
   int mEURJPY;
   int mUSDJPY;
   int mGBPUSD;
   int mEURGBP;
   int mGBPJPY;
   int mGBPCHF;
   int mCHFJPY;
   int mEURCHF;
   int mUSDCHF;
   int mAUDNZD;
   
   int mNZDCAD;
   int mCHFCAD;
   int mAUDCAD;
   
   int mNZDCHF;
   int mAUDCHF;
   int mCADCHF;
   
   int mGBPNZD;
   int mGBPAUD;
   int mGBPCAD;
   
   int mNZDJPY;
   int mAUDJPY;
   int mCADJPY;  
   
   int mEURCAD;
   int mEURAUD;
   int mEURNZD; 
   
   int mUSDCAD;
   int mAUDUSD;
   int mNZDUSD;
      
   int TotalWindow=WindowsTotal();

  if (ObjectFind("EUR")<0)
     {
     ObjectCreate("EUR",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("EUR",OBJPROP_XDISTANCE,150);
     ObjectSet("EUR",OBJPROP_YDISTANCE,1);
     ObjectSetText("EUR","EUR",12,"Arial",indicator_color1);
     }
  if (ObjectFind("USD")<0)
     {
     ObjectCreate("USD",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("USD",OBJPROP_XDISTANCE,200);
     ObjectSet("USD",OBJPROP_YDISTANCE,1);
     ObjectSetText("USD","USD",12,"Arial",indicator_color2);
     }
  if (ObjectFind("JPY")<0)
     {
     ObjectCreate("JPY",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("JPY",OBJPROP_XDISTANCE,250);
     ObjectSet("JPY",OBJPROP_YDISTANCE,1);
     ObjectSetText("JPY","JPY",12,"Arial",indicator_color3);
     }
  if (ObjectFind("GBP")<0)
     {
     ObjectCreate("GBP",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("GBP",OBJPROP_XDISTANCE,300);
     ObjectSet("GBP",OBJPROP_YDISTANCE,1);
     ObjectSetText("GBP","GBP",12,"Arial",indicator_color4);
     }
     if (ObjectFind("CHF")<0)
     {
     ObjectCreate("CHF",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("CHF",OBJPROP_XDISTANCE,350);
     ObjectSet("CHF",OBJPROP_YDISTANCE,1);
     ObjectSetText("CHF","CHF",12,"Arial",indicator_color5);
     }
	 
	 if (ObjectFind("CAD")<0)
     {
     ObjectCreate("CAD",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("CAD",OBJPROP_XDISTANCE,400);
     ObjectSet("CAD",OBJPROP_YDISTANCE,1);
     ObjectSetText("CAD","CAD",12,"Arial",indicator_color6);
     }
	 
	 if (ObjectFind("AUD")<0)
     {
     ObjectCreate("AUD",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("AUD",OBJPROP_XDISTANCE,450);
     ObjectSet("AUD",OBJPROP_YDISTANCE,1);
     ObjectSetText("AUD","AUD",12,"Arial",indicator_color7);	 
     }

	 if (ObjectFind("NZD")<0)
     {
     ObjectCreate("NZD",OBJ_LABEL,TotalWindow-1,0,0);
     ObjectSet("NZD",OBJPROP_XDISTANCE,500);
     ObjectSet("NZD",OBJPROP_YDISTANCE,1);
     ObjectSetText("NZD","NZD",12,"Arial",indicator_color8);	 
     }


   if(Bars<=Periode+1) return(0);
   if (counted_bars<0) return(-1);
   if (counted_bars>0) counted_bars--;
	
	if(counted_bars == 0) limit = Bars;
	if(counted_bars > 0)	 limit = Bars - counted_bars;
	
   
	for(i = limit; i >= 0; i--)
     {

	 
     mEURUSD= NormalizeDouble((iClose("EURUSD",0,i)-iClose("EURUSD",0,i+Periode))/0.0001,0);  
     mEURJPY= NormalizeDouble((iClose("EURJPY",0,i)-iClose("EURJPY",0,i+Periode))/0.01,0);  
     mUSDJPY= NormalizeDouble((iClose("USDJPY",0,i)-iClose("USDJPY",0,i+Periode))/0.01,0);  
     mCHFJPY= NormalizeDouble((iClose("USDJPY",0,i)-iClose("USDJPY",0,i+Periode))/0.01,0);
     mUSDCHF= NormalizeDouble((iClose("USDCHF",0,i)-iClose("USDCHF",0,i+Periode))/0.0001,0); 
     
     mGBPJPY= NormalizeDouble((iClose("GBPJPY",0,i)-iClose("GBPJPY",0,i+Periode))/0.01,0);  
     mEURGBP= NormalizeDouble((iClose("EURGBP",0,i)-iClose("EURGBP",0,i+Periode))/0.0001,0);  
     mGBPUSD= NormalizeDouble((iClose("GBPUSD",0,i)-iClose("GBPUSD",0,i+Periode))/0.0001,0);
     mGBPCHF= NormalizeDouble((iClose("GBPCHF",0,i)-iClose("GBPCHF",0,i+Periode))/0.0001,0); 
     mEURCHF= NormalizeDouble((iClose("EURCHF",0,i)-iClose("EURCHF",0,i+Periode))/0.0001,0); 
	 

	 mEURCAD= NormalizeDouble((iClose("EURCAD",0,i)-iClose("EURCAD",0,i+Periode))/0.0001,0); 
	 mEURAUD= NormalizeDouble((iClose("EURAUD",0,i)-iClose("EURAUD",0,i+Periode))/0.0001,0); 
	 mEURNZD= NormalizeDouble((iClose("EURNZD",0,i)-iClose("EURNZD",0,i+Periode))/0.0001,0); 

	 mUSDCAD= NormalizeDouble((iClose("USDCAD",0,i)-iClose("USDCAD",0,i+Periode))/0.0001,0); 
     mAUDUSD= NormalizeDouble((iClose("AUDUSD",0,i)-iClose("AUDUSD",0,i+Periode))/0.0001,0); 
     mNZDUSD = NormalizeDouble((iClose("NZDUSD",0,i)-iClose("NZDUSD",0,i+Periode))/0.0001,0); 


     mCADJPY= NormalizeDouble((iClose("CADJPY",0,i)-iClose("CADJPY",0,i+Periode))/0.01,0);  
     mAUDJPY= NormalizeDouble((iClose("AUDJPY",0,i)-iClose("AUDJPY",0,i+Periode))/0.01,0);  
	 mNZDJPY= NormalizeDouble((iClose("NZDJPY",0,i)-iClose("NZDJPY",0,i+Periode))/0.01,0);  
	 
	 mGBPCAD= NormalizeDouble((iClose("GBPCAD",0,i)-iClose("GBPCAD",0,i+Periode))/0.0001,0);  
	 mGBPAUD= NormalizeDouble((iClose("GBPAUD",0,i)-iClose("GBPAUD",0,i+Periode))/0.0001,0);  
	 mGBPNZD= NormalizeDouble((iClose("GBPNZD",0,i)-iClose("GBPNZD",0,i+Periode))/0.0001,0);  

	 mCADCHF= NormalizeDouble((iClose("CADCHF",0,i)-iClose("CADCHF",0,i+Periode))/0.0001,0);  
	 mAUDCHF= NormalizeDouble((iClose("AUDCHF",0,i)-iClose("AUDCHF",0,i+Periode))/0.0001,0);  
	 mNZDCHF= NormalizeDouble((iClose("NZDCHF",0,i)-iClose("NZDCHF",0,i+Periode))/0.0001,0); 
	 
	 mAUDCAD= NormalizeDouble((iClose("AUDCAD",0,i)-iClose("AUDCAD",0,i+Periode))/0.0001,0); 
	 mCHFCAD= NormalizeDouble((iClose("CHFCAD",0,i)-iClose("CHFCAD",0,i+Periode))/0.0001,0); 	 
	 mNZDCAD= NormalizeDouble((iClose("NZDCAD",0,i)-iClose("NZDCAD",0,i+Periode))/0.0001,0); 
	 
	 mAUDNZD= NormalizeDouble((iClose("AUDNZD",0,i)-iClose("AUDNZD",0,i+Periode))/0.0001,0); 
 
     BufferEUR[i]=(BufferEUR[i+1]+BufferEUR[i+2]+((mEURUSD+mEURJPY+mEURGBP+mEURCHF+mEURCAD+mEURAUD+mEURNZD)/(TotalDevise-1)))/7;
     BufferUSD[i]=(BufferUSD[i+1]+BufferUSD[i+2]+((mUSDJPY-mEURUSD-mGBPUSD+mUSDCHF+mUSDCAD- mAUDUSD - mNZDUSD   )/(TotalDevise-1)))/7;
     BufferJPY[i]=(BufferJPY[i+1]+BufferJPY[i+2]+((mEURJPY-mUSDJPY-mGBPJPY-mCHFJPY-mCADJPY-mAUDJPY -mNZDJPY)/(TotalDevise-1)))/7;  
     BufferGBP[i]=(BufferGBP[i+1]+BufferGBP[i+2]+((mEURGBP+mGBPJPY+mGBPUSD+mGBPCHF+mGBPCAD+mGBPAUD  +mGBPNZD  )/(TotalDevise-1)))/7; 
     BufferCHF[i]=(BufferCHF[i+1]+BufferCHF[i+2]+((mCHFJPY-mGBPCHF-mUSDCHF-mEURCHF+mCADCHF-mAUDCHF  +mNZDCHF)/(TotalDevise-1)))/7; 
	 BufferCAD[i]=(BufferCAD[i+1]+BufferCAD[i+2]+((mCADJPY-mGBPCAD-mUSDCAD-mEURCAD-mAUDCAD  -mNZDCAD-mCHFCAD)/(TotalDevise-1)))/7;
     BufferAUD[i]=(BufferAUD[i+1]+BufferAUD[i+2]+((mAUDJPY-mGBPAUD   -mEURAUD + mAUDUSD + mAUDCHF - mNZDCAD +mAUDCAD )/(TotalDevise-1)))/7;
	 
     BufferNZD[i]=(BufferNZD[i+1]+BufferNZD[i+2]+((mNZDUSD -mEURNZD-mGBPNZD+ mNZDJPY+  mNZDCHF +mNZDCAD - mAUDNZD)/(TotalDevise-1)))/7;
 
	     //USD EUR GBP JPY  CHF CAD  NZDAUD  NZD 
	 
     
     }
   return(0);
  }
//+------------------------------------------------------------------+