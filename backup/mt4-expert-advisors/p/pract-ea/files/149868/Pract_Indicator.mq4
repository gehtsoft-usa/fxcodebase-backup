//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73453


//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
 
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Red

extern int arrowSize = 2;
extern bool AlertON = True;

double upArrow[], dnArrow[];
double Dir[];
datetime lastAlert;

int init() {
	IndicatorBuffers(3);
	SetIndexBuffer(0,upArrow);
	SetIndexBuffer(1,dnArrow);
	SetIndexBuffer(2,Dir);
	SetIndexStyle(0,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexStyle(1,DRAW_ARROW,STYLE_SOLID,arrowSize);
	SetIndexArrow(0,233);	
	SetIndexArrow(1,234);
	IndicatorDigits(Digits+1);
	lastAlert = Time[0];
	return(0);
}

int start() {
   int    limit;
   int    counted_bars=IndicatorCounted();
   if(counted_bars>0) counted_bars--;
   if(counted_bars<1) ArrayInitialize(Dir,0.0);
   limit=Bars-counted_bars;
   for(int i=limit; i>0; i--) {
   		int Current = i;
   		int Order = 0;
		double Buy1_1 = iClose(NULL, 0, Current + 1);
		double Buy1_2 = iHigh(NULL, 0, Current + 2);
		double Buy2_1 = iClose(NULL, 0, Current + 0);
		double Buy2_2 = iHigh(NULL, 0, Current + 1);
		double Buy3_1 = iClose(NULL, 0, Current + 0);
		double Buy3_2 = iHigh(NULL, 0, Current + 2);

		double Sell1_1 = iClose(NULL, 0, Current + 1);
		double Sell1_2 = iLow(NULL, 0, Current + 2);
		double Sell2_1 = iClose(NULL, 0, Current + 0);
		double Sell2_2 = iLow(NULL, 0, Current + 1);
		double Sell3_1 = iClose(NULL, 0, Current + 0);
		double Sell3_2 = iLow(NULL, 0, Current + 2);
   		if (Buy1_1 <= Buy1_2 && Buy2_1 > Buy2_2 && Buy3_1 > Buy3_2) Order = 1;
   		if (Sell1_1 >= Sell1_2 && Sell2_1 < Sell2_2 && Sell3_1 < Sell3_2) Order = -1;
   		if(Order==0) Dir[i] = Dir[i+1];
   		else Dir[i] = Order;
   		if(Dir[i]!=Dir[i+1]){
   			if(Dir[i]==1) {
   		 		upArrow[i] = Low[i]-0.5*iATR(NULL,0,10,i+1);
   		 		if(Time[i]>lastAlert){
   		 			lastAlert = Time[i];
   		 			Alert("UP");
   		 		}
   		 	}
   			else if(Dir[i]==-1) {
   				dnArrow[i] = High[i]+0.5*iATR(NULL,0,10,i+1);
   		 		if(Time[i]>lastAlert){
   		 			lastAlert = Time[i];
   		 			Alert("DOWN");
   		 		}
   			}
   		}
   	}
   return(0);
}
//+------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

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