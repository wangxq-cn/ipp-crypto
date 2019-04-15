/*******************************************************************************
* Copyright 2016-2019 Intel Corporation
* All Rights Reserved.
*
* If this  software was obtained  under the  Intel Simplified  Software License,
* the following terms apply:
*
* The source code,  information  and material  ("Material") contained  herein is
* owned by Intel Corporation or its  suppliers or licensors,  and  title to such
* Material remains with Intel  Corporation or its  suppliers or  licensors.  The
* Material  contains  proprietary  information  of  Intel or  its suppliers  and
* licensors.  The Material is protected by  worldwide copyright  laws and treaty
* provisions.  No part  of  the  Material   may  be  used,  copied,  reproduced,
* modified, published,  uploaded, posted, transmitted,  distributed or disclosed
* in any way without Intel's prior express written permission.  No license under
* any patent,  copyright or other  intellectual property rights  in the Material
* is granted to  or  conferred  upon  you,  either   expressly,  by implication,
* inducement,  estoppel  or  otherwise.  Any  license   under such  intellectual
* property rights must be express and approved by Intel in writing.
*
* Unless otherwise agreed by Intel in writing,  you may not remove or alter this
* notice or  any  other  notice   embedded  in  Materials  by  Intel  or Intel's
* suppliers or licensors in any way.
*
*
* If this  software  was obtained  under the  Apache License,  Version  2.0 (the
* "License"), the following terms apply:
*
* You may  not use this  file except  in compliance  with  the License.  You may
* obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
*
*
* Unless  required  by   applicable  law  or  agreed  to  in  writing,  software
* distributed under the License  is distributed  on an  "AS IS"  BASIS,  WITHOUT
* WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
*
* See the   License  for the   specific  language   governing   permissions  and
* limitations under the License.
*******************************************************************************/

/*
//     Intel(R) Integrated Performance Primitives. Cryptography Primitives.
// 
//     Context:
//        ippsGFpECSignDSA()
//
*/

#include "owndefs.h"
#include "owncp.h"
#include "pcpeccp.h"

