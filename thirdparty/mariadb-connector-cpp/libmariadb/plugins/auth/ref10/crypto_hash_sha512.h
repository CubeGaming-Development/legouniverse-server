#if defined(MYSQL_CLIENT) || defined(LIBMARIADB)
#include <ma_crypt.h>
#define crypto_hash_sha512(DST,SRC,SLEN) ma_hash(MA_HASH_SHA512, SRC, SLEN, DST)
#else
#include <mysql/service_sha2.h>
#define crypto_hash_sha512(DST,SRC,SLEN) my_sha512(DST,(char*)(SRC),SLEN)
#endif
