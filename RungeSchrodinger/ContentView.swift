import SwiftUI
struct SchrodingerSolver {
    let potential: [Double]
    let dx: Double
    let hbar: Double
    
    func solve() -> (eigenvalue: Double, wavefunction: [Double]) {
        let n = potential.count
        var psi = Array(repeating: 0.0, count: n)
        var x = Array(stride(from: 0, to: Double(n)*dx, by: dx))
        var eigenvalue = 0.0
        
        // Initial conditions
        psi[0] = 0.0
        psi[1] = 1.0e-16
        
        // Finite difference method
        let alpha = hbar / 2 / dx / dx
        let beta = 2 * alpha - potential[0] / hbar
        let gamma = -alpha
        let temp = beta[i-1] - alpha * psi[i-2]
        let r = gamma / temp

        for i in 2..<n {
            let r = gamma / (beta[i-1] - alpha * psi[i-2])
            psi[i] = r * (alpha * psi[i-1] + psi[i-2] * (2 - beta[i-1] * dx*dx / hbar))
        }
        
        // Normalize wavefunction
        let normalizationFactor = sqrt(dx * psi.map { $0 * $0 }.reduce(0, +))
        psi = psi.map { $0 / normalizationFactor }
        
        // Calculate eigenvalue
        eigenvalue = (beta[n-1] - alpha * psi[n-2]) / (dx * dx / hbar)
        
        return (eigenvalue, psi)
    }
}

struct ContentView: View {
    @State private var eigenvalue: Double = 0.0
    @State private var wavefunction: [Double] = []
    let potential: [Double] = [0, 0, 0, 10, 10, 10, 0, 0, 0] // Default potential
    @State private var potentialString: String = ""

    var body: some View {
        VStack {
            Text("1D Schrödinger Equation Solver")
                .font(.largeTitle)
                .padding()
            
            HStack {
                Text("Potential:")
                    .padding()
                
                TextField("Enter potential...", text: $potentialString)
                    .padding()
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            NavigationView {
                // ...
            }
            .onAppear {
                potentialString = potential.map { String($0) }.joined(separator: ",")
            }
            Button(
                action: {
                    let potentialArray = potentialString.components(separatedBy: ",").compactMap { Double($0.trimmingCharacters(in: .whitespacesAndNewlines)) }
                    if potentialArray.count == potential.count {
                        let solver = SchrodingerSolver(potential: potentialArray, dx: 0.01, hbar: 1.0)
                        let (eigenvalue, wavefunction) = solver.solve()
                        self.eigenvalue = eigenvalue
                        self.wavefunction = wavefunction
                    }
                    else {
                        // Invalid potential, reset to example potential
                        let solver = SchrodingerSolver(potential: [0, 0, 0, 10, 10, 10, 0, 0, 0], dx: 0.01, hbar: 1.0)
                        let (eigenvalue, wavefunction) = solver.solve()
                        self.eigenvalue = eigenvalue
                        self.wavefunction = wavefunction
                    }
                },
                label: {
                    Text("Solve")
                        .padding()
                }
                )
            
            
            HStack {
                Text("Eigenvalue: \(eigenvalue, specifier: "%.4f")")
                    .padding()
                Spacer()
            },
            
            PlotView(x: Array(stride(from: 0, to: Double(wavefunction.count)*0.01, by: 0.01)), y: wavefunction)
            
        }
        .padding()
    }
}

      

    
    
   
      
            
     
struct PlotView: View {
let x: [Double]
let y: [Double]

    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let xRange = x.max()! - x.min()!
                let yRange = y.max()! - y.min()!
                let xOffset = geometry.size.width * CGFloat(x.min()! / xRange)
                let yOffset = geometry.size.height * CGFloat(y.min()! / yRange)
                let xScale = geometry.size.width / CGFloat(xRange)
                let yScale = geometry.size.height / CGFloat(yRange)
                let initialX = CGFloat(x[0]) * xScale + xOffset
                let initialY = geometry.size.height - (CGFloat(y[0]) * yScale + yOffset)
                path.move(to: CGPoint(x: initialX, y: initialY))
                
                for i in 1..<x.count {
                    let x = CGFloat(x[i]) * xScale + xOffset
                    let y = geometry.size.height - (CGFloat(y[i]) * yScale + yOffset)
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            .stroke(style: StrokeStyle(lineWidth: 2.0, lineJoin: .round))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
static var previews: some View {
ContentView()
}
}
