/*
Copyright Rene Rivera 2019
Use, modification and distribution are subject to the
Boost Software License, Version 1.0. (See accompanying file
LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt)
*/
#include "sample.hpp"

// tag::sample_class[]
class A
{
    public:

    // Feature A allows for using A.
    // This feature is optional and
    // is used when feature_a_enabled
    // == true. The feature_a_value
    // is a value in the range
    // [0,15000].

    bool feature_a_enabled;
    unsigned int feature_a_value;

    // Feature B allows for using B.
    // This feature is optional and
    // is used when feature_b_enabled
    // == true. The feature_b_value
    // is a value in the range
    // [0,60000].

    bool feature_b_enabled;
    unsigned int feature_b_value;
};
// end::sample_class[]

// tag::sample_function[]
unsigned int A_q(A const & a)
{
    return a.feature_a_value + a.feature_b_value;
}
// end::sample_function[]

int main()
{
    std::cout << "BASE: sizeof(A) = " << sizeof(A) << "\n";
    std::cout << "1M[]: sizeof(A[1024*1024]) = " << sizeof(A[1024*1024]) << "\n";
}
