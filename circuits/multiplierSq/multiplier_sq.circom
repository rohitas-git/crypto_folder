pragma circom 2.0.0;

template MultiplierSq() {
  
  // Declaration of signals.  
  signal input a;
  signal input b;
  signal ab;
  signal output c;

  // Constraints.  
  ab <== a * b;
  c <== ab * ab;
}

 component main = MultiplierSq();