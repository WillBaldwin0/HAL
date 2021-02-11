module CALC

using PyCall
using ASE
using IPFitting: Dat
EAM = pyimport("ase.calculators.eam")["EAM"]
CASTEP = pyimport("ase.calculators.castep")["Castep"]

function EAM_calculator(at)
    py_at = ASEAtoms(at).po

    calculator = EAM(potential=@__DIR__() * "/Ti1.eam.fs")
    py_at[:set_calculator](calculator)

    E = py_at.get_potential_energy()
    F = py_at.get_forces()
    #V = -1.0 * py_at.get_stress() * py_at.get_volume()

    dat = Dat( at,"HMD", E = E, F = F)#, V = V)

    return dat
end

function CASTEP_calculator(at)
    py_at = ASEAtoms(at)

    calculator = CASTEP()
    calculator[:_directory] = "./CASTEP"
    calculator.param[:cut_off_energy] = 500
    calculator.param[:calculate_stress] = true
    calculator.param[:smearing_width] = 0.1
    calculator.param[:finite_basis_corr] = "automatic"
    calculator.cell[:mixing_scheme] = "Pulay"
    calculator.param[:write_checkpoint] = "none"
    calculator.param[:kpoints_mp_spacing] = 0.1
    py_at[:set_calculator](calculator)

    E = py_at.po.get_potential_energy()
    F = py_at.po.get_forces()
    V = -1.0 * py_at.po.get_stress() * py_at.po.get_volume()

    write_xyz("./temp.xyz", py_at)

    dat = Dat( at,"HMD", E = E, F = F, V = V)

    return dat
end

end