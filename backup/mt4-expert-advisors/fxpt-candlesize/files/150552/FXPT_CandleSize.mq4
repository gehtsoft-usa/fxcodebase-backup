// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73637

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

extern int TextPosition=10;
extern int TextAngle   =0;//0-90
extern int NumberBars  =100;//0-90
static datetime prevtime = 0;

double Poin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   if (Point==0.00001) Poin=0.0001;
   else {
      if (Point==0.001) Poin=0.01;
      else Poin=Point;
   }

//----
   return(0);
  }
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+
int deinit(){
   DeleteObjects();
   return(0);
}
//+------------------------------------------------------------------+
//                                                                   +
//+------------------------------------------------------------------+
void DeleteObjects(){
   int objs = ObjectsTotal();
   string name;
   for(int cnt=ObjectsTotal()-1;cnt>=0;cnt--)
   {
      name=ObjectName(cnt);
      if (StringFind(name,"FXPTc_",0)>-1) ObjectDelete(name);
     WindowRedraw();
   }
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
 
 string text,sObjName;
 double Rng;
 
 if(prevtime == Time[0]) {
	return(0);
 }
 DeleteObjects();
 
 for(int i=0; i<NumberBars; i++){
    Rng= MathAbs(Open[i] - Close[i])/Poin;

text=DoubleToStr(Rng,2);

if(Open[i] < Close[i]){
sObjName="FXPTc_label1"+i;
 ObjectCreate(sObjName, OBJ_TEXT, 0, Time[i], High[i]+TextPosition*Poin);
  ObjectSet(sObjName, OBJPROP_ANGLE, TextAngle);
ObjectSetText(sObjName,text,10, "Corbel", Green);
}
else{
sObjName="FXPTc_label1"+i;
 ObjectCreate(sObjName, OBJ_TEXT, 0, Time[i], Low[i]-TextPosition*Poin);
  ObjectSet(sObjName, OBJPROP_ANGLE, TextAngle);
ObjectSetText(sObjName,text,10, "Corbel", Red);

}
   
   
   }
   
//----
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