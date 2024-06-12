/// # Sample
/// Getting started
///
/// # Description
/// This is a minimal Q# program that can be used to start writing Q# code.
namespace MyQuantumProgram {

    open Microsoft.Quantum.Measurement;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Diagnostics;
    open Microsoft.Quantum.Convert;

    @EntryPoint()
    operation Main() : Result[] {
        use qs = Qubit[8];
        // X(qs[2]);
        // X(qs[1]);
        DumpMachine();

        use aux = Qubit();
        X(aux);

        PhaseEstimation (qs, U, aux);
        DumpMachine();

        let result = MeasureEachZ(qs);
        // Message($"Result: {result}");

        ResetAll(qs);
        Reset(aux);

        return result;
    }

    operation PhaseEstimation (qs : Qubit[], U : ((Qubit, Int) => Unit is Ctl), eigenstate : Qubit) : Unit {
        let n = Length(qs);
        for i in 0 .. n-1 {
            H(qs[i]);
        }
        
        for i in 0 .. n-1 {
            let exponent = (1 <<< i);
            Controlled U ([qs[n-1-i]], (eigenstate, exponent));
        }

        // DumpMachine();

        Adjoint QuantumFourierTransform(qs);
    }

    operation QuantumFourierTransform (qs : Qubit[]) : Unit is Ctl + Adj {
        // Big-Endian to Big-Endian
        // Big-Endian means that the leftmost qubit (index 0) is the most significant one.
        let n = Length(qs);
        for i in 0 .. n-1 {
            // Message($"i: {i}");
            H(qs[i]);
            for j in i+1 .. n-1 {
                // Message($"i: {i}, j: {j}");
                let theta = 2.*PI() / IntAsDouble(1 <<< (j-i+1));
                // Message($"theta: {theta}");
                Controlled R1([qs[j]], (theta, qs[i]));
            }
        }
        // Before the SWAP, the result is in Little-Endian.
        for i in 0 .. n/2 - 1 {
            SWAP(qs[i], qs[n - 1 - i]);
        }
        // Now the result is in Big-Endian.
    }

    operation U (q : Qubit, exponent : Int) : Unit is Ctl + Adj {
        // R1^{exponent}(theta) = R1(exponent*theta) 
        let theta = 2.*PI()/3.;
        R1 (IntAsDouble(exponent)*theta, q);
    }



}
