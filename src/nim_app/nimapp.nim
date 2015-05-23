proc fib(a: cint): cint {.exportc.} =
  echo("What's your name? ")
  var name: string = readLine(stdin)
  echo("Hi, ", name, "!")


