# random-connection
The following code generates closed-form cumulant expressions via symbolic calculations in SageMath for any dimension d ≥ 1, any connected subgraph G and any set of endpoints E. The choice of SageMath for this implementation is due to its fast handling of symbolic integration via Maxima, which is significantly faster than the Python package Sympy. This code is also sped up by parallel processing that distributes the load among multiple CPU cores. This code also covers the case where G has no endpoints (m = 0) by taking E := [ ] empty. However, in this case µ should be a finite measure, i.e. the density function mu(x, λ, β) should be integrable with respect to the Lebesgue measure.
cumulants_parallel.sage

The following code generates closed-form joint cumulant expressions via symbolic calculations in SageMath for any dimension d ≥ 1, any sequence (G1,...,Gn) of connected subgraphs, and any sequence (e1,...,em) of endpoints.
