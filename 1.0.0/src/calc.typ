#let round-float(value) = {
  calc.round(value, digits: 10)
}

#let E(exponent) = {
  calc.pow(10, float(exponent))
}

#let sq(base) = {
  calc.pow(base, 2)
}

#let sinc(value) = {
  if value == 0 {
    1
  } else {
  calc.sin(value) / value
  }
}

#let average(values) = {
  if values.len() == 0 {
    0
  } else {
    values.sum(default: 0) / values.len()
  }
}

#let deviation(values, sample: false) = {
  let average = average(values)
  calc.sqrt(values.map(v => sq(v - average)).sum() / if sample {
    values.len() - 1
  } else {
    values.len()
  })
}

#let regression(points) = {
  let x-sum = points.map(p => p.at(0)).sum()
  let y-sum = points.map(p => p.at(1)).sum()
  let xy-sum = points.map(p => p.at(0) * p.at(1)).sum()
  let x2-sum = points.map(p => sq(p.at(0))).sum()
  let y2-sum = points.map(p => sq(p.at(1))).sum()
  let n = points.len()
  let k = (n * xy-sum - x-sum * y-sum) / (n * x2-sum - sq(x-sum))
  let m = (y-sum - k * x-sum) / n
  let r = (n * xy-sum - x-sum * y-sum) / calc.sqrt(
    (n * x2-sum - sq(x-sum)) * (n * y2-sum - sq(y-sum))
  )
  
  (
    k: k,
    m: m,
    r: r,
    r2: sq(r),
    func: x => k * x + m
  )
}

#let trinum(n) = calc.binom(n + 1, 2)

#let norm(v) = {
  calc.sqrt(v.map(v => v*v).sum())
}

#let transpose(mat) = {
  // Handle empty matrix case.
  if mat == none or mat == () { return () }
  // For each column index, create a row with elements from that column.
  return range(mat.first().len()).map(i => mat.map(row => row.at(i)))
}

#let det(mat) = {
  let size = mat.len()
  
  // Error handling for non-square matrices
  if mat.any(row => row.len() != size) {
    panic("Matrix must be square to calculate determinant")
  }
  
  // Base case: 1x1 matrix
  if size == 1 {
    return mat.first().first()
  }
  
  // Base case: 2x2 matrix
  if size == 2 {
    return mat.at(0).at(0) * mat.at(1).at(1) - mat.at(0).at(1) * mat.at(1).at(0)
  }
  
  // Recursive case: use cofactor expansion along the first row
  let determinant = 0
  
  for j in range(size) {
    // Create submatrix by removing first row and j-th column
    let submat = ()
    for i in range(1, size) {
      let row = ()
      for k in range(size) {
        if k != j {
          row = row + (mat.at(i).at(k),)
        }
      }
      submat = submat + (row,)
    }
    
    // Calculate cofactor
    let sign = if calc.rem(j, 2) == 0 { 1 } else { -1 }
    determinant = determinant + sign * mat.at(0).at(j) * det(submat)
  }
  
  return determinant
}

#let dotprod(m1, m2) = {
  // Check if both inputs are vectors
  if type(m1.first()) != array and type(m2.first()) != array and m1.len() == m2.len() {
    // Calculate dot product for vectors
    return range(m1.len()).map(i => m1.at(i) * m2.at(i)).sum()
  }
  
  // Validate dimensions for matrix multiplication
  if m1.first().len() != m2.len() {
    panic("Matrix dimensions don't match for multiplication")
  }
  
  // Transpose m2 once to make column access more efficient
  let m2t = transpose(m2)
  
  // Create result matrix directly with calculated values
  return m1.map(row => 
    m2t.map(col => {
      let sum = 0
      for i in range(row.len()) {
        sum += row.at(i) * col.at(i)
      }
      sum
    })
  )
}

#let inverse(mat) = {
  let size = mat.len()
  
  // Error handling for non-square matrices
  if mat.any(row => row.len() != size) {
    panic("Matrix must be square to calculate inverse")
  }
  
  // Calculate determinant
  let determinant = det(mat)
  
  // Check if matrix is invertible
  if calc.abs(determinant) < 1e-10 {
    panic("Matrix is not invertible (determinant is zero)")
  }
  
  // For 1x1 matrix, inverse is 1/element
  if size == 1 {
    return ((1 / mat.first().first()),)
  }
  
  // Calculate the cofactor matrix
  let cofactors = range(size).map(i => {
    range(size).map(j => {
      // Create submatrix by removing i-th row and j-th column
      let submat = range(size).filter(r => r != i).map(r => {
        range(size).filter(c => c != j).map(c => mat.at(r).at(c))
      })
      
      // Calculate cofactor with appropriate sign
      let sign = if calc.rem(i + j, 2) == 0 { 1 } else { -1 }
      sign * det(submat)
    })
  })
  
  // Transpose the cofactor matrix to get the adjugate
  let adjugate = transpose(cofactors)
  
  // Divide each element by the determinant
  return adjugate.map(row => row.map(elem => elem / determinant))
}

#let assert-even(a, b, address: "") = {
  let at = type(a)
  let bt = type(b)
  if at != array or bt != array {
    if at == array or bt == array {
      panic(address + ": type of left op is " + at + "while right op is " +
        bt)
    }
  // Both are arrays.
  } else if (a.len() != b.len()) {
    panic(address + ": Arrays are not of equal length.")
  } else {
    if address != "" {
      address += "."
    }
    for i in range(a.len()) {
      assert-even(a.at(i), b.at(i), address: address + str(i))
    }
  }
}

#let cross(v1, v2) = {
  if v1.len() != 3 or v2.len() != 3 {
    panic("Cross product requires 3-dimensional vectors.")
  }
  (
    v1.at(1) * v2.at(2) - v1.at(2) * v2.at(1),
    v1.at(2) * v2.at(0) - v1.at(0) * v2.at(2),
    v1.at(0) * v2.at(1) - v1.at(1) * v2.at(0)
  )
}

#let _matrix_op(m1, m2, op) = {
  if type(m1) == array {
    range(m1.len()).map(i => _matrix_op(m1.at(i), m2.at(i), op))
  }
  else {
    op(m1, m2)
  }
}

#let sub(m1, m2) = {
  _matrix_op(m1, m2, (a, b) => a - b)
}

#let add(m1, m2) = {
  _matrix_op(m1, m2, (a, b) => a + b)
}

#let _matrix_scalar(m, s, op) = {
  if type(m) == array {
    range(m.len()).map(i => _matrix_scalar(m.at(i), s, op))
  }
  else {
    op(m, s)
  }
}

#let prod(v, scalar) = {
  _matrix_scalar(v, scalar, (a, b) => a * b)
}

#let div(v, scalar) = {
  _matrix_scalar(v, scalar, (a, b) => a / b)
}

#let unit(v) = div(v, norm(v))

#let proj(v1, v2) = {
  let hat = unit(v2)
  prod(hat, dotprod(v1, hat))
}

#let I = ((1, 0, 0), (0, 1, 0), (0, 0, 1))
