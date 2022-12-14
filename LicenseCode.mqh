//+------------------------------------------------------------------+
//|                                                  LicenseCode.mqh |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.03"
#property strict

#define LC_CHECK_TIME_UNLIMITED  1

enum ENUM_LICENSE_CODE_TYPE
{
   LCT_LIFETIME = 1,
   LCT_LIMITED  = 2
};

//+------------------------------------------------------------------+
//| class CLicenseCode - Multi-MQL License Code                      |
//+------------------------------------------------------------------+
class CLicenseCode
{
   private:
      string                  m_LicenseCode;
      string                  m_SaltMd5;
      string                  m_SaltAes32Bit;
      ulong                   excludedAccounts[];
      //---
      ENUM_LICENSE_CODE_TYPE  m_LicenseType;
      int                     m_LicenseStatus;
      datetime                m_LicenseTime;
      //---
      datetime                m_CheckTime;
      
      //---
      bool                    CheckExcludedAccount(const ulong accountLogin);
      bool                    CheckLctLifetime(const ulong accountLogin);
      bool                    CheckLctLimited(const ulong accountLogin);
      //---
      int                     RandomRange(const int min, const int max) { return MathRand() % (max - min + 1) + min; };
   
   public:
                              CLicenseCode(void);
                             ~CLicenseCode(void);
      //---
      void                    Init(const string licenseCode, const string saltMd5);
      void                    Init(const string licenseCode, const string saltMd5, const string saltAes32Bit);
      bool                    ExcludeAccount(const ulong accountLogin);
      bool                    CheckLicense();
      //---
      int                     GetLicenseStatus() { return m_LicenseStatus; };
      datetime                GetLicenseTime()   { return m_LicenseTime;   };
      //--- Generate
      string                  GenerateLicenseCode(const ulong ccountLogin, const string saltMd5);
      string                  GenerateLicenseCode(const ulong accountLogin, const string saltMd5, const string saltAes32Bit, const datetime timeUntil);
      string                  GenerateSalt(const bool forAes256 = false);
      //--- CRYPT
      string                  Md5(const string str);
      string                  Aes256Decode(const string base64, const string key);
};

//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CLicenseCode::CLicenseCode(void): m_LicenseStatus(0)
{
   MathSrand(GetTickCount());
}

//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
void CLicenseCode::~CLicenseCode(void)
{}

//+------------------------------------------------------------------+
//| Initialize (for MD5 hash)                                        |
//+------------------------------------------------------------------+
void CLicenseCode::Init(const string licenseCode, const string saltMd5)
{
   m_LicenseType = LCT_LIFETIME;
   Init(licenseCode, saltMd5, "");
}

//+------------------------------------------------------------------+
//| Initialize (for AES-256 crypt)                                   |
//+------------------------------------------------------------------+
void CLicenseCode::Init(const string licenseCode, const string saltMd5, const string saltAes32Bit)
{
   m_SaltMd5 = saltMd5;
   m_SaltAes32Bit = saltAes32Bit;
   m_LicenseCode = licenseCode;
   //---
   m_LicenseStatus = 0;
   m_CheckTime = 0;
   //---
   if (m_LicenseType != LCT_LIFETIME)
      m_LicenseType = LCT_LIMITED;
}

//+------------------------------------------------------------------+
//| Exclude an account                                               |
//+------------------------------------------------------------------+
bool CLicenseCode::ExcludeAccount(const ulong accountLogin)
{
   if (accountLogin <= 0)
      return false;
   
   int arrSize = ArraySize(excludedAccounts);
   
   if (arrSize > 0 && CheckExcludedAccount(accountLogin))
      return true;
   
   if (ArrayResize(excludedAccounts, arrSize+1) == -1)
      return false;
   
   excludedAccounts[arrSize] = accountLogin;
   return true;
}

