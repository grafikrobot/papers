/*
Copyright Rene Rivera 2019
Use, modification and distribution are subject to the
Boost Software License, Version 1.0. (See accompanying file
LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
*/
#include "sample.hpp"

namespace before
{
// tag::compare_before[]
class A
{
    public:

    // Feature A allows for using A.
    // This feature is optional and
    // is used when feature_a_enabled
    // == true. The feature_a_value
    // is a value in the range
    // [0,15000].

    // Feature B allows for using B.
    // This feature is optional and
    // is used when feature_b_enabled
    // == true. The feature_b_value
    // is a value in the range
    // [0,60000].

    unsigned int feature_b_value:16;
    unsigned int feature_a_value:14;
    bool feature_a_enabled:1;
    bool feature_b_enabled:1;
};
// end::compare_before[]
unsigned int A_q(A const & a)
{
    return a.feature_a_value + a.feature_b_value;
}
}

namespace after
{
/*
// tag::compare_after[]
class A
{
    public:

    // Feature A allows for using A.
    // This feature is optional and
    // is used when feature_a_enabled
    // == true. The feature_a_value
    // is a value in the range
    // [0,15000].

    bool feature_a_enabled:1;
    unsigned int feature_a_value:14;

    // Feature B allows for using B.
    // This feature is optional and
    // is used when feature_b_enabled
    // == true. The feature_b_value
    // is a value in the range
    // [0,60000].

    bool feature_b_enabled:1;
    unsigned int feature_b_value:16;

    layout:

    // This layout gives us a 4 byte
    // structure size with minimal
    // additional access instructions.
    // When compiling with x86-64
    // gcc 9.2 with -O3.

    feature_b_value;
    feature_a_value;
    feature_a_enabled;
    feature_b_enabled;
};
// end::compare_after[]
*/
class A
{
    public:

    unsigned int feature_b_value:16;
    unsigned int feature_a_value:14;
    bool feature_a_enabled:1;
    bool feature_b_enabled:1;
};
unsigned int A_q(A const & a)
{
    return a.feature_a_value + a.feature_b_value;
}
}

int main()
{
    std::cout << "BEFORE: sizeof(A) = " << sizeof(before::A) << "\n";
    std::cout << "  1M[]: sizeof(A[1024*1024]) = " << sizeof(before::A[1024*1024]) << "\n";
    std::cout << " AFTER: sizeof(A) = " << sizeof(after::A) << "\n";
    std::cout << "  1M[]: sizeof(A[1024*1024]) = " << sizeof(after::A[1024*1024]) << "\n";
}
