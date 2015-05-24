template macro_round*(x: expr): expr = 
  (if (x) >= 0: (long)((x) + 0.5) else: (long)((x) - 0.5))


