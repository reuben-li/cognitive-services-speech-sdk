//
// Copyright (c) Microsoft. All rights reserved.
// Licensed under the MIT license. See LICENSE.md file in the project root for full license information.
//
// create_module_object.cpp: Implementation definitions for *CreateModuleObject* methods
//

#include "stdafx.h"

#include "default_recognizer_factory.h"
#include "factory_helpers.h"


namespace CARBON_IMPL_NAMESPACE() {


SPX_EXTERN_C void* AudioLib_CreateModuleObject(const char* className, const char* interfaceName);
SPX_EXTERN_C void* SRLib_CreateModuleObject(const char* className, const char* interfaceName);


SPX_EXTERN_C void* PrimaryCarbon_CreateModuleObject(const char* className, const char* interfaceName)
{
    SPX_FACTORY_MAP_BEGIN();
    SPX_FACTORY_MAP_ENTRY_FUNC(AudioLib_CreateModuleObject);
    SPX_FACTORY_MAP_ENTRY_FUNC(SRLib_CreateModuleObject);
    SPX_FACTORY_MAP_ENTRY(CSpxDefaultRecognizerFactory, ISpxRecognizerFactory);
    SPX_FACTORY_MAP_END();
}

SPX_EXTERN_C SPXDLL_EXPORT void* CreateModuleObject(const char* className, const char* interfaceName)
{
    return PrimaryCarbon_CreateModuleObject(className, interfaceName);
}


} // CARBON_IMPL_NAMESPACE
