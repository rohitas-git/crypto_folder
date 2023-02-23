# Write the .circom file 
# These programs are often referred to as circuits, which express constraints among your set of variables, or signals.


# Program.circom -> Circom [] -> R1CS, WASM, SYM, ..etc as per flags
    circom multiplier_sq.circom --r1cs --wasm --sym -o ./build
#



# Take user public and private input
# "Execute" the circuit using binary from compilation
# -> Calculates the values of intermediate and output variables
# Note: This assignment of every signal to its concrete value is called a witness or trace.
# Note. For big circuits, the C++ witness calculator is significantly faster than the WASM calculator.
# Note: Witness - (Inputs, Intermediate Signals, Output)



# Public Input, Private Input -> Binary [] -> Witness
# Witness:
    cd build && node ./multiplier_sq_js/generate_witness.js  ./multiplier_sq_js/multiplier_sq.wasm  ../input.json  ./witness.wtns
#


# R1CS -> Ceremony[] -> Keys for Proving and Verification 
# Ceremony

    # Start a new "power of tau" Ceremony
    snarkjs powersoftau new bn128 12 pot12_0000.ptau -v

    # Contribute to the ceremony
    snarkjs powersoftau contribute pot12_0000.ptau pot12_0001.ptau --name="First contribution" -v
#
# Phase 2

    # Start the generation of this circuit's phase
    snarkjs powersoftau prepare phase2 pot12_0001.ptau pot12_final.ptau -v

    # Generate zkey containing - PK, VK, Phase2 Contributions
    snarkjs groth16 setup multiplier_sq.r1cs pot12_final.ptau multiplier_sq_0000.zkey

    # Contribute to phase 2 of the ceremony
    snarkjs zkey contribute multiplier_sq_0000.zkey multiplier_sq_0001.zkey --name="1st Contributor Name" -v

    # Export the Verification Key
    snarkjs zkey export verificationkey multiplier_sq_0001.zkey verification_key.json
#



# Generating a zk-Proof associated to the circuit and witness:
    # After Witness computed and Trusted Setup done
    snarkjs groth16 prove multiplier_sq_0001.zkey witness.wtns proof.json public.json
#



# Public Input, Proof, Verifying Key -> [] -> Ok / Err
# Verification:
    snarkjs groth16 verify verification_key.json public.json proof.json
#

##########################################

# the circuit is used twice by the prover: 
## first to generate the witness, 
## and then to derive the constraints that are covered by the proof.

# For ab <== a*b
# Execution Phase       ab <-- a*b
# Compiling Constraints  ab === a*b
# In other words, when writing a circuit you're writing two different programs, 
# that belong to two different programming paradigms, in a single one.
# While you will usually write assignments and constraints that are equivalent, 
# sometimes you need to split them up. A good example of this is the IsZero circuit.
