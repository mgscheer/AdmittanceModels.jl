module CircuitExample
    using AdmittanceModels
    Q0_SIGNAL = "q0_signal"
    Q0_GROUND = "q0_ground"
    Q1_SIGNAL = "q1_signal"
    Q1_GROUND = "q1_ground"
    GROUND = AdmittanceModels.ground
    circuit = Circuit([Q0_SIGNAL, Q0_GROUND, Q1_SIGNAL, Q1_GROUND, GROUND])
    set_capacitance!(circuit, Q0_SIGNAL, Q0_GROUND, 100.0)
    set_capacitance!(circuit, Q1_SIGNAL, Q1_GROUND, 100.0)
    set_capacitance!(circuit, Q0_SIGNAL, Q1_SIGNAL, 10.0)
    set_capacitance!(circuit, Q0_GROUND, Q1_GROUND, 10.0)
    set_capacitance!(circuit, Q0_GROUND, GROUND, 1.0)
    set_capacitance!(circuit, Q1_GROUND, GROUND, 1.0)
    set_inv_inductance!(circuit, Q0_SIGNAL, Q0_GROUND, .1)
    set_inv_inductance!(circuit, Q1_SIGNAL, Q1_GROUND, .1)

    root = GROUND
    edges = [(Q0_SIGNAL, Q0_GROUND),
             (Q0_GROUND, GROUND),
             (Q1_SIGNAL, Q1_GROUND),
             (Q1_GROUND, GROUND)]
    tree = SpanningTree(root, edges)
end

module CircuitCascadeExample
    using LinearAlgebra: I
    using AdmittanceModels
    circuit0 = Circuit([0,1,2,3])
    set_capacitance!(circuit0, 0, 1, 1.0)
    set_capacitance!(circuit0, 0, 2, 2.0)
    set_capacitance!(circuit0, 0, 3, 1.0)
    set_capacitance!(circuit0, 1, 2, 10.0)
    set_capacitance!(circuit0, 1, 3, 20.0)
    set_capacitance!(circuit0, 2, 3, 30.0)
    c = circuit0.c
    i = ones(size(c)...) - I
    k = 2*c + i
    g = 3*c + 2 * i
    circuit0 = Circuit(k, g, c, circuit0.vertices)
    circuit1 = Circuit(2*k+3*i, 3*g+5*i, 8*c+2*i, [4,5,6,7])
    circuit2 = Circuit(12*k+4*i, 11*g+2*i, 9*c+i, [8,9,10,11])
end

module PSOModelExample
    using AdmittanceModels
    using SparseArrays: sparse, spzeros
    K = sparse(hcat([[0.1, 0., 0., 0.],
              [0., 0., 0., 0.],
              [0., 0., 0.1, 0.],
              [0., 0., 0., 0.]]...))
    G = spzeros(size(K)...)
    C = sparse(hcat([[110., 10., -10., -10.],
              [10., 21., -10., -20.],
              [-10., -10., 110., 10.],
              [-10., -20., 10., 21.]]...))
    PORT_0 = "port_0"
    PORT_1 = "port_1"
    ports = [PORT_0, PORT_1]
    P = 1.0 * sparse([[1, 0, 0, 0] [0, 0, 1, 0]])
    pso = PSOModel(K, G, C, P, P, ports)
end

module LRCExample
    using AdmittanceModels
    circuit = Circuit([0, 1])
    l, r, c = 1.0, 100.0, 3.0
    ω = sqrt(1/(l * c) - 1/(2 * r * c)^2)
    κ = 1/(r * c)
    set_inv_inductance!(circuit, 0, 1, 1/l)
    set_conductance!(circuit, 0, 1, 1/r)
    set_capacitance!(circuit, 0, 1, c)
    pso = PSOModel(circuit, [(0, 1)], ["port"])
end
