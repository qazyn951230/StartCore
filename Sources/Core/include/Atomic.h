// MIT License
//
// Copyright (c) 2017-present qazyn951230 qazyn951230@gmail.com
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#ifndef START_POINT_ATOMIC_H
#define START_POINT_ATOMIC_H

#include <stdlib.h>
#include <stdbool.h>
#include <stdatomic.h>
#include "Config.h"

SP_C_FILE_BEGIN

typedef SP_ENUM(int, SPMemoryOrder) {
    SPMemoryOrderRelaxed = memory_order_relaxed,
    SPMemoryOrderConsume = memory_order_consume,
    SPMemoryOrderAcquire = memory_order_acquire,
    SPMemoryOrderRelease = memory_order_relaxed,
    SPMemoryOrderAcquireAndRelease = memory_order_acq_rel,
    SPMemoryOrderSequentiallyConsistent = memory_order_seq_cst,
};

#define SP_ATOMIC_TYPE_CREATE(swift_type, swift_name, raw_type, atomic_type)                                    \
typedef struct sp_atomic_##swift_name* SPA##swift_type##Ref;                                                    \
static inline SPA##swift_type##Ref spa_##swift_name##_create(raw_type value) {                                  \
    atomic_##atomic_type* result = (atomic_##atomic_type*)malloc(sizeof(atomic_##atomic_type));                 \
    atomic_init(result, value);                                                                                 \
    return SP_POINTER_CAST(SPA##swift_type##Ref, result);                                                       \
}                                                                                                               \
static inline void spa_##swift_name##_free(SPA##swift_type##Ref swift_type) {                                   \
    free(SP_POINTER_CAST(atomic_##atomic_type*, swift_type));                                                   \
}                                                                                                               \

#define SP_ATOMIC_TYPE_STORE(swift_type, swift_name, raw_type, atomic_type)                                     \
static inline void spa_##swift_name##_store(SPA##swift_type##Ref swift_type, raw_type value) {                  \
    return atomic_store(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value);                             \
}                                                                                                               \
static inline void spa_##swift_name##_store_explicit(SPA##swift_type##Ref swift_type, raw_type value,           \
                                                     SPMemoryOrder order) {                                     \
    return atomic_store_explicit(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value, order);             \
}                                                                                                               \

#define SP_ATOMIC_TYPE_LOAD(swift_type, swift_name, raw_type, atomic_type)                                      \
static inline raw_type spa_##swift_name##_load(SPA##swift_type##Ref swift_type) {                               \
    return atomic_load(SP_POINTER_CAST(atomic_##atomic_type*, swift_type));                                     \
}                                                                                                               \
static inline raw_type spa_##swift_name##_load_explicit(SPA##swift_type##Ref swift_type,                        \
                                                     SPMemoryOrder order) {                                     \
    return atomic_load_explicit(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), order);                     \
}                                                                                                               \

#define SP_ATOMIC_TYPE_EXCHANGE(swift_type, swift_name, raw_type, atomic_type)                                  \
static inline raw_type spa_##swift_name##_exchange(SPA##swift_type##Ref swift_type, raw_type value) {           \
    return atomic_exchange(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value);                          \
}                                                                                                               \
static inline raw_type spa_##swift_name##_exchange_explicit(SPA##swift_type##Ref swift_type, raw_type value,    \
                                                     SPMemoryOrder order) {                                     \
    return atomic_exchange_explicit(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value, order);          \
}                                                                                                               \

#define SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, action)                             \
static inline void spa_##swift_name##_##action(SPA##swift_type##Ref swift_type, raw_type value) {               \
    atomic_fetch_##action(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value);                           \
}                                                                                                               \
static inline void spa_##swift_name##_##action##_explicit(SPA##swift_type##Ref swift_type, raw_type value,      \
                                                     SPMemoryOrder order) {                                     \
    atomic_fetch_##action##_explicit(SP_POINTER_CAST(atomic_##atomic_type*, swift_type), value, order);         \
}                                                                                                               \

#define sp_atomic_type_operation(swift_type, swift_name, raw_type, atomic_type)                                 \
SP_ATOMIC_TYPE_STORE(swift_type, swift_name, raw_type, atomic_type)                                             \
SP_ATOMIC_TYPE_LOAD(swift_type, swift_name, raw_type, atomic_type)                                              \
SP_ATOMIC_TYPE_EXCHANGE(swift_type, swift_name, raw_type, atomic_type)                                          \
SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, add)                                        \
SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, sub)                                        \
SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, or)                                         \
SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, xor)                                        \
SP_ATOMIC_TYPE_FETCH(swift_type, swift_name, raw_type, atomic_type, and)                                        \

#define SP_MAKE_ATOMIC_TYPE(swift_type, swift_name, raw_type, atomic_type)                                         \
SP_ATOMIC_TYPE_CREATE(swift_type, swift_name, raw_type, atomic_type)                                            \
sp_atomic_type_operation(swift_type, swift_name, raw_type, atomic_type)                                         \


// C11 => #define bool _Bool,
// after expanded from macro `atomic_bool` => `atomic__Bool`
SP_ATOMIC_TYPE_CREATE(Bool, bool, bool, bool)
SP_ATOMIC_TYPE_STORE(Bool, bool, bool, bool)
SP_ATOMIC_TYPE_LOAD(Bool, bool, bool, bool)
SP_ATOMIC_TYPE_EXCHANGE(Bool, bool, bool, bool)
SP_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, add)
SP_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, sub)
SP_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, or)
SP_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, xor)
SP_ATOMIC_TYPE_FETCH(Bool, bool, bool, bool, and)

SP_MAKE_ATOMIC_TYPE(Int8, int8, signed char, schar)
SP_MAKE_ATOMIC_TYPE(UInt8, uint8, unsigned char, uchar)
SP_MAKE_ATOMIC_TYPE(Int16, Int16, short, short)
SP_MAKE_ATOMIC_TYPE(UInt16, UInt16, unsigned short, ushort)
SP_MAKE_ATOMIC_TYPE(Int32, int32, int, int)
SP_MAKE_ATOMIC_TYPE(UInt32, uint32, unsigned int, uint)
#if defined(__LP64__) && __LP64__
SP_MAKE_ATOMIC_TYPE(Int, int, long, long)
SP_MAKE_ATOMIC_TYPE(UInt, uint, unsigned long, ulong)
#else
SP_MAKE_ATOMIC_TYPE(Int, int, int, int)
SP_MAKE_ATOMIC_TYPE(UInt, uint, unsigned int, uint)
#endif
SP_MAKE_ATOMIC_TYPE(Int64, int64, long long, llong)
SP_MAKE_ATOMIC_TYPE(UInt64, uint64, unsigned long long, ullong)

#undef SP_ATOMIC_TYPE_CREATE
#undef SP_ATOMIC_TYPE_STORE
#undef SP_ATOMIC_TYPE_LOAD
#undef SP_ATOMIC_TYPE_EXCHANGE
#undef SP_ATOMIC_TYPE_FETCH
#undef SP_ATOMIC_TYPE_FETCH
#undef SP_ATOMIC_TYPE_FETCH
#undef SP_ATOMIC_TYPE_FETCH
#undef SP_ATOMIC_TYPE_FETCH
#undef SP_MAKE_ATOMIC_TYPE

SP_C_FILE_END

#endif //START_POINT_ATOMIC_H
