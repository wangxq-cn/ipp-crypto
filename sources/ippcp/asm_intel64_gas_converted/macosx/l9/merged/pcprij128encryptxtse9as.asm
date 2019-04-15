###############################################################################
# Copyright 2019 Intel Corporation
# All Rights Reserved.
#
# If this  software was obtained  under the  Intel Simplified  Software License,
# the following terms apply:
#
# The source code,  information  and material  ("Material") contained  herein is
# owned by Intel Corporation or its  suppliers or licensors,  and  title to such
# Material remains with Intel  Corporation or its  suppliers or  licensors.  The
# Material  contains  proprietary  information  of  Intel or  its suppliers  and
# licensors.  The Material is protected by  worldwide copyright  laws and treaty
# provisions.  No part  of  the  Material   may  be  used,  copied,  reproduced,
# modified, published,  uploaded, posted, transmitted,  distributed or disclosed
# in any way without Intel's prior express written permission.  No license under
# any patent,  copyright or other  intellectual property rights  in the Material
# is granted to  or  conferred  upon  you,  either   expressly,  by implication,
# inducement,  estoppel  or  otherwise.  Any  license   under such  intellectual
# property rights must be express and approved by Intel in writing.
#
# Unless otherwise agreed by Intel in writing,  you may not remove or alter this
# notice or  any  other  notice   embedded  in  Materials  by  Intel  or Intel's
# suppliers or licensors in any way.
#
#
# If this  software  was obtained  under the  Apache License,  Version  2.0 (the
# "License"), the following terms apply:
#
# You may  not use this  file except  in compliance  with  the License.  You may
# obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
#
#
# Unless  required  by   applicable  law  or  agreed  to  in  writing,  software
# distributed under the License  is distributed  on an  "AS IS"  BASIS,  WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#
# See the   License  for the   specific  language   governing   permissions  and
# limitations under the License.
###############################################################################

 
.text
.p2align 5, 0x90
 
ALPHA_MUL_CNT:
.quad                 0x87,                 0x1 
.p2align 5, 0x90
 
.globl _l9_cpAESEncryptXTS_AES_NI

 
_l9_cpAESEncryptXTS_AES_NI:
 
    sub          $(104), %rsp
 
    movslq       %r8d, %r8
    movdqu       (%r9), %xmm15
    shl          $(4), %r8
    movdqa       (%rcx), %xmm0
    movdqa       ALPHA_MUL_CNT(%rip), %xmm8
    pshufd       $(95), %xmm15, %xmm9
    movslq       %edx, %rdx
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    movdqa       %xmm15, %xmm10
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm0, %xmm10
    pxor         %xmm14, %xmm15
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    movdqa       %xmm15, %xmm11
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm0, %xmm11
    pxor         %xmm14, %xmm15
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    movdqa       %xmm15, %xmm12
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm0, %xmm12
    pxor         %xmm14, %xmm15
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    movdqa       %xmm15, %xmm13
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm0, %xmm13
    pxor         %xmm14, %xmm15
    movdqa       %xmm15, %xmm14
    psrad        $(31), %xmm9
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm9
    pxor         %xmm0, %xmm14
    pxor         %xmm9, %xmm15
    movdqa       %xmm15, %xmm8
    pxor         %xmm0, %xmm15
    sub          $(6), %rdx
    jc           .Lshort_inputgas_1
.p2align 5, 0x90
.Lblks_loopgas_1: 
    pxor         (%r8,%rcx), %xmm0
    lea          (-96)(%r8), %rax
    lea          (16)(%rcx,%rax), %r10
    neg          %rax
    movdqu       (%rsi), %xmm2
    movdqu       (16)(%rsi), %xmm3
    movdqu       (32)(%rsi), %xmm4
    movdqu       (48)(%rsi), %xmm5
    movdqu       (64)(%rsi), %xmm6
    movdqu       (80)(%rsi), %xmm7
    movdqa       (16)(%rcx), %xmm1
    pxor         %xmm10, %xmm2
    pxor         %xmm11, %xmm3
    pxor         %xmm12, %xmm4
    pxor         %xmm13, %xmm5
    pxor         %xmm14, %xmm6
    pxor         %xmm15, %xmm7
    pxor         %xmm0, %xmm10
    pxor         %xmm0, %xmm11
    pxor         %xmm0, %xmm12
    pxor         %xmm0, %xmm13
    pxor         %xmm0, %xmm14
    pxor         %xmm0, %xmm15
    movdqa       (32)(%rcx), %xmm0
    movdqa       %xmm10, (%rsp)
    movdqa       %xmm11, (16)(%rsp)
    movdqa       %xmm12, (32)(%rsp)
    movdqa       %xmm13, (48)(%rsp)
    movdqa       %xmm14, (64)(%rsp)
    movdqa       %xmm15, (80)(%rsp)
    add          $(96), %rsi