/*F*
//    Name: ippsGFpECSignDSA
//
// Purpose: DSA Signature Generation.
//
// Returns:                   Reason:
//    ippStsNullPtrErr           NULL == pEC
//                               NULL == pMsgDigest
//                               NULL == pRegPrivate
//                               NULL == pEphPrivate
//                               NULL == pSignR
//                               NULL == pSignS
//                               NULL == pScratchBuffer
//
//    ippStsContextMatchErr      illegal pEC->idCtx
//                               pEC->subgroup == NULL
//                               illegal pMsgDigest->idCtx
//                               illegal pRegPrivate->idCtx
//                               illegal pEphPrivate->idCtx
//                               illegal pSignR->idCtx
//                               illegal pSignS->idCtx
//
//    ippStsIvalidPrivateKey     0 >= RegPrivate
//                               RegPrivate >= order
//
//                               0 >= EphPrivate
//                               EphPrivate >= order
//
//    ippStsMessageErr           MsgDigest >= order
//                               MsgDigest <  0
//
//    ippStsRangeErr             not enough room for:
//                               signR
//                               signS
//
//    ippStsEphemeralKeyErr      (0==signR) || (0==signS)
//
//    ippStsNotSupportedModeErr  pGFE->extdegree > 1
//
//
//    ippStsNoErr                no errors
//
// Parameters:
//    pMsgDigest     pointer to the message representative to be signed
//    pRegPrivate    pointer to the regular private key
//    pEphPrivate    pointer to the ephemeral private key
//    pSignR,pSignS  pointer to the signature
//    pEC            pointer to the EC context
//    pScratchBuffer pointer to buffer (1 mul_point operation)
//
*F*/
IPPFUN(IppStatus, ippsGFpECSignDSA,(const IppsBigNumState* pMsgDigest,
                                    const IppsBigNumState* pRegPrivate,
                                    const IppsBigNumState* pEphPrivate,
                                    IppsBigNumState* pSignR, IppsBigNumState* pSignS,
                                    IppsGFpECState* pEC,
                                    Ipp8u* pScratchBuffer))
{
   IppsGFpState*  pGF;
   gsModEngine* pMontP;

   /* EC context and buffer */
   IPP_BAD_PTR2_RET(pEC, pScratchBuffer);
   pEC = (IppsGFpECState*)( IPP_ALIGNED_PTR(pEC, ECGFP_ALIGNMENT) );
   IPP_BADARG_RET(!ECP_TEST_ID(pEC), ippStsContextMatchErr);
   IPP_BADARG_RET(!ECP_SUBGROUP(pEC), ippStsContextMatchErr);

   pGF = ECP_GFP(pEC);
   pMontP = GFP_PMA(pGF);
   IPP_BADARG_RET(1<GFP_EXTDEGREE(pMontP), ippStsNotSupportedModeErr);

   /* test message representative */
   IPP_BAD_PTR1_RET(pMsgDigest);
   pMsgDigest = (IppsBigNumState*)( IPP_ALIGNED_PTR(pMsgDigest, ALIGN_VAL) );
   IPP_BADARG_RET(!BN_VALID_ID(pMsgDigest), ippStsContextMatchErr);
   IPP_BADARG_RET(BN_NEGATIVE(pMsgDigest), ippStsMessageErr);

   /* test signature */
   IPP_BAD_PTR2_RET(pSignR, pSignS);
   pSignR = (IppsBigNumState*)( IPP_ALIGNED_PTR(pSignR, BN_ALIGNMENT) );
   pSignS = (IppsBigNumState*)( IPP_ALIGNED_PTR(pSignS, BN_ALIGNMENT) );
   IPP_BADARG_RET(!BN_VALID_ID(pSignR), ippStsContextMatchErr);
   IPP_BADARG_RET(!BN_VALID_ID(pSignS), ippStsContextMatchErr);
   IPP_BADARG_RET((BN_ROOM(pSignR)*BITSIZE(BNU_CHUNK_T)<ECP_ORDBITSIZE(pEC)), ippStsRangeErr);
   IPP_BADARG_RET((BN_ROOM(pSignS)*BITSIZE(BNU_CHUNK_T)<ECP_ORDBITSIZE(pEC)), ippStsRangeErr);

   /* test private keys */
   IPP_BAD_PTR2_RET(pRegPrivate, pEphPrivate);

   pRegPrivate = (IppsBigNumState*)( IPP_ALIGNED_PTR(pRegPrivate, ALIGN_VAL) );
   IPP_BADARG_RET(!BN_VALID_ID(pRegPrivate), ippStsContextMatchErr);
   IPP_BADARG_RET(BN_NEGATIVE(pRegPrivate), ippStsIvalidPrivateKey);

   pEphPrivate = (IppsBigNumState*)( IPP_ALIGNED_PTR(pEphPrivate, ALIGN_VAL) );
   IPP_BADARG_RET(!BN_VALID_ID(pEphPrivate), ippStsContextMatchErr);
   IPP_BADARG_RET(BN_NEGATIVE(pEphPrivate), ippStsEphemeralKeyErr);

   {
      gsModEngine* pMontR = ECP_MONT_R(pEC);
      BNU_CHUNK_T* pOrder = MOD_MODULUS(pMontR);
      int ordLen = MOD_LEN(pMontR);

      BNU_CHUNK_T* dataC = BN_NUMBER(pSignR);
      BNU_CHUNK_T* dataD = BN_NUMBER(pSignS);
      BNU_CHUNK_T* buffF = BN_BUFFER(pSignR);
      BNU_CHUNK_T* buffT = BN_BUFFER(pSignS);

      BNU_CHUNK_T* pPriData = BN_NUMBER(pRegPrivate);
      int priLen = BN_SIZE(pRegPrivate);

      BNU_CHUNK_T* pEphData = BN_NUMBER(pEphPrivate);
      int ephLen = BN_SIZE(pEphPrivate);

      BNU_CHUNK_T* pMsgData = BN_NUMBER(pMsgDigest);
      int msgLen = BN_SIZE(pMsgDigest);

      /* test value of private keys: 0 < regPrivate < order, 0 < ephPrivate < order */
      IPP_BADARG_RET(cpEqu_BNU_CHUNK(pPriData, priLen, 0) ||
                  0<=cpCmp_BNU(pPriData, priLen, pOrder, ordLen), ippStsIvalidPrivateKey);
      IPP_BADARG_RET(cpEqu_BNU_CHUNK(pEphData, ephLen, 0) ||
                  0<=cpCmp_BNU(pEphData, ephLen, pOrder, ordLen), ippStsEphemeralKeyErr);

      /* make sure msg <order */
      IPP_BADARG_RET(0<=cpCmp_BNU(pMsgData, msgLen, pOrder, ordLen), ippStsMessageErr);

      {
         int elmLen = GFP_FELEN(pMontP);
         int ns;

         /* compute ephemeral public key */
         IppsGFpECPoint ephPublic;
         cpEcGFpInitPoint(&ephPublic, cpEcGFpGetPool(1, pEC), 0, pEC);
         gfec_MulBasePoint(&ephPublic,
                           BN_NUMBER(pEphPrivate), BN_SIZE(pEphPrivate),
                           pEC, pScratchBuffer);

         /*
         // signR = int(ephPublic.x) (mod order)
         */
         {
            BNU_CHUNK_T* buffer = gsModPoolAlloc(pMontP, 1);
            gfec_GetPoint(buffer, NULL, &ephPublic, pEC);
            GFP_METHOD(pMontP)->decode(buffer, buffer, pMontP);
            ns = cpMod_BNU(buffer, elmLen, pOrder, ordLen);
            cpGFpElementCopyPadd(dataC, ordLen, buffer, ns);
            gsModPoolFree(pMontP, 1);
         }
         cpEcGFpReleasePool(1, pEC);

         if(!GFP_IS_ZERO(dataC, ordLen)) {
            /*
            // signS = (1/ephPrivate)*(pMsgDigest + private*signR) (mod order)
            */

            /* reduce message: msg = msg mod ordfer */
            BNU_CHUNK_T* buffMsg= BN_BUFFER(pMsgDigest);
            COPY_BNU(buffMsg, pMsgData, msgLen);
            ns = cpMod_BNU(buffMsg, msgLen, pOrder, ordLen);
            /* copy and expand message is being signed */
            ZEXPAND_COPY_BNU(buffF, ordLen, buffMsg, ns);

            /* private representation in Montgomery domain */
            ZEXPAND_COPY_BNU(dataD, ordLen, pPriData, priLen);
            GFP_METHOD(pMontR)->encode(dataD, dataD, pMontR);

            /* (private*signX) in regular domain */
            GFP_METHOD(pMontR)->mul(dataD, dataD, dataC, pMontR);

            /* pMsgDigest + private*signX */
            cpModAdd_BNU(dataD, dataD, buffF, pOrder, ordLen, buffT);

            if(!GFP_IS_ZERO(dataD, ordLen)) {
               /* (1/ephPrivate) in Montgomery domain */
               ZEXPAND_COPY_BNU(buffT, ordLen, pEphData, ephLen);
               gs_mont_inv(buffT, buffT, pMontR, alm_mont_inv_ct);

               /* (1/ephPrivate)*(pMsgDigest + private*signS) */
               GFP_METHOD(pMontR)->mul(dataD, dataD, buffT, pMontR);

               /* signR */
               ns = ordLen;
               FIX_BNU(dataC, ns);
               BN_SIGN(pSignR) = ippBigNumPOS;
               BN_SIZE(pSignR) = ns;
               /* signS */
               ns = ordLen;
               FIX_BNU(dataD, ns);
               BN_SIGN(pSignS) = ippBigNumPOS;
               BN_SIZE(pSignS) = ns;

               return ippStsNoErr;
            }
         }

         return ippStsEphemeralKeyErr;
      }
   }
}