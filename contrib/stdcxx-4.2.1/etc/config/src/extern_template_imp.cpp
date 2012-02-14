
/***************************************************************************
 *
 * Licensed to the Apache Software  Foundation (ASF) under one or more
 * contributor  license agreements.  See  the NOTICE  file distributed
 * with  this  work  for  additional information  regarding  copyright
 * ownership.   The ASF  licenses this  file to  you under  the Apache
 * License, Version  2.0 (the  License); you may  not use  this file
 * except in  compliance with the License.   You may obtain  a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the  License is distributed on an  "AS IS" BASIS,
 * WITHOUT  WARRANTIES OR CONDITIONS  OF ANY  KIND, either  express or
 * implied.   See  the License  for  the  specific language  governing
 * permissions and limitations under the License.
 *
 * Copyright 1999-2007 Rogue Wave Software, Inc.
 * 
 **************************************************************************/

#include "config.h"

// establish dependencies on the config tests and define config
// macros used in the header below (the are not autodetected
// in headers)
#ifdef _RWSTD_NO_INLINE_MEMBER_TEMPLATE
#  define NO_INLINE_MEMBER_TEMPLATE
#endif   // _RWSTD_NO_INLINE_MEMBER_TEMPLATE

#ifndef _RWSTD_NO_MEMBER_TEMPLATE
#  define NO_MEMBER_TEMPLATE
#endif   // _RWSTD_NO_MEMBER_TEMPLATE

// explicitly instantiate the template defined in the header
#define INSTANTIATE
#include "extern_template_imp.h"