//+------------------------------------------------------------------+
//| Check License code                                               |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLicense()
{
   if (m_LicenseStatus == 1)
   {
      if (m_CheckTime == LC_CHECK_TIME_UNLIMITED || m_CheckTime > TimeCurrent())
         return true;
      
      m_LicenseStatus = 0;
   }
   else if (m_LicenseStatus == -1)
      return false;
   
   //--- checking the terminal and account status
   if (! TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   ulong accountLogin = (ulong)AccountInfoInteger(ACCOUNT_LOGIN);
   if (accountLogin < 1)
      return false;
   
   if (CheckExcludedAccount(accountLogin))
   {
      m_LicenseStatus = 1;
      m_CheckTime = LC_CHECK_TIME_UNLIMITED;
      return true;
   }
   
   //--- checking the minimum data for key generation
   if (StringLen(m_LicenseCode) < 32 || StringLen(m_SaltMd5) < 1)
   {
      m_LicenseStatus = -1;
      m_CheckTime = 0;
      return false;
   }
   
   //--- checking license
   m_LicenseStatus = -1;
   m_CheckTime = (bool)MQLInfoInteger(MQL_TESTER) ? LC_CHECK_TIME_UNLIMITED : 0;
   
   switch (m_LicenseType)
   {
      case LCT_LIFETIME:
         if (! CheckLctLifetime(accountLogin))
            return false;
         if (m_CheckTime != LC_CHECK_TIME_UNLIMITED)
            m_CheckTime = TimeCurrent() + 86400; // +24 hours
         break;
      
      case LCT_LIMITED:
         if (! CheckLctLimited(accountLogin))
            return false;
         if (m_CheckTime != LC_CHECK_TIME_UNLIMITED)
            m_CheckTime = m_LicenseTime;
         break;
      
      default: return false;
   }
   
   m_LicenseStatus = 1;
   return true;
}

//+------------------------------------------------------------------+
//| Check the excluded account                                       |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckExcludedAccount(const ulong accountLogin)
{
   int i1 = ArrayBsearch(excludedAccounts, accountLogin);
   
   return (i1 != -1 && excludedAccounts[i1] == accountLogin);
}

//+------------------------------------------------------------------+
//| Check LicenseCode Type-Lifetime                                  |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLctLifetime(const ulong accountLogin)
{
   string code = m_SaltMd5 + string(accountLogin);
   
   return (StringCompare(Md5(code), m_LicenseCode, true) == 0);
}

//+------------------------------------------------------------------+
//| Check LicenseCode Type-Limited                                   |
//+------------------------------------------------------------------+
bool CLicenseCode::CheckLctLimited(const ulong accountLogin)
{
   //--- Decode and parse license
   string licenseDecode = Aes256Decode(m_LicenseCode, m_SaltAes32Bit);
   
   if (StringLen(licenseDecode) != 42)
      return false;
   
   string md5Hash = StringSubstr(licenseDecode, 0, 32);
   string timeStr = StringSubstr(licenseDecode, 32);
   
   //--- Check time
   string checkCode = m_SaltMd5 + string(accountLogin) + timeStr;
   
   if (StringCompare(Md5(checkCode), md5Hash, true) != 0)
      return false;
   
   m_LicenseTime = datetime(int(timeStr));
   
   return (m_LicenseTime > TimeCurrent());
}

//+------------------------------------------------------------------+
//| Generate License code (for MD5 hash)                             |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateLicenseCode(const ulong accountLogin, const string saltMd5)
{
   string code = saltMd5 + string(accountLogin);
   
   return Md5(code);
}

//+------------------------------------------------------------------+
//| Generate License code (for AES-256 crypt)                        |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateLicenseCode(const ulong accountLogin, const string saltMd5, const string saltAes32Bit, const datetime timeUntil)
{
   if (StringLen(saltAes32Bit) != 32 || StringLen(saltMd5) < 1)
      return "";
   
   string timeStr = string(int(timeUntil));
   string code = saltMd5 + string(accountLogin) + timeStr;
   code = Md5(code) + timeStr;
   
   uchar src[], keyAes[], dstAes[], dstBase64[];
   const uchar keyBase64[] = {};
   
   StringToCharArray(code, src, 0, StringLen(code));
   StringToCharArray(saltAes32Bit, keyAes, 0, StringLen(saltAes32Bit));
   
   if (CryptEncode(CRYPT_AES256, src, keyAes, dstAes) > 0 &&
       CryptEncode(CRYPT_BASE64, dstAes, keyBase64, dstBase64) > 0)
   {
      return CharArrayToString(dstBase64);
   }
   
   return "";
}

//+------------------------------------------------------------------+
//| Generate salt (key)                                              |
//+------------------------------------------------------------------+
string CLicenseCode::GenerateSalt(const bool forAes256 = false)
{
   string strBase = "abcdefghijklmnopqrstuvwxyz" + "0123456789"; // 36
   
   if (! forAes256)
      strBase += "ABCDEFGHIJKLMNOPQRSTUVWXYZ" + "!@#$&()?/+="; // 73
   
   string result = "";
   int strBaseCnt = StringLen(strBase);
   
   for (int i=31; i>=0; i--)
      result += StringSubstr(strBase, RandomRange(0, strBaseCnt-1), 1);
   
   return result;
}

//+------------------------------------------------------------------+
//| MD5                                                              |
//+------------------------------------------------------------------+
string CLicenseCode::Md5(const string str)
{
   if (StringLen(str) == 0)
      return "D41D8CD98F00B204E9800998ECF8427E"; // empty md5
 
   string res = "";
   uchar src[], dst[];
   const uchar key[] = {};
   
   StringToCharArray(str, src, 0, StringLen(str));
   
   if (CryptEncode(CRYPT_HASH_MD5, src, key, dst) <= 0)
      return res;
   
   int cnt = ArraySize(dst);
   for (int i=0; i<cnt; i++)
      res += StringFormat("%.2X", dst[i]);

   return res;
}

//+------------------------------------------------------------------+
//| AES-256-ECB decode                                               |
//+------------------------------------------------------------------+
string CLicenseCode::Aes256Decode(const string base64, const string key)
{
   uchar src[], keyAes[], dstBase64[], dstAes[];
   const uchar keyEmpty[] = {};
   
   StringToCharArray(base64, src, 0, StringLen(base64));
   StringToCharArray(key, keyAes, 0, StringLen(key));
   
   if (CryptDecode(CRYPT_BASE64, src, keyEmpty, dstBase64) > 0 &&
       CryptDecode(CRYPT_AES256, dstBase64, keyAes, dstAes) > 0)
   {
      // check 16 bit
      int dstAesCnt = ArraySize(dstAes);
      uchar dstAesEnd = dstAes[dstAesCnt-1];
      
      if (dstAesEnd == 0)
      {
         int i;
         for (i=dstAesCnt-1; i>=0; i--)
         {
            if (dstAes[i] != 0)
               break;
         }
         if (i < (dstAesCnt-1) && ArrayResize(dstAes, i+1) <= 0)
            return "";
      }
      else if (dstAesEnd <= 16)
      {
         if (dstAesCnt <= dstAesEnd || (dstAes[dstAesCnt-dstAesEnd] == dstAesEnd && ArrayResize(dstAes, dstAesCnt-dstAesEnd) <= 0))
            return "";
      }
      
      //--- result
      return CharArrayToString(dstAes);
   }
   
   return "";
}

//+------------------------------------------------------------------+
