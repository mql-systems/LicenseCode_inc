//+------------------------------------------------------------------+
//|                                                DeleteObjects.mq5 |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   ObjectsDeleteAll(ChartID(), "LicenseKeys");
   ObjectsDeleteAll(ChartID(), "LicenseCode");
}

//+------------------------------------------------------------------+
