/*

**ANALIZO NOTE**

This file was copied from kdelibs project for testing analizo features.

The original file was modified and some code was deleted to keep only what is
needed to create automated tests on analizo side fixing the bug below.

- https://github.com/analizo/analizo/issues/173

GitHub kdelibs repository:

- https://github.com/KDE/kdelibs.git

Original file was copied from the commit 0f4cf41b22 from kdelibs git repository
and it is located inside kdelibs repository on the path below.

- experimental/libkdeclarative/bindings/backportglobal.h

Link to the original file on GitHub:

- https://github.com/KDE/kdelibs/blob/9941ebff54bd9d4349c0384dfa0cca2ace9549c4/experimental/libkdeclarative/bindings/backportglobal.h

*/

/****************************************************************************
**
** This file is part of the Qt Script Generator.
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
**
** Contact:  Nokia Corporation info@qt.nokia.com
**
** GNU Lesser General Public License Usage
** This file may be used under the terms of the GNU Lesser General Public
** License version 2.1 as published by the Free Software Foundation
** and appearing in the file LICENSE.LGPL included in the packaging of
** this file.  Please review the following information to ensure the GNU
** Lesser General Public License version 2.1 requirements will be met:
** http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** Copyright (C)  2011 Nokia. All rights reserved
****************************************************************************/
#ifndef QTSCRIPTEXTENSIONS_GLOBAL_H
#define QTSCRIPTEXTENSIONS_GLOBAL_H

#include <QtCore/QSharedData>

#define DECLARE_GET_METHOD(Class, __get__) \
BEGIN_DECLARE_METHOD(Class, __get__) { \
    return qScriptValueFromValue(eng, self->__get__()); \
} END_DECLARE_METHOD

#define DECLARE_SET_METHOD(Class, T, __set__) \
BEGIN_DECLARE_METHOD(Class, __set__) { \
    self->__set__(qscriptvalue_cast<T>(ctx->argument(0))); \
    return eng->undefinedValue(); \
} END_DECLARE_METHOD

#define DECLARE_GET_SET_METHODS(Class, T, __get__, __set__) \
DECLARE_GET_METHOD(Class, /*T,*/ __get__) \
DECLARE_SET_METHOD(Class, T, __set__)

namespace QScript
{

enum {
    UserOwnership = 1
};

} // namespace QScript

#endif // QTSCRIPTEXTENSIONS_GLOBAL_H