.p2align 5, 0x90
.Lcipher_loopgas_1: 
    add          $(32), %rax
    aesenc       %xmm1, %xmm2
    aesenc       %xmm1, %xmm3
    aesenc       %xmm1, %xmm4
    aesenc       %xmm1, %xmm5
    aesenc       %xmm1, %xmm6
    aesenc       %xmm1, %xmm7
    movdqa       (%r10,%rax), %xmm1
    aesenc       %xmm0, %xmm2
    aesenc       %xmm0, %xmm3
    aesenc       %xmm0, %xmm4
    aesenc       %xmm0, %xmm5
    aesenc       %xmm0, %xmm6
    aesenc       %xmm0, %xmm7
    movdqa       (16)(%r10,%rax), %xmm0
    jnz          .Lcipher_loopgas_1
    movdqa       (%rcx), %xmm10
    movdqa       %xmm8, %xmm15
    pshufd       $(95), %xmm8, %xmm9
    movdqa       ALPHA_MUL_CNT(%rip), %xmm8
    aesenc       %xmm1, %xmm2
    aesenc       %xmm1, %xmm3
    aesenc       %xmm1, %xmm4
    aesenc       %xmm1, %xmm5
    aesenc       %xmm1, %xmm6
    aesenc       %xmm1, %xmm7
    movdqa       (-48)(%r8,%rcx), %xmm1
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm14, %xmm15
    movdqa       %xmm10, %xmm11
    pxor         %xmm15, %xmm10
    aesenc       %xmm0, %xmm2
    aesenc       %xmm0, %xmm3
    aesenc       %xmm0, %xmm4
    aesenc       %xmm0, %xmm5
    aesenc       %xmm0, %xmm6
    aesenc       %xmm0, %xmm7
    movdqa       (-32)(%r8,%rcx), %xmm0
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm14, %xmm15
    movdqa       %xmm11, %xmm12
    pxor         %xmm15, %xmm11
    aesenc       %xmm1, %xmm2
    aesenc       %xmm1, %xmm3
    aesenc       %xmm1, %xmm4
    aesenc       %xmm1, %xmm5
    aesenc       %xmm1, %xmm6
    aesenc       %xmm1, %xmm7
    movdqa       (-16)(%r8,%rcx), %xmm1
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm14, %xmm15
    movdqa       %xmm12, %xmm13
    pxor         %xmm15, %xmm12
    aesenc       %xmm0, %xmm2
    aesenc       %xmm0, %xmm3
    aesenc       %xmm0, %xmm4
    aesenc       %xmm0, %xmm5
    aesenc       %xmm0, %xmm6
    aesenc       %xmm0, %xmm7
    movdqa       %xmm9, %xmm14
    paddd        %xmm9, %xmm9
    psrad        $(31), %xmm14
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm14
    pxor         %xmm14, %xmm15
    movdqa       %xmm13, %xmm14
    pxor         %xmm15, %xmm13
    aesenc       %xmm1, %xmm2
    aesenc       %xmm1, %xmm3
    aesenc       %xmm1, %xmm4
    aesenc       %xmm1, %xmm5
    aesenc       %xmm1, %xmm6
    aesenc       %xmm1, %xmm7
    movdqa       %xmm9, %xmm0
    paddd        %xmm9, %xmm9
    psrad        $(31), %xmm0
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm0
    pxor         %xmm0, %xmm15
    movdqa       %xmm14, %xmm0
    pxor         %xmm15, %xmm14
    aesenclast   (%rsp), %xmm2
    aesenclast   (16)(%rsp), %xmm3
    aesenclast   (32)(%rsp), %xmm4
    aesenclast   (48)(%rsp), %xmm5
    aesenclast   (64)(%rsp), %xmm6
    aesenclast   (80)(%rsp), %xmm7
    psrad        $(31), %xmm9
    paddq        %xmm15, %xmm15
    pand         %xmm8, %xmm9
    pxor         %xmm9, %xmm15
    movdqa       %xmm15, %xmm8
    pxor         %xmm0, %xmm15
    movdqu       %xmm2, (%rdi)
    movdqu       %xmm3, (16)(%rdi)
    movdqu       %xmm4, (32)(%rdi)
    movdqu       %xmm5, (48)(%rdi)
    movdqu       %xmm6, (64)(%rdi)
    movdqu       %xmm7, (80)(%rdi)
    add          $(96), %rdi
    sub          $(6), %rdx
    jnc          .Lblks_loopgas_1
.Lshort_inputgas_1: 
    add          $(6), %rdx
    jz           .Lquitgas_1
    movdqa       %xmm10, (%rsp)
    movdqa       %xmm11, (16)(%rsp)
    movdqa       %xmm12, (32)(%rsp)
    movdqa       %xmm13, (48)(%rsp)
    movdqa       %xmm14, (64)(%rsp)
    movdqa       %xmm15, (80)(%rsp)
    movdqa       (%rcx), %xmm0
    pxor         (%r8,%rcx), %xmm0
    lea          (-144)(%r8,%rcx), %r10
    xor          %rax, %rax
.Lsingle_blk_loopgas_1: 
    movdqu       (%rsi), %xmm2
    movdqa       (%rsp,%rax), %xmm1
    add          $(16), %rsi
    pxor         %xmm1, %xmm2
    pxor         %xmm0, %xmm1
    cmp          $(192), %r8
    jl           .Lkey_128_sgas_1
.Lkey_256_sgas_1: 
    aesenc       (-64)(%r10), %xmm2
    aesenc       (-48)(%r10), %xmm2
    aesenc       (-32)(%r10), %xmm2
    aesenc       (-16)(%r10), %xmm2
.Lkey_128_sgas_1: 
    aesenc       (%r10), %xmm2
    aesenc       (16)(%r10), %xmm2
    aesenc       (32)(%r10), %xmm2
    aesenc       (48)(%r10), %xmm2
    aesenc       (64)(%r10), %xmm2
    aesenc       (80)(%r10), %xmm2
    aesenc       (96)(%r10), %xmm2
    aesenc       (112)(%r10), %xmm2
    aesenc       (128)(%r10), %xmm2
    aesenclast   %xmm1, %xmm2
    movdqu       %xmm2, (%rdi)
    add          $(16), %rdi
    add          $(16), %rax
    sub          $(1), %rdx
    jnz          .Lsingle_blk_loopgas_1
    movdqa       (%rsp,%rax), %xmm10
.Lquitgas_1: 
    pxor         (%rcx), %xmm10
    movdqu       %xmm10, (%r9)
    pxor         %xmm1, %xmm1
    add          $(104), %rsp
vzeroupper 
 
    ret
 