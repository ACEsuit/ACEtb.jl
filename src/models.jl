
module Models

using Parameters
using ACEtb.SlaterKoster: TwoCentreModel, SKH
using JuLIP.Potentials: fcut

import ACEtb.SlaterKoster: eval_bonds!, eval_diag!, getskh
import JuLIP: cutoff

export KwonTB


"""
`KwonTB <: SKModel`

Hamiltonian for an orthogonal sp TB model of Si developed by Kwon et al [1].

This implementation deviates  from [1] in how the cut-off is applied:
instead of "patching" a cubic spline between r1 and rcut, we simply multiply
with a quintic spline on the interval [0.5 (rcut + r0), rcut].

[1] I. Kwon, R. Biswas, C. Z. Wang, K. M. Ho and C. M. Soukoulis.
Transferable tight-binding models for silicon.
Phys Rev B 49 (11), 1994.
"""
@with_kw struct KwonTB <: TwoCentreModel
   skh::SKH = SKH("sp")
   # -------------------------------
   r0::Float64 = 2.360352   # Å
   Es::Float64 = -5.25      # eV
   Ep::Float64 = 1.2        # eV
   E0::Float64 = 8.7393204  # eV   8.7393204  is the original value; but it is just a constant shift
   # ------------------------------- Electronic Parameters
   # α   1     2    3     4
   #    ssσ   spσ  ppσ   ppπ
   hr0::NTuple{4, Float64} = (-2.038, 1.745, 2.75, -1.075)
   nc::NTuple{4, Float64} = (9.5, 8.5, 7.5, 7.5)
   rc::NTuple{4, Float64} = (3.4, 3.55, 3.7, 3.7)
   # ------------------------------- 2-body parameters
   m::Float64 = 6.8755
   mc::Float64 = 13.017
   dc::Float64 = 3.66995     # Å
   C::NTuple{4, Float64} = (2.1604385, -0.1384393, 5.8398423e-3, -8.0263577e-5)
   # --------------------------------
   r1::Float64 = 3.260176     # Å  (start of cut-off) >>> different r1 from Kwon paper
   rcut::Float64 = 4.16       # Å  (end of cut-off)
end

cutoff(model::KwonTB) = model.rcut

getskh(model::KwonTB) = model.skh

# isorthogonal(H::KwonTB) = true

kwon_bond(m::KwonTB, r::Real, α) = (
          m.hr0[α] * (m.r0 / r)^2 *
               exp( - 2 * (r/m.rc[α])^m.nc[α] + 2 * (m.r0/m.rc[α])^m.nc[α] ) )

function eval_bonds!(V, model::KwonTB, r)
   fc = fcut(r, model.r1, model.rcut)
   for α = 1:4
      V[α] = kwon_bond(model, r, α) * fc
   end
   return V
end


function eval_diag!(D, model::KwonTB, r, R)
   D[1] = model.Es
   D[2:4] .= model.Ep
   return D
end

end
