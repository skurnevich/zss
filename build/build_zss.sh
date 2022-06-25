#!/bin/sh
set -e

################################################################################
#  This program and the accompanying materials are
#  made available under the terms of the Eclipse Public License v2.0 which accompanies
#  this distribution, and is available at https://www.eclipse.org/legal/epl-v20.html
#
#  SPDX-License-Identifier: EPL-2.0
#
#  Copyright Contributors to the Zowe Project.
################################################################################


export _C89_LSYSLIB="CEE.SCEELKED:SYS1.CSSLIB:CSF.SCSFMOD0"

WORKING_DIR=$(dirname "$0")
ZSS="../.."
COMMON="../../deps/zowe-common-c"
GSKDIR=/usr/lpp/gskssl
GSKINC="${GSKDIR}/include"
GSKLIB="${GSKDIR}/lib/GSKSSL.x ${GSKDIR}/lib/GSKCMS31.x"


echo "********************************************************************************"
echo "Building ZSS..."

rm -f ${ZSS}/bin/zssServer

mkdir -p "${WORKING_DIR}/tmp-zss" && cd "$_"

IFS='.' read -r major minor micro < "${ZSS}/version.txt"
date_stamp=$(date +%Y%m%d)
echo "Version: $major.$minor.$micro"
echo "Date stamp: $date_stamp"

export _C89_ACCEPTABLE_RC=0

if ! c89 \
  -c -O2 \
  -DPRODUCT_MAJOR_VERSION="$major" \
  -DPRODUCT_MINOR_VERSION="$minor" \
  -DPRODUCT_REVISION="$micro" \
  -DPRODUCT_VERSION_DATE_STAMP="$date_stamp" \
  -D_XOPEN_SOURCE=600 \
  -DNOIBMHTTP=1 \
  -D_OPEN_THREADS=1 \
  -DHTTPSERVER_BPX_IMPERSONATION=1 \
  -DAPF_AUTHORIZED=0 \
  -Wc,dll,expo,langlvl\(extc99\),gonum,goff,hgpr,roconst,ASM,asmlib\('CEE.SCEEMAC','SYS1.MACLIB','SYS1.MODGEN'\) \
  -Wc,agg,exp,list\(\),so\(\),off,xref \
  -I ${COMMON}/h \
  -I ${COMMON}/platform/posix \
  -I ${COMMON}/jwt/jwt \
  -I ${COMMON}/jwt/rscrypto \
  -I ${ZSS}/h \
  ${COMMON}/c/charsets.c \
  ${COMMON}/c/collections.c \
  ${COMMON}/c/json.c ;
then
  echo "Build failed"
  exit 8
fi

if c89 \
  -DPRODUCT_MAJOR_VERSION="$major" \
  -DPRODUCT_MINOR_VERSION="$minor" \
  -DPRODUCT_REVISION="$micro" \
  -DPRODUCT_VERSION_DATE_STAMP="$date_stamp" \
  -D_XOPEN_SOURCE=600 \
  -DNOIBMHTTP=1 \
  -D_OPEN_THREADS=1 \
  -DUSE_ZOWE_TLS=1 \
  -DHTTPSERVER_BPX_IMPERSONATION=1 \
  -DAPF_AUTHORIZED=0 \
  -Wc,dll,expo,langlvl\(extc99\),gonum,goff,hgpr,roconst,ASM,asmlib\('CEE.SCEEMAC','SYS1.MACLIB','SYS1.MODGEN'\) \
  -Wc,agg,exp,list\(\),so\(\),off,xref \
  -Wl,ac=1,dll \
  -I ${COMMON}/h \
  -I ${COMMON}/platform/posix \
  -I ${COMMON}/jwt/jwt \
  -I ${COMMON}/jwt/rscrypto \
  -I ${ZSS}/h \
  -I ${GSKINC} \
  -o ${ZSS}/bin/zssServer \
  ${COMMON}/c/alloc.c \
  ${COMMON}/c/bpxskt.c \
  charsets.o \
  ${COMMON}/c/cmutils.c \
  collections.o \
  ${COMMON}/c/crossmemory.c \
  ${COMMON}/c/configmgr.c \
  ${COMMON}/c/crypto.c \
  ${COMMON}/c/dataservice.c \
  ${COMMON}/c/discovery.c \
  ${COMMON}/c/dynalloc.c \
  ${COMMON}/c/embeddedjs.c \
  ${COMMON}/c/fdpoll.c \
  ${COMMON}/c/http.c \
  ${COMMON}/c/httpclient.c \
  ${COMMON}/c/httpserver.c \
  ${COMMON}/c/httpfileservice.c \
  ${COMMON}/c/icsf.c \
  ${COMMON}/c/idcams.c \
  ${COMMON}/c/impersonation.c \
  ${COMMON}/c/jcsi.c \
  json.o \
  ${COMMON}/jwt/jwt/jwt.c \
  ${COMMON}/c/le.c \
  ${COMMON}/c/logging.c \
  ${COMMON}/c/microjq.c \
  ${COMMON}/c/nametoken.c \
  ${COMMON}/c/zos.c \
  ${COMMON}/c/pdsutil.c \
  ${COMMON}/c/qsam.c \
  ${COMMON}/c/radmin.c \
  ${COMMON}/c/rawfd.c \
  ${COMMON}/c/recovery.c \
  ${COMMON}/jwt/rscrypto/rs_icsfp11.c \
  ${COMMON}/jwt/rscrypto/rs_rsclibc.c \
  ${COMMON}/c/scheduling.c \
  ${COMMON}/c/signalcontrol.c \
  ${COMMON}/c/socketmgmt.c \
  ${COMMON}/c/stcbase.c \
  ${COMMON}/c/storage.c \
  ${COMMON}/c/storage_mem.c \
  ${COMMON}/c/timeutls.c \
  ${COMMON}/c/tls.c \
  ${COMMON}/c/utils.c \
  ${COMMON}/c/vsam.c \
  ${COMMON}/c/xlate.c \
  ${COMMON}/c/xml.c \
  ${COMMON}/c/zosaccounts.c \
  ${COMMON}/c/zosfile.c \
  ${COMMON}/c/zvt.c \
  ${ZSS}/c/zssLogging.c \
  ${ZSS}/c/zss.c \
  ${ZSS}/c/storageApiml.c \
  ${ZSS}/c/serviceUtils.c \
  ${ZSS}/c/authService.c \
  ${ZSS}/c/omvsService.c \
  ${ZSS}/c/certificateService.c \
  ${ZSS}/c/unixFileService.c \
  ${ZSS}/c/datasetService.c \
  ${ZSS}/c/datasetjson.c \
  ${ZSS}/c/envService.c \
  ${ZSS}/c/zosDiscovery.c \
  ${ZSS}/c/securityService.c \
  ${ZSS}/c/registerProduct.c \
  ${ZSS}/c/zis/client.c \
  ${ZSS}/c/serverStatusService.c \
  ${ZSS}/c/rasService.c \
  ${ZSS}/c/userInfoService.c \
  ${ZSS}/c/passTicketService.c \
  ${ZSS}/c/jwk.c \
  ${ZSS}/c/safIdtService.c \
  ${GSKLIB} ;
then
  extattr +p ${ZSS}/bin/zssServer
  echo "Build successful"
  exit 0
else
  # remove zssServer in case the linker had RC=4 and produced the binary
  rm -f ${ZSS}/bin/zssServer
  echo "Build failed"
  exit 8
fi
